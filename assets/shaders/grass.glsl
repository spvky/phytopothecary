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
		float noise_value = texture2D(noise, vertexTexCoord).r;
		float y_value = (sin(vertexPosition.x) * 0.5) + (sin(vertexPosition.z) * 0.5);
		float height = sin(time * (noise_value * 0.5));

		vec3 newPosition = vec3(vertexPosition.x, height, vertexPosition.z);
		
		vec4 newColor = vec4(vertexColor.x - y_value, vertexColor.y - y_value, vertexColor.z - y_value, 1);

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    gl_Position = mvp*vec4(newPosition, 1.0);
}



