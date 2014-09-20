module gui.worldPerspective;

import
	ws.gui.base,
	gui.weaponSelection,
	game.component.camera,
	game.system.draw,
	game.entity.entity,
	game.commands,
	window;


__gshared:


class WorldPerspective: Base {

	WeaponSelection weaponSelection;
	Draw drawSystem;
	Camera camera;

	private Window window;

	this(Window window, EntityManager ents, Commands commands){
		this.window = window;
		camera = new Camera;
		drawSystem = new Draw(window, ents, {return camera;});
		//weaponSelection = new WeaponSelection;
		setCursor(Mouse.cursor.none);

		commands.add("look_x", (float x){
			camera.angle.rotate(pow(-x/10, 1.1), 0, 0, 1);
			window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});

		commands.add("look_y", (float y){
			camera.angle.rotate(pow(-y/10, 1.1), camera.angle.right());
			window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
		});
	}

	double pow(double n, double e){
		int sign = (n > 0 ? 1 : -1);
		double pow = (n*sign)^^e;
		return pow*sign;
	}

	override void onDraw(){
		drawSystem.draw();
	}


	override void onResize(int x, int y){
		if (!y)
			y = 1;
		camera.aspect = cast(double)x/cast(double)y;
		//weaponSelection.setPos(100, 100);
		//weaponSelection.setSize(200, 100);
	}

}

