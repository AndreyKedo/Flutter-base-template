.PHONY: build-android-apk build-web build-ios

build-android-apk: clean get gen-locale
	@echo "Building Android APK"
	$(flutter) build apk --release --target-platform  android-arm,android-arm64 --obfuscate --split-debug-info=. --build-name=${VERSION}  --build-number=${BUILD_NUMBER} --dart-define-from-file=.env

build-web: clean
	@echo "Building Web app"
	$(flutter) build web --web-renderer canvaskit --release --no-source-maps --no-web-resources-cdn --build-number=${PIPLINE_ID} --dart-define-from-file=.env

build-ios: ios-deep-clean gen-locale
	@echo "Building iOS IPA"
	$(flutter) build ipa --release --obfuscate --split-debug-info=. --build-name=${VERSION}  --build-number=${BUILD_NUMBER} --dart-define-from-file=.env