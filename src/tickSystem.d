module game.tickSystem;


import
	ws.time,
	ws.math,
	ws.log;


class TickSystem {

	bool isRunning = true;
	float last;
	float tickRate = 60;

	void loop(){
		last = ws.time.time.now;
		try {
			last = ws.time.time.now();
			while(isRunning){
				double now = time.now();
				tick(now-last);
				ws.time.time.sleep(clamp(tickRate - (ws.time.time.now() - last), 0.0, 1.0/tickRate));
				last = now;
			}
		}catch(Throwable t)
			Log.error(t.toString());
	}

	abstract void tick(double ft);

	void shutdown(){
		isRunning = false;
	}

}
