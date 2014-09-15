module weapon.creator;

import
	weapon.base,
	editor.editor,
	window,
	gui.engine;


class Creator: Weapon {

	this(Engine engine){
		creator = engine.add!Editor(engine);
		creator.hide;
		name = "Creator";
	}
	
	override void onPrimary(bool b){
		if(b){
			creator.show;
			creator.parent.setTop(creator);
		}
	}
	
	protected {
		Editor creator;
	}

}