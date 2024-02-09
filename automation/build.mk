.PHONY: build-android-apk build-web build-ios

build-android-apk: clean
	@echo "Building Android APK"
	$(flutter) build apk --release --target-platform  android-arm,android-arm64 --obfuscate --split-debug-info=./sberdevices --dart-define-from-file=config.json 

build-web: clean
	@echo "Building Web app"
	$(flutter) build web --web-renderer canvaskit --release --build-number=${PIPLINE_ID} --dart-define-from-file=config.json

build-ios: clean
	@echo "Building iOS IPA"
	$(flutter) build ipa --release --obfuscate --split-debug-info=./sberdevices --build-number="${CI_COMMIT_TAG}" --dart-define-from-file=config.json