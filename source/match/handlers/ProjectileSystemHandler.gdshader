shader_type particles;

uniform vec3 projectile_pos[1000];
uniform vec3 projectile_normals[1000];
uniform int projectile_active_mask[1000];
uniform float projectile_speed[1000];
uniform float projectile_synced[1000];
uniform float update_interval;

void start() {
	// Called when a particle is spawned.
}

void process() {
	// if instance is not active
	if ( projectile_active_mask[INDEX] == 0 ) {
		ACTIVE = false;
	} else {
		ACTIVE = true;

		vec3 to = projectile_pos[INDEX];
		float step_range = projectile_speed[INDEX] * update_interval;
		vec3 from = to - projectile_normals[INDEX] * step_range;
		float progress = clamp((TIME - projectile_synced[INDEX]) / ( update_interval * 1000.0), 0.0, 1.0);
		TRANSFORM[3].xyz = mix(from, to, progress);
		//TRANSFORM[3].xyz = projectile_pos[INDEX];
	}
}
