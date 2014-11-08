module gui.worldPerspective;

import
	ws.gl.gl,
	ws.gui.base,
	ws.math,
	gui.weaponSelection,
	game.component.projection,
	game.component.transform,
	game.component.weapons,
	game.system.draw,
	game.entity.entity,
	game.commands,
	window;


__gshared:


class WorldPerspective: Base {

	Draw drawSystem;
	Transform transform;
	Projection projection;
	Window window;
	WeaponSelection weaponSelection;

	private {
		Matrix!(4,4) view;
	}

	this(Window window, EntityManager ents, Commands commands, Entity player){
		this.window = window;
		drawSystem = new Draw(window, ents, player, this);
		setCursor(Mouse.cursor.none);
		transform = player.get!Transform;
		projection = player.get!Projection;
		weaponSelection = add!WeaponSelection(player.get!Weapons);
		weaponSelection.setPos(100, 100);
		weaponSelection.setSize(200, 100);
		view = new Matrix!(4,4);
	}

	override void onDraw(){
		glViewport(0,0,size[0],size[1]);
		drawSystem.draw();
		glViewport(0,0,size[0],size[1]);
		glEnable(GL_BLEND);
	}


	override void onResize(int x, int y){
		if (!y)
			y = 1;
		projection.aspect = cast(double)x/cast(double)y;
		drawSystem.setScreenSize(x, y);
	}

	Matrix!(4,4) getView(){
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

	override void onMouseMove(int x, int y){
		if(hasFocus && (x > size.x/4*3 || x < size.x/4 || y > size.y/4*3 || y < size.y/4))
			window.setCursorPos(size.x/2, size.y/2);
	}

	void update(){
		view = new Matrix!(4,4);
		view.rotate(transform.angle*Quaternion.euler(180,180,180));
		view.translate(-transform.position);
	}

}

