module game.component.projection;

import
	ws.math,
	game.component.component,
	game.component.transform,
	window;


class Projection: Component {

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

}
