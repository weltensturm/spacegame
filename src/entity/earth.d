module game.entity.earth;


import
	gui.engine,
	game.physics.gravity,
	game.physics.bulletPhysics,
	game.radius,
	game.transform,
	game.graphics.drawable,
	game.entity.entity;


alias Earth = Entity!(Drawable,BulletPhysics,Transform,Mass,Radius);


Earth earth(Engine engine){
	auto earth = new Earth;
	earth.model = engine.perspective.renderPipeline.getModel("planets/earth.obj");
	earth.object = engine.physicsSystem.createObject("planets/earth.obj");
	earth.object = engine.physicsSystem.createObject("maps/sponza_ph.obj");
	earth.radius = 6371;
	return earth;
}
