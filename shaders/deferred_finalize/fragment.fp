#version 130

uniform sampler2D mapDiffuse;
uniform sampler2D mapTexCoord;
uniform sampler2D mapNormal;
uniform sampler2D mapLightInfo;
uniform sampler2D mapLight;

uniform vec3 screen;

out vec4 col;

void main(){
	vec2 xy = gl_FragCoord.xy/screen.xy;
	vec4 light = texture(mapLight, xy);
	col = texture(mapDiffuse, xy);
	if(texture(mapLightInfo, xy).a > 0.01)
		col *= vec4(light.rgb*light.a, 1);
}
