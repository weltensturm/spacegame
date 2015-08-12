module game.voxelHeap;


import
	std.algorithm,
	ws.nullable,
	ws.gl.render,
	ws.gl.material,
	ws.gl.model,
	ws.math.math,
	ws.math.vector,
	ws.math.transform,
	ws.math.collision,
	gui.engine;


void remove(T)(T[] array, T obj){
	for(int i=0; i < array.length; i++)
		if(array[i] == obj)
			array = array[0..i] ~ array[i+1..$];
}


class VoxelHeap {

	alias int[3] VoxelPos;
	VoxelPos[] cubes;

	this(){
		int width = 10;
		foreach(x; -width/2..width/2+1)
			foreach(y; -width/2..width/2+1){
				cubes ~= [x,y,0];
			}
	}

	void spawn(VoxelPos pos){
		if(!cubes.canFind(pos))
			cubes ~= pos;
	}

	void remove(VoxelPos pos){
		if(cubes.canFind(pos))
			cubes.remove(pos);
	}

	LineCubeResult trace(Vector!3 start, Vector!3 dir){
		LineCubeResult result;
		foreach(cube; cubes){
			auto collision = collide(Line(start, dir), Cube(vec(cube[0], cube[1], cube[2]), 1));
			if(collision && (!result || collision.distance < result.distance)){
				result = collision;
			}
		}
		return result;
	}

	Nullable!VoxelPos removePos(Vector!3 start, Vector!3 dir){
		auto res = trace(start, dir);
		if(res){
			auto p = res.pos.vec - res.normal.vec/2;
			return new Nullable!VoxelPos(Vector!(3,int)([
				cast(int)round(p.x), cast(int)round(p.y), cast(int)round(p.z)
			]));
		}
		return null;
	}

	Nullable!VoxelPos spawnPos(Vector!3 start, Vector!3 dir){
		auto res = trace(start, dir);
		if(res){
			auto p = res.pos.vec + res.normal.vec/2;
			return new Nullable!VoxelPos(Vector!(3,int)([
				cast(int)round(p.x), cast(int)round(p.y), cast(int)round(p.z)
			]));
		}
		return null;
	}

}

