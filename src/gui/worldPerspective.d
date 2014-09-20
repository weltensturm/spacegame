module gui.worldPerspective;

import
	ws.gui.base,
	gui.weaponSelection,
	gui.engine,
	game.component.camera,
	game.system.draw;


__gshared:


class WorldPerspective: Base {

	WeaponSelection weaponSelection;
	Draw drawSystem;
	Camera camera;

	this(Engine engine){
		camera = new Camera;
		drawSystem = new Draw(engine.window, engine.ents, {return camera;});
		//weaponSelection = new WeaponSelection;
		setCursor(Mouse.cursor.none);
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


	void onRawMouse(int x, int y){
		//window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
	}

}

