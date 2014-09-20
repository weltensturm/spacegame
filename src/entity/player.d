module game.input.movement;


import
	ws.math,
	gui.weaponSelection,
	game.component.weapons,
	game.component.transform,
	game.component.noclip,
	game.commands;


class Player {

	Weapons weapons;
	Noclip movement;
	Transform transform;

	this(Commands commands, WeaponSelection weaponSelection, Weapons weapons){

		this.weapons = weapons;
		movement = new Noclip;
		transform = new Transform;

		commands.add("player_weapon_next", (){
			weapons.active++;
			if(weapons.active > weapons.weapons.length-1)
				weapons.active = 0;
			weaponSelection.update;
		});
		commands.add("player_weapon_previous", (){
			weapons.active--;
			if(weapons.active >= weapons.weapons.length)
				weapons.active = cast(int)(weapons.weapons.length-1);
			weaponSelection.update;
		});
		
		commands.add("player_weapon_fire", (bool b){
			weapons.weapons[weapons.active].onPrimary(b);
			weaponSelection.clear;
		});
		
		commands.add("player_weapon_fire_secondary", (bool b){
			weapons.weapons[weapons.active].onSecondary(b);
			weaponSelection.clear;
		});

		commands.add("player_move_x", (float x){
			movement.velocityTarget[0] = clamp(x, -1, 1);
		});
		commands.add("player_move_y", (float y){
			movement.velocityTarget[1] = clamp(y, -1, 1);
		});
		commands.add("player_move_z", (float z){
			movement.velocityTarget[2] = clamp(z, -1, 1);
		});

	}

}
