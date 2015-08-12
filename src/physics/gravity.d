module game.physics.gravity;


import
	ws.math.math,
	game.entity.entity,
	game.component,
	game.transform,
	game.physics.bulletPhysics,
	game.radius,
	game.tickSystem;


class Mass: Component {
	float mass = 1;
}


class GravitySystem {
	
	EntityManager ents;

	this(EntityManager ents){
		this.ents = ents;
	}

	void tick(double ft){
		foreach(bullet, transform, gravity, radius; ents.iterate!(BulletPhysics,Transform,Mass,Radius)){
			foreach(bullet2, transform2; ents.iterate!(BulletPhysics,Transform)){
				if(bullet != bullet2){
					auto dist = transform.position.distance(transform2.position).max(radius.radius);
					auto dir = (transform.position-transform2.position).normal;
					auto force = dir*ft*10000000000/dist/dist;
					bullet2.object.applyForce(force*100);
				}
			}
		}
	}

}

