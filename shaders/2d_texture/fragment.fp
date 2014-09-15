
#version 130

uniform sampler2D Image;
uniform vec4 Color;

out vec4 vFragColor;

smooth in vec2 vVaryingTexCoord;

void main(void){
	vec4 color = texture(Image, vVaryingTexCoord);
	if(color.a < 0.01) discard;
	vFragColor = color * Color;
}

