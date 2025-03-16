#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform float time;
uniform vec3 playerPos;
uniform sampler2D noise;
uniform sampler2D check;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

void main()
{
		bool near_player = distance(vertexPosition, playerPos) < 1.0;
		float noise_value = texture2D(noise, vertexTexCoord).r;
		//float height = sin(time * (noise_value * 10.0)) * 0.5;
		float height  = noise_value + (sin(time) * 0.02);
		float sway = height * sin(time);
		vec3 newPosition = vec3(vertexPosition.x + sway, height, vertexPosition.z);
		if (near_player) {
			vec3 target_direction = normalize(vertexPosition - playerPos);
			vec3 new_poinst = playerPos + target_direction;
			newPosition = new_poinst;
		}

		

    fragTexCoord = vertexTexCoord;

		//fragColor = vec4(0.0,1.0,0.0,1.0);

    fragColor = vertexColor;
    gl_Position = mvp*vec4(newPosition, 1.0);
}



