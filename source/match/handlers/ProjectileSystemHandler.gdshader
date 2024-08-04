shader_type particles;

uniform vec3 projectile_pos[1000];
uniform int projectile_active_mask[1000];

void start() {
	// Called when a particle is spawned.
}

void process() {
	// if instance is not active
	//if ( projectile_active_mask[INDEX] == 0 ) {
		//ACTIVE = false;
	//} else {
		//ACTIVE = true;
	TRANSFORM[3].xyz = projectile_pos[INDEX];
	//}
}
