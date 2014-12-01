#version 130

uniform sampler2D diffuse;

in vec2 passTexCoord;

vec4 calcDiffuse(){
	return texture(diffuse, passTexCoord);
}
