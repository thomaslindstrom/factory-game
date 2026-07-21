shader_type canvas_item;

uniform bool use_color = false;
uniform vec4 color: source_color;

void fragment() {
	vec4 sample = texture(TEXTURE, UV);
	
	if (use_color && sample.a > 0.0) {
		sample = color;
	}
	
	COLOR = sample;
}
