module game.system.noclip;


import
	game.entity.entity,
	game.system.system;


class NoclipSystem: System {
	
	Entity list;
	
	void tick(float frameTime){
		foreach(entity; list){
			noclip = entity.get!Noclip;
			transform = entity.get!Transform;
			noclip.velocity -= ((
				noclip.velocity - (
					transform.angle.right*noclip.velocityTarget[0]
					+ transform.angle.up*noclip.velocityTarget[1]
					+ transform.angle.forward*noclip.velocityTarget[2]
				)
			) * frameTime * acceleration);
			transform.position += noclip.velocity*frameTime;
		}
	}

}
