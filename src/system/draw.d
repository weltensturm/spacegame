module game.system.draw;

import
	derelict.opengl3.gl3,
	std.math,
	std.string,

	ws.event,
	ws.gui.base,
	ws.exception,
	ws.gui.point,
	ws.io,
	ws.log,
	ws.time,
	ws.string,
	ws.math.math,
	ws.math.angle,
	ws.math.quaternion,
	ws.math.vector,
	ws.math.matrix,
	ws.gl.material,
	ws.gl.gl,
	ws.gl.render,
	ws.gl.texture,
	ws.gl.model,
	ws.gl.draw,
	ws.thread.loader,

	gui.weaponSelection,
	matrixStack,
	game.system.system,
	game.component.drawable,
	window;


__gshared:


struct Screen {
	double w;
	double h;
}

struct Light {
	float intensity = 100;
	Vector!3 color = Vector!3(1,1,1);
	Vector!3 position = Vector!3(0,0,0);
}

class WorldMatrix: MatrixStack {

	this(){
		super();
	}

	void reset(){
		clear;
		push(new Matrix!(4,4));
	}
	
	Matrix!(4,4) getModelviewProjection(){
		return player.camera.getProjection() * player.camera.getView() * back();
	}
	
	Matrix!(4,4) getModelview(){
		return player.camera.getView() * back();
	}
	
	Matrix!(3,3) getNormal(){
		auto normalMatrix = new Matrix!(3,3);
		normalMatrix.data[0..3] = back.data[0..3];
		normalMatrix.data[3..6] = back.data[4..7];
		normalMatrix.data[6..9] = back.data[8..11];
		return normalMatrix;
	}
	
}


class Draw: System {

	protected {

		Model[string] models;
		Drawable[] drawables;
		
	}
		
	Screen screen;
	Material defaultMat;
	WorldMatrix matrix;
	Light light;
	Render render;
	
	Model getModel(string path){
		if(path in models)
			return models[path];
		auto m = new Model(path);
		models[path] = m;
		return m;
	}
	
	void finishMaterial(Material m){
		m.finish();
	}
	
	this(Window window){
		matrix = new WorldMatrix;
		defaultMat = new Material(
			"error", ["singlelight": "forwardSpecular"], ["singlelight": "getSpecular"],
			["vertex": gl.attributeVertex, "normal": gl.attributeNormal, "texture": gl.attributeTexture]
		);
		defaultMat.finish();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		render = new Render({ return matrix.getModelviewProjection(); });

	}

	void draw(){
		if(!paused){
			currentTime = time.now();
			frameTime = (currentTime - lastRender).clamp!double(0, 1.0/60.0);
		}
		matrix.reset();
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		render.color = [1,0,0,1];
		render.line(light.position, light.position + Vector!3(10,0,0));
		render.color = [0,1,0,1];
		render.line(light.position, light.position + Vector!3(0,10,0));
		render.color = [0,0,1,1];
		render.line(light.position, light.position + Vector!3(0,0,10));
		foreach(e; drawables){
			matrix.push();
			e.draw(matrix, light, defaultMat);
			matrix.pop();
		}
		matrix.pop();
		glEnable(GL_BLEND);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		lastRender = currentTime;
	}

}

