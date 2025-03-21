.PHONY: install-pods simulator ios-deep-clean check-lines-count

CFLAGS += -D osx

_echo_os:
	@echo "Running Makefile on macOS"

install-pods:
	@echo "* Installing pods *"
	@pod install --repo-update --project-directory=./ios
	@pod install --project-directory=./ios

simulator:
	@echo "* Opening an iOS simulator *"
	@open -a Simulator

ios-deep-clean: clean get install-pods
	@echo "* Performing a deep clean for iOS completed*"

check-lines-count:
	@find . -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.gr.dart' ! -name '*.gen.dart' ! -name 'app_localizations_*.dart' ! -name 'app_localizations.dart' | xargs wc -l | sort -n