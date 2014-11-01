#version 130

uniform vec3 ambientColor;
uniform vec3 diffuseColor;
uniform vec3 specularColor;
uniform vec3 lightPosition;
uniform float lumen;

smooth in vec3 normalDir;
smooth in vec3 worldPos;

uniform mat4 matVi;


vec4 getSpecular(){

	vec3 varyingLightDir = normalize(lightPosition - worldPos);
	vec3 viewDirection = normalize(vec3(matVi * vec4(0.0, 0.0, 0.0, 1.0) - vec4(worldPos, 1)));

	float dist = distance(lightPosition, worldPos)*10;

	float diff = max(1/pow(dist/lumen+2, 2), dot(normalize(normalDir), normalize(varyingLightDir)))/pow(dist/lumen+1, 2);
	vec4 color = vec4((diff*diffuseColor), 1);

	if(diff != 0) {
		vec3 reflection = normalize(reflect(-normalize(varyingLightDir), normalize(normalDir)));
		float spec = pow(max(0.0, dot(reflection, viewDirection)), 128.0);
		color.rgb += specularColor.rgb*spec * color.rgb;
	}
	return color;
}

