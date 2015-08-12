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
	game.commands,
	lua;

__gshared:

class Console: Base {
	
	this(Commands commands, Lua lua){
		textField = addNew!Text;
		textField.moveLocal([5, 30]);
		textField.setFont("UbuntuMono-R", 11);
		auto writeOld = ws.io.writeFunc;
		commands.add("history", {
			writeln(textField.text);
		});
		ws.io.writeFunc = (arg){
			try{
				textField.text ~= arg;
				writeOld(arg);
			}catch(UnicodeException e)
				writeOld("C [!] Invalid UTF string\n");
		};
		textBox = addNew!InputField;
		textBox.moveLocal([5, 5]);
		textBox.onEnter ~= (line){
			writeln("> %", line);
			try {
				commands.run(line);
				//lua.run(line);
			}catch(Exception e)
				writeln(e);
			history ~= line;
			historyCurrent = 0;
			textBox.text.set("");
		};
		textBox.setFont("UbuntuMono-R", 11);
		setTop(textBox);
		commands.add("toggle_console", {
			hidden ? show() : hide();
		});

		textField.style.fg = [1,1,1,1];
		//textBox.style = textField.style;
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
		super.onKeyboard(k, p);
	}
	
	
	override void onKeyboardFocus(bool focus){
		setTop(textBox);
	}

	override void onDraw(){
		draw.setColor([0.1, 0.1, 0.1]);
		draw.rect(pos, size);
		draw.setColor([0.2, 0.2, 0.2]);
		draw.rect(pos, [size.x, 30]);
		super.onDraw();
	}

	override void resize(int[2] size){
		textField.resize([size.w-10, size.h-35]);
		textBox.resize([size.w-10, 20]);
		super.resize(size);
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

