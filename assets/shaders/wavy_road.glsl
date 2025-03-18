#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform float time;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 worldPosition;

void main()
{
		float sway = sin(time * 0.5) * sin(vertexPosition.z * 0.5);
		vec3 newPosition = vec3(vertexPosition.x + sway, vertexPosition.y, vertexPosition.z);
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
		worldPosition = newPosition;
    gl_Position = mvp*vec4(newPosition, 1.0);
}



