module weapon.ballcannon;

import
	window,
	game.entity.entity,
	game.system.draw,
	game.system.bulletWorld,
	game.component.transform,
	game.component.bulletPhysics,
	game.component.drawable,
	weapon.base;


class BallCannon: Weapon {
	
	protected {
		EntityManager ents;
		BulletWorld bullet;
		Draw drawSystem;
		Entity owner;
	}

	this(EntityManager ents, Entity owner, Draw drawSystem, BulletWorld bullet){
		this.ents = ents;
		this.owner = owner;
		this.drawSystem = drawSystem;
		this.bullet = bullet;
		name = "Ball Cannon";
	}
	
	override
	void onPrimary(bool pressed){
		if(pressed){
			auto ent = ents.create!(Drawable,BulletPhysics,Transform);
			ent.get!Drawable.model = drawSystem.getModel("20cmsphere.obj");
			ent.get!BulletPhysics.object = bullet.createObject("20cmsphere_ph.obj");
			auto dir = owner.get!Transform.angle.forward;
			ent.get!Transform.position = owner.get!Transform.position + dir*2;
			ent.get!BulletPhysics.object.setVel(dir*200);
		}
	}

}

