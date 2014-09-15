module game.entity.entity;


import game.component.component;


final class Entity {

	private	Component[string] components;

	T get(T)(){
		return components[T.stringof];
	}

	private void addComponents()(Entity){}

	private void addComponents(T, Tnext...)(Entity e){
		components[T.stringof] = new T(e);
		addComponents!Tnext(e);
	}

}


class EntityManager {

	private Entity[] entityList;

	static Entity create(Components...)(){
		auto e = new Entity;
		addComponents!Components(e);
		entityList ~= e;
		return e;
	}

}

