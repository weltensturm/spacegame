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
	game.entity.entity,
	game.system.system,
	game.component.camera,
	game.component.drawable,
	game.component.transform,
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

	Camera delegate() camera;

	this(Camera delegate() camera){
		this.camera = camera;
		super();
	}

	void reset(){
		clear;
		push(new Matrix!(4,4));
	}

	Matrix!(4,4) getModelviewProjection(){
		return camera().getProjection() * camera().getView() * back();
	}

	Matrix!(4,4) getModelview(){
		return camera().getView() * back();
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
		LoaderThread glLoader;
		LoaderQueue mainLoader;
		EntityManager ents;

	}

	Screen screen;
	Material defaultMat;
	WorldMatrix matrix;
	Light light;
	Render render;
	
	Model getModel(string path){
		if(path in models)
			return models[path];
		auto m = new Model(path, glLoader, mainLoader);
		models[path] = m;
		return m;
	}
	
	this(Window window, EntityManager ents, Camera delegate() camera){
		this.ents = ents;
		matrix = new WorldMatrix(camera);
		defaultMat = new Material(
			"error", ["singlelight": "forwardSpecular"], ["singlelight": "getSpecular"],
			["vertex": gl.attributeVertex, "normal": gl.attributeNormal, "texture": gl.attributeTexture]
		);
		defaultMat.finish();
		render = new Render({ return matrix.getModelviewProjection(); });
		auto sharedContext = window.shareContext;
		glLoader = new LoaderThread({
			window.makeCurrent(sharedContext);
		});
		mainLoader = new LoaderQueue;
	}

	void draw(){
		matrix.reset();
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		render.color = [1,0,0,1];
		render.line(light.position, light.position + Vector!3(10,0,0));
		render.color = [0,1,0,1];
		render.line(light.position, light.position + Vector!3(0,10,0));
		render.color = [0,0,1,1];
		render.line(light.position, light.position + Vector!3(0,0,10));

		foreach(drawable, transform; ents.iterate!(Drawable, Transform)){
			matrix.push();

			if(!drawable.model || !drawable.model.loaded)
				return;
			matrix.translate(transform.position);
			matrix.scale(1, 1, 1);
			matrix.rotate(transform.angle);
			foreach(d; drawable.model.data){
				if(!d.batch)
					continue;
				Material m = (d.mat && d.mat.loaded ? d.mat : defaultMat);
				m.use(
					"matMVP", matrix.getModelviewProjection(),
					"matMV", matrix.getModelview(),
					"matM", matrix.back(),
					"matN", matrix.getNormal(),
					"lightPosition", light.position,
					"diffuseColor", light.color,
					"specularColor", light.color,
					"ambientColor", light.color/10,
					"lumen", light.intensity
				);
				d.batch.draw();
			}

			matrix.pop();
		}
		matrix.pop();
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);

		mainLoader.tick();
	}

}

