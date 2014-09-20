module gui.menu.controls;

import
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
		entryHeight = 25;
		padding = 10;
	}

	override void onShow(){
		children.clear();
		/+
		foreach(name, action; controls.controls.commands)
			add(new ControlsButton(name, controls.controls.getActionKey(name), this.controls.controls));
		+/
	}

}


class ControlsButton: Button {

	bool waitingForInput = false;
	string action;
	string key;
	Controls controls;

	this(string action, string key, Controls controls){
		super("");
		this.action = action;
		this.key = key;
		this.controls = controls;
		updateText();
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

	void updateText(){
		title.text.set(action ~ " = " ~ key);
	}

}
