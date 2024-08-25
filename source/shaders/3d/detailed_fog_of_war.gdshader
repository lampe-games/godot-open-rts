shader_type spatial;
render_mode unshaded;

// essential parameters
uniform vec4 color : source_color = vec4(vec3(0.0), 1.0);
uniform sampler2D world_visibility_texture : hint_default_white, filter_linear, repeat_disable;
uniform int texture_units_per_world_unit = 2;

// optional blurr
uniform int blurr_none_moore_gauss : hint_range(0, 2) = 0;
uniform float gauss_blurr_directions = 16.0;
uniform float gauss_blurr_distance = 1.0;
uniform float gauss_blurr_radius = 1.0;

// optional grain
uniform bool grain = false;
uniform sampler2D grain_texture : hint_default_black;
uniform float grain_strength : hint_range(0.0, 1.0) = 0.1;
uniform float grain_size : hint_range(0.001, 10.0) = 0.1;
uniform float grain_attenuation_lb : hint_range(0.0, 1.0) = 0.1;
uniform float grain_attenuation_ub : hint_range(0.0, 10.0) = 1.0;

// optional debug view
uniform bool debug_texture_view = false;

uniform sampler2D depth_texture : hint_depth_texture;

void vertex()
{
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
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
      if (blurr_none_moore_gauss == 1) // moore blurr
      {
        float offset = 0.005;
        for (int x = -1; x <= 1; x++)
        {
          for (int y = -1; y <= 1; y++)
          {
            transparency_from_world_visibility_texture +=
                textureLod(
                    world_visibility_texture,
                    world_visibility_texture_uv + vec2(offset * float(x), offset * float(y)),
                    0.0)
                    .r;
          }
        }
        transparency_from_world_visibility_texture /= 9.0;
      }
      else if (blurr_none_moore_gauss == 2) // gaussian blurr
      {
        transparency_from_world_visibility_texture =
            textureLod(world_visibility_texture, world_visibility_texture_uv, 0.0).r;
        float pi_times_2 = 6.28318530718;
        vec2 radius = gauss_blurr_radius / vec2(textureSize(world_visibility_texture, 0));
        for (float d = 0.0; d < pi_times_2; d += pi_times_2 / gauss_blurr_directions)
        {
          for (float i = 1.0 / gauss_blurr_distance; i <= 1.0; i += 1.0 / gauss_blurr_distance)
          {
            transparency_from_world_visibility_texture +=
                textureLod(
                    world_visibility_texture,
                    world_visibility_texture_uv + vec2(cos(d), sin(d)) * radius * i,
                    0.0)
                    .r;
          }
        }
        transparency_from_world_visibility_texture /=
            gauss_blurr_distance * gauss_blurr_directions + 1.0;
        ALPHA = max(ALPHA, 1.0 - transparency_from_world_visibility_texture);
      }
      else // no blurr
      {
        transparency_from_world_visibility_texture =
            textureLod(world_visibility_texture, world_visibility_texture_uv, 0.0).r;
      }
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

  if (grain && grain_size != 0.0 && grain_strength != 0.0 && ALPHA > grain_attenuation_lb)
  {
    vec2 grain_to_screen_ratio = vec2(textureSize(grain_texture, 0)) / VIEWPORT_SIZE * grain_size;
    vec2 periodic_grain_texture_uv = mod(SCREEN_UV, grain_to_screen_ratio) / grain_to_screen_ratio;
    float grain_value = textureLod(grain_texture, periodic_grain_texture_uv, 0.0).r;
    float grain_attenuation = smoothstep(grain_attenuation_lb, grain_attenuation_ub, ALPHA);
    ALPHA = clamp(ALPHA + grain_attenuation * grain_strength * grain_value, 0.0, 1.0);
  }
}
