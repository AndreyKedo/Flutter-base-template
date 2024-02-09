.PHONY: run run-develop run-beta run-production

run:
	@echo "* Running app *"
	$(flutter) run --web-browser-flag --disable-web-security --dart-define-from-file=config-dev.json

# Development
run-develop:
	$(flutter) run --web-browser-flag --disable-web-security --dart-define-from-file=config-dev.json

# Beta
run-beta:
	$(flutter) run --web-browser-flag --disable-web-security --dart-define-from-file=config-beta.json

# Production
run-production:
	$(flutter) run --web-browser-flag --disable-web-security --dart-define-from-file=config-prod.json