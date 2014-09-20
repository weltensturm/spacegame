module game.system.noclip;


import
	game.entity.entity,
	game.component.noclip,
	game.component.transform,
	game.system.system;


class NoclipSystem: System {
	
	EntityManager ents;

	this(EntityManager ents){
		this.ents = ents;
	}
	
	void tick(float frameTime){
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
	}

}
