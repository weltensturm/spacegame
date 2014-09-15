module gui.weaponSelection;



import
	ws.gl.draw,
	ws.gui.base,
	ws.gui.text,
	ws.math.math,
	ws.time,
	game.component.weapons,
	weapon.base,
	gui.engine;



class WeaponSelection: Base {

	this(Weapons weapons){
		this.player = player;
	}

	override void onDraw(){
		auto t = time.now();
		if(lastActive > t-visibleTime){
			float alpha = clamp((lastActive-t+visibleTime)*5, 0, 1);
			int count = 0;
			foreach(name, weapon; weapons){
				if(weapon == player.weapon)
					draw.setColor(0.5,0.1,0.1,alpha);
				else
					draw.setColor(0.1,0.1,0.1,alpha);
				draw.rect(pos+Point(0,count++*30), [size.x, 30]);
				name.style.fg = [1,1,1,alpha];
			}
			super.onDraw(); 
		}
	}
	
	void update(){
		foreach(n, w; weapons)
			children.remove(n);
		weapons.destroy;
		foreach(i, weapon; player.allWeapons){
			auto name = add!Text();
			name.text.set(weapon.name);
			name.setFont("UbuntuMono-R", cast(int)(30/1.5));
			name.setSize(size.x, 30);
			name.setPos(pos.x, pos.y + cast(int)i*30);
			weapons[name] = weapon;
		}
		lastActive = time.now;
	}

	void clear(){
		lastActive = time.now-visibleTime;
	}

	protected {
		Weapons weapons;
		float lastActive;
		float visibleTime = 2;
	}

}
