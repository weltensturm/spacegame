module gui.engine;

import
	ws.gui.base,
	gui.console,
	gui.weaponSelection,
	game.entity.entity,
	game.system.bulletPhysics,
	game.system.noclip,
	game.system.draw,
	ws.math;


__gshared:


class Engine: Base {

	Screen screen;
	Vector!2 dragStart;
	WeaponSelection weaponSelection;
	Draw drawSystem;
	BulletPhysics physicsSystem;
	NoclipSystem noclipSystem;
	EntityManager ents;
	Console console;

	this(Engine engine){

		spawnmenu = add!SpawnMenu(this);
		spawnmenu.hide();
		console = add!Console(this);
		console.hide();
		menu = add!Menu(this);
		controls.load();
		lua.runFile("scripts/autorun.lua");

		setTop(menu);
		onResize(w, h);

		this.engine = engine;
		draw = new Event!(WorldMatrix, Light, Material);
		matrix = new WorldMatrix;
		physics = new PhysicsWorld(this);
		drawer = new DebugDrawer(physics.world);
		noclipSystem = new NoclipSystem;
		ents = new EntityManager;
		lastRender = time.now();
		setCursor(Mouse.cursor.none);
		player = system.createPlayer();
		player = new Player(entityList, engine);
		player.setAngle(Quaternion.euler(0, 0, 45));
		player.setPos(Vector!3(0,-5,5));
		player.giveWeapon(new CubeCannon(engine));
		player.giveWeapon(new Creator(engine, this));
		weaponSelection = add!WeaponSelection(this);

	}

	void tick(){
		physicsSystem.tick(frameTime);
		noclipSystem.tick(frameTime);

	}

	override void onDraw(){
		if(!paused){
			currentTime = time.now();
			frameTime = (currentTime - lastRender).clamp!double(0, 1.0/60.0);
		}
		lastRender = currentTime;
		drawSystem.draw();
	}


	override void onResize(int x, int y){
		if (!y)
			y = 1;
		player.camera.aspect = cast(double)x/cast(double)y;
		weaponSelection.setPos(100, 100);
		weaponSelection.setSize(200, 100);
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
		engine.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
	}


	override void onKeyboard(Keyboard.key key, bool pressed){
		controls.keyPress("Player", key, pressed);
	}


}

