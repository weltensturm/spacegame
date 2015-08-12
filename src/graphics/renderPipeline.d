module game.graphics.draw;

import
	derelict.opengl3.gl3,
	std.math,
	std.string,

	ws.gl.batch,
	ws.gl.shader,
	ws.gl.gbuffer,
	ws.gl.framebuffer,
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
	gui.worldPerspective,
	matrixStack,
	game.entity.entity,
	game.transform,
	game.voxelChunk,
	game.graphics.drawable,
	game.graphics.lightGlobal,
	game.graphics.pointLight,
	window;


alias EventDraw = ws.event.Event!(Matrix!(4,4), Matrix!(4,4));


class ModelMatrix: MatrixStack {

	void reset(){
		clear;
		push(new Matrix!(4,4));
	}

	Matrix!(3,3) getNormal(){
		auto normalMatrix = new Matrix!(3,3);
		normalMatrix.data[0..3] = back.data[0..3];
		normalMatrix.data[3..6] = back.data[4..7];
		normalMatrix.data[6..9] = back.data[8..11];
		return normalMatrix;
	}

}


class RenderPipeline {

	protected {

		Model[string] models;
		LoaderThread glLoader;
		LoaderQueue batchFinisher;
		EntityManager ents;
		WorldPerspective perspective;
		DeferredMaterial defaultMat;
		ModelMatrix model;

		bool rebuildFramebuffer;
		
		Shader shaderLightGlobal;
		Shader shaderLightPoint;
		Shader directionalPass;
		Shader shaderFinalize;
		Shader nullPass;
		FrameBuffer geomBuffer;
		FrameBuffer lightBuffer;
		Batch screenQuad;
		Model lightSphere;
		int width, height;

		int batchTick;
	}
	DeferredMaterial voxelMat;

	Render render;
	EventDraw eventDraw;

	Model getModel(string path){
		if(path in models)
			return models[path];
		auto m = new Model(path, glLoader, batchFinisher);
		models[path] = m;
		return m;
	}

	this(Window window, EntityManager ents, WorldPerspective perspective){
		this.ents = ents;
		this.perspective = perspective;
		model = new ModelMatrix;
		defaultMat = new DeferredMaterial("error", ["normal_default": "forwardNormal"], ["diffuse_default", "normal_default", "lit"]);
		defaultMat.finish;
		voxelMat = new DeferredMaterial(
			"voxel",
			["normal_default": "forwardNormal", "diffuse_voxel": "forwardColor"],
			["diffuse_voxel", "normal_default", "lit"],
			["vertex": gl.attributeVertex, "normal": gl.attributeNormal, "color": gl.attributeColor]
		);
		voxelMat.finish;
		render = new Render({ return perspective.projection.getProjection * perspective.getView * model.back; });
		auto sharedContext = window.shareContext;
		glLoader = new LoaderThread({
			window.makeCurrent(sharedContext);
		});
		batchFinisher = new LoaderQueue;
		eventDraw = new EventDraw;

		width = 512;
		height = 512;
		geomBuffer = new FrameBuffer(width, height, 3);
		lightBuffer = new FrameBuffer(width, height, 1);
		string[uint] empty;
		nullPass = Shader.load("deferred_null", empty);
		shaderLightGlobal = Shader.load("deferred_light_global", [gl.attributeVertex: "vertex"]);
		shaderLightPoint = Shader.load("deferred_light_point", [gl.attributeVertex: "vertex"]);
		shaderFinalize = Shader.load("deferred_finalize", [gl.attributeVertex: "vertex"]);

		lightSphere = new Model("light_sphere.obj");

		screenQuad = new Batch;
		screenQuad.begin(4, GL_TRIANGLE_FAN);
		screenQuad.add([-1, 1, 0]);
		screenQuad.add([-1, -1, 0]);
		screenQuad.add([1, -1, 0]);
		screenQuad.add([1, 1, 0]);
		screenQuad.finish;
	}

	void shutdown(){
		glLoader.shutdown;
	}

	void draw(){

		glViewport(0,0,width,height);

		perspective.update;
		auto projection = perspective.projection.getProjection;
		auto view = perspective.getView;
		auto matVP = projection*view;

		float[3] screen = [width, height, 0];

		if(rebuildFramebuffer){
			geomBuffer.destroy;
			geomBuffer = new FrameBuffer(width, height, 3);
			lightBuffer.destroy;
			lightBuffer = new FrameBuffer(width, height, 1);
			rebuildFramebuffer = false;
		}
		model.reset();

		glEnable(GL_DEPTH_TEST);
		glDepthMask(GL_TRUE);
		glDisable(GL_BLEND);
		glEnable(GL_CULL_FACE);
		glClearColor(0, 0, 0, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		geomBuffer.draw(DeferredMaterial.targetTextures);
		geomBuffer.clear;
		foreach(drawable, transform; ents.iterate!(Drawable,Transform)){
			if(!drawable.model || !drawable.model.loaded)
				continue;
			model.push;
			model.translate(transform.position);
			auto mvp = matVP*model.back;
			foreach(d; drawable.model.data){
				if(!d.batch)
					continue;
				auto mat = (d.material && d.material.loaded) ? d.material : defaultMat;
				mat.use("mvp", mvp, "world", model.back);
				d.batch.draw;
			}
			model.pop;
		}
		foreach(chunk, transform; ents.iterate!(VoxelChunk,Transform)){
			model.push;
			model.translate(transform.position);
			auto mvp = matVP*model.back;
			voxelMat.use("mvp", mvp, "world", model.back);
			chunk.vertexObject.draw;
		}
		eventDraw(projection, view);

		glEnable(GL_BLEND);
		glDepthMask(GL_FALSE);
		
		// point lights
		lightBuffer.draw([0]);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		glClearColor(0.05, 0.05, 0.05, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	
		foreach(transform, light; ents.iterate!(Transform,LightGlobal)){
			shaderLightGlobal.use(
				"mapDiffuse", geomBuffer.textures[0].bind(0),
				"mapNormal", geomBuffer.textures[1].bind(1),
				"mapLightData", geomBuffer.textures[2].bind(2),
				"mapDepth", geomBuffer.depth.bind(3),

				"screen", screen,
				"vpI", matVP.inverse,

				"lightColor", light.color,
				"lightAmbient", light.ambientIntensity,
				"lightDiffuse", light.diffuseIntensity,
				"lightPosition", transform.position,
				"specPower", 0.2f,
				"specIntensity", 0.2f
			);
			screenQuad.draw;
		}

 		foreach(transform, light; ents.iterate!(Transform,PointLight)){
			shaderLightPoint.use(
				"mapDiffuse", geomBuffer.textures[0].bind(0),
				"mapNormal", geomBuffer.textures[1].bind(1),
				"mapLightData", geomBuffer.textures[2].bind(2),
				"mapDepth", geomBuffer.depth.bind(3),

				"screen", screen,
				"vpI", matVP.inverse,

				"lightColor", light.color,
				"lightAmbient", light.ambientIntensity,
				"lightDiffuse", light.diffuseIntensity,
				"lightPosition", transform.position,
				"attenConstant", light.attenuationConstant,
				"attenLinear", light.attenuationLinear,
				"attenExp", light.attenuationExp,
				"specPower", 0.2f,
				"specIntensity", 0.2f
			);
			screenQuad.draw;
		}

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClearColor(0, 0, 0, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		
		shaderFinalize.use(
			"screen", screen,
			"mapDiffuse", geomBuffer.textures[0].bind(0),
			"mapNormal", geomBuffer.textures[1].bind(1),
			"mapLightInfo", geomBuffer.textures[2].bind(2),
			"mapLight", lightBuffer.textures[0].bind(3)
		);
		screenQuad.draw;
		
		geomBuffer.blit(0, 20, 20, 300);
		geomBuffer.blit(1, 340, 20, 300);
		lightBuffer.blit(0, 660, 20, 300);

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);

		try {
			if(batchTick++ > 1){
				batchFinisher.tick;
				batchTick = 0;
			}
		}
		catch(Throwable e)
			Log.warning("DRAW MAIN LOADER ERROR: " ~ e.toString);
	}

	void setScreenSize(int w, int h){
		rebuildFramebuffer = true;
		width = w;
		height = h;
	}

}

float calcPointLightSphere(PointLight light){
	float max = fmax(fmax(light.color[0], light.color[1]), light.color[2]);
	return (
		- light.attenuationLinear
			+ sqrt(
				light.attenuationLinear * light.attenuationLinear - 4 * light.attenuationExp
					* (light.attenuationExp - 256 * max * light.diffuseIntensity))
		) / 2 * light.attenuationExp;

}
	
