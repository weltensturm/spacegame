module game.editor.tool;


import
	ws.gui.base,
	ws.math,
	ws.math.collision,
	game.editor.editor;


class Tool: Base {

	Editor editor;
	int[2] mousePos;
	float[3] pos;
	float[3] dir;

	this(Editor editor){
		this.editor = editor;
	}

	override void onMouseMove(int x, int y){
		mousePos = [x, y];
		dir = editor.perspective.screenToWorld([x, y]);
		pos = editor.perspective.transform.position;
	}

	LineCubeResult trace(){
		auto c = editor.chunk;
		auto hit = collide(Line(pos, dir), Cube(c.position+vec(1,1,1)*c.width/2*c.voxelSize, c.width*c.voxelSize));
		if(hit){
			foreach(x; 0..c.width)
				foreach(y; 0..c.width)
					foreach(z; 0..c.width){
						hit = collide(Line(pos, dir), Cube(c.position+vec(x,y,z)*c.voxelSize, c.voxelSize));
						if(hit)
							return hit;
					}
		}
		return null;
	}

	void draw3d(Matrix!(4,4) projection, Matrix!(4,4) view){

	}

}

