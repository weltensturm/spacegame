module gui.engine;

import
	std.parallelism,

	ws.math,
	ws.gui.base,
	ws.gl.render,
	ws.gl.model,
	ws.time,
	ws.io,

	gui.console,
	gui.menu.menu,
	gui.worldPerspective,

	game.entity.entity,
	game.system.bulletWorld,
	game.system.noclip,
	game.component.drawable,
	game.component.transform,
	game.component.noclip,
	game.component.weapons,
	game.component.projection,
	game.system.draw,
	game.controls,
	game.commands,

	window,
	lua;


__gshared:


class Engine: Base {

	BulletSystem physicsSystem;
	NoclipSystem noclipSystem;
	EntityManager ents;
	Console console;
	Lua lua;
	Controls controls;
	Commands commands;
	Menu menu;
	Window window;
	WorldPerspective perspective;

	this(Window window){
		this.window = window;
		lua = new Lua();

		commands = new Commands();
		commands.add("exit", &window.hide);
		controls = new Controls("config/controls.ws", commands);
		controls.load();

		console = add!Console(commands, lua);
		console.hide();
		menu = add!Menu(commands, this);
		lua.runFile("scripts/autorun.lua");

		setTop(menu);

		ents = new EntityManager;

		physicsSystem = new BulletSystem;
		task(&physicsSystem.loop).executeInNewThread();

		noclipSystem = new NoclipSystem(ents);
		task(&noclipSystem.loop).executeInNewThread();

		setCursor(Mouse.cursor.none);

		auto localPlayer = createPlayer;

		perspective = add!WorldPerspective(window, ents, commands, localPlayer);

		auto sponza = ents.create!(Drawable,Transform);
		sponza.get!Drawable.model = perspective.drawSystem.getModel("maps/sponza.obj");


		//auto bulletDebug = new DebugDrawer(physicsSystem.world);
	}


	override void hide(){
		physicsSystem.shutdown();
		noclipSystem.shutdown();
	}


	double pow(double n, double e){
		int sign = (n > 0 ? 1 : -1);
		double pow = (n*sign)^^e;
		return pow*sign;
	}


	Entity createPlayer(){
		auto player = ents.create!(Projection, Noclip, Transform, Weapons);

		auto playerTransform = player.get!Transform;
		auto playerMovement = player.get!Noclip;
		playerMovement.acceleration = 1;

		commands.add("look_x", (float x){
			if(!perspective.hasFocus)
				return;
			playerTransform.angle.rotate(pow(-x, 1.1), 0, 0, 1);
			window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});

		commands.add("look_y", (float y){
			if(!perspective.hasFocus)
				return;
			playerTransform.angle.rotate(pow(-y, 1.1), playerTransform.angle.right());
			window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});

		commands.add("move_x", (float x){
			if(!perspective.hasFocus)
				return;
			playerMovement.velocityTarget[0] = x;
		});

		commands.add("move_y", (float y){
			if(!perspective.hasFocus)
				return;
			playerMovement.velocityTarget[1] = y;
		});

		return player;
	}


	override void onResize(int x, int y){
		menu.setSize(x, y);
		console.setSize(x, y);
		perspective.setSize(x, y);
	}


	void onRawMouse(int x, int y){
		controls.input(Mouse.X, x);
		controls.input(Mouse.Y, y);
	}


	override void onKeyboard(Keyboard.key key, bool pressed){
		controls.keyPress(key, pressed);
		super.onKeyboard(key, pressed);
	}


	override void onMouseButton(Mouse.button b, bool p, int x, int y){
		controls.keyPress(5000+b, p);
		super.onMouseButton(b, p, x, y);
	}


}
