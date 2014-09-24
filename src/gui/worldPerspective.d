module gui.worldPerspective;

import
	ws.gui.base,
	ws.math,
	gui.weaponSelection,
	game.component.projection,
	game.component.transform,
	game.system.draw,
	game.entity.entity,
	game.commands,
	window;


__gshared:


class WorldPerspective: Base {

	WeaponSelection weaponSelection;
	Draw drawSystem;
	Transform transform;
	Projection projection;

	this(Window window, EntityManager ents, Commands commands, Entity player){
		drawSystem = new Draw(window, ents, player, this);
		//weaponSelection = new WeaponSelection;
		setCursor(Mouse.cursor.none);
		transform = player.get!Transform;
		projection = player.get!Projection;
	}

	override void onDraw(){
		drawSystem.draw();
	}


	override void onResize(int x, int y){
		if (!y)
			y = 1;
		projection.aspect = cast(double)x/cast(double)y;
		//weaponSelection.setPos(100, 100);
		//weaponSelection.setSize(200, 100);
	}

	Matrix!(4,4) getView(){
		auto view = new Matrix!(4,4);
		view.rotate(transform.angle*Quaternion.euler(180,180,180));
		view.translate(-transform.position);
		return view;
	}

	Vector!3 screenToWorld(float[2] v){
		auto res = Vector!3((projection.getProjection*getView).inverse * [2*v[0]/size[0]-1, 2*v[1]/size[1]-1, 1]);
		return res;
	}

	int[3] worldToScreen(float[3] v){
		auto product = projection.getProjection * getView * v;
		int x = cast(int)((product[0]/product[2]+1)*size[0]/2);
		int y = cast(int)((product[1]/product[2]+1)*size[1]/2);
		return [x, y, cast(int)product[2]];
	}

}

