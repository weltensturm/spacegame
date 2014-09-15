#version 130

uniform sampler2D Texture;

smooth in vec2 texCoords;

vec4 getTexColor(){
	return texture(Texture, texCoords);
}
