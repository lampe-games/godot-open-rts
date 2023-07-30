shader_type canvas_item;

uniform sampler2D reference_texture : hint_default_white, repeat_disable;

void fragment()
{
  COLOR.a = 1.0 - textureLod(reference_texture, UV, 0.0).r;
}
