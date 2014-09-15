module lua;

import
	ws.io,
	ws.string,
	ws.script.lua,
	ws.math.angle,
	ws.math.vector,
	window,
	game.entity.entity;

__gshared:

class Lua: ws.script.lua.Lua {

	this(){
		super();
		/+

		string s = typeid(Entity).toString();

		this["getmeta"] = (Var v){
			return v.getMetatable();
		};
		
		this["setmeta"] = (Var v, string s){
			v.setMetatable(s);
		};

		this["clear"] = {
			//engine.menu.console.clear;
		};

		this["writeln"] = (Var arg){
			writeln(arg);
		};

		this["run"] = (string s){
			runFile("scripts/" ~ s);
		};

		this["pause"] = (bool p){
			engine.world.paused = p;
		};

		this["quit"] = {
			engine.hide();
		};

		this["exit"] = this["quit"];

		this["game"] = new Var(Var.Table);
		this["game"]["load"] = (Var arg){
			foreach(string s, Var v; arg)
				writeln(s, " = ", v);
		};

		auto light = new Var(Var.Table);
		light["setPos"] = (int x, int y, int z){
			engine.world.light.position = Vector!3(x, y, z);
		};
		light["setLumen"] = (double f){
			engine.world.light.intensity = f;
		};
		light["setColor"] = (double r, double g, double b){
			engine.world.light.color = Vector!3(r, g, b);
		};
		this["light"] = light;

		this["ents"] = new Var(Var.Table);
		this["ents"]["all"] = (){
			auto var = new Var(Var.Table);
			foreach(int i, e; engine.world.entityList.all())
				var[i+1] = newUserdata(e);
			return var;
		};

		this["new"] = (string type){
			Entity ent = engine.world.entityList.create(type);
			Var v = newUserdata(ent);
			v.setMetatable(type);
			return v;
		};
		+/
	}

}



