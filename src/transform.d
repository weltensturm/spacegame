module game.transform;


import
	ws.math,
	game.component;


class Transform: Component {

	Vector!3 position;
	Quaternion angle;

}


float[3] local(Transform tf, float[3] v){
	return [v[0]-tf.position.x, v[1]-tf.position.y, v[2]-tf.position.z];
}
