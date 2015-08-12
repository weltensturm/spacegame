module gui.engine;

import
	std.parallelism,
	std.datetime,
	std.conv,

	ws.math,
	ws.gui.base,
	ws.gl.render,
	ws.gl.model,
	ws.time,
	ws.io,

	gui.console,
	gui.menu.menu,
	gui.worldPerspective,

	game.editor.editor,
	game.entity.player,
	game.entity.entity,
	game.entity.earth,
	game.entity.skybox,
	game.physics.bulletWorld,
	game.physics.gravity,
	game.physics.humanMovement,
	game.physics.noclip,
	game.physics.bulletPhysics,
	game.graphics.draw,
	game.graphics.drawable,
	game.graphics.lightGlobal,
	game.transform,
	game.input,
	game.commands,

	window,
	lua;


__gshared:


class Engine: Base {

	BulletWorld physicsSystem;
	NoclipSystem noclipSystem;
	GravitySystem gravitySystem;
	HumanMovementSystem moveSystem;
	EntityManager ents;
	Console console;
	Lua lua;
	Input input;
	Commands commands;
	Menu menu;
	Window window;
	Editor editor;
	WorldPerspective perspective;

	this(Window window){
		this.window = window;
		lua = new Lua();

		commands = new Commands();
		commands.add("exit", &window.hide);
		input = new Input("config/controls.ws", commands);
		input.load();

		console = addNew!Console(commands, lua);
		console.hide();
		menu = addNew!Menu(commands, this);
		lua.runFile("scripts/autorun.lua");

		setTop(menu);

		ents = new EntityManager;

		physicsSystem = new BulletWorld(ents);
		task(&physicsSystem.loop).executeInNewThread();
 
		noclipSystem = new NoclipSystem(ents);
		task(&noclipSystem.loop).executeInNewThread();

		moveSystem = new HumanMovementSystem(ents);
		physicsSystem.preTick ~= &moveSystem.tick;
		
		//gravitySystem = new GravitySystem(ents);
		//physicsSystem.preTick ~= &gravitySystem.tick;

		setCursor(Mouse.cursor.none);

		auto localPlayer = this.createPlayer;

		perspective = addNew!WorldPerspective(window, ents, commands, localPlayer);

		this.playerWeapons(localPlayer);

		editor = addNew!Editor(perspective, perspective.renderPipeline.render, ents, commands);
		editor.hide;
		commands.add("toggle_editor", {
			editor.hidden ? editor.show : editor.hide;
		});

		auto map = new Entity!(Drawable,Transform,BulletPhysics);
		map.model = perspective.renderPipeline.getModel("maps/plate.obj");
		map.object = physicsSystem.createObject("maps/plate.obj");
		map.object.setMass(0);
		ents.add(map);

		skybox(this);

		auto light = new Entity!(Transform,LightGlobal);
		light.position = Vector!3(1000,0,1000);
		ents.add(light);

		/+
		auto box = new Entity!(Drawable,Transform);
		box.model = perspective.renderPipeline.getModel("sky/skybox_outerbox.obj");
		ents.add(box);
		+/

		/+
		auto sponza = new Entity!(Drawable,Transform,BulletPhysics);
		sponza.get!Drawable.model = perspective.renderPipeline.getModel("maps/sponza.obj");
		sponza.get!BulletPhysics.object = physicsSystem.createObject("maps/sponza_ph.obj");
		sponza.get!BulletPhysics.object.setMass(0);
		ents.add(sponza);
		+/
		
		//earth(this);

		//auto bulletDebug = new DebugDrawer(physicsSystem.world);
	}


	override void hide(){
		perspective.renderPipeline.shutdown;
		physicsSystem.shutdown;
		noclipSystem.shutdown;
		moveSystem.shutdown;
	}


	override void resize(int[2] size){
		menu.resize(size);
		console.resize([size.w, size.h/2]);
		console.move([0, size.h/2]);
		perspective.resize(size);
		editor.resize(size);
		super.resize(size);
	}


	void onRawMouse(int x, int y){
		if(x && window.keyboardFocus)
			input.input(Mouse.X, x);
		if(y && window.keyboardFocus)
			input.input(Mouse.Y, y);
	}


	override void onKeyboard(Keyboard.key key, bool pressed){
		input.keyPress(key, pressed);
		super.onKeyboard(key, pressed);
	}


	override void onMouseButton(Mouse.button b, bool p, int x, int y){
		input.keyPress(5000+b, p);
		super.onMouseButton(b, p, x, y);
	}

}
