# Flutter application template

Flexible base flutter application project structure.

### How run

1. Clone this repository via `git clone`.
2. Decide which platforms your app will be running on.
3. Run `flutter create . --org com.yourdomain --platforms ios,android,... or nothing if you are writing an app for each platform` in your terminal.
4. Run `flutter pub get` to install all dependencies.
5. Run `flutter run` to run your app.
6. Here you go, start coding!

### Package renaming

To rename the package to your own name, use the provided script:

```bash
./rename_package.sh --new-name your_new_package_name
```

For more options, see [scripts/README.md](scripts/README.md)
