module weapon.ballcannon;

import
	window,
	game.entity.entity,
	weapon.base;


class BallCannon: Weapon {
	
	protected {
		Window window;
		EntityManager ents;
	}

	this(Window w, EntityManager e){
		window = w;
		ents = e;
		name = "Ball Cannon";
	}
	
	override
	void onPrimary(bool pressed){
		if(pressed){
			auto obj = ents.create("Sphere");
			auto dir = owner.aimDir();
			obj.physics.position = owner.position + dir*2;
			obj.physics.velocity = dir*200;
		}
	}

}

