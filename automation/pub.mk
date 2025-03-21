.PHONY: get outdated upgrade upgrade-major add-package clean fix gen-locale

ifeq (clean,$(firstword $(MAKECMDGOALS)))
  CLEAN_TYPE := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CLEAN_TYPE):;@:)
endif

clean:
	@echo "* Cleaning project *"
ifneq (,$(findstring force,$(CLEAN_TYPE)))
	 @(echo -e "Y" |	$(flutter) pub cache clean)
endif
	@$(flutter) clean
	@rm -rf build .flutter-plugins .flutter-plugins-dependencies .dart_tool .packages pubspec.lock ios/Podfile.lock

fix:
	@echo "* Dart code fix *"
	$(dart) fix --dry-run
	$(dart) fix --apply

gen-locale:
	@echo "* Localizaion gen *"
	$(flutter) gen-l10n

get:
	@echo "* Getting latest dependencies *"
	$(flutter) pub get

upgrade:
	@echo "* Upgrading dependencies *"
	$(flutter) pub upgrade

upgrade-major:
	@echo "* Upgrading dependencies --major-versions *"
	$(flutter) pub upgrade --major-versions

outdated: upgrade
	@echo "* Checking for outdated dependencies *"
	$(flutter) pub outdated

regen:
	@echo "* Regeneration codegen files *"
	$(dart) run build_runner build --delete-conflicting-outputs


ifeq (add-package,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

add-package:
	@echo "* Adding package $(RUN_ARGS) *"
	$(flutter) pub add $(RUN_ARGS)