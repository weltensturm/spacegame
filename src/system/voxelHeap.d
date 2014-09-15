module game.system.voxelHeap;


import
	ws.nullable,
	ws.gl.render,
	ws.gl.material,
	ws.gl.model,
	ws.math.math,
	ws.math.vector,
	ws.math.transform,
	ws.math.collision,
	game.system.system,
	gui.engine;


class VoxelHeap: System {

	alias int[3] VoxelPos;
	VoxelPos[] cubes;

	this(){
		int width = 10;
		foreach(x; -width/2..width/2+1)
			foreach(y; -width/2..width/2+1){
				/+ TODO: add cubes
				auto cube = world.entityList.create("UniformCube");
				cube.setPos(vec(x, y, 0));
				cubes[[x,y,0]] = cube;
				+/
			}
	}

	void spawn(VoxelPos pos){
		if(pos !in cubes){
			/+ TODO: add cubes
			auto cube = world.entityList.create("UniformCube");
			cube.setPos(vec(pos));
			cubes[pos] = cube;
			+/
		}
	}

	void remove(VoxelPos pos){
		if(pos in cubes){
			cubes[pos].remove;
			cubes.remove(pos);
		}
	}

	LineCubeResult trace(Vector!3 start, Vector!3 dir){
		LineCubeResult result;
		foreach(pos, cube; cubes){
			auto collision = collide(Line(start, dir), Cube(vec(pos[0], pos[1], pos[2]), 1));
			if(collision && (!result || collision.distance < result.distance)){
				result = collision;
			}
		}
		return result;
	}

	Nullable!VoxelPos removePos(Vector!3 start, Vector!3 dir){
		auto res = trace(start, dir);
		if(res){
			auto p = res.pos - res.normal/2;
			return new Nullable!VoxelPos(Vector!(3,int)([
				cast(int)round(p.x), cast(int)round(p.y), cast(int)round(p.z)
			]));
		}
		return null;
	}

	Nullable!VoxelPos spawnPos(Vector!3 start, Vector!3 dir){
		auto res = hitCube(start, dir);
		if(res){
			auto p = res.pos + res.normal/2;
			return new Nullable!VoxelPos(Vector!(3,int)([
				cast(int)round(p.x), cast(int)round(p.y), cast(int)round(p.z)
			]));
		}
		return null;
	}

}

