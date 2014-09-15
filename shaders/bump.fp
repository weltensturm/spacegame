#version 130

uniform sampler2D Bump;
uniform mat3 matN;

smooth in vec2 texCoords;
smooth in vec3 bumpLightDir;

vec4 getBump(){
    vec3 normal = texture2D(Bump, texCoords).rgb * 2.0 - 1;
    float diff = max(0.0, dot(normalize(normal), normalize(bumpLightDir)));
	return vec4(diff, diff, diff, 1);
}

