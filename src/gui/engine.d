module gui.engine;

import
	ws.gui.base,
	ws.gl.render,
	ws.time,
	ws.io,
	gui.console,
	game.entity.entity,
	game.system.bulletWorld,
	game.system.noclip,
	game.component.camera,
	game.system.draw,
	ws.math,
	game.controls,
	game.commands,
	gui.menu.menu,
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
	float lastRender, frameTime;
	Window window;

	this(Window window){
		this.window = window;
		lua = new Lua();

		commands = new Commands();
		controls = new Controls("config/controls.ws", commands);

		console = add!Console(commands, lua);
		console.hide();
		menu = add!Menu(commands, this);
		controls.load();
		lua.runFile("scripts/autorun.lua");

		setTop(menu);

		ents = new EntityManager;
		physicsSystem = new BulletSystem;
		noclipSystem = new NoclipSystem(ents);
		lastRender = time.now();
		setCursor(Mouse.cursor.none);

		commands.add("exit", &window.hide);
		/+
		player = system.createPlayer();
		player = new Player(entityList, engine);
		player.setAngle(Quaternion.euler(0, 0, 45));
		player.setPos(Vector!3(0,-5,5));
		player.giveWeapon(new CubeCannon(engine));
		player.giveWeapon(new Creator(engine, this));
		+/

		//auto bulletDebug = new DebugDrawer(physicsSystem.world);
	}

	void tick(){
		float currentTime = time.now();
		frameTime = (currentTime - lastRender).clamp!double(0, 1.0/60.0);
		lastRender = currentTime;
		physicsSystem.tick(frameTime);
		noclipSystem.tick(frameTime);
	}


	override void onResize(int x, int y){
		menu.setSize(x, y);
		console.setSize(x, y);
	}


	double pow(double n, double e){
		int sign = (n > 0 ? 1 : -1);
		double pow = (n*sign)^^e;
		return pow*sign;
	}


	override void onMouseMove(int x, int y){
		writeln(x, ' ', y);
		super.onMouseMove(x, y);
	}


	void onRawMouse(int x, int y){
		if(!hasFocus)
			return;
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

