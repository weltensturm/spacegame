module game.system.draw;

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
	game.system.system,
	game.component.drawable,
	game.component.transform,
	game.component.pointLight,
	window;


alias EventDraw = ws.event.Event!(ModelMatrix, Matrix!(4,4), Matrix!(4,4));


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


class Draw: System {

	protected {

		Model[string] models;
		LoaderThread glLoader;
		LoaderQueue batchFinisher;
		LoaderQueue materialFinisher;
		EntityManager ents;
		WorldPerspective perspective;
		Entity player;
		DeferredMaterial defaultMat;
		ModelMatrix model;

		bool rebuildFramebuffer;
		
		Shader shaderLightPoint;
		Shader directionalPass;
		Shader shaderFinalize;
		Shader nullPass;
		//GBuffer gbuffer;
		FrameBuffer geomBuffer;
		FrameBuffer lightBuffer;
		Batch screenQuad;
		Model lightSphere;
		int width, height;

		int batchTick;
		int materialTick;
	}

	Render render;
	EventDraw eventDraw;

	Model getModel(string path){
		if(path in models)
			return models[path];
		auto m = new Model(path, glLoader, batchFinisher, materialFinisher);
		models[path] = m;
		return m;
	}

	this(Window window, EntityManager ents, Entity player, WorldPerspective perspective){
		this.ents = ents;
		this.perspective = perspective;
		model = new ModelMatrix;
		defaultMat = new DeferredMaterial("error", ["normal_default": "forwardNormal"], ["diffuse_default", "normal_default"]);
		defaultMat.finish();
		render = new Render({ return perspective.projection.getProjection * perspective.getView * model.back; });
		auto sharedContext = window.shareContext;
		glLoader = new LoaderThread({
			window.makeCurrent(sharedContext);
		});
		batchFinisher = new LoaderQueue;
		materialFinisher = new LoaderQueue;
		eventDraw = new EventDraw;

		width = 512;
		height = 512;
		//gbuffer = new GBuffer(width, height);
		geomBuffer = new FrameBuffer(width, height, 2);
		lightBuffer = new FrameBuffer(width, height, 1);
		string[uint] empty;
		nullPass = Shader.load("deferred_null", empty);
		shaderLightPoint = Shader.load("deferred_light_point", [gl.attributeVertex: "vertex"]);
		//directionalPass = Shader.load("deferred_light_directional", [gl.attributeVertex: "vertex"], [GBuffer.LIGHT: "frag"]);
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

	void draw(){
		perspective.update;

		auto projection = perspective.projection.getProjection;
		auto view = perspective.getView;
		auto matVP = projection*view;

		float[3] screen = [width, height, 0];

		if(rebuildFramebuffer){
			//gbuffer.destroy;
			//gbuffer = new GBuffer(width, height);
			geomBuffer.destroy;
			geomBuffer = new FrameBuffer(width, height, 2);
			lightBuffer.destroy;
			lightBuffer = new FrameBuffer(width, height, 1);
			rebuildFramebuffer = false;
		}
		model.reset();
		//gbuffer.startFrame;
		//gbuffer.bindGeom;
		
		geomBuffer.draw([DeferredMaterial.diffuse, DeferredMaterial.normal]);
		glClearColor(0.3, 0.3, 0.3, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glViewport(0,0,width,height);
		glEnable(GL_DEPTH_TEST);
		glDepthMask(GL_TRUE);
		glDisable(GL_BLEND);		
		float[3] clear = [0, 0, 0];
		float one = 1;
		for(int i=0; i<GBuffer.NUM; i++)
			glClearBufferfv(GL_COLOR, i, clear.ptr);
		glClearBufferfv(GL_DEPTH, 0, &one);
		foreach(drawable, transform; ents.iterate!(Drawable,Transform)){
			if(!drawable.model || !drawable.model.loaded)
				continue;

			model.push;
			model.translate(transform.position);

			foreach(d; drawable.model.data){
				if(!d.batch)
					continue;
				auto mat = (d.material && d.material.loaded) ? d.material : defaultMat;
				mat.use("mvp", matVP*model.back, "world", model.back);
				d.batch.draw;
			}

			model.pop;
		}
		glEnable(GL_BLEND);
		glDepthMask(GL_FALSE);
		

		// point lights
		//gbuffer.bindLight;
		lightBuffer.draw([0]);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		glClearColor(0, 0, 0, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		//gbuffer.bindDepth(5);
	
 		foreach(transform, light; ents.iterate!(Transform,PointLight)){
			shaderLightPoint.use(
					"mapDiffuse", geomBuffer.textures[0].bind(0),
					"mapNormal", geomBuffer.textures[1].bind(1),
					"mapDepth", geomBuffer.depth.bind(2),

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
		//gbuffer.bindTextures;
		//lightBuffer.read([5: 0]);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		
		shaderFinalize.use(
				"screen", screen,
				"mapDiffuse", geomBuffer.textures[0].bind(0),
				"mapNormal", geomBuffer.textures[1].bind(1),
				"mapLight", lightBuffer.textures[0].bind(2)
		);
        screenQuad.draw;
		
		geomBuffer.blit(0, 20, 20, 300);
		geomBuffer.blit(1, 340, 20, 300);
		lightBuffer.blit(0, 980, 20, 300);

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);

		try {
			if(batchTick++ > 1){
				batchFinisher.tick;
				batchTick = 0;
				writeln("batch: ", batchFinisher.length);
			}
			if(materialTick++ > 10){
				materialFinisher.tick;
				materialTick = 0;
				writeln("material: ", materialFinisher.length);
			}
		}
		catch(Exception e)
			Log.warning("DRAW MAIN LOADER ERROR: " ~ e.toString);
	}

	/+
	void blit(int which, int x, int y, int w){
		float aspect = width/cast(float)height;
		int h = cast(int)(w/aspect);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
		gbuffer.bindRead(which);
		glBlitFramebuffer(0,0,width,height,x,y,x+w,y+h,GL_COLOR_BUFFER_BIT,GL_LINEAR);
	}
	+/

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
	
