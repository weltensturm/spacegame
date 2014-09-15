module game.system.bulletPhysics;

import
	std.math,
	std.conv,
	std.file,
	ws.exception,
	ws.math.vector,
	ws.math.quaternion,
	ws.physics.bullet.object,
	game.component.component;


class BulletPhysics: Component {
		
	BulletObject physObject;

	@property
	Vector!3 position(){
		return physObject.getPos();
	}

	@property
	void position(Vector!3 p){
		physObject.setPos(p);
	}

	@property
	void velocity(Vector!3 v){
		physObject.setVel(v);
	}

	@property
	Vector!3 velocity(){
		return physObject.getVel();
	}

	@property
	Quaternion angle(){
		return physObject.getAngle();
	}
	
	@property
	void angle(Quaternion a){
		physObject.setAngle(a);
	}

	@property
	void mass(double m){
		physObject.setMass(m);
	}

	@property
	double mass(){
		return physObject.getMass();
	}

	void applyForce(Vector!3 v){
		physObject.applyForce(v);
	}

	void tick(float frameTime){}

	void setModel(string path){
		super.setModel(path);
		if(exists("models/" ~ path)){
			if(physObject)
				physObject.destroy();
			physObject = entityList.resourceLoader.getPhysicsModel(path);
		}else
			exception("Physics entity: \"" ~ path ~ "\" does not exist");
	}

	void onRemove(){
		if(physObject)
			physObject.destroy();
	}

}



