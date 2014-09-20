module editor.perspective;


import
	ws.gui.base,
	ws.gl.draw,
	ws.gl.material,
	ws.math.vector,

	ws.gl.render,

	game.component.camera,
	gui.engine,

	editor.editor,
	game.component.noclip,
	game.component.transform,
	game.system.voxelHeap;


class Perspective: Base {

	Camera camera;
	Noclip position;
	bool forwardInput;
	Editor creator;

	this(Editor creator){


	}

	override void onDraw(){
		if(forwardInput){
			draw.setColor(1,1,1,1);
			auto origin = size/2;
			draw.line(origin-[10,0], origin+[10,0]);
			draw.line(origin-[0,10], origin+[0,10]);
			super.onDraw;
		}
	}

}

