extends Resource

enum Visibility { PER_PLAYER, ALL_PLAYERS, FULL }

@export var players: Array[Resource] = []
@export var controlled_player = 0  # TODO: remove
@export var visibility = Visibility.PER_PLAYER
@export var visible_player = 0
