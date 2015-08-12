#version 130

uniform sampler2D diffuse;
uniform vec3 diffuseColor;

in vec2 passTexCoord;

vec4 calcDiffuse(){
	return texture(diffuse, passTexCoord)*vec4(diffuseColor,1);
}
