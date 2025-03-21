.PHONY: version doctor help

flutter = flutter
dart = dart

ifeq (, $(shell which fvm))
 
else
	flutter = fvm flutter
	dart = fvm dart
endif

-include automation/*.mk

help:
	@echo ""
	@echo ""
	@echo "* HELP PROJECT *"
	@echo ""
	@echo ""
	@echo "[1] Build: build-android-apk, build-web, build-ios"
	@echo ""
	@echo [2] Manage project: clean, get, upgrade, upgrade-major, outdated, regen, gen-locale, add-package \\n \\n \
	      usage: clean [force] deep clean with remove pubcache \\n \
	      usage: add-package [package_name] add new package
	@echo ""
	@echo "[3] Special MacOS options: install-pods, simulator, ios-deep-clean"
	@echo ""
	@echo "Check codel lines count: check-lines-count"

version:
	$(flutter) --version

doctor:
	$(flutter) doctor