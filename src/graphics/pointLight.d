module game.graphics.pointLight;

import game.component;


class PointLight: Component {
	
	float attenuationConstant = 0;
	float attenuationLinear = 0.001;
	float attenuationExp = 0.0000001;
	
	float[3] color = [1,1,1];
	float ambientIntensity = 0;
	float diffuseIntensity = 1;

}
