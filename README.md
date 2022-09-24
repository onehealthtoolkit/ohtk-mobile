# OHTK Mobile

OHTK mobile application for community and official reporting.

### What you'll need

- [flutter](https://docs.flutter.dev/get-started/install)
- [android studio](https://developer.android.com/studio) or [xcode](https://docs.flutter.dev/get-started/install/macos#ios-setup)

If necessary, add the Android emulator to your path
```export PATH=$PATH:~/Library/Android/sdk/emulator/```

### Install

Get latest version of ohtk-mobile from github:

```git clone https://github.com/onehealthtoolkit/ohtk-mobile.git```

```cd ~/ohtk-mobile```

Run flutter build command

```flutter pub run build_runner build --delete-conflicting-outputs```

#### Change server to test server

Change settings to 

```opensur.test```

#### Config Android emulator to use localhost custom url endpoint

```bash
# List all available emulators
> emulator  --list-avds

# Start emulator in write mode
# [AVD_NAME] such as Pixel_4_XL_API_25
> emulator  -writable-system -netdelay none -netspeed full -avd [AVD_NAME]

# Wait until emulator is completely started
# Login as root
> adb root

# Remount emulator path /system to writable
> adb remount

# Upload hosts file to emulator
> adb push /path/to/hosts /system/etc/

# List active reverse ports
> adb reverse --list

# Reverse port from localhost server port 8000
> adb reverse tcp:80 tcp:8000

```

### Run Mobile App

Now you're ready to actually test the app. Open your IDE and run the flutter program:

- ex. Visual Studio Code: Run > Run without Debugging

Try logging in with one of the users created via the [OHTK Management System](https://github.com/onehealthtoolkit/ohtk-ms)

#### hosts file sample

```
127.0.0.1 localhost
127.0.0.1 opensur.test
127.0.0.1 laos.opensur.test
::1 ip6-localhost
```


