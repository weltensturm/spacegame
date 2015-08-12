module game.physics.humanMovement;


import
	ws.math,
	ws.time,
	ws.log,
	game.entity.entity,
	game.component,
	game.physics.bulletPhysics,
	game.transform;


class HumanControls: Component {
	float[3] move = [0,0,0];
	float speed = 1;
	float accel;
}


class HumanMovementSystem {

	EntityManager ents;
	double last;
	bool isRunning = true;
	double tickrate = 60;

	this(EntityManager ents){
		this.ents = ents;
	}

	void loop(){
		try {
			last = ws.time.time.now();
			while(isRunning){
				double now = time.now();
				tick(now-last);
				ws.time.time.sleep(clamp(tickrate - (ws.time.time.now() - last), 0.0, 1.0/tickrate));
				last = now;
			}
		}catch(Throwable t)
			Log.error(t.toString());
	}

	void tick(double ft){
		foreach(bullet, transform, controls; ents.iterate!(BulletPhysics,Transform,HumanControls)){
			auto target = (
				transform.angle.right*controls.move[0]
				+transform.angle.up*controls.move[1]
				+transform.angle.forward*controls.move[2]
				);
			auto brake = bullet.object.getVel.vec*2;
			bullet.object.applyForce(target*controls.speed - brake);
		}
	}

	void shutdown(){
		isRunning = false;
	}

}

