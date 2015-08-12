module game.entity.skybox;


import
	gui.engine,
	game.transform,
	game.graphics.drawable,
	game.entity.entity;

alias Skybox = Entity!(Drawable,Transform);

Skybox skybox(Engine engine){
	auto sky = new Skybox;
	sky.model = engine.perspective.renderPipeline.getModel("sky/skybox_sixface.obj");
	engine.ents.add(sky);
	return sky;
}
