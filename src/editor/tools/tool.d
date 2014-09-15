module editor.tools.tool;

import ws.nullable;


interface Tool {

	alias Nullable!(int[3]) Ghost;

	void press(bool);
	void move(Ghost);
	void draw();

}

