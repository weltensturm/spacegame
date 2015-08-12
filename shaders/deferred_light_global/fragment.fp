#version 130

uniform sampler2D mapDiffuse;
uniform sampler2D mapTexCoord;
uniform sampler2D mapNormal;
uniform sampler2D mapLightData;
uniform sampler2D mapDepth;

uniform vec3 screen;
uniform mat4 vpI;

uniform vec3 lightColor;
uniform float lightAmbient;
uniform float lightDiffuse;
uniform vec3 lightPosition;
uniform float specPower;
uniform float specIntensity;

out vec4 col;

vec3 worldPos(){
	vec4 clipSpaceLocation;
	vec2 screenPos = gl_FragCoord.xy/screen.xy;
	clipSpaceLocation.xy = screenPos * 2 - 1;
	clipSpaceLocation.z = texture(mapDepth, screenPos).x * 2 - 1;
	clipSpaceLocation.w = 1;
	vec4 res = vpI * clipSpaceLocation;
	return res.xyz/res.w;
}

vec4 calcLightInternal(vec3 dir, vec3 pos, vec3 normal){
	vec4 ambient = vec4(lightColor, 1.0) * lightAmbient;
	float diffFactor = dot(normal, -dir);
	vec4 diffuse  = vec4(0, 0, 0, 0);
	vec4 specular = vec4(0, 0, 0, 0);
	if(diffFactor > 0.0){
		vec3 eyePos = (vpI * vec4(0,0,0,1)).xyz;
		diffuse = vec4(lightColor, 1.0) * lightDiffuse * diffFactor;
		vec3 eyeDir = normalize(eyePos - pos);
		vec3 reflection = normalize(reflect(dir, normal));
		/*
		float specFactor = pow(max(0, dot(reflection, eyeDir)), 128.0);
		specFactor = pow(specFactor, specPower);
		if(specFactor > 0.0){
			specular = vec4(lightColor, 1.0) * specIntensity * specFactor;
		}
		*/
	}
	return diffuse + specular;
}

vec4 calcPointLight(vec3 pos, vec3 normal){
	return calcLightInternal(normalize(pos - lightPosition), pos, normal);
}


void main(){
	vec2 screenPos = gl_FragCoord.xy/screen.xy;
	if(texture(mapLightData, screenPos).a < 0.01){
		col = vec4(0,0,0,0);
		return;
	}
	vec3 normal = texture(mapNormal, screenPos).xyz;
	vec3 pos = worldPos();
	col = calcLightInternal(normalize(pos - lightPosition), pos, normal);
}
