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
		LoaderQueue mainLoader;
		EntityManager ents;
		WorldPerspective perspective;
		Entity player;
		Material defaultMat;
		ModelMatrix model;

		bool rebuildFramebuffer;
		
		Shader shaderGeom;
		Shader shaderLightPoint;
		Shader directionalPass;
		Shader shaderFinalize;
		Shader nullPass;
		GBuffer gbuffer;
		FrameBuffer lightBuffer;
		Batch screenQuad;
		Model lightSphere;
		int width, height;

		float lastMatFinish;
	}

	Render render;
	ws.event.Event!(ModelMatrix, Matrix!(4,4), Matrix!(4,4)) onDraw;

	Model getModel(string path){
		if(path in models)
			return models[path];
		auto m = new Model(path, glLoader, mainLoader);
		models[path] = m;
		return m;
	}

	this(Window window, EntityManager ents, Entity player, WorldPerspective perspective){
		this.ents = ents;
		this.perspective = perspective;
		model = new ModelMatrix;
		defaultMat = new Material(
			"error", ["singlelight": "forwardSpecular"], ["singlelight": "getSpecular"],
			["vertex": gl.attributeVertex, "normal": gl.attributeNormal, "texture": gl.attributeTexture]
		);
		defaultMat.finish();
		render = new Render({ return perspective.projection.getProjection * perspective.getView * model.back; });
		auto sharedContext = window.shareContext;
		glLoader = new LoaderThread({
			window.makeCurrent(sharedContext);
		});
		mainLoader = new LoaderQueue;
		onDraw = new ws.event.Event!(ModelMatrix, Matrix!(4,4), Matrix!(4,4));

		width = 512;
		height = 512;
		gbuffer = new GBuffer(width, height);
		lightBuffer = new FrameBuffer(width, height, 1);
		shaderGeom = Shader.load(
				"deferred_geom",
				[
					gl.attributeVertex: "vertex",
					gl.attributeNormal: "normal",
					gl.attributeTexture: "texCoord"
				],
				[
					GBuffer.DIFFUSE: "outDiffuse",
					GBuffer.TEXCOORD: "outTexCoord",
					GBuffer.NORMAL: "outNormal"
				]
		);
		string[uint] empty;
		nullPass = Shader.load("deferred_null", empty);
		shaderLightPoint = Shader.load("deferred_light_point", [gl.attributeVertex: "vertex"]);
		//directionalPass = Shader.load("deferred_light_directional", [gl.attributeVertex: "vertex"], [GBuffer.LIGHT: "frag"]);
		shaderFinalize = Shader.load("deferred_finalize", [gl.attributeVertex: "vertex"]);

		/+
		auto light = PointLight();
		light.diffuseIntensity = 0.2;
		light.color = [1,0.5,0.5];
        light.position = Vector!3(0, 1.5, 5);
        light.diffuseIntensity = 1;
		light.attenuationConstant = 0;
        light.attenuationLinear = 0;
        light.attenuationExp = 0.1;
		pointLights ~= light;

		light.position = Vector!3(15, 1.5, 5);
		light.attenuationExp = 0.05;
		light.color = [1,1,1];
		pointLights ~= light;
		+/

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

		// geom pass
		if(rebuildFramebuffer){
			gbuffer.destroy;
			gbuffer = new GBuffer(width, height);
			lightBuffer.destroy;
			lightBuffer = new FrameBuffer(width, height, 1);
			rebuildFramebuffer = false;
		}
		model.reset();
		gbuffer.startFrame;
		gbuffer.bindGeom;
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
			shaderGeom.use("mvp", matVP*model.back, "world", model.back);
			model.pop;

			foreach(d; drawable.model.data){
				if(!d.batch)
					continue;
				if(d.mat)
					d.mat.activateTextures;
				d.batch.draw;
			}
		}
		glEnable(GL_BLEND);
		glDepthMask(GL_FALSE);

		// point lights
		gbuffer.bindLight;
		lightBuffer.draw([0]);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		glClearColor(0, 0, 0, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		gbuffer.bindDepth(5);
 		foreach(transform, light; ents.iterate!(Transform,PointLight)){
			shaderLightPoint.use(
					"mapDiffuse", GBuffer.DIFFUSE,
					"mapTexCoord", GBuffer.TEXCOORD,
					"mapNormal", GBuffer.NORMAL,
					"mapDepth", 5,

					"screen", screen,
					"vpI", matVP.inverse,

					"lightColor", light.color,
					"lightAmbient", light.ambientIntensity,
					"lightDiffuse", light.diffuseIntensity,
					"lightPosition", transform.position,
					"attenConstant", light.attenuationConstant,
					"attenLinear", light.attenuationLinear,
					"attenExp", light.attenuationExp,
					"specPower", 1.0f,
					"specIntensity", 1.0f 
			);
			screenQuad.draw;
		}

		/+
		// directional light pass
		glEnable(GL_BLEND);
		glBlendEquation(GL_FUNC_ADD);
		glBlendFunc(GL_ONE, GL_ONE);
		directionalPass.use("screen", screen);
		+/
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		gbuffer.bindTextures;
		lightBuffer.read([5: 0]);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		shaderFinalize.use(
				"screen", screen,
				"mapDiffuse", GBuffer.DIFFUSE,
				"mapTexCoord", GBuffer.TEXCOORD,
				"mapNormal", GBuffer.NORMAL,
				"mapLight", 5
		);
        screenQuad.draw;

		// draw to screen
		//gbuffer.bindFinal;
        //glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);

		blit(GBuffer.DIFFUSE, 20, 20, 300);
		blit(GBuffer.NORMAL, 340, 20, 300);
		blit(GBuffer.TEXCOORD, 660, 20, 300);
		lightBuffer.blit(0, 980, 20, 300);

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);

		try {
			if(lastMatFinish+5 < time.now){
				mainLoader.tick();
				lastMatFinish = time.now;
			}
		}
		catch(Exception e)
			Log.warning("DRAW MAIN LOADER ERROR: " ~ e.toString);
	}

	void blit(int which, int x, int y, int w){
		float aspect = width/cast(float)height;
		int h = cast(int)(w/aspect);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
		gbuffer.bindRead(which);
		glBlitFramebuffer(0,0,width,height,x,y,x+w,y+h,GL_COLOR_BUFFER_BIT,GL_LINEAR);
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
	
