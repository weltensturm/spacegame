module editor.editor;

import
	std.string,
	std.algorithm,

	ws.nullable,
	ws.log,
	ws.math,
	ws.gl.gl,
	ws.gl.draw,
	ws.gl.material,
	ws.gl.render,
	ws.gl.batch,
	ws.gui.base,
	ws.gui.style,
	ws.gui.list,
	ws.gui.button,
	ws.gui.input,
	ws.gui.inputField,
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


alias IntPos = int[3];


class Editor: Base {

	protected {
		List left;
		List right;
		Button spawnerButton;
		WorldPerspective perspective;
		Render render;
	}

	Mode mode;
	Vector!3[] points;
	IntPos[] ghost;
	IntPos ghostStart;
	float[4] ghostColor;
	VoxelHeap spawnGrid;
	Model cube;
	bool drawGhost;
	bool dragging;

	void savePopup(){
		auto popup = add!List;
		popup.add!InputField;
		auto save = popup.add!Button("save");
		save.leftClick ~= { children.remove(popup); };
		auto cancel = popup.add!Button("cancel");
		cancel.leftClick ~= { children.remove(popup); };
		popup.setSize(300, 300);
		popup.setLocalPos(size.x/2-150, size.y/2-150);
	}

	this(WorldPerspective perspective, Render render, Commands commands){
		this.perspective = perspective;
		this.render = render;

		style.bg = [0.3, 0.3, 0.3, 1];
		left = add!List;
		left.style = style;
		left.setSize(200, 0);

		cube = new Model("uniform_cube.obj");

		commands.add("editor_mode_add", (){
			if(hasFocus)
				setMode(Mode.add);
		});

		commands.add("editor_mode_remove", (){
			if(hasFocus)
				setMode(Mode.remove);
		});

		foreach(x; 0..2)
			foreach(y; 0..2)
				foreach(z; 0..2)
					points ~= vec(x-0.5, y-0.5, z-0.5);

		spawnGrid = new VoxelHeap();

		setMode(Mode.add);

		auto addButton = left.add!Button("add");
		addButton.leftClick ~= { setMode(Mode.add); };

		auto selectButton = left.add!Button("select");
		selectButton.leftClick ~= { setMode(Mode.select); };

		auto removeButton = left.add!Button("remove");
		removeButton.leftClick ~= { setMode(Mode.remove); };

		auto saveButton = left.add!Button("save");
		saveButton.leftClick ~= { savePopup(); };
		auto loadButton = left.add!Button("load");

		perspective.drawSystem.onDraw ~= &draw3d;
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
		super.onKeyboard(key, pressed);
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


	private void drawCube(int[3] pos){
		foreach(cbegin; points)
			foreach(cend; points)
				if(cend.x == cbegin.x || cend.y == cbegin.y || cend.z == cbegin.z)
					render.line(vec(pos) + cbegin, vec(pos) + cend);
	}

	void draw3d(ModelMatrix modelMatrix, Matrix!(4,4) projectionMatrix, Matrix!(4,4) viewMatrix){
		foreach(pos; spawnGrid.cubes){
			modelMatrix.push;
			modelMatrix.translate(Vector!3.from(pos));
			foreach(object; cube.data){
				object.material.use(
					"matMVP", projectionMatrix*viewMatrix*modelMatrix.back,
					"matMV", viewMatrix*modelMatrix.back,
					"matV", viewMatrix.inverse,
					"matM", modelMatrix.back,
					"matN", modelMatrix.getNormal,
					"lightPosition", perspective.transform.position,
					"diffuseColor", Vector!3(1,1,1),
					"specularColor", Vector!3(1,1,1),
					"ambientColor", Vector!3(1,1,1)/10,
					"lumen", 200.0f
				);
				object.batch.draw();
			}
			modelMatrix.pop;
		}
		render.color = ghostColor;
		if(drawGhost){
			foreach(pos; ghost)
				drawCube(pos);
		}
	}

	override void onMouseButton(Mouse.button b, bool pressed, int x, int y){
		if(b == Mouse.buttonRight && pressed){
			//perspective.forwardInput = !perspective.forwardInput;
			//world.onMouseFocus(perspective.forwardInput);
			//setCursor(perspective.forwardInput ? Mouse.cursor.none : Mouse.cursor.inherit);
		}else if(b == Mouse.buttonLeft && drawGhost){
			/*
			auto ent = world.entityList.create("Entity");
			ent.setModel("20cmsphere.obj");
			ent.setPos(ghost.getPos());
			*/
			dragging = pressed;
			if(!pressed){
				foreach(pos; ghost){
					if(mode == Mode.add)
						spawnGrid.spawn(pos);
					else if(mode == Mode.select)
						{}//spawnGrid.select;
					else if(mode == Mode.remove)
						spawnGrid.remove(pos);
				}
			}
		}
		super.onMouseButton(b, pressed, x, y);
	}

	override void onMouseMove(int x, int y){
		auto dir = perspective.screenToWorld([x, y]);
		Nullable!(int[3]) pos;
		if(mode == Mode.add)
			pos = spawnGrid.spawnPos(perspective.transform.position, dir);
		else if(mode == Mode.remove)
			pos = spawnGrid.removePos(perspective.transform.position, dir);
		if(pos){
			ghost = [];
			if(!dragging)
				ghostStart = pos;
			for(int cx = min(ghostStart[0], pos[0]); cx <= max(ghostStart[0], pos[0]); cx++)
				for(int cy = min(ghostStart[1], pos[1]); cy <= max(ghostStart[1], pos[1]); cy++)
					for(int cz = min(ghostStart[2], pos[2]); cz <= max(ghostStart[2], pos[2]); cz++)
						ghost ~= [cx, cy, cz];
			drawGhost = true;
		}else
			drawGhost = false;
		super.onMouseMove(x, y);
	}

}



