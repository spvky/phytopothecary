#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform float time;
uniform float wind_speed = 0.05;
uniform float wind_strength = 2.0;
uniform float wind_texture_tile_size = 20.0;
uniform float wind_vertical_strength = 0.3;
uniform sampler2D noise;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

vec2 wind_horizontal_direction = vec2(1.0, 0.5);


void main()
{
		vec2 normalized_wind_direction = normalize(wind_horizontal_direction);
		vec2 noise_pos = vec2(vertexTexCoord.x, vertexTexCoord.y);
		float noise_value = texture2D(noise, noise_pos).r;
		float y_value = (sin(vertexPosition.x) * 0.5) + (sin(vertexPosition.z) * 0.5);

		vec3 newPosition = vec3(vertexPosition.x, y_value, vertexPosition.z);
		
		vec4 newColor = vec4(vertexColor.x - y_value, vertexColor.y - y_value, vertexColor.z - y_value, 1);

    fragTexCoord = vertexTexCoord;
    fragColor = newColor;

    // Calculate final vertex position
    gl_Position = mvp*vec4(newPosition, 1.0);
}



