shader_type canvas_item;

uniform float blurr_factor : hint_range(0.0, 10.0) = 2.0;
uniform bool remove_alpha = true;
uniform bool overlay = true;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment()
{
  vec4 blurred_color;
  if (overlay)
  {
    blurred_color = textureLod(screen_texture, SCREEN_UV, blurr_factor);
  }
  else
  {
    blurred_color = textureLod(TEXTURE, UV, blurr_factor);
  }
  if (remove_alpha)
  {
    COLOR.rgb = blurred_color.rgb;
  }
  else
  {
    COLOR = blurred_color;
  }
}
