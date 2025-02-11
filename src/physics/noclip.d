module game.physics.noclip;


import
	ws.io,
	ws.time,
	ws.math,

	game.component,
	game.entity.entity,
	game.physics.noclip,
	game.transform;


class Noclip: Component {

	Vector!3 velocity;
	Vector!3 velocityTarget;
	float acceleration;

}



class NoclipSystem {
	
	protected {
		EntityManager ents;
		bool isRunning = true;
		double tickrate = 30;
		double last;
	}

	this(EntityManager ents){
		this.ents = ents;
	}
	
	void shutdown(){
		isRunning = false;
	}

	void loop(){
		last = time.now;
		while(isRunning){
			double now = ws.time.time.now();
			double frameTime = now - last;
			foreach(noclip, transform; ents.iterate!(Noclip,Transform)){
				noclip.velocity -= ((
					noclip.velocity - (
						transform.angle.right*noclip.velocityTarget[0]
						+ transform.angle.up*noclip.velocityTarget[1]
						+ transform.angle.forward*noclip.velocityTarget[2]
					)
				) * frameTime * noclip.acceleration);
				transform.position += noclip.velocity*frameTime;
			}
			time.sleep(clamp(tickrate - (ws.time.time.now() - last), 0.0, 1.0/tickrate));
			last = now;
		}
	}

}
