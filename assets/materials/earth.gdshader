shader_type canvas_item;
render_mode unshaded;

const int SHADING_MODE_NONE = 0;
const int SHADING_MODE_SMOOTH = 1;
const int SHADING_MODE_QUANT = 2;
const int SHADING_MODE_DITHER = 3;
const int SHADING_MODE_MAX = 4;

const float COLOUR_ESTIMATION_CUTOFF = 0.001;

// This should usually be set to the side of the rect that is displaying the
// planet, to match the size of pixels of sprites.
uniform float pixel_scale = 360.0;


//// Surface
uniform float surface_radius : hint_range(0.01, 0.5, 0.001) = .3;
// Palette for the surface.
// The colours should be in a single row ordered from lowest to highest.
// If a second row is present, cutoff values for the colours above will be
// taken from the red channel, with animation values taken from the green
// channel. See the 'surface' function for details of how these are used.
uniform sampler2D surface_palette : filter_nearest, hint_default_white;
// === new: texture to drive surface colours ===
uniform sampler2D surface_texture : filter_nearest, hint_default_white;
// 0 = nearest-colour quantise, 1 = luminance -> palette cutoffs
uniform int mapping_mode : hint_enum("Nearest", "Luminance") = 0;

// New uniforms to control user-driven rotation about X and Y axes (radians).
// Modify these from code to rotate the sampled surface texture and noise.
uniform float surface_rotation_x : hint_range(-6.283,6.283,0.01) = 0.0;
uniform float surface_rotation_y : hint_range(-6.283,6.283,0.01) = 0.0;
uniform float surface_rotation_z : hint_range(-6.283,6.283,0.01) = 0.0;

uniform vec4 background_colour : source_color = vec4(0., 0., 0., 1.0);
// Base rotation of the planet on its axis.
uniform float surface_base_rotation : hint_range(0.0, 6.28, 0.1) = 0.0;
// Speed at which to animate the rotation of the planet.
uniform float surface_rotation_speed : hint_range(-1.0, 1.0, 0.001) = 0.0;


// Non-noise bumpmap.
// This is added to the primary noise, before the secondary and tertiary noise
// is added.
uniform sampler2D surface_bump_map : hint_default_transparent, repeat_enable;
// Factor by which to multiply the bump map values.
uniform float surface_bump_strength : hint_range(-1.0, 1.0, 0.01) = 0.3;


//// Clouds
uniform bool display_cloud_shadows = true;
uniform float cloud_shadow_darkness : hint_range(0.0, 1.0, 0.05) = 0.25;
uniform float cloud_alpha : hint_range(0.0, 1.0) = 1.0;


// First cloud layer
uniform float cloud_1_cover : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float cloud_1_radius : hint_range(0.01, 0.5, 0.001) = .32;
// Palette for the clouds.
// Works the same as the surface palette.
uniform sampler2D cloud_1_palette: filter_nearest, hint_default_transparent;
uniform int cloud_1_cell_amount = 10;
// The speed at which the clouds move over the surface.
uniform float cloud_1_rotation_speed : hint_range(-1.0, 1.0, 0.001) = 0.03;
// The speed at which the clouds change shape.
uniform float cloud_1_fluctuation_speed : hint_range(-1.0, 1.0, 0.001) = 0.03;
uniform vec3 cloud_1_period = vec3(9.5, 9.5, 9.5);
uniform vec3 cloud_1_secondary_period = vec3(9.5, 9.5, 9.5);
uniform int cloud_1_secondary_cell_amount = 10;
// Factor by which to multiply the generated noise.
uniform float cloud_1_secondary_strength : hint_range(-10.0, 10.0, 0.01) = 0.3;

// Second cloud layer
uniform float cloud_2_cover : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float cloud_2_radius : hint_range(0.01, 0.5, 0.001) = .32;
// Palette for the clouds.
// Works the same as the surface palette.
uniform sampler2D cloud_2_palette: filter_nearest, hint_default_transparent;
uniform int cloud_2_cell_amount = 10;
// The speed at which the clouds move over the surface.
uniform float cloud_2_rotation_speed : hint_range(-1.0, 1.0, 0.001) = 0.03;
// The speed at which the clouds change shape.
uniform float cloud_2_fluctuation_speed : hint_range(-1.0, 1.0, 0.001) = 0.03;
uniform vec3 cloud_2_period = vec3(9.5, 9.5, 9.5);
uniform vec3 cloud_2_secondary_period = vec3(9.5, 9.5, 9.5);
uniform int cloud_2_secondary_cell_amount = 10;
// Factor by which to multiply the generated noise.
uniform float cloud_2_secondary_strength : hint_range(-1.0, 1.0, 0.01) = 0.3;


//// Atmosphere
uniform float atmosphere_radius : hint_range(0.01, 0.5, 0.001) = .34;
// Palette for the atmosphere.
// The colours should be in a single row ordered from lowest to highest.
// Additional rows will be ignored.
uniform sampler2D atmosphere_palette : filter_nearest, hint_default_transparent;


//// Posterisation
uniform bool posterise = false;
// Palette to restrict the calculated colours to. All colours in the palette
// are considered.
uniform sampler2D posterisation_palette : filter_nearest, hint_default_black;


//// Light/shading
uniform int shading_mode : hint_enum(
	"None",
	"Smooth",
	"Quantised",
	"Dithered",
	"Max Brightness"
) = 2;
// A cap on the brightness produces by the light.
uniform float maximum_brightness : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float sun_strength = 2.0;
// Controls the width of the transition from light to dark. Higher values result
// in a quicker transition. For Quantised shading, this means narrower bands of
// different shades.
uniform float shade_transition = 10.0;
// Also contributes to the width of the transition from light to dark.
// For Quantised shading, higher values result in more bands.
uniform float shade_step = 8.0;
// Vector pointing to the sun. This must have some magnitude or the lighting
// will not work.
uniform vec3 sun_direction = vec3(1.0, 0.2, -0.3);
// Textures for different shades when using the "Dithered" shading mode.
// Only the alpha channel is used to indicate if the pixel should be lit or not.
uniform sampler2D dither_texture : filter_nearest;
uniform int dither_levels = 0;

// Noise specification for the shading.
uniform int shading_noise_cell_amount = 40;
uniform float shading_noise_strength : hint_range(-1.0, 1.0, 0.01) = 0.3;
uniform vec3 shading_noise_period = vec3(9.5, 9.5, 9.5);

// modulo function that returns positive wrapped values. (13 % 5 = 3, but -13 % 5 = 2)
vec3 modulo(vec3 divident, vec3 divisor){
	vec3 positiveDivident = mod(divident, divisor) + divisor;
	return mod(positiveDivident, divisor);
}

// 3 dimensional pseudo random number generator
vec3 random(vec3 value){
	vec3 return_value = vec3( dot(value, vec3(127.1,311.7, 201.9) ),
				  dot(value, vec3(269.5,183.3, 367.7) ),
				  dot(value, vec3(245.1,367.7, 105.6) ) );
	return -1.0 + 2.0 * fract(sin(return_value) * 43758.5453123);
}

// Calculate z-position of sphere surface
float calculate_z(vec2 uv, float radius) {
	// equation of a sphere at coordinates (0.5, 0.5)
	// (x-.5)^2 + (y-.5)^2 + z^2 = surface_radius^2
	float w = sqrt(pow(radius, 2.) - pow(uv.x - .5, 2.) - pow(uv.y - .5, 2.));
	return w;
}

mat3 rotate_x(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

mat3 rotate_y(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

mat3 rotate_z(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

// construct rotation matrix about 1/sqrt(2)i, 1/sqrt(2)j, 0k unit vector
// because UV coordinates start at the top left and rotating the noise
// rotates all the noise, not just the sphere so if you rotate about any
// axis of the coordinate system the noise moves through the sphere
// and it doesn't look like it's spinning (duh)
// it's also why it rotates on a tilted axis
// because this was the easiest solution I found
mat3 generate_rotation_matrix(float theta) {
	vec3 rot_1 = vec3(
		.5*(1.-cos(theta)) + cos(theta),
		.5*(1.-cos(theta)),
		-(1./sqrt(2))*sin(theta)
	);
	vec3 rot_2 = vec3(
		.5*(1.-cos(theta)),
		.5*(1.-cos(theta)) + cos(theta),
		(1./sqrt(2))*sin(theta)
	);
	vec3 rot_3 = vec3(
		(1./sqrt(2))*sin(theta),
		-(1./sqrt(2))*sin(theta),
		cos(theta)
	);
	return mat3(rot_1, rot_2, rot_3);
}

// Put the UV on a pixel grid.
vec2 calculate_grid_uv(vec2 uv) {
	return round(uv * pixel_scale) / pixel_scale;
}

// Return the colour from a palette that most closely matches target.
vec3 get_nearest_colour(in sampler2D palette, in vec3 target) {
	ivec2 palette_size = textureSize(palette, 0);
	vec3 closest_color = background_colour.rgb;
	float min_dist = 2.0;
	int rows = palette_size.y;
	int columns = palette_size.x;
	float n = float(columns);

	for (int row = 0; row < palette_size.y; row++) {
		float yuv = 1.000 / (2.000 * float(rows)) + float(row) / float(rows);
		for (int column = 0; column < columns; column++){
			float xuv = 1.000 / (2.000 * n) + float(column) / n;
			vec3 index_color = texture(palette, vec2(xuv,yuv)).rgb;
			float dist = length(index_color - target);
			if (dist < min_dist) {
				min_dist = dist;
				closest_color = index_color;
				// If the current colour is really really close, just return it
				// and don't bother checking the rest.
				if (min_dist < COLOUR_ESTIMATION_CUTOFF){
					return closest_color;
				}
			}
		}
	}
	return closest_color;
}

// Get the inverse alpha from a dither texture for the specified UV.
float get_leveled_dither(int level, vec2 uv) {
	ivec2 texture_size = textureSize(dither_texture, 0);
	int level_width = texture_size.x / dither_levels;

	float pattern_x = mod(uv.x * pixel_scale, float(level_width));
	// Add an offset for the pattern location
	pattern_x = pattern_x + float(level_width * level);
	float duvx = pattern_x / float(texture_size.x);

	float duvy = round(
		mod(uv.y * pixel_scale, float(texture_size.y))
	) / float(texture_size.y);

	vec2 dither_uv = vec2(
		duvx,
		duvy
	);
	return 1.0 - texture(dither_texture, dither_uv).a;
}

// Get a colour from a palette by row and column index.
vec4 get_colour(sampler2D palette, ivec2 palette_size, int column, int row) {
	float uvx = (1.0 / float(palette_size.x + 1)) * (float(column + 1));
	float uvy = (1.0 / float(palette_size.y + 1)) * (float(row + 1));
	return texture(palette, vec2(uvx, uvy));
}

// seamless noise function adapted from Godot Shaders seamless Perlin Noise function
float seamless_noise(vec2 uv, float w, vec3 _period, mat3 rot_p, int cell_amount) {
	vec3 uvw = rot_p * vec3(uv, w); // multiply by rotation vector to spin world
	uvw = vec3(uvw * float(cell_amount)); // multiply by cell amount and then round to create discrete cells
	vec3 cells_minimum = floor(uvw);
	vec3 cells_maximum = ceil(uvw);
	vec3 uvw_fract = fract(uvw);

	// wrap every period
	cells_minimum = modulo(cells_minimum, _period);
	cells_maximum = modulo(cells_maximum, _period);

	// calc lerp
	vec3 blur = smoothstep(0.3, 1.0, uvw_fract);

	// generate cube of pseudo-random values for every pixel
	vec3 p_000 = random(vec3(cells_minimum.x, cells_minimum.y, cells_minimum.z));
	vec3 p_100 = random(vec3(cells_maximum.x, cells_minimum.y, cells_minimum.z));
	vec3 p_010 = random(vec3(cells_minimum.x, cells_maximum.y, cells_minimum.z));
	vec3 p_110 = random(vec3(cells_maximum.x, cells_maximum.y, cells_minimum.z));
	vec3 p_001 = random(vec3(cells_minimum.x, cells_minimum.y, cells_maximum.z));
	vec3 p_101 = random(vec3(cells_maximum.x, cells_minimum.y, cells_maximum.z));
	vec3 p_011 = random(vec3(cells_minimum.x, cells_maximum.y, cells_maximum.z));
	vec3 p_111 = random(vec3(cells_maximum.x, cells_maximum.y, cells_maximum.z));

	// return a smoothed version of the noise
	return mix(mix( mix( dot( p_000, uvw_fract - vec3(0, 0, 0) ),
                     dot( p_100, uvw_fract - vec3(1, 0, 0) ), blur.x),
                mix( dot( p_010, uvw_fract - vec3(0, 1, 0) ),
                     dot( p_110, uvw_fract - vec3(1, 1, 0) ), blur.x), blur.y),
			mix( mix( dot( p_001, uvw_fract - vec3(0, 0, 1) ),
                     dot( p_101, uvw_fract - vec3(1, 0, 1) ), blur.x),
                mix( dot( p_011, uvw_fract - vec3(0, 1, 1) ),
                     dot( p_111, uvw_fract - vec3(1, 1, 1) ), blur.x), blur.y), blur.z) * 0.8 + 0.5;
}

// Calculate the light at the given radius.
float calculate_light(vec2 grid_uv, float radius) {

	// Some shading types do not need the light to be calculated, so return
	// early for those.
	if (shading_mode == SHADING_MODE_NONE) {
		return 1.0;
	} else if (shading_mode == SHADING_MODE_MAX) {
		return maximum_brightness;
	}

	// Normalize UV coordinates
    vec2 normalized_uv = (grid_uv - vec2(0.5)) / radius;

    // Convert UV to 3D point on sphere
    vec3 sphere_point = vec3(
        normalized_uv.x,
        sqrt(max(0.0, 1.0 - dot(normalized_uv, normalized_uv))),
        normalized_uv.y
    );

	float light = dot(
		normalize(
			sphere_point
		),
		normalize(sun_direction)
	);
	float brightness_cap = maximum_brightness / sun_strength;

	// Introduce some noise into the light to create more interesting shading,
	// if requested.
	if (shading_noise_strength != 0.0) {
		float w = calculate_z(grid_uv, radius);
		float noise = seamless_noise(
			grid_uv,
			w,
			shading_noise_period,
			mat3(1.0),
			shading_noise_cell_amount
		);
		if (!isnan(light)) {
			light = clamp (
				light + ((noise - 0.5) * shading_noise_strength),
				0.0,
				1.0
			);
		}
	}

	// Adjust the light value for the selected shading type.
	if (shading_mode == SHADING_MODE_SMOOTH) {
		light = sun_strength * min(
			brightness_cap,
			(light * shade_transition) / shade_step
		);
	} else if (shading_mode == SHADING_MODE_QUANT) {
		// Adding the floor results in a quantised gradient.
		light = sun_strength * min(
			brightness_cap,
			floor(light * shade_transition) / shade_step
		);
	} else if (shading_mode == SHADING_MODE_DITHER) {
		// When using dithering, the quantisation is done by dividing into
		// different types of dither below.
		light = sun_strength * min(
			brightness_cap,
			(light * shade_transition) / shade_step
		);

		ivec2 texture_size = textureSize(dither_texture, 0);
		for (int level = 0; level < dither_levels; level++) {
			float cutoff = float(level + 1) * (1.0 / float(dither_levels));
			if (light <= cutoff) {
				light = maximum_brightness * get_leveled_dither(
					level,
					grid_uv
				);
				break;
			}
		}
	}

	return light;
}

// Calculate additional noise and combine it with the existing noise for the
// surface.
float apply_surface_noise(
	float perlin,
	vec3 period,
	vec2 uv,
	float w,
	mat3 rot_p,
	int cell_amount,
	float strength
) {
	if (isnan(perlin)) {
		return perlin;
	}
	float result = perlin;
	float noise = seamless_noise(
		uv,
		w,
		period,
		rot_p,
		cell_amount
	);
	result = clamp(
		perlin + ((noise - 0.5) * strength),
		0.0,
		1.0
	);
	return result;
}

// Generate the surface.
// NOTE: replaced the perlin-based generation with a texture-driven approach.
// mapping_mode controls how the sampled texture drives palette selection:
// 0 => nearest palette colour to sampled texel
// 1 => luminance (grayscale) used in the original cutoff-based palette loop
// small constant used for angle math


vec4 surface(vec2 uv, mat3 rot_p){
      // z used for bump sampling and for any shading noise
    float w = calculate_z(uv, surface_radius);

    // If outside the sphere, bail out early
    if (isnan(w)) {
        return vec4(0.0);
    }

    // 1) Convert 2D UV to 3D direction on unit sphere (same convention as calculate_light)
    vec2 normalized_uv = (uv - vec2(0.5)) / surface_radius;
    float portal = dot(normalized_uv, normalized_uv);
    if (portal > 1.0) {
        return vec4(0.0);
    }
    float y = sqrt(max(0.0, 1.0 - portal));
    vec3 dir = vec3(normalized_uv.x, y, normalized_uv.y); // (x, y, z)

    // 2) Rotate the 3D direction with the provided rotation matrix.
    //    rot_p must be constructed so yaw (Z) is applied first, then pitch (X).
    vec3 rdir = normalize(rot_p * dir);

    // 3) Convert rotated direction back to spherical lon/lat and equirect UV
    float lon = atan(rdir.z, rdir.x);
    float lat = asin(clamp(rdir.y, -1.0, 1.0));

    float u_s = 0.5 + lon / (2.0 * PI);
    float v_s = 0.5 - lat / PI;
    u_s = fract(u_s);

    vec2 tex_uv = vec2(u_s, v_s);
    vec4 texcol = texture(surface_texture, tex_uv);
    if (texcol.a <= 0.0) {
        return vec4(0.0);
    }

    // outside sphere -> transparent/background if texture has alpha
    if (texcol.a <= 0.0) {
        return vec4(0.0);
    }

    // Keep the rest of your palette mapping logic using texcol...
    vec4 color = vec4(0.0);

    if (mapping_mode == 0) {
        // nearest-colour quantization using surface_palette
        vec3 nc = get_nearest_colour(surface_palette, texcol.rgb);
        color = vec4(nc, 1.0);
    } else {
        // luminance -> palette cutoffs (re-uses original palette logic)
        float luminance = dot(texcol.rgb, vec3(0.299, 0.587, 0.114));
        float perlin = clamp(luminance, 0.0, 1.0);

        ivec2 palette_size = textureSize(surface_palette, 0);
        float last_cutoff = -0.1;
        for (int column = 0; column <= palette_size.x; column++) {
            float cutoff;
            float animation_factor = 0.0;
            if (palette_size.y > 1) {
                vec4 spec = get_colour(surface_palette, palette_size, column, 1);
                cutoff = spec.r;
                if (column == palette_size.x) {
                    cutoff = 1.0;
                }
                animation_factor = spec.g;
                if (animation_factor > 0.0) {
                    cutoff = cutoff + sin(TIME)/(512.0 * (1.0 - animation_factor));
                }
            } else {
                cutoff = (1.0 / float(palette_size.x)) * float(column + 1);
            }
            if (perlin > last_cutoff && perlin <= cutoff) {
                color = get_colour(surface_palette, palette_size, column, 0);
            }
            last_cutoff = cutoff;
        }
    }

    // optional bumpmap tweak: sample bump using the spherical UV as well
    vec4 bump = texture(surface_bump_map, tex_uv);
    if (bump.a > 0.0) {
        color.rgb = clamp(color.rgb + ((bump.r - 0.5) * surface_bump_strength), 0.0, 1.0);
    }

    // shading (light computation still uses original grid_uv -> calculate_light)
    float light = calculate_light(uv, surface_radius);
    color.rgb = color.rgb * light;
    color.a = 1.0;
    return color;
}
// returns rotated direction (rdir). Use this for noise sampling.
// If the point is outside the visible sphere, return vec3(0.0) and let caller handle it.
vec3 rotated_direction(mat3 rot_p, vec2 uv, float radius) {
    vec2 normalized_uv = (uv - vec2(0.5)) / radius;
    float portal = dot(normalized_uv, normalized_uv);
    if (portal > 1.0) {
        return vec3(0.0); // outside sphere
    }
    float y = sqrt(max(0.0, 1.0 - portal));
    vec3 dir = vec3(normalized_uv.x, y, normalized_uv.y);
    vec3 rdir = normalize(rot_p * dir);
    return rdir;
}

// convenience to get equirectangular UV from a direction
vec2 dir_to_equirect_uv(vec3 rdir) {
    float lon = atan(rdir.z, rdir.x);
    float lat = asin(clamp(rdir.y, -1.0, 1.0));
    float u_s = 0.5 + lon / (2.0 * PI);
    float v_s = 0.5 - lat / PI;
    u_s = fract(u_s);
    return vec2(u_s, v_s);
}


// Generate clouds
// clouds now takes rotated direction (rdir) instead of screen uv for noise sampling.
// `rdir` should be vec3(0,0,0) for points outside the sphere (caller should check).
vec4 clouds(
	float cover,
	vec3 rdir,                // rotated 3D direction on the sphere (unit vector)
	vec3 period,
	int cell_amount,
	vec3 noise_period,
	int noise_cell_amount,
	float noise_strength,
	float radius,
	sampler2D palette,
	float fluctuation_speed,
	bool shadow
){
	if (cover == 0.0) {
		return vec4(0.0);
	}
	// outside sphere sentinel
	if (rdir == vec3(0.0)) {
		return vec4(0.0);
	}

	// derive an equirectangular UV for palette/bump sampling
	vec2 sample_uv = dir_to_equirect_uv(rdir);

	// derive a 'w' and build a sample vector from the rotated direction
	// Optionally rotate rdir for local cloud fluctuation (wind)
	float theta = TIME * fluctuation_speed;
	mat3 rot_0 = mat3(
		vec3(1, 0, 0),
		vec3(0, cos(theta), -sin(theta)),
		vec3(0, sin(theta), cos(theta))
	);
	// apply only local fluctuation rotation — DO NOT apply user rotation here
	vec3 sample_dir = rot_0 * rdir;

	// Use the 3D direction components as the coordinates for seamless_noise:
	// (x,z) -> uv, y -> w. Use mat3(1.0) for noise-space rotation to avoid warping.
	float perlin = seamless_noise(
		vec2(sample_dir.x, sample_dir.z),
		sample_dir.y,
		period,
		mat3(1.0),
		cell_amount
	);
	float noise = seamless_noise(
		vec2(sample_dir.x, sample_dir.z),
		sample_dir.y,
		noise_period,
		mat3(1.0),
		noise_cell_amount
	);
	if (!isnan(perlin)) {
		perlin = clamp(perlin + ((noise - 0.5) * noise_strength), 0.0, 1.0);
	}

	float base_cutoff = 1.0 - cover;
	vec4 color = vec4(0.0);

	if (shadow) {
		// Shadows only where cloud exists
		if (perlin < base_cutoff) {
			color = vec4(0.0);
		} else {
			color = vec4(0.0, 0.0, 0.0, cloud_shadow_darkness * cloud_alpha);
		}
	} else {
		ivec2 palette_size = textureSize(palette, 0);

		float last_cutoff = base_cutoff;
		for (int column = 0; column < palette_size.x; column++) {
			float cutoff;
			float animation_factor = 0.0;

			if (palette_size.y > 1) {
				vec4 spec = get_colour(palette, palette_size, column, 1);
				cutoff = base_cutoff + ((1.0-base_cutoff) * spec.r);
				if (column == palette_size.x - 1) {
					cutoff = 1.0;
				}
				animation_factor = spec.g;
				if (animation_factor > 0.0) {
					cutoff = cutoff + sin(TIME)/(512.0 * (1.0 - animation_factor));
				}
			} else {
				cutoff = base_cutoff + (
					(1.0 - base_cutoff) / float(palette_size.x)
				) * float(column + 1);
			}

			if (perlin < base_cutoff) {
				color = vec4(0.0);
			} else if (perlin > last_cutoff && perlin <= cutoff) {
				// sample palette for cloud colour — use sample_uv for any texture lookups
				color = get_colour(palette, palette_size, column, 0);
				color.a = cloud_alpha;
			}
			last_cutoff = cutoff;
		}
	}

	// apply lighting (use same light calc as surface; pass sample_uv->calculate_light if needed)
	float light = calculate_light(sample_uv, radius);
	color.rgb = color.rgb * light;
	return color;
}


vec4 atmosphere(vec2 uv) {
	vec4 result = vec4(0.0);

	if (atmosphere_radius <= surface_radius) {
		return result;
	}

	ivec2 palette_size = textureSize(atmosphere_palette, 0);
	float atmosphere_thickness = (atmosphere_radius - surface_radius);
	float atmos_layer_thickness = atmosphere_thickness / float(palette_size.x);

	for (int column = palette_size.x - 1; column >= 0; column--) {
		float radius = surface_radius + (
			atmos_layer_thickness * float(column + 1)
		);
		float w = calculate_z(uv, radius);

		if (w < 1.0) {
			float light = calculate_light(uv, radius);
			result = get_colour(atmosphere_palette, palette_size, column, 0);
			result.rgb = result.rgb * light;
		}
	}
	return result;
}
vec2 rotated_spherical_uv(mat3 rot_p, vec2 uv, float radius) {
    // convert 2D UV to 3D direction on unit sphere
    vec2 normalized_uv = (uv - vec2(0.5)) / radius;
    float portal = dot(normalized_uv, normalized_uv);
    if (portal > 1.0) {
        return vec2(-1.0); // outside sphere sentinel
    }
    float y = sqrt(max(0.0, 1.0 - portal));
    vec3 dir = vec3(normalized_uv.x, y, normalized_uv.y);

    // rotate the 3D direction with the provided rotation matrix
    vec3 rdir = normalize(rot_p * dir);

    // convert rotated direction to lon/lat -> equirectangular uv
    float lon = atan(rdir.z, rdir.x);
    float lat = asin(clamp(rdir.y, -1.0, 1.0));

    float u_s = 0.5 + lon / (2.0 * PI);
    float v_s = 0.5 - lat / PI;
    u_s = fract(u_s);
    return vec2(u_s, v_s);
}
void fragment() {
	// Put the UV on a pixel grid.
	vec2 grid_uv = calculate_grid_uv(UV);

	mat3 user_rot = rotate_z(surface_rotation_z) * rotate_x(surface_rotation_x);

	// constant pre-rotation: rotate the whole result so the originally-centered north pole
	// maps to the equator in view (moves center to equator). Important: apply it on the left,
	// so it does not change how user_rot axes behave.
	mat3 pre_rot = rotate_x(-PI * 0.5) * rotate_z(PI * 0.5);

	// final rotation applied to the sphere-sampling direction
	mat3 rot_p = pre_rot * user_rot;
	// compute equirectangular UVs (rotated) for the two cloud layers
vec3 cloud1_rdir = rotated_direction(rot_p, grid_uv, cloud_1_radius);
vec3 cloud2_rdir = rotated_direction(rot_p, grid_uv, cloud_2_radius);





	// Surface rotation matrices (apply user_rot so they affect sampling & noise)
	mat3 srot = user_rot * generate_rotation_matrix(
		surface_base_rotation + (TIME * surface_rotation_speed)
	);
	mat3 cloud_rot = mat3(1.0f);
	vec4 color = surface(grid_uv, rot_p);
	vec4 clouds_1_shadows = vec4(0.0);
	vec4 clouds_1 = vec4(0.0);

// shadows
if (cloud_1_cover > 0.0) {
    mat3 crot1 = mat3(1.0); // local cloud rotation handled inside clouds() via rot_0
    if (display_cloud_shadows) {
        clouds_1_shadows = clouds(
            cloud_1_cover,
            cloud1_rdir,
            cloud_1_period,
            cloud_1_cell_amount,
            cloud_1_secondary_period,
            cloud_1_secondary_cell_amount,
            cloud_1_secondary_strength,
            surface_radius,
            cloud_1_palette,
            cloud_1_fluctuation_speed,
            true
        );
    }
    clouds_1 = clouds(
        cloud_1_cover,
        cloud1_rdir,
        cloud_1_period,
        cloud_1_cell_amount,
        cloud_1_secondary_period,
        cloud_1_secondary_cell_amount,
        cloud_1_secondary_strength,
        surface_radius,
        cloud_1_palette,
        cloud_1_fluctuation_speed,
        false
    );
}

	vec4 clouds_2_shadows = vec4(0.0);
	vec4 clouds_2 = vec4(0.0);if (cloud_2_cover > 0.0) {
    if (display_cloud_shadows) {
        clouds_2_shadows = clouds(
            cloud_2_cover,
            cloud2_rdir,
            cloud_2_period,
            cloud_2_cell_amount,
            cloud_2_secondary_period,
            cloud_2_secondary_cell_amount,
            cloud_2_secondary_strength,
            surface_radius,
            cloud_2_palette,
            cloud_2_fluctuation_speed,
            true
        );
    }
    clouds_2 = clouds(
        cloud_2_cover,
        cloud2_rdir,
        cloud_2_period,
        cloud_2_cell_amount,
        cloud_2_secondary_period,
        cloud_2_secondary_cell_amount,
        cloud_2_secondary_strength,
        surface_radius,
        cloud_2_palette,
        cloud_2_fluctuation_speed,
        false
    );
}

	COLOR = vec4(0., 0., 0., 0.);

	COLOR.rgba = atmosphere(grid_uv);
	if (color.a > 0.0) {
		COLOR.rgba = color.rgba; // draw the world

		// Darken for the cloud shadows.
		// - clouds_2_shadows apply normally (shadow where mask exists)
		// - clouds_1_shadows are only applied where clouds_2 exists (masking)
		if (display_cloud_shadows) {
			// apply clouds_2 shadows
			//COLOR.rgb = COLOR.rgb * (1.0 - clouds_2_shadows.a);
			// apply clouds_1 shadows only where clouds_2 is present (using clouds_2.a as mask)
			COLOR.rgb = COLOR.rgb * (1.0 - (clouds_1_shadows.a * clouds_2.a));
		}
	}

	// Add the clouds
	// New behaviour: clouds_2 acts as a mask for clouds_1.
	// Only display clouds_1 where clouds_2 is present.
	// If clouds_2 is disabled (cover == 0), clouds_1 is drawn as before.
		// Compute mask (use clouds_2 as mask if present)
	float mask = 1.0;
	if (cloud_2_cover > 0.0) {
		// clouds_2.a is the per-pixel mask strength (0..1)
		mask = clouds_2.a;
		// apply clouds_2 shadows normally
		if (display_cloud_shadows) {
			COLOR.rgb = COLOR.rgb * (1.0 - clouds_2_shadows.a);
		}
	}

	// apply clouds_1 shadows only where mask is >0
	if (display_cloud_shadows) {
		COLOR.rgb = COLOR.rgb * (1.0 - (clouds_1_shadows.a * mask));
	}

	// Mask clouds_1 by mask value; result alpha = clouds_1.a * mask
	vec4 masked_clouds_1 = vec4(clouds_1.rgb, clouds_1.a * mask);

	// Standard "over" composite: out = src*src.a + dst*(1-src.a)
	if (masked_clouds_1.a > 0.0) {
		COLOR.rgb = masked_clouds_1.rgb * masked_clouds_1.a + COLOR.rgb * (1.0 - masked_clouds_1.a);
		// keep alpha conservative (optional)
		COLOR.a = max(COLOR.a, masked_clouds_1.a);
	}

	// Note: clouds_2 is only used as mask. If you want clouds_2 visible too, composite it similarly.

	// NOTE: we no longer draw clouds_2 separately; it is only used as a mask for clouds_1.

	// Posterise
	if (posterise) {
		COLOR.rgb = get_nearest_colour(posterisation_palette, COLOR.rgb);
	}
}

// Given the final rotation matrix (rot_p) and the "screen" uv (0..1),
// return the equirectangular / texture UV (u_s, v_s) that corresponds to the
// rotated direction on the sphere. This duplicates the logic in surface(),
// but is separated for reuse by clouds.


