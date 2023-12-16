extends Node

enum PlayerType {
	NONE = 0,
	HUMAN = 1,
	SIMPLE_CLAIRVOYANT_AI = 2,
}


class Match:
	extends "res://source/match/MatchConstants.gd"

	class Player:
		const CONTROLLER_SCENES = {
			PlayerType.HUMAN: preload("res://source/match/players/human/Human.tscn"),
			PlayerType.SIMPLE_CLAIRVOYANT_AI:
			preload("res://source/match/players/simple-clairvoyant-ai/SimpleClairvoyantAI.tscn"),
		}


class Player:
	const COLORS = [
		Color("66b1ff"),
		Color("ff5c73"),
		Color("a5ff99"),
		Color("ed85ff"),
		Color("006400"),
		Color("bdb76b"),
		Color("000080"),
		Color("48d1cc"),
		# TODO: make sure the colors below are visually distinct from the ones above
		Color("ff0000"),
		Color("ffa500"),
		Color("ffff00"),
		Color("00ff00"),
		Color("00fa9a"),
		Color("0000ff"),
		Color("da70d6"),
		Color("d8bfd8"),
		Color("ff00ff"),
		Color("1e90ff"),
		Color("fa8072"),
		Color("2f4f4f"),
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
