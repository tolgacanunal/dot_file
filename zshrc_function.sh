bounds() {
  if [ -z "$1" ]; then
    echo "Usage: bounds <true|false>"
    return 1
  fi

  local prop_value="false"
  if [ "$1" = "true" ]; then
    prop_value="true"
  fi

  adb shell setprop debug.layout "$prop_value"
  adb shell service call activity 1599295570
}

deeplink() {
  if [ -z "$1" ]; then
    echo "Usage: deeplink <url>"
    return 1
  fi
  adb shell am start -a android.intent.action.VIEW -d "$1"
}

skiagl() {
   adb shell su -c "setprop debug.hwui.renderer skiagl; stop; start"
}

ss() {
  local name
  if [ $# -eq 0 ]; then
    name="$(date '+%d-%m-%Y-time-%H-%M-%S').png"
  else
    name="$1.png"
  fi

  local screenshot_dir="${ANDROID_SCREENSHOT_DIR:-$HOME/Documents/androidss}"
  mkdir -p "$screenshot_dir"

  local remote_path="/sdcard/$name"

  if adb shell screencap -p "$remote_path"; then
    if adb pull "$remote_path" "$screenshot_dir/"; then
      adb shell rm "$remote_path"
      echo "Screenshot saved to $screenshot_dir/$name"
    else
      echo "Failed to pull screenshot from device."
      adb shell rm "$remote_path" # Clean up remote file
      return 1
    fi
  else
    echo "Failed to take screenshot."
    return 1
  fi
}

rec() {
  if [ $# -eq 0 ]; then
    echo "Usage: rec <filename>"
    return 1
  fi

  local name="$1.mp4"
  echo "Video recording started with the name of $name. Press Ctrl+C to stop."
  echo "You can get the file with: get_file $name"
  adb shell screenrecord --bit-rate 7000000 "/sdcard/$name"
  get_file "$name"
}

get_file() {
  if [ $# -eq 0 ]; then
    echo "Usage: get_file <filename>"
    return 1
  fi

  local file_to_get="$1"
  local dest_dir="${ANDROID_SCREENSHOT_DIR:-$HOME/Documents/androidss}"
  mkdir -p "$dest_dir"
  local remote_path="/sdcard/$file_to_get"

  if adb pull "$remote_path" "$dest_dir/"; then
    adb shell rm "$remote_path"
    echo "File '$file_to_get' moved to '$dest_dir'"
  else
    echo "Failed to pull file from device."
    # Don't remove the file if pull fails, so user can retry
    return 1
  fi
}

charles() {
  if [ -z "$1" ]; then
    echo "Usage: charles <true|false>"
    return 1
  fi

  local proxy_value=":0"
  if [ "$1" = "true" ]; then
    local ip
    ip=$(ipconfig getifaddr en0)
    if [ -z "$ip" ]; then
      echo "Could not get IP address from en0"
      return 1
    fi
    proxy_value="$ip:8888"
  fi

  adb shell settings put global http_proxy "$proxy_value"
}
