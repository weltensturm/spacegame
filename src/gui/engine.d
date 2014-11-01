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

	weapon.ballcannon,

	editor.editor,

	game.entity.entity,
	game.system.bulletWorld,
	game.system.noclip,
	game.component.drawable,
	game.component.transform,
	game.component.bulletPhysics,
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

	BulletWorld physicsSystem;
	NoclipSystem noclipSystem;
	EntityManager ents;
	Console console;
	Lua lua;
	Controls controls;
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
		controls = new Controls("config/controls.ws", commands);
		controls.load();

		console = add!Console(commands, lua);
		console.hide();
		menu = add!Menu(commands, this);
		lua.runFile("scripts/autorun.lua");

		setTop(menu);

		ents = new EntityManager;

		physicsSystem = new BulletWorld(ents);
		task(&physicsSystem.loop).executeInNewThread();

		noclipSystem = new NoclipSystem(ents);
		task(&noclipSystem.loop).executeInNewThread();

		setCursor(Mouse.cursor.none);

		auto localPlayer = createPlayer;

		perspective = add!WorldPerspective(window, ents, commands, localPlayer);

		addWeapons(localPlayer);

		editor = add!Editor(perspective, perspective.drawSystem.render, commands);
		editor.hide;
		commands.add("toggle_editor", {
			editor.hidden ? editor.show : editor.hide;
		});

		/+
		auto sponza = ents.create!(Drawable,Transform,BulletPhysics);
		sponza.get!Drawable.model = new Model("maps/sponza.obj");
		sponza.get!BulletPhysics.object = physicsSystem.createObject("maps/sponza_ph.obj");
		sponza.get!BulletPhysics.object.setMass(0);
		+/

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


	void addWeapons(Entity player){
		auto weapons = player.get!Weapons;
		weapons.weapons ~= new BallCannon(ents, player, perspective.drawSystem, physicsSystem);
	}


	Entity createPlayer(){
		auto player = ents.create!(Projection, Noclip, Transform, Weapons);

		auto transform = player.get!Transform;
		auto movement = player.get!Noclip;
		auto weapons = player.get!Weapons;
		movement.acceleration = 5;

		commands.add("look_x", (float x){
			if(!perspective.hasFocus)
				return;
			transform.angle.rotate(pow(-x, 1.1)/5, 0, 0, 1);
			//window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});

		commands.add("look_y", (float y){
			if(!perspective.hasFocus)
				return;
			transform.angle.rotate(pow(-y, 1.1)/5, transform.angle.right());
			//window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});

		commands.add("move_x", (float x){
			if(!perspective.hasFocus)
				return;
			movement.velocityTarget[0] = x*10;
		});

		commands.add("move_y", (float y){
			if(!perspective.hasFocus)
				return;
			movement.velocityTarget[2] = y*10;
		});

		commands.add("move_z", (float z){
			if(!perspective.hasFocus)
				return;
			movement.velocityTarget[1] = z*10;
		});

		commands.add("weapon_next", {
			if(!perspective.hasFocus)
				return;
			weapons.active++;
			if(weapons.active >= weapons.weapons.length){
				weapons.active = 0;
			}
			perspective.weaponSelection.update;
		});

		commands.add("weapon_previous", {
			if(!perspective.hasFocus)
				return;
			weapons.active--;
			if(weapons.active < 0)
				weapons.active = cast(int)weapons.weapons.length-1;
			perspective.weaponSelection.update;
		});

		commands.add("weapon_fire", (bool b){
			if(!perspective.hasFocus)
				return;
			if(!weapons.weapons.length)
				return;
			weapons.weapons[weapons.active].onPrimary(b);
		});

        commands.add("weapon_fire_alt", (bool b){
                if(!perspective.hasFocus)
                        return;
                if(!weapons.weapons.length)
                        return;
                weapons.weapons[weapons.active].onSecondary(b);
        });

		return player;
	}


	override void onResize(int x, int y){
		menu.setSize(x, y);
		console.setSize(x, y);
		perspective.setSize(x, y);
		editor.setSize(x, y);
	}


	void onRawMouse(int x, int y){
		if(x)
			controls.input(Mouse.X, x);
		if(y)
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
