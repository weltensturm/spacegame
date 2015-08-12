module game.weapon.ballCannon;

import
	window,
	game.entity.entity,
	game.entity.player,
	game.graphics.draw,
	game.physics.bulletWorld,
	game.component,
	game.transform,
	game.physics.bulletPhysics,
	game.graphics.pointLight,
	game.graphics.drawable,
	weapon.base;


class BallCannon: Weapon {
	
	protected {
		EntityManager ents;
		BulletWorld bullet;
		RenderPipeline renderPipeline;
		Player owner;
	}

	this(EntityManager ents, Player owner, RenderPipeline renderPipeline, BulletWorld bullet){
		this.ents = ents;
		this.owner = owner;
		this.renderPipeline = renderPipeline;
		this.bullet = bullet;
		name = "Ball Cannon";
	}
	
	override
	void onPrimary(bool pressed){
		if(pressed){
			auto ent = new Entity!(Drawable,BulletPhysics,Transform,PointLight);
			ent.model = renderPipeline.getModel("20cmsphere.obj");
			ent.object = bullet.createObject("20cmsphere_ph.obj");
			ent.position = owner.position + owner.angle.forward*2;
			//ent.get!BulletPhysics.object.setVel(dir*200);

			ent.color = [1,1,1];
			ent.diffuseIntensity = 0.5;
			ent.attenuationConstant = 0;
			ent.attenuationLinear = 0.01;
			ent.attenuationExp = 0.0001;
			ents.add(ent);
		}
	}

}

