module game.component.pointLight;

import game.component.component;


class PointLight: Component {
	
	float attenuationConstant;
	float attenuationLinear;
	float attenuationExp;
	
    float[3] color;
    float ambientIntensity;
    float diffuseIntensity;

}
