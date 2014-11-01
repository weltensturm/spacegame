#version 130

uniform sampler2D mapDiffuse;
uniform sampler2D mapTexCoord;
uniform sampler2D mapNormal;
uniform sampler2D mapDepth;

uniform vec3 screen;
uniform mat4 vpI;

uniform vec3 lightColor;
uniform float lightAmbient;
uniform float lightDiffuse;
uniform vec3 lightPosition;
uniform float attenConstant;
uniform float attenLinear;
uniform float attenExp;
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

/*
vec4 calcLightInternal(vec3 dir, vec3 pos, vec3 normal){
    vec4 ambient = vec4(lightColor, 1.0) * lightAmbient;
    float diffFactor = dot(normal, -dir);
    vec4 diffuse  = vec4(0, 0, 0, 0);
    vec4 specular = vec4(0, 0, 0, 0);
    if (diffFactor > 0.0) {
    	vec3 eyePos = (vpI * vec4(0,0,0,1)).xyz;
        diffuse = vec4(lightColor, 1.0) * lightDiffuse * diffFactor;
        vec3 eyeDir = normalize(eyePos - pos);
        vec3 reflection = normalize(reflect(dir, normal));
        float specFactor = dot(eyeDir, reflection);
        specFactor = pow(specFactor, specPower);
        if (specFactor > 0.0) {
            specular = vec4(lightColor, 1.0) * specIntensity * specFactor;
        }
    }
    return (ambient + diffuse + specular);
}

vec4 calcPointLight(vec3 pos, vec3 normal){
    vec3 dir = pos - lightPosition;
    float dist = length(dir);
    dir = normalize(dir);
    vec4 result = calcLightInternal(dir, pos, normal);
    float att =  attenConstant +
                         attenLinear * dist +
                         attenExp * dist * dist;
    att = max(1.0, att);
    return result;
    
    //return vec4(dist, dist, dist, dist)/10;
}
*/

float calcPointLight(vec3 pos, vec3 normal){
	vec3 dir = pos - lightPosition;
	float dist = length(dir);
	dir = normalize(dir);
	float diff = dot(normal, -dir);
	/*
	if(diff > 0){
		vec3 reflection = normalize(reflect(dir, normal));
		float spec = pow(max(0, dot(reflection, viewDir)), 128);
		diff += spec;
	}
	*/
    float att =  attenConstant +
                         attenLinear * dist +
                         attenExp * dist * dist;
	return diff/att;
}

void main(){
	vec2 screenPos = gl_FragCoord.xy/screen.xy;
	vec3 normal = texture(mapNormal, screenPos).xyz;
	float intensity = calcPointLight(worldPos(), normalize(normal));
    col = vec4(lightColor, intensity);
}
