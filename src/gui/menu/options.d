module gui.menu.options;

import
	std.conv,
	std.algorithm,

	ws.io,
	ws.event,
	ws.gl.draw,
	ws.gui.base,
	ws.gui.checkBox,
	ws.gui.list,
	ws.gui.tabs,
	ws.gui.sliderDecorated,
	ws.gui.input,
	ws.math.vector,
	window,
	game.commands,
	game.controls,
	gui.menu.controls;


class Options: Tabs {
	
	this(Commands commands, Controls controls){
		super(left);
		offset = 0.7;
		style.bg = [0.9, 0.9, 0.9, 1];
		style.fg = [0,0,0,1];
		buttonStyle.bg = style.bg;
		buttonStyle.fg = style.fg;
		swap(buttonStyle.bg.normal, buttonStyle.bg.hover);
		font = "Ubuntu-R";
		auto c = new ControlsMenu(controls);
		c.style.bg = style.bg;
		c.style.fg = style.fg;
		addPage("controls", c);

		auto g = new Lighting(commands);
		g.style.bg = style.bg;
		g.style.fg = style.fg;
		addPage("graphics", g);
	}

}


class Lighting: List {

	SliderDecorated s;

	this(Commands commands){
		super();
		padding = 5;
		entryHeight = 25;
		s = add!SliderDecorated("Lumen", 1, 10000, 100);
		s.onSlide ~= (v){
			commands.run("world_light_intensity", v);
		};
		s.setLocalPos(10, 70);
		auto box = add!CheckBox("Draw Collision Objects");
		box.font = "UbuntuMono-R";
		box.update ~= (b){
			commands.run("physics_debug_draw", b);
		};
	}

	/+
	override void onResize(int w, int h){
		s.setSize(w-20, 20);
	}
	+/

}
