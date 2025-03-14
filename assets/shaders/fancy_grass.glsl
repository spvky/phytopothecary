
#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
// Time
uniform float time;
// Speed of the wind
uniform float wind_speed = 0.05;
// How strong the wind is
uniform float wind_strength = 2.0;
// How big, in world space, is the noise texture
// wind will tile every wind_texture_tile_size
uniform float wind_texture_tile_size = 20.0;
uniform float wind_vertical_strength = 0.3;
// Which way the wind is blowing
uniform vec2 wind_horizontal_direction = vec2(1.0, 0.5);
// Where is the character standing
uniform vec3 character_position;
// Characters push radius
uniform float character_radius = 3.0;
// how hard does the character push the grass away
uniform float character_push_strength = 1.0;
uniform sampler2D diffuse;
uniform sampler2D wind_noise;
uniform sampler2D character_distance_falloff_curve;



out vec2 fragTexCoord;
out vec4 fragColor;

void main()
{
		vec3 world_vert = (mvp4 * vec4(vertex_position, 1.0));
		vec2 normalized_wind_direction = normalize(wind_horizontal_direction);



    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    gl_Position = mvp*vec4(newPosition, 1.0);
}
