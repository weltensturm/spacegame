module gui.console;

import
	core.exception,
	std.utf,
	ws.io,
	ws.string,
	ws.gl.draw,
	ws.gui.base,
	ws.gui.input,
	ws.gui.text,
	ws.gui.inputField,
	ws.math.vector,
	game.commands,
	lua;

//__gshared:

class Console: Base {
	
	this(Commands commands, Lua lua){
		textField = add!Text();
		textField.setLocalPos(5, 30);
		textField.setFont("UbuntuMono-R", 11);
		auto old = ws.io.writeFunc;
		ws.io.writeFunc = (arg){
			try
				textField.text ~= arg;
			catch(UnicodeException e)
				textField.text ~= "[!] Invalid UTF string\n";
			old(arg);
		};
		textBox = add!InputField();
		textBox.setLocalPos(5, 5);
		textBox.onEnter ~= (line){
			writeln("> %", line);
			try {
				lua.run(line);
			}catch(Exception e)
				writeln(e);
			history ~= line;
			historyCurrent = 0;
			textBox.text.set("");
		};
		textBox.setFont("UbuntuMono-R", 11);
		setTop(textBox);
		commands.add("open_console", {
			hidden ? show() : hide();
		});

		textField.style.fg = [1,1,1,1];
		textBox.style = textField.style;
	}


	override void onKeyboard(Keyboard.key k, bool p){
		if(p){
			if(k == Keyboard.up || k == Keyboard.down){
				historyCurrent +=
					(k==Keyboard.up)
					? (historyCurrent<history.length ? 1 : 0)
					: (historyCurrent>0 ? -1 : 0);
				textBox.text.set(historyCurrent ? history[history.length - historyCurrent] : "");
				return;
			}else if(k == Keyboard.escape)
				hide();
		}
	}
	
	
	override void onKeyboardFocus(bool focus){
		setTop(textBox);
	}

	override void onDraw(){
		draw.setColor(0,0,0,0.7);
		draw.rect(pos, size);
		draw.setColor(0,0,0,0.8);
		draw.rect(0,0,5,size.y);
		draw.rect(size.x-5,0,5,size.y);
		draw.rect(5,0,size.x-10,5);
		draw.rect(5,size.y-5,size.x-10,5);
		draw.rect(5,25,size.x-10,5);
		super.onDraw();
	}

	override void onResize(int w, int h){
		textField.setSize(w-10, h-35);
		textBox.setSize(w-10, 20);
	}


	override void onShow(){
		setTop(textBox);
	}


	void clear(){
		textField.text.set("");
	}


	protected:
		string[] history;
		size_t historyCurrent = 0;
		Text textField;
		InputField textBox;
		
}

