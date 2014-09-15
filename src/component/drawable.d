module game.component.drawable;

import
	ws.gl.model,
	ws.gl.material,
	game.system.draw,
	game.component.component,
	game.component.transform;


class Drawable: Component {
	
	Model model;

	void draw(Transform transform, WorldMatrix matrix, Light light, Material defaultMat){
		if(!model || !model.loaded)
			return;
		matrix.translate(transform.position);
		matrix.scale(1, 1, 1);
		matrix.rotate(transform.angle);
		foreach(d; model.data){
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
	}

}

