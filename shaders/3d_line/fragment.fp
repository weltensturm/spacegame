#version 130

uniform vec4 color;
out vec4 fragColor;

void main(){
	fragColor = color;
	gl_FragDepth = gl_FragCoord.z + log(gl_FragCoord.z) * 0.001;
}
