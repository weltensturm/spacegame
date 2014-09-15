
module matrixStack;

import std.math;
import ws.list, ws.math.matrix;


class MatrixStack: List!(Matrix!(4,4)) {

	this(){
		this ~= Matrix!(4,4).identity;
	}

	void loadIdentity(){
		back = Matrix!(4,4).identity;
	}

	void loadMatrix(Matrix!(4,4) matrix){
		back = matrix;
	}

	void multMatrix(T)(T o){
		back *= o;
	}

	void push(){
		super.push(back.dup());
	}
	
	override void push(Matrix!(4,4) m){
		super.push(m);
	}
	
	void pop(){
		popBack();
	}
	
	void scale(T...)(T a){
		back().scale(a);
	}
	
	void translate(T...)(T a){
		back().translate(a);
	}
	
	void rotate(T...)(T a){
		back().rotate(a);
	}
	
}

