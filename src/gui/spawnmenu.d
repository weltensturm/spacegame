module gui.spawnmenu;

import
	ws.io,
	ws.gl.draw,
	ws.gl.texture,
	ws.gui.base,
	ws.gui.button,
	ws.gui.text,
	ws.gui.tabs,
	ws.gui.point,
	ws.gui.grid,
	game.entity.entity,
	gui.engine;
	


class SpawnMenu: Tabs {

	Engine engine;

	this(Engine e){
		super(top);
		engine = e;
		offset = 0.7;
		e.commands.add("spawnmenu_show", (bool p){
			if(engine.hasFocus || !p)
				p ? show() : hide();
		});
		addPage("Entities", addNew!ListEntities(e));
		hide();
	}

	override void onDraw(){
		draw.setColor([0,0,0,0.8]);
		draw.rect(pos.a+[1,1].a*size.length/20, size.a-[1,1].a*size.length/10);
		super.onDraw();
	}

}

private:

	class ListEntities: Grid {
		
		Engine engine;
		
		this(Engine e){
			super(Point(100, 100));
			/+
			foreach(name, factory; e.world.entityList.classes)
				addEntry(name, factory.factory);
			engine = e;
			+/
		}

		void addEntry(string n, ComponentContainer delegate() factory){
			Button b = new EntityButton(n);
			add(b);
			b.leftClick ~= {
				factory();
			};
		}

		class EntityButton: Button {
	
			Texture image;
			Text title;

			this(string t){
				super(t);
				title = addNew!Text();
				title.text.set(t);
				title.setFont("consola", 12);
				try 
					image = Texture.load("entities/" ~ t ~ ".tga");
				catch(Exception e)
					image = Texture.load("entities/default.tga");
			}
			
			override void resize(int[2] size){
				title.move(pos);
				title.resize([size.w, 20]);
				super.resize(size);
			}
			
			override void onDraw(){
				draw.setColor([0,0,0,0.8]);
				draw.rect(pos, size);
				draw.setColor([1,1,1, mouseFocus ? 0.5 : 1]);
				//draw.texture = image;
				//draw.texturedRect(pos.a+[5,5], size.a-[10,10]);
				title.onDraw();
			}
			
		}
		
		
	}
