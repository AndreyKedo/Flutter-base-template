.PHONY: version doctor help

flutter = flutter
dart = dart

ifeq (, $(shell which fvm))
 
else
	flutter = fvm flutter
	dart = fvm dart
endif

# ifeq (, $(shell command -v fvm), /dev/null)
# 	flutter = flutter
# 	dart = dart
# else 
# 	flutter = fvm flutter
# 	dart = fvm dart
# endif

-include automation/*.mk

help:
	@echo ""
	@echo ""
	@echo "* HELP PROJECT *"
	@echo ""
	@echo ""
	@echo "[1] Build: build-android-apk, build-web, build-ios"
	@echo ""
	@echo "[2] Manage project: clean, get, upgrade, upgrade-major, outdated, regen, gen-locale"
	@echo ""
	@echo "[3] Runing: run, run-develop, run-beta, run-production"
	@echo ""
	@echo "[4] Special MacOS options: install-pods, simulator, ios-deep-clean"

version:
	$(flutter) --version

doctor:
	$(flutter) doctor