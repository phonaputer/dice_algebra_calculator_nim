APP_BINARY=dice_algebra_calculator
MAIN_FILE=main.nim

debug_build: format debug_compile

debug_compile:
	nim compile -o=$(APP_BINARY) $(MAIN_FILE)

compile:
	nim compile -d:release -o=$(APP_BINARY) $(MAIN_FILE)

format:
	ls | grep ".nim$$" | xargs nimpretty --indent:2
