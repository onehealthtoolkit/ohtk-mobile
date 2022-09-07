# podd_mobile

Podd mobile application for reporting.

## command

```
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Config Android emulator to use localhost custom url endpoint

```bash
# List all available emulators
> emulator  --list-avds

# Start emulator in write mode
# [AVD_NAME] such as Pixel_4_XL_API_25
> emulator  -writable-system -netdelay none -netspeed full -avd [AVD_NAME]

# Wait until emulator is completely started
# Login as root (emulator must be created with GOOGLE_API to be able to login as root)
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

#### hosts file sample

```
127.0.0.1 localhost
127.0.0.1 opensur.test
127.0.0.1 laos.opensur.test
::1 ip6-localhost
```

#### Google map api key

##### iOS

create file 'Config.xcconfig' in ios/Flutter

```
GOOGLE_MAP_API_KEY=YOUR_API_KEY
```

##### Andriod

edit file android/local.properties

```
google.map.key=YOUR_API_KEY
```
