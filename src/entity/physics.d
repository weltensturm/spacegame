module game.entity.physics;


import game.entity.entity,
	game.transform,
	game.physics.bulletPhysics;


void setPos(Entity!() ent, float[3] pos){
	synchronized(ent){
		ent.get!Transform.position = pos;
		ent.get!BulletPhysics.object.setPos(pos);
	}
}


