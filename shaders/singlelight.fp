#version 130

uniform vec3 ambientColor;
uniform vec3 diffuseColor;
uniform vec3 specularColor;
uniform vec3 lightPosition;
uniform float lumen;

smooth in vec3 varyingNormal;
smooth in vec3 worldPos;

vec4 getSpecular(){

	vec3 varyingLightDir = normalize(lightPosition - worldPos);

	float dist = distance(lightPosition, worldPos)*10;

	float diff = max(1/pow(dist/lumen+2, 2), dot(normalize(varyingNormal),
			normalize(varyingLightDir)))/pow(dist/lumen+1, 2);
	vec4 color = vec4((diff*diffuseColor), 1);

	if(diff != 0) {
		vec3 reflection = normalize(reflect(-normalize(varyingLightDir),
				normalize(varyingNormal)));
		float spec = pow(max(0.0, dot(normalize(varyingNormal), reflection)),
				128.0);
		color.rgb += specularColor.rgb*spec * color.rgb;
	}
	return color;
}

