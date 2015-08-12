module gui.weaponSelection;



import
	ws.gl.draw,
	ws.gui.base,
	ws.gui.text,
	ws.math.math,
	ws.time,
	game.weapons.weapons,
	weapon.base,
	gui.engine;



class WeaponSelection: Base {

	protected {
		Weapons weapons;
		Text[] titles;
		float lastActive;
		float visibleTime = 2;
	}

	this(Weapons weapons){
		this.weapons = weapons;
	}

	override void onDraw(){
		auto t = time.now();
		if(lastActive > t-visibleTime){
			float alpha = clamp((lastActive-t+visibleTime)*5, 0, 1);
			int count = 0;
			foreach(i, text; titles){
				if(i == weapons.active)
					draw.setColor([0.5,0.1,0.1,alpha]);
				else
					draw.setColor([0.1,0.1,0.1,alpha]);
				draw.rect(pos.a+[0,count++*30], [size.x, 30]);
				text.style.fg = [1,1,1,alpha];
			}
			super.onDraw(); 
		}
	}
	
	void update(){
		foreach(t; titles)
			children = children.without(t);
		titles.destroy;
		foreach(i, weapon; weapons.weapons){
			auto name = addNew!Text();
			name.text.set(weapon.name);
			name.setFont("UbuntuMono-R", cast(int)(30/1.5));
			name.resize([size.x, 30]);
			name.move(pos.a + [0, i*30]);
			titles ~= name;
		}
		lastActive = time.now;
	}

	void clear(){
		lastActive = time.now-visibleTime;
	}

}
