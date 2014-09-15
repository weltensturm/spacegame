module entity.camera;

import
	ws.math.math,
	ws.math.angle,
	ws.math.quaternion,
	ws.math.vector,
	ws.math.matrix,
	game.component.transform,
	window;


class Camera: Transform {

	protected {
		float m_aspect, m_fov, m_near, m_far;
		Matrix!(4,4) matrix;
	}

	this(){
		matrix = new Matrix!(4,4);
		m_fov = 45;
		m_near = 0.01;
		m_far = 10000;
		update();
	}

	@property
	void aspect(float a){
		m_aspect = a;
		update;
	}
	@property
	float aspect(){
		return m_aspect;
	}

	@property
	void fov(float f){
		m_fov = f;
		update;
	}
	@property
	float fov(){
		return m_fov;
	}
	
	@property
	void near(float n){
		m_near = n;
		update;
	}
	@property
	float near(){
		return m_near;
	}

	@property
	void far(float v){
		m_far = v;
		update;
	}
	@property
	float far(){
		return m_far;
	}

	void update(){
		auto tanHalfFovy = tan(m_fov/360*PI);
		matrix[0,0] = 1 / (m_aspect * tanHalfFovy);
		matrix[1,1] = 1 / tanHalfFovy;
		matrix[2,2] = - (m_far + m_near) / (m_far - m_near);
		matrix[3,2] = - 1;
		matrix[2,3] = (2 * m_far * m_near) / (m_near - m_far);
		matrix[3,3] = 0;
	}

	Matrix!(4,4) getProjection(){
		return matrix;
	}

	Matrix!(4,4) getView(){
		auto view = new Matrix!(4,4);
		view.rotate(angle*Quaternion.euler(180,180,180));
		view.translate(-position);
		return view;
	}

	Vector!3 screenToWorld(float[2] v, int[2] screen){
		auto res = Vector!3((getProjection()*getView()).inverse * [2*v[0]/screen[0]-1, 2*v[1]/screen[1]-1, 1]);
		return res;
	}

	int[3] worldToScreen(float[3] v, int[2] screen){
		auto product = getProjection() * getView() * v;
		int x = cast(int)((product[0]/product[2]+1)*screen[0]/2);
		int y = cast(int)((product[1]/product[2]+1)*screen[1]/2);
		return [x, y, cast(int)product[2]];
	}

}
