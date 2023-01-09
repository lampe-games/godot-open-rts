shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color = vec4(1.0);
uniform float width_pixels = 15.0;
uniform float inner_edge_width_pixels = 1.0;
uniform float outer_edge_width_pixels = 1.0;

varying vec3 vertex_model;

void vertex()
{
  vertex_model = VERTEX;
}

void fragment()
{
  ALBEDO.rgb = color.rgb;
  if (UV.x == 0.5 && UV.y == 0.5)
  {
    ALPHA = 0.0;
  }
  else
  {
    vec2 center_uv = vec2(0.5);
    float uv_dist_to_center_uv = distance(UV, center_uv);
    float edge_dist_to_center_uv = 0.5;
    float vertex_dist_to_center_model = length(vertex_model);
    // proportions:
    //   uv_dist_to_center_uv - vertex_dist_to_center_model
    // edge_dist_to_center_uv - edge_dist_to_center_model
    float edge_dist_to_center_model =
        edge_dist_to_center_uv * vertex_dist_to_center_model / uv_dist_to_center_uv;
    float signed_distance = vertex_dist_to_center_model - edge_dist_to_center_model;
    vec2 gradient = vec2(dFdx(signed_distance), dFdy(signed_distance));
    float rangeFromLine = signed_distance / length(gradient);
    ALPHA = smoothstep(-width_pixels, -width_pixels + inner_edge_width_pixels, rangeFromLine);
    ALPHA = min(ALPHA, 1.0 - smoothstep(-outer_edge_width_pixels, 0.0, rangeFromLine));
  }
}
