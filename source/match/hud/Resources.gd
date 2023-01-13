extends PanelContainer

@onready var _res_a_color_rect = find_child("ResourceAColorRect")
@onready var _res_b_color_rect = find_child("ResourceBColorRect")


func _ready():
	_res_a_color_rect.color = Constants.Match.Resources.A.COLOR
	_res_b_color_rect.color = Constants.Match.Resources.B.COLOR
