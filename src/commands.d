module game.commands;


import
	std.conv,
	std.traits,
	std.file,
	std.algorithm,
	ws.exception,
	ws.log,
	ws.string,
	ws.decode,
	ws.gui.input;


alias void delegate(string) Command;


class Commands {

	Command[string] commands;

	void add(T...)(string name, void delegate(T) fn){
		commands[name] = (string arg){
			try {
				static if(T.length == 1){
					static if(is(T[0] == bool))
						fn(arg == "1" || arg == "true");
					else
						fn(to!T(arg));
				}else static if(T.length == 0) {
					float val = 1;
					if(arg.length)
						val = to!float(arg);
					if(val > 0)
						fn();
				} else
					static assert(0, T.length);
			}catch(ConvException e)
				Log.warning("Cannot run %s with %s: %s".format(name, arg, e));
		};
	}

	void run()(string name){
		run(name, "");
	}

	void run(T)(string name, T arg){
		if(name in commands)
			commands[name](to!string(arg));
		else
			Log.warning("Command %s does not exist".format(name));
	}

}