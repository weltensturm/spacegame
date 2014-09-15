
#version 130

uniform vec4 Color;

out vec4 vFragColor;

void main(void){
	if(Color.a < 0.01) discard;
	vFragColor = Color;
}
