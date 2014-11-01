module gui.menu.controls;

import
	ws.decode,
	ws.gl.draw,
	ws.gui.base,
	ws.gui.text,
	ws.gui.list,
	ws.gui.button,
	ws.gui.input,
	ws.io,
	window,
	game.controls;

class ControlsMenu: List {

	Controls controls;

	this(Controls controls){
		this.controls = controls;
		
		style.fg = [1, 1, 1, 1];
		style.bg = [0.5,0.5,0.5,1];
		entryHeight = 25;
		padding = 10;
		Decode.file("config/menu.ws", (category, c, b){
			auto text = add!Text;
			text.style.fg = style.bg;
			text.text.set(category);
			Decode.text(c, (id, name, b){
				if(id[0] == '~')
					add(new ControlsFieldFloat(id[1..$], name, controls));
				else
					add(new ControlsFieldSimple(id, name, controls));
			});
		});
	}

}

/+
class ControlsButton: Button {

	bool waitingForInput = false;
	string action;
	string key;
	Controls controls;

	this(string action, string name, Controls controls){
		super("");
		title.text.set(name);
		this.action = action;
		this.key = controls.getBind(action);
		this.controls = controls;
		leftClick ~= {
			waitingForInput = true;
			title.text.set("Press any key ...");
			parent.setTop(this);
		};
	}

	override void onKeyboardFocus(bool f){
		if(!f){
			waitingForInput = false;
			updateText();
		}
	}

	override void onMouseButton(Mouse.button b, bool p, int x, int y){
		if(p && waitingForInput){
			key = getButtonName(b);
			controls.bind(action, key);
			waitingForInput = false;
			updateText();
		}else{
			super.onMouseButton(b, p, x, y);
		}
	}

	override void onKeyboard(Keyboard.key k, bool p){
		if(p && waitingForInput){
			key = getKeyName(k);
			controls.bind(action, key);
			waitingForInput = false;
			updateText();
		}
	}

}
+/


class ControlsFieldSimple: Base {
	
	Text title;
	ControlsButton input;

	this(string action, string name, Controls controls){
		style.bg = [0,0,0,0.4];
		title = add!Text;
		title.text.set(name);
		title.setLocalPos(0,0);
		input = add!ControlsButton(action, controls);
	}

	override void onResize(int w, int h){
		title.setSize(w/2, h);
		input.setSize(w/2, h);
		input.setLocalPos(w/2, 0);
		title.setFont("Ubuntu-R", cast(int)(h/1.8));
	}
	
	override void onDraw(){
		draw.setColor(style.bg.normal);
		draw.rect(pos, size);
		super.onDraw();
	}

}




class ControlsFieldFloat: Base {

	Text title;
	ControlsButton input1;
	ControlsButton input2;

	this(string action, string name, Controls controls){
		style.bg = [0,0,0,0.4];
		title = add!Text;
		title.text.set(name);
		title.setLocalPos(0,0);

		input1 = add!ControlsButton(action, controls, true);
		input2 = add!ControlsButton(action, controls);
	}

	override void onResize(int w, int h){
		title.setSize(w/2, h);
		input1.setSize(w/4, h);
		input1.setLocalPos(w/2, 0);
		input2.setSize(w/4, h);
		input2.setLocalPos(w/4*3, 0);
		title.setFont("Ubuntu-R", cast(int)(h/1.8));
	}
	
	override void onDraw(){
		draw.setColor(style.bg.normal);
		draw.rect(pos, size);
		super.onDraw();
	}

}



class ControlsButton: Button {

	this(string action, Controls controls, bool whenNegative=false){
		super(controls.getBind((whenNegative ? "-": "") ~ action));
		leftClick ~= {
			string n1 = (whenNegative ? "" : "-");
			string n2 = (whenNegative ? "-" : "");
			text = "Press input ...";
			controls.captureNext((key, value){
				controls.bind((value < 0 ? n1 : n2) ~ action, key);
				text = key;
			});
		};
	}

}

