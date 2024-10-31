extends Node3D

var icon_folder: String = "res://assets/ui/icons/"

var icons_to_render_count: int = 0
var icon_render_index: int = 0

@onready var render_booth: SubViewport = $RenderBooth


func _ready() -> void:
	icons_to_render_count = render_booth.get_child_count()

	for c in render_booth.get_children():
		c.visible = false

	set_process(true)


func render_icon() -> void:
	if icon_render_index > 0:
		render_booth.get_child(icon_render_index - 1).visible = false

	var rendered_icon_node: Node3D = render_booth.get_child(icon_render_index)
	var rendered_icon_camera: Camera3D = rendered_icon_node.get_node("Camera3D")

	rendered_icon_node.visible = true
	rendered_icon_camera.current = true

	var icon_name: String = rendered_icon_node.name

	await get_tree().process_frame

	var img: Image = render_booth.get_texture().get_image()

	var filepath: String = icon_folder + icon_name + ".png"
	img.save_png(filepath)

	icon_render_index += 1

	if icon_render_index >= icons_to_render_count:
		set_process(false)


func _process(_delta: float) -> void:
	render_icon()
