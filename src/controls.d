module game.controls;


import
	std.conv,
	std.file,
	std.algorithm,
	ws.exception,
	ws.log,
	ws.string,
	ws.decode,
	ws.gui.input,
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
		5000 + Mouse.wheelDown: "Mouse Wheel Down"
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


class Controls {

	string[string] bindings;
	const string path;
	Commands commands;
	
	this(string path, Commands commands){
		this.path = path;
		this.commands = commands;
	}


	void bind(string action, string key, bool shouldSave=true){
		foreach(k,i; bindings)
			if(i == action){
				bindings.remove(k);
				break;
			}
		bindings[key] = action;
		if(shouldSave)
			save();
	}

	void keyPress(int key, bool pressed){
		auto keyId = getKeyName(key);
		if(keyId in bindings){
			if(bindings[keyId] !in commands.commands)
				exception(tostring("\"%\" is not a registered command", bindings[keyId]));
			commands.run(bindings[keyId], pressed ? 1 : 0);
		}
	}

	void input(int id, float value){
		auto keyId = getKeyName(id);
		if(keyId in bindings){
			if(bindings[keyId] !in commands.commands)
				exception(tostring("\"%\" is not a registered command", bindings[keyId]));
			commands.run(bindings[keyId], value);
		}
	}

	string getBind(string action){
		foreach(k, a; bindings)
			if(a == action)
				return k;
		return "";
	}

	void load(){
		Decode.file(path, (action, key, b){
			bind(action, key, false);
		});
	}

	void save(){
		try {
			string content;
			foreach(action, key; bindings)
				content ~= '\"' ~ key ~ "\" \"" ~ action ~ "\"\n";
			write(path, content);
		}catch(FileException e){
			Log.warning("Failed to save controls: " ~ e.toString());
		}
	}

}