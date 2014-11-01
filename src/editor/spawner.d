module editor.spawner;


import
	std.file,
	ws.log,
	ws.gl.texture,
	ws.gl.draw,
	ws.gui.base,
	ws.gui.grid,
	ws.gui.button,
	ws.gui.text,
	editor.editor;


class Spawner: Grid {

	Editor creator;

	this(Editor creator){
		super(Point(100, 100));
		style.bg = [0.5, 0.5, 0.5, 0.5];
		this.creator = creator;
		foreach(model; dirEntries("models/parts", SpanMode.shallow))
			addEntry("parts/" ~ model);
	}

	void addEntry(string n){
		auto b = add!SpawnButton(n);
		b.leftClick ~= {
			//creator.spawn(n);
		};
	}

	override void onDraw(){
		draw.setColor(style.bg);
		draw.rect(pos, size);
		super.onDraw;
	}

	override void onKeyboardFocus(bool focus){
		if(!focus)
			hide;
	}
	
}


class SpawnButton: Button {

	Texture image;
	Text title;

	this(string t){
		super(t);
		title = add!Text();
		title.text.set(t);
		title.setFont("consola", 12);
		try {
			import ws.io; writeln(1);
			image = Texture.load("entities/" ~ t ~ ".tga");}
		catch(Exception e){
			Log.warning(e.toString);
			image = Texture.load("entities/default.tga");
		}
	}
	
	override void onResize(int w, int h){
		title.setPos(pos.x, pos.y);
		title.setSize(w, 20);
	}
	
	override void onDraw(){
		draw.setColor(0, 0, 0, 0.8);
		draw.rect(title.pos, title.size);
		draw.rect(pos, size);
		draw.setColor(1,1,1, mouseFocus ? 0.5 : 1);
		draw.texture = image;
		draw.texturedRect(pos+Point(5,5), size-Point(10,10));
		draw.setColor(0, 0, 0, 0.8);
		draw.rect(title.pos, title.size);
		title.onDraw();
	}
	
}
