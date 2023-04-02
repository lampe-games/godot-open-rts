extends Node

enum PlayerController {
	NONE = 0,
	HUMAN = 1,
	SIMPLE_CLAIRVOYANT_AI = 2,
	DETECT_FROM_SCENE,
}


class Match:
	extends "res://source/match/MatchConstants.gd"

	class Player:
		const CONTROLLER_SCENES = {
			PlayerController.HUMAN: preload("res://source/match/players/human/Human.tscn"),
			PlayerController.SIMPLE_CLAIRVOYANT_AI:
			preload("res://source/match/players/simple-clairvoyant-ai/SimpleClairvoyantAI.tscn"),
		}


class Player:
	const COLORS = [
		Color("66b1ff"),
		Color("ff5c73"),
		Color("a5ff99"),
		Color("ed85ff"),
	]


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
