module gui.menu.input;

import
	std.array,
	ws.decode,
	ws.gl.draw,
	ws.gui.base,
	ws.gui.text,
	ws.gui.list,
	ws.gui.button,
	ws.gui.input,
	ws.io,
	window,
	game.input;

class InputMenu: List {

	Input input;

	this(Input input){
		this.input = input;
		
		style.fg = [1, 1, 1, 1];
		style.bg = [0.5,0.5,0.5,1];
		entryHeight = 25;
		padding = 10;
		Decode.file("config/menu.ws", (category, c, b){
			auto text = addNew!Text;
			text.style.fg = style.bg;
			text.text.set(category);
			Decode.text(c, (id, name, b){
				if(id[0] == '~')
					add(new InputFieldFloat(id[1..$], name, input));
				else
					add(new InputFieldSimple(id, name, input));
			});
		});
	}

}


class InputFieldSimple: Base {
	
	Text title;
	InputButton input;

	this(string action, string name, Input Input){
		style.bg = [0,0,0,0.4];
		title = addNew!Text;
		title.text.set(name);
		title.moveLocal([0,0]);
		input = addNew!InputButton(action, Input);
	}

	override void resize(int[2] size){
		title.resize([size.w/2, size.h]);
		input.resize([size.w/2, size.h]);
		input.moveLocal([size.w/2, 0]);
		title.setFont("Ubuntu-R", cast(int)(size.h/1.8));
		super.resize(size);
	}
	
	override void onDraw(){
		draw.setColor(style.bg.normal);
		draw.rect(pos, size);
		super.onDraw();
	}

}




class InputFieldFloat: Base {

	Text title;
	InputButton input1;
	InputButton input2;

	this(string action, string name, Input Input){
		style.bg = [0,0,0,0.4];
		title = addNew!Text;
		title.text.set(name);
		title.moveLocal([0,0]);

		input1 = addNew!InputButton(action, Input);
		input2 = addNew!InputButton(action, Input, true);
	}

	override void resize(int[2] size){
		title.resize([size.w/2, size.h]);
		input1.resize([size.w/4, size.h]);
		input1.moveLocal([size.w/2, 0]);
		input2.resize([size.w/4, size.h]);
		input2.moveLocal([size.w/4*3, 0]);
		title.setFont("Ubuntu-R", cast(int)(size.h/1.8));
		super.resize(size);
	}
	
	override void onDraw(){
		draw.setColor(style.bg.normal);
		draw.rect(pos, size);
		super.onDraw();
	}

}



class InputButton: Button {

	string action;
	Input input;

	this(string action, Input input, bool whenNegative=false){
		super("");
		action = (whenNegative ? "-": "") ~ action;
		this.action = action;
		this.input = input;
		updateText;
		leftClick ~= {
			text = "Press input ...";
			input.captureNext((key, value){
				input.bind(key, action);
				updateText;
			});
		};
		rightClick ~= {
			foreach(key; input.getBind(action)){
				input.unbind(key, action);
			}
			updateText;
		};
	}

	void updateText(){
		auto binds = input.getBind(action);
		if(binds.length)
			text = binds.join(", ");
		else
			text = action[0] == '-' ? "-" : "+";
	}

}

