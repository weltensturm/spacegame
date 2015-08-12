module game.entity.planet;


	/+
import ws.gl.batch;


const int CHUNK_WIDTH = 32;
const float VOXEL_SIZE = 1;


enum Type {

	empty,
	lava,
	soil

}

enum Geometry {

	normal

}

struct Voxel {
	Geometry geometry;
	Type type;
}


void cube(Batch batch, float[3] offset, int size){
	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset[]+[1,0,0], [0,0,1], [0,1]);
	batch.addPoint(offset[]+[0,1,0], [0,0,1], [1,0]);
	batch.addPoint(offset[]+[1,1,0], [0,0,1], [1,1]);

	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset, [0,0,1], [0,1]);
	batch.addPoint(offset, [0,0,1], [1,0]);
	batch.addPoint(offset, [0,0,1], [1,1]);

	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset, [0,0,1], [0,1]);
	batch.addPoint(offset, [0,0,1], [1,0]);
	batch.addPoint(offset, [0,0,1], [1,1]);

	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset, [0,0,1], [0,1]);
	batch.addPoint(offset, [0,0,1], [1,0]);
	batch.addPoint(offset, [0,0,1], [1,1]);

	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset, [0,0,1], [0,1]);
	batch.addPoint(offset, [0,0,1], [1,0]);
	batch.addPoint(offset, [0,0,1], [1,1]);

	batch.addPoint(offset, [0,0,1], [0,0]);
	batch.addPoint(offset, [0,0,1], [0,1]);
	batch.addPoint(offset, [0,0,1], [1,0]);
	batch.addPoint(offset, [0,0,1], [1,1]);
}


class Chunk {
	
	Voxel[CHUNK_WIDTH^3] data;


	void build(){
		auto batch = new Batch;
		batch.begin(6*active, GL_QUADS);
		foreach(x; 0..CHUNK_WIDTH)
			foreach(y; 0..CHUNK_WIDTH)
				foreach(z; 0..CHUNK_WIDTH){
					batch.cube([x,y,z], VOXEL_SIZE);
				}
	}

	int active(){
		int count;
		foreach(v; data)
			if(v.type)
				count++;
		return count;
	}


}


class PlanetNode {

	PlanetNode[] children;
	Voxel lod;

	this(){
		lod = build;
	}


	Type build(){
		Type[int] count;

	}

}


class Planet {

	PlanetNode root;
	int radius;


}


	+/