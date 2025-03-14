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
uniform sampler2D check;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

void main()
{
		float noise_value = texture2D(noise, vertexTexCoord).r;
		//float height = sin(time * (noise_value * 10.0)) * 0.5;
		float height = noise_value + (sin(time * 20.0) * 0.02);
		float sway = height * sin(time);
		vec3 newPosition = vec3(vertexPosition.x + sway, height, vertexPosition.z);
		

    fragTexCoord = vertexTexCoord;

		//fragColor = vec4(0.0,1.0,0.0,1.0);

    fragColor = vertexColor;
    gl_Position = mvp*vec4(newPosition, 1.0);
}



