module window;


public import ws.wm;

import
	std.file,
	std.algorithm,
	std.conv,
	core.thread,
	
	ws.vers,
	ws.io,
	ws.log,
	ws.math,
	ws.decode,
	ws.exception,
	ws.time,
	ws.list,
	ws.string,
	ws.gl.gl,
	ws.gl.draw,
	ws.gui.input,
	ws.gui.point,
	
	ws.check,
	
	gui.menu.menu,
	gui.engine,
	gui.console,
	gui.spawnmenu;

__gshared:


static assert(ws.vers.VERSION >= 1, "Version 1 of WS required");


int main(string[] args){
	auto window = new Window(1280, 720, "Engine", args);
	while(wm.hasActiveWindows()){
		try {
			wm.processEvents(true);
			window.onDraw();
		}catch(Throwable e){
			Log.error(e.toString());
			window.hide();
			writeln("[FATAL ERROR]\n", e);
			return -1;
		}
	}
	return 0;
}


///	App window and GUI root
class Window: ws.wm.Window {

	double currentTime;
	Framerate framerate;
	Engine engine;

	this(int w, int h, string t, string[] args){
		super(w, h, t);
		chdir("..");
		engine = add!Engine(this);
		setTop(engine);
		onResize(size[0], size[1]);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_BLEND);
	}


	override void onRawMouse(int dx, int dy){
		if(active)
			engine.onRawMouse(dx, dy);
	}


	override void onDraw(){
		assert(gl.active());

		double renderStart = time.now();
		currentTime = renderStart + clamp!double(1.0/120.5 - (renderStart - framerate.lastRender), 0, 1);
		time.sleep(currentTime - renderStart);

		glClearColor(0.2, 0.2, 0.2, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

		super.onDraw();

//		engine.tick();
		gl.check();
		swapBuffers();

		framerate.theoretical += (renderStart - framerate.lastRender);
		framerate.renderTimes++;
		if(framerate.lowest < currentTime - framerate.lastRender)
			framerate.lowest = currentTime - framerate.lastRender;
		if (framerate.lastDisplay + 0.5 < currentTime) {
			setTitle("% [+%]".tostring(
				cast(int)(1.0/framerate.lowest),
				cast(int)(1.0/(framerate.theoretical / framerate.renderTimes)) - cast(int)(1.0/framerate.lowest)
			));
			framerate.lowest = 0;
			framerate.renderTimes = 0;
			framerate.lastDisplay = currentTime;
			framerate.theoretical = 0;
		}
		framerate.lastRender = currentTime;
	}
	

	override void onKeyboard(Keyboard.key key, bool pressed){
		scope(exit)
			Keyboard.set(key, pressed);
		if(pressed && key == 'q' && Keyboard.get(Keyboard.control))
			hide();
		super.onKeyboard(key, pressed);
	}


	override void onResize(int x, int y){
		glViewport(0, 0, x, y);
		draw.setScreenResolution(x, y);
		foreach(c; children ~ hiddenChildren)
			c.setSize(Point(x, y) - c.pos);
		super.onResize(x, y);
	}
	
	/// returns time in seconds since program start
	@property double now(){
		return currentTime;
	}
	
	struct Framerate {
		double lastRender = 0;
		double lastDisplay = 0;
		long renderTimes = 0;
		double lowest = 0;
		double theoretical;
	}
	
	
}
