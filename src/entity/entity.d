module game.entity.entity;


import
	std.traits,
	std.algorithm,
	game.component.component;


final class Entity {

	private	Component[string] components;

	T get(T)(){
		return cast(T)components[typeid(T).toString];
	}

	Component get(string s){
		return components[s];
	}

}


template Tuple(E...) {
	alias Tuple = E;
}


class EntityManager {

	private Entity[] entityList;

	Entity create(Components...)(){
		auto e = new Entity;
		addComponents!Components(e);
		entityList ~= e;
		return e;
	}

	Entity[] get(Args...)(){
		Entity[] result;
		string[] names = typenames!Args;
		foreach(e; entityList){
			bool valid = true;
			foreach(name; names){
				if(name !in e.components){
					valid = false;
					break;
				}
			}
			if(valid)
				result ~= e;
		}
		return result;
	}

	ComponentIterator!Args iterate(Args...)(){
		return ComponentIterator!Args(this);
	}

	private void addComponents()(Entity e){}

	private void addComponents(T, Tnext...)(Entity e){
		e.components[typeid(T).toString] = new T;
		addComponents!Tnext(e);
	}


}


private struct ComponentIterator(Args...) {

	EntityManager em;

	this(EntityManager em){
		this.em = em;
	}

	int opApply(int delegate(Args) dg){
		int result = 0;
		Args components;
		string[] names = typenames!Args;
		foreach(r; em.get!Args){
			foreach(i, component; components){
				components[i] = cast(Args[i])r.get(typeid(Args[i]).toString);
			}
			result = dg(components);
			if(result)
				break;
		}

		return result;
	}

}


private string[] typenames()(){
	return [];
}

private string[] typenames(T, Args...)(){
	return [typeid(T).toString] ~ typenames!Args;
}


