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


alias void delegate(string, string) Command;


class Commands {

	Command[string] commands;

	void add(T)(string name, void delegate(T) fn){
		commands[name] = (string arg){
			try
				fn(to!T(arg));
			catch(ConvException e)
				writeln("Cannot run % (%) with %", name, fullyQualifiedName!T, arg);
		};
	}

	void run(T)(string name, T arg){
		commands[name](to!string(arg));
	}

}