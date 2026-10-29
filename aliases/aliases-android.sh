alias android_enter="adb shell input keyevent 66"
alias android_tab="adb shell input keyevent 61"
alias android_text="adb shell input $1"
alias android_input="adb shell input $1"
alias android_back="adb shell input keyevent 4"
alias android_screenshot="adb exec-out screencap -p > android-screenshot.png"

alias android_devices="adb devices"
alias android_log="adb logcat"

alias android-enter="android_enter"
alias android-tab="android_tab"
alias android-text="android_text"
alias android-input="android_text"
alias android-screenshot="android_screenshot"
alias android-devices="android_devices"

get_file_from_android_device() {
    # adb pull storage/emulated/0/here/20260320_152859.jpg .
    adb pull storage/emulated/0/here/$1 $2
}

alias get_file_from_android="get_file_from_android_device"

# Capacitor (IOS_SIM_ID in ~/.dotfiles.env)
alias run_android="npx vite build && npx cap sync android && npx cap run android --target Medium_Phone_API_36.1"
alias run_ios='pnpm run build:mobile && pnpm run sync:ios:dev && pnpm run run:ios --target "$IOS_SIM_ID"'

alias run_android_device="npx vite build && npx cap sync android && npx cap run android"
alias run-android-device="run_android_device"

alias run-and='run_android'
alias run-android='run_android'
alias run-ios='run_ios'
