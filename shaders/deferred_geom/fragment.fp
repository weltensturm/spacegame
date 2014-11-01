
#version 130

in vec3 worldNormal;
in vec2 passTexCoord;

out vec4 outDiffuse;
out vec4 outTexCoord;
out vec4 outNormal;

uniform sampler2D texMap;

void main(){
    outDiffuse = texture(texMap, passTexCoord);
    outTexCoord = vec4(passTexCoord,0,1);
    outNormal = vec4(worldNormal,1);
}
