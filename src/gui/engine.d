module gui.engine;

import
	ws.gui.base,
	ws.gl.render,
	ws.time,
	gui.console,
	gui.weaponSelection,
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

	Screen screen;
	Vector!2 dragStart;
	WeaponSelection weaponSelection;
	Draw drawSystem;
	Render renderer;
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
	Camera camera;

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

		camera = new Camera;

		setTop(menu);

		ents = new EntityManager;
		physicsSystem = new BulletSystem;
		drawSystem = new Draw(window, ents, {return camera;});
		noclipSystem = new NoclipSystem(ents);
		lastRender = time.now();
		setCursor(Mouse.cursor.none);
		/+
		player = system.createPlayer();
		player = new Player(entityList, engine);
		player.setAngle(Quaternion.euler(0, 0, 45));
		player.setPos(Vector!3(0,-5,5));
		player.giveWeapon(new CubeCannon(engine));
		player.giveWeapon(new Creator(engine, this));
		+/
		//weaponSelection = add!WeaponSelection(this);

		//auto bulletDebug = new DebugDrawer(physicsSystem.world);
	}

	void tick(){
		physicsSystem.tick(frameTime);
		noclipSystem.tick(frameTime);

	}

	override void onDraw(){
		float currentTime = time.now();
		frameTime = (currentTime - lastRender).clamp!double(0, 1.0/60.0);
		lastRender = currentTime;
		drawSystem.draw();
		super.onDraw();
	}


	override void onResize(int x, int y){
		if (!y)
			y = 1;
		camera.aspect = cast(double)x/cast(double)y;
		weaponSelection.setPos(100, 100);
		weaponSelection.setSize(200, 100);
		menu.setSize(x, y);
		console.setSize(x, y);
	}

	double pow(double n, double e){
		int sign = (n > 0 ? 1 : -1);
		double pow = (n*sign)^^e;
		return pow*sign;
	}

	void onRawMouse(int x, int y){
		if(!hasFocus)
			return;
		controls.input(Mouse.X, x);
		controls.input(Mouse.Y, y);
		window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
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

