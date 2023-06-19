all: lint format-check shaders-format-check
version = "0.9.0"

format-check:
	find source/ -name '*.gd' | xargs gdformat --check

shaders-format-check:
	find source/ -name '*.gdshader' | xargs clang-format --style=file --dry-run -Werror

lint:
	find source/ -name '*.gd' | xargs gdlint

cc:
	find source/ -name '*.gd' | xargs gdradon cc

todo:
	ack ' todo' -i source/

release-linux:
	godot4 --export-release "Linux/X11" "build/Open_RTS_$(version)_linux64.bin"

release-macos:
	godot4 --export-release "macOS" "build/Open_RTS_$(version)_osx64.zip"

release-windows:
	godot4 --export-release "Windows Desktop" "build/Open_RTS_$(version)_windows64.exe"

release: release-linux release-macos release-windows
