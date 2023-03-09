extends Node

enum PlayerController {
	NONE,
	HUMAN,
	SIMPLE_CLAIRVOYANT_AI,
	DETECT_FROM_SCENE,
}

const Match = preload("res://source/match/MatchConstants.gd")

# gdlint: ignore=class-variable-name
var OPTIONS_FILE_PATH:
	set(_value):
		pass
	get:
		return (
			"user://options.tres"
			if not FeatureFlags.save_user_files_in_tmp
			else "res://tmp/options.tres"
		)
