module game.graphics.bulletDebug;

import
	ws.math,
	ws.gl.gl,
	ws.gl.batch,
	ws.gl.shader,
	ws.physics.bullet.cbullet,
	game.graphics.draw,
	game.graphics.drawable;


extern(C) static void lineCallback(void* userdata, btScalar* from, btScalar* to, btScalar* color){
	auto drawer = cast(BulletDebugDrawer)userdata;
	drawer.shader.use(
		"matMVP", drawer.mvp,
		"offset", Vector!4(from[0], from[1], from[2], 1),
		"color", Vector!4(color[0], color[1], color[2], 1),
		"scale", Vector!4(to[0]-from[0], to[1]-from[1], to[2]-from[2], 1)
	);
	drawer.batch.draw();
}


class BulletDebugDrawer: Drawable {
	
	this(BulletWorld* world){
		this.world = world;
		drawer = createDebugDrawer(world, cast(void*)this, &lineCallback);
		mvp = new Matrix!(4,4);
		batch = new Batch;
		batch.begin(2, gl.lines);
		batch.add([0,0,0]);
		batch.add([1,1,1]);
		batch.finish();
		shader = Shader.load("3d_line", [gl.attributeVertex: "vertex"]);
	}

	void draw(ModelMatrix matrix){
		//mvp = matrix.getModelviewProjection();
		debugDrawWorld(world);
	}

	Matrix!(4,4) mvp;
	Shader shader;
	Batch batch;
	BulletWorld* world;
	ws.physics.bullet.cbullet.DebugDrawer* drawer;

}
