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
				static if(T.length == 1)
					fn(to!T(arg));
				else static if(T.length == 0) {
					float val = 1;
					if(arg.length)
						val = to!float(arg);
					if(val > 0)
						fn();
				} else
					static assert(0, T.length);
			}catch(ConvException e)
				Log.warning("Cannot run % with %".format(name, arg));
		};
	}

	void run()(string name){
		run(name, "");
	}

	void run(T)(string name, T arg){
		commands[name](to!string(arg));
	}

}