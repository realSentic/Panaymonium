shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform vec4 inner_color : source_color = vec4(0.1, 0.0, 0.0, 1.0);
uniform float edge_width : hint_range(0.0, 0.2) = 0.08;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;

float hash(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

float organic_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float n = organic_noise(UV * 6.0 + vec2(TIME * 0.1, TIME * 0.05));
	n = n * 0.6 + organic_noise(UV * 12.0) * 0.4;

	if (n < dissolve_amount) {
		discard;
	}

	float edge = smoothstep(dissolve_amount, dissolve_amount + edge_width, n);
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	vec4 pulsing_edge = mix(inner_color, edge_color, pulse);
	vec4 final_color = mix(pulsing_edge, tex, edge);
	final_color.a = tex.a;

	COLOR = final_color;
}