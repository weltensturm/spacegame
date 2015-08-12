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
	ws.file.bbatch,
	
	ws.check,
	
	gui.menu.menu,
	gui.engine,
	gui.console,
	gui.spawnmenu;

__gshared:


static assert(ws.vers.VERSION >= 1, "Version 1 of WS required");


int main(string[] args){
	auto window = new Window(1280, 720, "Engine", args);
	wm.add(window);

	while(wm.hasActiveWindows()){
		try {
			wm.processEvents;
			window.onDraw;
		}catch(Throwable e){
			Log.error(e.toString());
			window.hide();
			writeln("[FATAL ERROR]\n", e);
			return -1;
		}
	}
	Log.info("Bye!");
	return 0;
}


///	App window and GUI root
class Window: ws.wm.Window {

	double currentTime;
	Framerate framerate;
	Engine engine;
	bool keyboardFocus;

	this(int w, int h, string t, string[] args){
		super(w, h, t);
		chdir("..");
		engine = addNew!Engine(this);
		setTop(engine);
		resize(size);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_BLEND);
	}


	override void onRawMouse(int dx, int dy){
		if(active)
			engine.onRawMouse(dx, dy);
	}


	override void onDraw(){
		if(!gl.active())
			throw new Exception("gl not active in thread %s".format(cast(void*)Thread.getThis()));

		double renderStart = time.now();
		currentTime = renderStart + ws.math.clamp!double(1.0/120.5 - (renderStart - framerate.lastRender), 0, 1);
		time.sleep(currentTime - renderStart);

		super.onDraw;

		gl.check;
		swapBuffers;

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

	override void onKeyboardFocus(bool focus){
		keyboardFocus = focus;
		super.onKeyboardFocus(focus);
	}

	override void hide(){
		super.hide;
		engine.hide;
	}


	override void resize(int[2] size){
		glViewport(0, 0, size.w, size.h);
		draw.resize(size);
		foreach(c; children ~ hiddenChildren)
			c.resize([size.w-c.pos.x, size.h-c.pos.y]);
		super.resize(size);
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
