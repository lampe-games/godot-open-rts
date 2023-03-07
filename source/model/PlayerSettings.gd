extends Resource

# TODO: rename to PlayerController and extract
enum PlayerType {
	NONE,
	HUMAN,
	SIMPLE_CLAIRVOYANT_AI,
	DETECT_FROM_SCENE,
}

@export var color = Color.BLUE
@export var type = PlayerType.SIMPLE_CLAIRVOYANT_AI
