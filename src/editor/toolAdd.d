module game.editor.toolAdd;


import
	ws.math,
	ws.gl.draw,
	ws.gui.input,
	game.transform,
	game.editor.editor,
	game.editor.tool;


class ToolAdd: Tool {

	this(Editor editor){
		super(editor);
	}

	override void onDraw(){
		auto hit = trace;
		if(hit){
			draw.rect(editor.perspective.worldToScreen(hit.pos)[0..2], [5,5]);
		}
	}

	override void onMouseButton(Mouse.button button, bool pressed, int x, int y){
		auto hit = trace;
		if(hit && pressed){
			auto lpos = editor.chunk.Transform_.local(hit.pos.add(hit.normal));
			auto i =
					cast(int)(lpos[0]*editor.chunk.voxelSize)
					+cast(int)(lpos[1]*editor.chunk.width*editor.chunk.voxelSize)
					+cast(int)(lpos[2]*editor.chunk.width*editor.chunk.width*editor.chunk.voxelSize);
			editor.chunk.data[i] = 1-editor.chunk.data[i];
			import ws.io;
			writeln(i);
			editor.chunk.build;
		}
		super.onMouseButton(button, pressed, x, y);
	}

}