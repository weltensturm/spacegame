module game.vertexObject;


import
	std.string,
	ws.gl.gl;



class VertexObject {

	immutable int vertexCount;
	immutable uint type;
	uint vao;
	Array[int] arrays;

	this(int vertexCount, float[][int] vertexData, uint type=GL_TRIANGLES){
		this.vertexCount = vertexCount;
		this.type = type;
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);
		foreach(attrId, data; vertexData){
			assert(data.length % vertexCount == 0, format("%s %% %s = %s", data.length, vertexCount, data.length % vertexCount));
			auto width = data.length/vertexCount;
			auto array = new Array(cast(int)width);
			array.array[0..vertexCount*width] = vertexData[attrId][0..$];
			arrays[attrId] = array;
		}
		foreach(attrId, array; arrays){
			glBindBuffer(GL_ARRAY_BUFFER, array.globj);
			glUnmapBuffer(GL_ARRAY_BUFFER);
		}
		glBindVertexArray(vao);
		foreach(attrId, array; arrays){
			glBindBuffer(GL_ARRAY_BUFFER, array.globj);
			glEnableVertexAttribArray(attrId);
			glVertexAttribPointer(attrId, array.size, GL_FLOAT, GL_FALSE, 0, null);
		}
		glBindVertexArray(0);
	}

	void draw(){
		glBindVertexArray(vao);
		glDrawArrays(type, 0, vertexCount);
	}

	class Array {

		float* array = null;
		uint globj = 0;
		uint size;

		this(int size){
			this.size = size;
			glGenBuffers(1, cast(uint*)&globj);
			glBindBuffer(GL_ARRAY_BUFFER, globj);
			glBufferData(GL_ARRAY_BUFFER, float.sizeof*size*vertexCount, null, GL_DYNAMIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, globj);
			array = cast(float*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
			if(!array)
				throw new Exception("Failed to create array buffer");
		}
		
		void update(float[] data, size_t pos=0, size_t length=1){
			glBindBuffer(GL_ARRAY_BUFFER, globj);
			glBufferSubData(GL_ARRAY_BUFFER, pos*size*float.sizeof, length*size*float.sizeof, data.ptr);
		}

		void destroy(){
			glDeleteBuffers(1, &globj);
		}

	}

}

