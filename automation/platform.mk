ifeq ($(OS),Windows_NT)
	include automation/platform/win.mk
else
    _detected_OS := $(shell uname -s)
    ifeq ($(_detected_OS),Linux)
		include automation/platform/nix.mk
    else ifeq ($(_detected_OS),Darwin)
		include automation/platform/mac.mk
    endif
endif