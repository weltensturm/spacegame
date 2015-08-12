module game.voxelChunk;


import
	std.algorithm,
	std.math,
	ws.gl.gl,
	ws.gl.batch,
	ws.math.vector,
	ws.math.quaternion,
	game.transform,
	game.vertexObject,
	game.component;


alias Voxel = int;


class VoxelChunk: Component {

	double voxelSize = 0.1;
	enum width = 32;
	Voxel[] data;
	VertexObject vertexObject;

	this(){
		data = new Voxel[width*width*width];
	}

	void build(){
		float[] vertices;
		float[] normals;
		float[] colors;
		void addSide(Vector!3 pos, float[3] normal, float[4] color, float[3][6] verts){
			foreach(vert; verts)
				vertices ~= (pos+vec(vert.x,vert.y,vert.z)/2)*voxelSize;
				foreach(_; 0..6){
					normals ~= normal;
					colors ~= color;
				}
		}
		enum faceInfo = [ // [fwd][right][up]
			[[ 1, 0, 0],[ 0,-1, 0],[ 0, 0, 1]],
			[[ 0, 1, 0],[ 1, 0, 0],[ 0, 0, 1]],
			[[-1, 0, 0],[ 0, 1, 0],[ 0, 0, 1]],
			[[ 0,-1, 0],[-1, 0, 0],[ 0, 0, 1]],
			[[ 0, 0, 1],[ 1, 0, 0],[ 0,-1, 0]],
			[[ 0, 0,-1],[ 1, 0, 0],[ 0, 1, 0]]
		];
		foreach(x; 0..width)
			foreach(y; 0..width)
				foreach(z; 0..width){
					auto data = data[x+y*width+z*width*width];
					if(data > 0){
						float[4] c = [data,0,0,0];
						auto p = vec(x, y, z);
						foreach(face; faceInfo){
							auto dir = vec(face[0].x, face[0].y, face[0].z);
							auto right = vec(face[1].x, face[1].y, face[1].z);
							auto up = vec(face[2].x, face[2].y, face[2].z);
							if(this[x+face[0].x, y+face[0].y, z+face[0].z] <= 0){
								addSide(
									p, dir, c,
									[-right+up+dir, right+up+dir, right-up+dir,
									right-up+dir, -right-up+dir, -right+up+dir]
								);
							}
						}
					}
				}
		vertexObject = new VertexObject(
			cast(int)vertices.length/3,
			[gl.attributeVertex: vertices, gl.attributeNormal: normals, gl.attributeColor: colors]
		);
	}

	Voxel opIndex(long x, long y, long z){
		if(x < 0 || y < 0 || z < 0 || x >= width || y >= width || z >= width)
			return -1;
		return data[cast(size_t)(x + y*width + z*width*width)];
	}

	int opApply(int delegate(int x, int y, int z, Voxel voxel) dg){
		int ret;
		foreach(x; 0..width)
			foreach(y; 0..width)
				foreach(z; 0..width){
					auto data = data[x+y*width+z*width*width];
					if(data > 0){
						ret = dg(x, y, z, data);
						if(ret)
							return ret;
					}
				}
		return ret;
	}

}
