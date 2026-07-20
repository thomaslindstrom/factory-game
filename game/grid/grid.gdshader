shader_type canvas_item;

uniform vec2 region_offset = vec2(0.0);
uniform vec2 region_size = vec2(1.0);

void vertex() {
	UV = region_offset + UV * region_size;
}

void fragment() {
	COLOR *= texture(TEXTURE, UV);
}
