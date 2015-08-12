module game.editor.editor;

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
	ws.gl.model,
	ws.gui.base,
	ws.gui.style,
	ws.gui.list,
	ws.gui.button,
	ws.gui.input,
	ws.gui.inputField,

	window,
	gui.engine,
	gui.worldPerspective,

	game.editor.spawner,
	game.editor.tool,
	game.editor.toolAdd,
	game.transform,
	game.entity.entity,
	game.commands,
	game.physics.noclip,
	game.graphics.draw,
	game.voxelChunk;


class Editor: Base {

	package {
		List left;
		List right;
		Button spawnerButton;
		WorldPerspective perspective;
		Render render;
		Entity!(VoxelChunk,Transform) chunk;
		Tool[] tools;
	}

	Tool tool;

	this(WorldPerspective perspective, Render render, EntityManager ents, Commands commands){
		this.perspective = perspective;
		this.render = render;

		style.bg = [0.3, 0.3, 0.3, 1];
		left = new List;
		add(left);
		left.style = style;
		left.resize([200, 0]);

		auto toolAdd = new ToolAdd(this);
		add(toolAdd);
		tools ~= toolAdd;

		chunk = new Entity!(VoxelChunk,Transform);
		chunk.data[0..10] = 1;
		chunk.data[32*32*5..32*32*32] = 1;
		chunk.data[chunk.width*chunk.width] = 1;
		chunk.data[chunk.width*chunk.width+9] = 1;
		chunk.build;
		chunk.position = [0,0,1];
		ents.add(chunk);

	}

	void saveDialog(){
		auto popup = addNew!List;
		popup.style.bg.normal = [0.3,0.3,0.3,1];
		popup.addNew!InputField;
		auto save = popup.addNew!Button("save");
		save.leftClick ~= { children = children.without(popup); };
		auto cancel = popup.addNew!Button("cancel");
		cancel.leftClick ~= { children = children.without(popup); };
		popup.resize([300, 300]);
		popup.moveLocal(size.a/2 - [150,150]);
	}

	override void onKeyboard(Keyboard.key key, bool pressed){
		if(key == Keyboard.escape)
			hide;
		super.onKeyboard(key, pressed);
	}

	override void resize(int[2] size){
		left.resize([left.size.w, size.h]);
		foreach(t; tools)
			t.resize(size);
		super.resize(size);
	}

}
