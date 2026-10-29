// dotinstall sets up this repo on the machine: builds tools, links config
// into $HOME and installs the pre-commit leak check.
//
//	dotinstall [-n]   install (-n = dry run, print what would happen)
//	dotinstall check  pre-commit hook: block staged files containing ~/.dotfiles.env values
package main

import (
	"bufio"
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"maps"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"time"
)

const envFile = ".dotfiles.env"

var (
	dryRun    bool
	root      string
	home      string
	backupDir string
)

func main() {
	home, _ = os.UserHomeDir()
	root = strings.TrimSpace(output("git", "rev-parse", "--show-toplevel"))
	if root == "" {
		fail("run inside the dotfiles repo")
	}

	args := os.Args[1:]
	if len(args) > 0 && args[0] == "check" {
		os.Exit(check())
	}
	dryRun = slices.Contains(args, "-n")
	backupDir = filepath.Join(home, ".dotfiles-backup", time.Now().Format("20060102-150405"))

	buildGo()
	makeExecutable()
	pythonVenv()
	linkConfig()
	cursorExtensions()
	checkEnv()
	installHook()
	fmt.Println("\nDone. Open a new terminal to load the shell config.")
}

// Go tools are built next to their source, where the aliases expect them.
func buildGo() {
	step("Building Go tools")
	dir := filepath.Join(root, "src/go")
	files, _ := filepath.Glob(filepath.Join(dir, "*.go"))
	for _, f := range files {
		name := strings.TrimSuffix(filepath.Base(f), ".go")
		run(dir, "go", "build", "-o", name, filepath.Base(f))
	}
	run(filepath.Join(dir, "dotinstall"), "go", "build", "-o", "dotinstall", ".")
}

func makeExecutable() {
	step("Making scripts executable")
	for _, pattern := range []string{"src/sh/*.sh", "src/js/*.js", "src/python/*.py", "install.sh"} {
		files, _ := filepath.Glob(filepath.Join(root, pattern))
		for _, f := range files {
			if info, err := os.Stat(f); err == nil && info.Mode()&0o111 == 0 && hasShebang(f) {
				say("chmod +x %s", rel(f))
				if !dryRun {
					os.Chmod(f, info.Mode()|0o755)
				}
			}
		}
	}
}

// Recreates the venv only when requirements.txt changes.
func pythonVenv() {
	step("Python venv")
	reqs := filepath.Join(root, "src/python/requirements.txt")
	data, err := os.ReadFile(reqs)
	if err != nil {
		return
	}
	sum := sha256.Sum256(data)
	hash := hex.EncodeToString(sum[:])
	venv := filepath.Join(root, ".venv")
	stamp := filepath.Join(venv, ".requirements.sha256")
	if current, _ := os.ReadFile(stamp); string(current) == hash {
		say("up to date")
		return
	}
	if _, err := os.Stat(venv); err != nil {
		run(root, "python3", "-m", "venv", ".venv")
	}
	run(root, filepath.Join(venv, "bin/pip"), "install", "-q", "-r", reqs)
	if !dryRun {
		os.WriteFile(stamp, []byte(hash), 0o644)
	}
}

func linkConfig() {
	step("Linking config")
	link(filepath.Join(root, "zshrc.sh"), filepath.Join(home, ".zshrc"))

	cursor := filepath.Join(home, "Library/Application Support/Cursor/User")
	vs := filepath.Join(root, "vs-settings")
	link(filepath.Join(vs, "settings.json"), filepath.Join(cursor, "settings.json"))
	link(filepath.Join(vs, "keybindings.json"), filepath.Join(cursor, "keybindings.json"))

	entries, _ := os.ReadDir(vs)
	for _, e := range entries {
		name := e.Name()
		isSnippet := strings.HasSuffix(name, ".code-snippets") ||
			(strings.HasSuffix(name, ".json") && name != "settings.json" && name != "keybindings.json")
		if isSnippet {
			link(filepath.Join(vs, name), filepath.Join(cursor, "snippets", name))
		}
	}
}

// Points dst at src, moving whatever was at dst into the backup folder first.
func link(src, dst string) {
	if _, err := os.Stat(src); err != nil {
		return
	}
	if target, err := os.Readlink(dst); err == nil && target == src {
		return
	}
	if _, err := os.Lstat(dst); err == nil {
		backup := filepath.Join(backupDir, strings.TrimPrefix(dst, home))
		say("backup %s -> %s", dst, backup)
		if !dryRun {
			os.MkdirAll(filepath.Dir(backup), 0o755)
			if err := os.Rename(dst, backup); err != nil {
				fail(err.Error())
			}
		}
	}
	say("link %s -> %s", dst, rel(src))
	if !dryRun {
		os.MkdirAll(filepath.Dir(dst), 0o755)
		if err := os.Symlink(src, dst); err != nil {
			fail(err.Error())
		}
	}
}

func cursorExtensions() {
	step("Cursor extensions")
	if _, err := exec.LookPath("cursor"); err != nil {
		say("cursor CLI not found, skipping")
		return
	}
	data, err := os.ReadFile(filepath.Join(root, "vs-settings/cursor-extensions.txt"))
	if err != nil {
		return
	}
	installed := strings.Fields(strings.ToLower(output("cursor", "--list-extensions")))
	missing := 0
	for _, ext := range strings.Fields(string(data)) {
		if !slices.Contains(installed, strings.ToLower(ext)) {
			run(root, "cursor", "--install-extension", ext)
			missing++
		}
	}
	if missing == 0 {
		say("up to date")
	}
}

func checkEnv() {
	step("Checking ~/" + envFile)
	expected := readEnv(filepath.Join(root, "dotfiles.env.example"))
	path := filepath.Join(home, envFile)
	actual := readEnv(path)
	if _, err := os.Stat(path); err != nil {
		say("missing, create it: cp %s %s", filepath.Join(root, "dotfiles.env.example"), path)
		return
	}
	for _, key := range slices.Sorted(maps.Keys(expected)) {
		if actual[key] == "" {
			say("not set: %s", key)
		}
	}
}

func installHook() {
	step("Pre-commit hook")
	hook := filepath.Join(strings.TrimSpace(output("git", "rev-parse", "--git-path", "hooks")), "pre-commit")
	if !filepath.IsAbs(hook) {
		hook = filepath.Join(root, hook)
	}
	content := `#!/bin/sh
dir="$(git rev-parse --show-toplevel)/src/go/dotinstall"
[ -x "$dir/dotinstall" ] || (cd "$dir" && go build -o dotinstall .) || exit 1
exec "$dir/dotinstall" check
`
	if current, err := os.ReadFile(hook); err == nil {
		if string(current) == content {
			say("up to date")
			return
		}
		if !strings.Contains(string(current), "dotinstall") {
			say("%s exists and is not ours, leaving it alone", hook)
			return
		}
	}
	say("write %s", hook)
	if !dryRun {
		os.MkdirAll(filepath.Dir(hook), 0o755)
		os.WriteFile(hook, []byte(content), 0o755)
	}
}

// Blocks the commit when a staged file contains any value from ~/.dotfiles.env.
// Short values are skipped to avoid false positives.
func check() int {
	env := readEnv(filepath.Join(home, envFile))
	if len(env) == 0 {
		fmt.Fprintln(os.Stderr, "dotinstall check: no ~/"+envFile+", nothing to check against")
		return 0
	}
	staged := strings.Split(output("git", "diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z"), "\x00")
	leaks := 0
	for _, file := range staged {
		if file == "" {
			continue
		}
		content := []byte(output("git", "show", ":"+file))
		for key, value := range env {
			if len(value) >= 6 && bytes.Contains(content, []byte(value)) {
				fmt.Fprintf(os.Stderr, "dotinstall check: %s contains the value of %s\n", file, key)
				leaks++
			}
		}
	}
	if leaks > 0 {
		fmt.Fprintln(os.Stderr, "Commit blocked. Use $VARS instead of the real values.")
		return 1
	}
	return 0
}

func readEnv(path string) map[string]string {
	env := map[string]string{}
	f, err := os.Open(path)
	if err != nil {
		return env
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, value, ok := strings.Cut(strings.TrimPrefix(line, "export "), "=")
		if ok {
			env[strings.TrimSpace(key)] = strings.Trim(strings.TrimSpace(value), `"'`)
		}
	}
	return env
}

func hasShebang(path string) bool {
	f, err := os.Open(path)
	if err != nil {
		return false
	}
	defer f.Close()
	head := make([]byte, 2)
	n, _ := f.Read(head)
	return n == 2 && string(head) == "#!"
}

func run(dir, name string, args ...string) {
	say("%s %s", name, strings.Join(args, " "))
	if dryRun {
		return
	}
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Run(); err != nil {
		fail(fmt.Sprintf("%s failed: %v", name, err))
	}
}

func output(name string, args ...string) string {
	out, _ := exec.Command(name, args...).Output()
	return string(out)
}

func rel(path string) string {
	if r, err := filepath.Rel(root, path); err == nil {
		return r
	}
	return path
}

func step(title string) { fmt.Printf("\n==> %s\n", title) }

func say(format string, args ...any) {
	prefix := "  "
	if dryRun {
		prefix = "  [dry run] "
	}
	fmt.Printf(prefix+format+"\n", args...)
}

func fail(msg string) {
	fmt.Fprintln(os.Stderr, "dotinstall:", msg)
	os.Exit(1)
}
