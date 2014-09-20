module game.entity.entity;


import
	std.traits,
	std.algorithm,
	game.component.component;


final class Entity {

	private	Component[string] components;

	T get(T)(){
		return components[T.stringof];
	}

	Component get(string s){
		return components[s];
	}

	private void addComponents()(Entity){}

	private void addComponents(T, Tnext...)(Entity e){
		components[typeid(T).toString] = new T(e);
		addComponents!Tnext(e);
	}

}


template Tuple(E...) {
	alias Tuple = E;
}


class EntityManager {

	private Entity[][string] entityList;

	Entity create(Components...)(){
		auto e = new Entity;
		addComponents!Components(e);
		entityList ~= e;
		return e;
	}

	Entity[] get(T, Args...)(){
		string[] names = typenames!Args;
		Entity[] result = entityList.get(typeid(T).toString, []);
		foreach(name; names){
			Entity[] tmp;
			foreach(e; setIntersection(result, entityList.get(name, [])))
				tmp ~= e;
			result = tmp;
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
		Args components;

		string[] names = typenames!Args;
		foreach(r; em.get!Args){
			foreach(ref component; components)
				component = cast(typeof(component))r.get(typeid(component).toString);
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


T get(T)(T[string] map, string key, T def){
	if(key in map)
		return map[key];
	return def;
}

