module game.entity.player;


import
	gui.engine,
	game.entity.entity,
	game.weapon.ballCannon,
	game.transform,
	game.physics.humanMovement,
	game.physics.bulletPhysics,
	game.graphics.pointLight,
	game.graphics.projection,
	game.weapons.weapons;


double pow(double n, double e){
	int sign = (n > 0 ? 1 : -1);
	double pow = (n*sign)^^e;
	return pow*sign;
}


alias Player = Entity!(Projection, BulletPhysics, HumanControls, Transform, Weapons);


Player createPlayer(Engine engine){
	auto player = new Player;
	player.speed = 10;
	player.object = engine.physicsSystem.createObject("20cmsphere_ph.obj");

	engine.commands.add("look_x", (float x){
		if(!engine.perspective.hasFocus)
			return;
		player.angle.rotate(pow(-x, 1.1)/5, 0, 0, 1);
		//window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
	});

	engine.commands.add("look_y", (float y){
		if(!engine.perspective.hasFocus)
			return;
		player.angle.rotate(pow(-y, 1.1)/5, player.angle.right());
		//window.setCursorPos(cast(int)(size.x / 2), cast(int)(size.y / 2));
	});

	engine.commands.add("move_x", (float x){
		if(!engine.perspective.hasFocus)
			return;
		player.move[0] = x;
	});

	engine.commands.add("move_y", (float y){
		if(!engine.perspective.hasFocus)
			return;
		player.move[2] = y;
	});

	engine.commands.add("move_z", (float z){
		if(!engine.perspective.hasFocus)
			return;
		player.move[1] = z;
	});

	engine.commands.add("weapon_next", {
		if(!engine.perspective.hasFocus)
			return;
		player.Weapons_.active++;
		if(player.Weapons_.active >= player.Weapons_.weapons.length){
			player.Weapons_.active = 0;
		}
		engine.perspective.weaponSelection.update;
	});

	engine.commands.add("weapon_previous", {
		if(!engine.perspective.hasFocus)
			return;
		player.Weapons_.active--;
		if(player.Weapons_.active < 0)
			player.Weapons_.active = cast(int)player.Weapons_.weapons.length-1;
		engine.perspective.weaponSelection.update;
	});

	engine.commands.add("weapon_fire", (bool b){
		if(!engine.perspective.hasFocus)
			return;
		if(!player.Weapons_.weapons.length)
			return;
		player.Weapons_.weapons[player.Weapons_.active].onPrimary(b);
	});

	engine.commands.add("weapon_fire_alt", (bool b){
		if(!engine.perspective.hasFocus)
			return;
		if(!player.Weapons_.weapons.length)
			return;
		player.Weapons_.weapons[player.Weapons_.active].onSecondary(b);
	});

	engine.commands.add("player_pos", {
		import ws.io;
		writeln(player.position);
	});

	engine.ents.add(player);

	return player;
}


void playerWeapons(Engine engine, Player player){
	player.get!Weapons.weapons ~=
		new BallCannon(engine.ents, player, engine.perspective.renderPipeline, engine.physicsSystem);
}
