APP_BINARY=dice_algebra_calculator
MAIN_FILE=src/main.nim

debug_build: format debug_compile test

debug_compile:
	nim compile -o=$(APP_BINARY) $(MAIN_FILE)

test:
	nimble test

compile:
	nim compile -d:release -o=$(APP_BINARY) $(MAIN_FILE)

format:
	find . -name "*.nim" -exec nimpretty {} \;
