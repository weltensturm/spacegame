module editor.editor;

import
	std.string,

	ws.nullable,
	ws.log,
	ws.math,
	ws.gl.draw,
	ws.gl.material,
	ws.gui.base,
	ws.gui.style,
	ws.gui.list,
	ws.gui.button,
	ws.gui.input,
	ws.gl.model,

	window,
	gui.engine,
	gui.worldPerspective,

	editor.spawner,
	game.commands,
	game.component.noclip,
	game.system.draw,
	game.system.voxelHeap;


enum Mode { add, remove, select }


class Editor: Base {

	protected {
		List left;
		List right;
		Button spawnerButton;
		WorldPerspective perspective;
	}

	Mode mode;
	Vector!3[] points;
	int[3] ghost;
	int[3] start;
	float[4] ghostColor;
	VoxelHeap spawnGrid;
	Engine engine;

	this(Engine engine, Commands commands){
		this.engine = engine;
		style.bg = [0.3,0.3,0.3,1];
		left = add!List;
		left.style = style;
		left.setSize(200,0);

		perspective = engine.perspective;

		/+
		commands.add("editor_perspective_speed_x", (float n){
			perspective.position.velocityTarget[0] = n;
		});
		commands.add("editor_perspective_speed_y", (float n){
			perspective.position.velocityTarget[1] = n;
		});
		commands.add("editor_perspective_speed_z", (float n){
			perspective.position.velocityTarget[2] = n;
		});
		commands.add("editor_perspective_turn_pitch", (float n){
			perspective.camera.angle.rotate(-pow(n/10.0, 1.2), 0,0,1);
		});
		commands.add("editor_perspective_turn_yaw", (float n){
			perspective.camera.angle.rotate(pow(n/10.0, 1.2), -perspective.camera.angle.right());
		});
		commands.add("editor_mode_add", (){
			setMode(Mode.add);
		});
		commands.add("editor_mode_remove", (){
			setMode(Mode.remove);
		});
		+/

		spawnGrid = new VoxelHeap();

		setMode(Mode.add);

		auto addButton = left.add!Button("add");
		addButton.leftClick ~= { setMode(Mode.add); };

		auto selectButton = left.add!Button("select");
		selectButton.leftClick ~= { setMode(Mode.select); };

		auto removeButton = left.add!Button("remove");
		removeButton.leftClick ~= { setMode(Mode.remove); };

		foreach(x; 0..2)
			foreach(y; 0..2)
				foreach(z; 0..2)
					points ~= vec(x-0.5, y-0.5, z-0.5);
					
		//world.draw ~= &draw3d;
	}


	void setMode(Mode mode){
		this.mode = mode;
		if(mode == Mode.add)
			ghostColor = [0,1,0,1];
		else
			ghostColor = [1,0,0,1];
	}


	override void onKeyboard(Keyboard.key key, bool pressed){
		if(key == Keyboard.escape)
			hide;
	}


	override void onResize(int w, int h){
		left.setSize(left.size.x, h);
		/+
		right.setPos(w-right.size.x, 0);
		right.setSize(right.size.x, h);
		spawner.setPos(spawnerButton.pos.x, spawnerButton.pos.y - 400);
		spawner.setSize(spawnerButton.size.x, 400);
		+/
	}


	void spawn(string model){
		Log.info("Spawning " ~ model);
	}

	private void drawCube(int[3] pos){
		/+
		foreach(cbegin; points)
			foreach(cend; points)
				if(cend.x == cbegin.x || cend.y == cbegin.y || cend.z == cbegin.z)
					engine.renderer.line(vec(pos) + cbegin, vec(pos) + cend);
		+/
	}

	void draw3d(WorldMatrix, Light light, Material defaultMat){
		/+
		engine.renderer.color = [ghostColor[0]*0.5, ghostColor[1]*0.5, ghostColor[2]*0.5, ghostColor[3]*0.5];
		drawCube(start);
		engine.renderer.color = ghostColor;
		drawCube(ghost);
		+/
	}

	void worldMouseButton(Mouse.button b, bool pressed){
		if(b == Mouse.buttonRight && pressed){
			//perspective.forwardInput = !perspective.forwardInput;
			//world.onMouseFocus(perspective.forwardInput);
			//setCursor(perspective.forwardInput ? Mouse.cursor.none : Mouse.cursor.inherit);
		}else if(b == Mouse.buttonLeft){
			/*
			auto ent = world.entityList.create("Entity");
			ent.setModel("20cmsphere.obj");
			ent.setPos(ghost.getPos());
			*/
			if(pressed){
				start = ghost;
			}else{
				if(mode == Mode.add)
					spawnGrid.spawn(start);
				else if(mode == Mode.select)
					{}//spawnGrid.select;
				else if(mode == Mode.remove)
					spawnGrid.remove(start);
			}
		}
	}

	override void onMouseMove(int x, int y){
		auto dir = perspective.screenToWorld([x, y]);
		Nullable!(int[3]) pos;
		if(mode == Mode.add)
			pos = spawnGrid.spawnPos(perspective.transform.position, dir);
		else if(mode == Mode.remove)
			pos = spawnGrid.removePos(perspective.transform.position, dir);
		if(pos)
			ghost = pos;
	}

}
