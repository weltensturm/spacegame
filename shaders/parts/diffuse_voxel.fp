#version 130

in vec4 passColor;

vec4 calcDiffuse(){
	return vec4(passColor.rgb, 1);
}

