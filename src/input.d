module game.input;


import
	std.conv,
	std.file,
	std.algorithm,
	ws.exception,
	ws.log,
	ws.string,
	ws.decode,
	ws.gui.input,
	game.util,
	game.commands;


alias void delegate(string, string) Command;

static const string[int] aliases;

static this(){
	aliases = [
		Keyboard.shift: "shift",
		Keyboard.control: "control",
		Keyboard.caps: "caps",
		Keyboard.win: "win",
		Keyboard.escape: "escape",
		Keyboard.enter: "enter",
		Keyboard.backspace: "backspace",
		Keyboard.space: "space",
		Keyboard.del: "del",
		Keyboard.left: "left",
		Keyboard.up: "up",
		Keyboard.right: "right",
		Keyboard.down: "down",
		5000 + Mouse.buttonLeft: "Mouse Left",
		5000 + Mouse.buttonRight: "Mouse Right",
		5000 + Mouse.wheelUp: "Mouse Wheel Up",
		5000 + Mouse.wheelDown: "Mouse Wheel Down",
		5500: "Mouse X",
		5501: "Mouse Y"
	];
}

string getButtonName(Mouse.button button){
	return getKeyName(button + 5000);
}

string getKeyName(int key){
	if(key in aliases)
		return aliases[key];
	else if(key > 5000)
		return "Mouse %s".format(key-5000);
	else if(key < 33 || key > 126)
		return to!string(key);
	else
		return [cast(char)key];
}


class Input {

	// (action[])[key]
	string[][string] bindings;
	const string path;
	Commands commands;
	void delegate(string,float) capture;
	
	this(string path, Commands commands){
		this.path = path;
		this.commands = commands;
	}


	void bind(string key, string action, bool shouldSave=true){
		assert(action.length);
		if(key !in bindings || !bindings[key].canFind(action))
			bindings[key] ~= action;
		if(shouldSave)
			save;
	}

	void unbind(string key, string action, bool shouldSave=true){
		assert(bindings[key].canFind(action), "No such action: " ~ action ~ " in " ~ key ~ to!string(bindings[key]));
		bindings[key] = bindings[key].without(action);
		if(shouldSave)
			save;
	}

	void unbind(string key, bool shouldSave=true){
		bindings[key] = [];
		if(shouldSave)
			save;
	}

	void keyPress(int key, bool pressed){
		input(key, pressed ? 1 : 0);
	}

	void input(int id, float value){
		if(capture){
			capture(getKeyName(id), value);
			capture = null;
		}
		auto keyId = getKeyName(id);
		if(keyId in bindings){
			foreach(bind; bindings[keyId]){
				bool minus = false;
				if(bind[0] == '-'){
					minus = true;
					bind = bind[1..$];
				}
				if(bind !in commands.commands)
					Log.warning(tostring("\"%\" is not a registered command", bind));
				else
					commands.run(bind, minus ? -value : value);
			}
		}
	}

	string[] getBind(string action){
		string[] res;
		foreach(k, a; bindings)
			if(a.canFind(action))
				res ~= k;
		return res;
	}

	void captureNext(void delegate(string,float) f){
		capture = f;
	}

	void load(){
		bindings = bindings.init;
		Decode.file(path, (key, action, b){
			bind(key, action, false);
		});
	}

	void save(){
		try {
			string content;
			foreach(key, actions; bindings)
				foreach(action; actions)
					content ~= '\"' ~ key ~ "\" \"" ~ action ~ "\"\n";
			write(path, content);
		}catch(FileException e){
			Log.warning("Failed to save controls: " ~ e.toString());
		}
	}

}
