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
	gui.engine;


__gshared:


class BulletSystem: Thread {


	BulletWorld* world;
	protected {
		Shape[string] shapes;
		BulletObject[] objects;
		double last;
	}

	double tickrate = 30;

	this(){
		isDaemon = true;
		super(&loop);
		//objects = new List!Physics;
		world = createWorld();
		//start();
	}


	BulletObject getPhysicsModel(string path){
		Shape shape;
		auto phpath = path[0..$-4] ~ "_ph.obj";
		if(phpath in shapes)
			shape = shapes[phpath];
		else{
			if(exists("models/" ~ phpath))
				shape = new Shape(phpath);
			else{
				shape = new Shape(path);
				Log.warning("Using view model as physics model for " ~ path);
			}
			shapes[phpath] = shape;
		}
		auto o = new BulletObject(world, shape);
		o.finish();
		objects ~= o;
		return o;
	}
	

	void destroy(){
		destroyWorld(world);
	}
	
	void tick(float ft){
		tickWorld(world, ft);
	}

	void loop(){
		last = ws.time.time.now();
		while(isRunning){
			double now = ws.time.time.now();
			tickWorld(world, now - last);
			ws.time.time.sleep(clamp(tickrate - (ws.time.time.now() - last), 0.0, 1.0/tickrate));
			last = now;
		}
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
