module gui.menu.menu;

import
	ws.list,
	ws.io,

	ws.gl.draw,
	ws.gl.texture,
	
	ws.gui.base,
	ws.gui.point,
	ws.gui.button,
	ws.gui.tabs,
	ws.gui.input,
	ws.gui.background,

	window,
	game.commands,
	gui.engine,
	gui.menu.options,
	gui.menu.game;


class Menu: Tabs {

	this(Commands commands, Engine engine){
		super(left);
		offset = 0.7;
		style.bg = [0.3, 0.3, 0.3, 1];
		style.bg.hover = [0.1, 0.1 ,0.1, 1];
		style.fg = [1, 1, 1, 1];
		setStyle(style);
		addPage("game", new Game(commands));
		addPage("options", new Options(commands, engine.controls));
		addPage("quit", new Base).button.leftClick ~= {
			commands.run("exit");
		};
		commands.add("menu_toggle", {
			hidden ? show() : hide();
		});
	}

	override void onDraw(){
		draw.setColor(0,0,0,0.9);
		draw.rect(pos, size);
		super.onDraw();
	}

}
