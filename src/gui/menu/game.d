module gui.menu.game;

import
	std.file,
	ws.io,
	ws.gui.base,
	ws.gui.button,
	ws.gui.tabs,
	game.commands,
	window;


class Game: Tabs {

	this(Commands commands){
		super(left);
		style.fg = [1, 1, 1, 1];
		style.bg = [0.5,0.5,0.5,1];
		/+
		buttonStyle.bg = style.bg;
		buttonStyle.fg = style.fg;
		+/
		setStyle(style);
		offset = 0.7;
		font = "Ubuntu-R";
		addPage("new", new MapList(commands));
	}

}

private:

	class MapList: Base {

		Commands commands;
		int padding = 20;
		int entryHeight = 50;

		this(Commands commands){
			super();
			this.commands = commands;
			foreach(f; dirEntries("scripts/maps", SpanMode.shallow))
				addEntry(f);
		}

		void addEntry(string n){
			Button b = new Button(n);
			add(b);
			b.leftClick ~= {
				commands.run("lua_file", n);
			};
		}

		override void onResize(int w, int h){
			int y = pos.y + h - padding - entryHeight;
			foreach(c; children){
				c.setPos(pos.x + padding, y);
				c.setSize(w-padding*2, entryHeight);
				y -= c.size.y + padding;
			}
		}
	
	}

