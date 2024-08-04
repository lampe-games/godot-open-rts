shader_type particles;

uniform vec3 projectile_pos[1000];
uniform vec3 projectile_previous_pos[1000];
uniform vec3 _projectile_active[1000];


void start() {
	// Called when a particle is spawned.
}

void process() {
	// todo: if instance is not active: return
	float ste = 0.5;
	TRANSFORM[3].xyz = projectile_pos[INDEX];
}
