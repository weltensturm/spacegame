module game.input.movement;


import game.commands;


class Player {

	this(Commands commands){

		commands.add("player_weapon_next", (){
			currentWeapon++;
			if(currentWeapon > weapons.length-1)
				currentWeapon = 0;
			engine.world.weaponSelection.update;
		});
		commands.add("player_weapon_previous", (){
			if(engine.world.hasFocus && b){
				currentWeapon--;
				if(currentWeapon >= weapons.length)
					currentWeapon = weapons.length-1;
				engine.world.weaponSelection.update;
			}
		});
		
		commands.add("player_weapon_fire", (){
			if(engine.world.hasFocus)
				weapon.onPrimary(b);
			engine.world.weaponSelection.clear;
		});
		
		commands.add("player_weapon_fire_secondary", (){
			if(engine.world.hasFocus)
				weapon.onSecondary(b);
			engine.world.weaponSelection.clear;
		});

		commands.add("player_move_x", (float x){
			speedTarget[0] = clamp(x, -1, 1);
		});
		commands.add("player_move_y", (float y){
			speedTarget[1] = clamp(y, -1, 1);
		});
		commands.add("player_move_z", (float z){
			speedTarget[2] = clamp(z, -1, 1);
		});

	}

}
