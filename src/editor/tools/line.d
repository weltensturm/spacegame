module editor.tools.line;

import
	ws.math.vector,
	editor.tools.tool;


class Line: Tool {

	Ghost ghost;
	int[3] start;

	void press(bool down){
		if(!ghost)
			return;
		if(down){
			start = ghost;
		}else{
			auto dir = vec(ghost)-vec(start);
		}
	}

	void move(Ghost pos){
		ghost = pos;
	}

	void draw(){

	}

}
