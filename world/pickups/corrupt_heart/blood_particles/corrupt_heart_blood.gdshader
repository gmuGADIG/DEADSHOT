shader_type spatial;

void fragment() {
	float dist_from_center = distance(UV,vec2(0.5,0.5));
	if(dist_from_center < 0.10){
		ALBEDO = vec3(0.6,0.0,0.0);
	}
	else if(dist_from_center < 0.15){
		ALBEDO = vec3(0.0,0.0,0.0);
	}
	else{
		ALPHA = 0.0;
	}
}
