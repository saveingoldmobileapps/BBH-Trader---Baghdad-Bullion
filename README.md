# Save in Gold FZCO App

SaveInGold Mobile App:
[x] Working UI Development
[x] Adding Shufti Pro KYC
[x] Adding Biometric Authentication

### Riverpod State Management

```
dart run build_runner watch --delete-conflicting-outputs
```

```
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

## Generate Production or Staging APK

```
flutter build apk --dart-define=ENVIRONMENT=production
```

```
flutter build apk --dart-define=ENVIRONMENT=staging
```

### Generate Production or Staging Build.sh

```
chmod +x build.sh
```

```
./build.sh --production
```

```
./build.sh --staging
```

### Generate Production or Staging Build_ios.sh

```
chmod +x build_ios.sh
```

```
./build_ios.sh --production
```

```
./build_ios.sh --staging
```