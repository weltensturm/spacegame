module game.system.bulletWorld;

import
	std.file,
	core.thread,
	ws.physics.bullet.cbullet,
	ws.physics.bullet.object,
	ws.physics.bullet.shape,
	ws.log,
	ws.list,
	ws.time,
	ws.math,
	game.entity.entity,
	game.component.bulletPhysics,
	game.component.transform,
	gui.engine;


__gshared:


class BulletWorld {

	ws.physics.bullet.cbullet.BulletWorld* world;
	protected {
		Shape[string] shapes;
		BulletObject[] objects;
		EntityManager ents;
		bool isRunning = true;
		double last;
	}

	double tickrate = 60;

	this(EntityManager ents){
		this.ents = ents;
		world = createWorld();
	}

	void shutdown(){
		isRunning = false;
	}

	BulletObject createObject(string path){
		Shape shape;
		if(path in shapes)
			shape = shapes[path];
		else{
			shape = new Shape(path);
			shapes[path] = shape;
		}
		auto o = new BulletObject(world, shape);
		o.finish();
		objects ~= o;
		return o;
	}
	

	void destroy(){
		destroyWorld(world);
	}
	
	void loop(){
		try {
			last = ws.time.time.now();
			while(isRunning){
				double now = time.now();
				Vector!3[Transform] positions;
				Quaternion[Transform] angles;
				foreach(bullet, transform; ents.iterate!(BulletPhysics,Transform)){
					if(bullet.object){
						bullet.object.setPos(transform.position);
						bullet.object.setAngle(transform.angle);
						positions[transform] = transform.position;
						angles[transform] = transform.angle;

					}
				}
				tickWorld(world, now - last);
				foreach(bullet, transform; ents.iterate!(BulletPhysics,Transform)){
					if(bullet.object){
						if(transform in positions && positions[transform] == transform.position)
							transform.position = bullet.object.getPos();
						if(transform in angles && angles[transform] == transform.angle)
							transform.angle = bullet.object.getAngle();
					}
				}
				ws.time.time.sleep(clamp(tickrate - (ws.time.time.now() - last), 0.0, 1.0/tickrate));
				last = now;
			}
		}catch(Throwable t)
			Log.error(t.toString());
	}

	auto trace(float[3] start, float[3] end){
		start[] *= 2;
		end[] *= 2;
		auto res = ws.physics.bullet.cbullet.trace(world, start[0], start[1], start[2], end[0], end[1], end[2]);
		auto object = res.object ? cast(BulletObject)getUserPointer(res.object) : null;
		foreach(o; objects)
			if(o == object)
				return Trace(o, res.distance, [res.x, res.y, res.z]);
		return Trace(null, res.distance, [res.x/2, res.y/2, res.z/2]);
	}

	struct Trace {
		BulletObject object;
		float distance;
		float[3] pos;
	}

}
