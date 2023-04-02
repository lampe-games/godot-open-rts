shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color = vec4(vec3(0.0), 1.0);
uniform sampler2D world_visibility_texture : hint_default_white, filter_linear, repeat_disable;
uniform int texture_units_per_world_unit = 2;
uniform bool debug_texture_view = false;
uniform sampler2D depth_texture : hint_depth_texture;

void vertex()
{
  POSITION = vec4(VERTEX, 1);
}

void fragment()
{
  ALBEDO = color.rgb;
  if (debug_texture_view && UV.x <= 0.2 && UV.y <= 0.2)
  {
    ALBEDO = textureLod(world_visibility_texture, vec2(UV * 5.0), 0.0).rgb;
    if (UV.x > 0.199 || UV.y > 0.199)
    {
      ALBEDO = vec3(1.0, 0.0, 0.0);
    }
  }

  ALPHA = 0.0;

  // depth is encoded on the first channel and is <0; 1>
  float depth = textureLod(depth_texture, SCREEN_UV, 0.0).x;
  // transform depth from <0; 1> value to corresponding point in projection space <-1,-1,0; 1,1,1>*
  // * note that projection space in Vulkan is different than in OpenGL
  vec3 normalized_device_coordinates = vec3(SCREEN_UV * 2.0 - 1.0, depth);
  // move depth point from projection space to world space
  // * note that INV_PROJECTION_MATRIX is broken atm. so, let's use inverse(PROJECTION_MATRIX)
  vec4 world_position =
      INV_VIEW_MATRIX * inverse(PROJECTION_MATRIX) * vec4(normalized_device_coordinates, 1.0);
  world_position.xyz /= world_position.w;

  if (depth == 1.0)
  {
    ALPHA = 1.0;
  }
  else
  {
    vec2 world_visibility_texture_uv = world_position.xz /
        vec2(textureSize(world_visibility_texture, 0)) * float(texture_units_per_world_unit);
    if (world_visibility_texture_uv.x >= 0.0 && world_visibility_texture_uv.x <= 1.0 &&
        world_visibility_texture_uv.y >= 0.0 && world_visibility_texture_uv.y <= 1.0)
    {
      float transparency_from_world_visibility_texture = 0.0;
      transparency_from_world_visibility_texture =
          textureLod(world_visibility_texture, world_visibility_texture_uv, 0.0).r;
      ALPHA = max(ALPHA, 1.0 - transparency_from_world_visibility_texture);
    }
    else
    {
      ALPHA = 1.0;
    }
  }

  if (debug_texture_view && UV.x <= 0.2 && UV.y <= 0.2)
  {
    ALPHA = 1.0;
  }
}
