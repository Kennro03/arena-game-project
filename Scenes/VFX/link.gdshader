shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float speed = 2.0; // pixels/sec or UV/sec tweak

void fragment() {
	vec2 uv = UV;
	uv.x += TIME * speed;
	COLOR = texture(TEXTURE, uv) * COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
