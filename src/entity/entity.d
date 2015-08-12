module game.entity.entity;


import
	std.string,
	std.traits,
	std.algorithm,
	game.component;


class ComponentContainer {

	private	Component[string] components;

	T get(T)(){
		return cast(T)components[T.stringof];
	}

	Component get(string s){
		return components[s];
	}

}

class Entity(Args...): ComponentContainer {

	mixin(memberComponents!(0, Args));

	this(){
		foreach(C; Args){
			mixin("%s = new C;".format(memberName!(C.stringof)));
			mixin("components[C.stringof] = %s;".format(memberName!(C.stringof)));
		}
	}

	// alias-this everything
	@property
	auto ref opDispatch(string member)(){
		static if(!checkExists!(member, Args))
			static assert(0);
		checkDuplicates!(member, Args);
		foreach(C; Args){
			static if(__traits(hasMember, C, member)){
				mixin("return %s.%s;".format(memberName!(C.stringof), member));
			}
		}
		assert(0);
	}

}


class EntityManager {

	private ComponentContainer[] entityList;
	private ComponentContainer[][string] componentLists;

	void add(ComponentContainer e){
		entityList ~= e;
		foreach(name, component; e.components){
			if(name !in componentLists)
				componentLists[name] = [];
			componentLists[name].sortedInsert(e);
			//assert(componentLists[name].isSorted!"cast(void*)a.entity < cast(void*)b.entity");
		}
	}

	ComponentContainer[] get(Args...)(){
		ComponentContainer[] result;
		mixin("Tuple!(" ~ containerListArgs!(Args.length-1) ~ ") queryLists;");
		foreach(i, C; Args)
			queryLists[i] = componentLists.get(C.stringof, []);
		foreach(match; setIntersection!"cast(void*)a < cast(void*)b"(queryLists)){
			result ~= match;
		}
		return result;
	}

	ComponentIterator!Args iterate(Args...)(){
		return ComponentIterator!Args(this);
	}

}


private struct ComponentIterator(Args...) {

	EntityManager em;

	this(EntityManager em){
		this.em = em;
	}

	int opApply(int delegate(Args) dg){
		int result = 0;
		mixin("Tuple!(" ~ containerListArgs!(Args.length-1) ~ ") queryLists;");
		foreach(i, C; Args)
			queryLists[i] = em.componentLists.get(C.stringof, []);
		Args parameters;
		foreach(match; setIntersection!"cast(void*)a < cast(void*)b"(queryLists)){
			foreach(i, C; Args)
				parameters[i] = match.get!C;
			synchronized(match)
				result = dg(parameters);
			if(result)
				break;
		}
		return result;
	}

}



template Tuple(Args...){
	alias Tuple = Args;
}

void sortedInsert(ref ComponentContainer[] list, ComponentContainer ent){
	list ~= ent;
	list.sort!"cast(void*)a < cast(void*)b";
}

string containerListArgs(int amt)(){
	static if(amt){
		return "ComponentContainer[], " ~ containerListArgs!(amt-1);
	}else
		return "ComponentContainer[]";
}

bool checkExists(string member, Args...)(){
	foreach(C; Args)
		if(__traits(hasMember, C, member))
			return true;
	return false;
}

void checkDuplicates(string member, Args...)(){
	foreach(I, C; Args)
		foreach(Cc; Args[I..$]){
			static if(!is(C == Cc) && __traits(hasMember, C, member) && __traits(hasMember, Cc, member)){
				pragma(msg, "[ERROR] Duplicate member in %s and %s: %s".format(C.stringof, Cc.stringof, member));
				static assert(0);
			}
		}
}

string memberName(string text)(){
	return text ~ "_";
}

string memberComponents(int id)(){
	return "";
}

string memberComponents(int id, T, Tmore...)(){
	return "Args[%s] %s;\n".format(id, memberName!(T.stringof))
		~ memberComponents!(id+1, Tmore);
}
