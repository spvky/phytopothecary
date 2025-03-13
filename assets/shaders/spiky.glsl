#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform float time;
uniform sampler2D noise;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;


void main()
{
		vec2 noise_pos = vec2(vertexPosition.y, vertexPosition.z);
		float noise_value = texture2D(noise, noise_pos).r;
		float x_value = 0.0;
		if (abs(vertexPosition.y) > 0.5) {
			x_value = vertexPosition.x;
		} else {
			// x_value = vertexPosition.x + (sin(time * (vertexPosition.y * 30.0)) * 0.05);
			x_value = vertexPosition.x + sin(time) * sin(noise_value);
		}
		vec3 newPosition = vec3(x_value, vertexPosition.y, vertexPosition.z);
    // Send vertex attributes to fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    // Calculate final vertex position
    gl_Position = mvp*vec4(newPosition, 1.0);
}
