module game.component.bulletPhysics;

import
	std.math,
	std.conv,
	std.file,
	ws.exception,
	ws.math.vector,
	ws.math.quaternion,
	ws.physics.bullet.object,
	game.system.bulletWorld,
	game.component.component;


class BulletPhysics: Component {

	BulletObject object;

}

