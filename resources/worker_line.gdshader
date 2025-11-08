shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 mov = vec2(UV.x-(TIME), UV.y);
	vec4 t = texture(TEXTURE, mov);
	COLOR = t;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
