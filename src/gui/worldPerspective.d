module gui.worldPerspective;

import
	ws.gl.gl,
	ws.gui.base,
	ws.math,
	gui.weaponSelection,
	game.transform,
	game.graphics.projection,
	game.graphics.draw,
	game.weapons.weapons,
	game.entity.entity,
	game.entity.player,
	game.commands,
	window;


__gshared:


class WorldPerspective: Base {

	RenderPipeline renderPipeline;
	Transform transform;
	Projection projection;
	Window window;
	WeaponSelection weaponSelection;

	private {
		Matrix!(4,4) view;
	}

	this(Window window, EntityManager ents, Commands commands, Player player){
		this.window = window;
		renderPipeline = new RenderPipeline(window, ents, this);
		setCursor(Mouse.cursor.none);
		transform = player.get!Transform;
		projection = player.get!Projection;
		weaponSelection = addNew!WeaponSelection(player.get!Weapons);
		weaponSelection.move([100, 100]);
		weaponSelection.resize([200, 100]);
		view = new Matrix!(4,4);
	}

	override void onDraw(){
		glViewport(0,0,size[0],size[1]);
		renderPipeline.draw();
		glViewport(0,0,size[0],size[1]);
		glEnable(GL_BLEND);
	}


	override void resize(int[2] size){
		if (!size.h)
			size.h = 1;
		projection.aspect = cast(double)size.w/cast(double)size.h;
		renderPipeline.setScreenSize(size.w, size.h);
		super.resize(size);
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
		if(hasFocus && window.keyboardFocus && (x > size.w/4*3 || x < size.w/4 || y > size.h/4*3 || y < size.h/4))
			window.setCursorPos(size.w/2, size.h/2);
	}

	void update(){
		view = new Matrix!(4,4);
		view.rotate(transform.angle*Quaternion.euler(180,180,180));
		view.translate(-transform.position);
	}

}

