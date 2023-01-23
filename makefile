all: lint format-check shaders-format-check

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
