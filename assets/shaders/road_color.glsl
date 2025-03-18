#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 worldPosition;

// Input uniform values
uniform vec3 playerPos;

// Output fragment color
out vec4 finalColor;

// NOTE: Add your custom variables here

void main()
{
		finalColor = vec4(0.0,0.0,0.0,1.0);
		if (distance(worldPosition, playerPos) < 1.0) {
			finalColor = vec4(0.0,1.0 - distance(worldPosition, playerPos),0.0,1.0);
		}
}
