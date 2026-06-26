shader_type canvas_item;

uniform int shape_type = 0; 
// 0=circle, 1=rectangle, 2=rounded_rectangle, 3=diamond, 4=ring, 5=capsule

uniform vec4 fill_color : source_color = vec4(0.2, 0.8, 0.2, 0.3);
uniform vec4 border_color : source_color = vec4(0.2, 0.8, 0.2, 0.8);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1; // for rounded rect
uniform float ring_inner_radius : hint_range(0.0, 1.0) = 0.6; // for ring
uniform bool animated_border = true;
uniform float animation_speed : hint_range(0.0, 5.0) = 1.0;
uniform float pixel_size : hint_range(1.0, 32.0) = 4.0;
uniform vec2 rect_size = vec2(40.0, 40.0);

float ellipse_sdf(vec2 p) {
    return length(p * vec2(1.0, 1.0));
}

float rectangle_sdf(vec2 p) {
    vec2 d = abs(p) - vec2(0.5);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float rounded_rectangle_sdf(vec2 p, float r) {
    vec2 d = abs(p) - vec2(0.5 - r);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

float diamond_sdf(vec2 p) {
    return (abs(p.x) + abs(p.y));
}

float capsule_sdf(vec2 p) {
    float aspect = rect_size.y / rect_size.x;
    float r = 0.5;                              // radius = half width in UV space
    float half_h = max(aspect * 0.5 - r, 0.0); // half height of straight section
    
    // clamp y to the straight section, then measure distance to that point
    vec2 q = vec2(p.x, p.y - clamp(p.y, -half_h, half_h));
    return length(q);
}

void fragment() {
	vec2 pixel_coords = UV * rect_size;
    vec2 snapped_coords = floor(pixel_coords / pixel_size) * pixel_size;
    vec2 snapped_uv = snapped_coords / rect_size;
    vec2 centered = snapped_uv - vec2(0.5);
    float dist = 0.0;
    float edge = 0.5;
    bool discard_pixel = false;
    
    if (shape_type == 0) {
        dist = length(centered);
        edge = 0.5;
    } else if (shape_type == 1) {
        vec2 d = abs(centered) - vec2(0.5);
        dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) + 0.5;
        edge = 0.5;
    } else if (shape_type == 2) {
        float r = corner_radius;
        vec2 d = abs(centered) - vec2(0.5 - r);
        dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r + 0.5;
        edge = 0.5;
    } else if (shape_type == 3) {
        dist = (abs(centered.x) + abs(centered.y));
        edge = 0.5;
    } else if (shape_type == 4) {
        dist = length(centered);
        edge = 0.5;
        float inner = length(centered) / (edge * ring_inner_radius);
        if (inner < 1.0) {
            discard_pixel = true;
        }
    } else if (shape_type == 5) {
	    dist = length(centered);
        edge = 0.5;
	}
    
    float normalized = dist / edge;
    float border_inner = 1.0 - border_width * 2.0;
    
    if (discard_pixel || normalized > 1.0) {
        COLOR = vec4(0.0);
    } else if (normalized > border_inner) {
        float dash = 1.0;
        if (animated_border) {
            float angle = atan(centered.y, centered.x);
            dash = step(0.5, fract(angle / (PI * 0.25) + TIME * animation_speed));
        }
        COLOR = border_color * vec4(1.0, 1.0, 1.0, dash);
    } else {
        COLOR = fill_color;
    }
}