module game.physics.bulletPhysics;

import
	std.math,
	std.conv,
	std.file,
	ws.exception,
	ws.math.vector,
	ws.math.quaternion,
	ws.physics.bullet.object,
	game.physics.bulletWorld,
	game.component;


class BulletPhysics: Component {

	BulletObject object;

	void tick(double ft){}

}

