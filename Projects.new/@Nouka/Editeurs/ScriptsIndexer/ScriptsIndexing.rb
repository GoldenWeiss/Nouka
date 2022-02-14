begin
_path = ARGV.empty? ? "./Projects.new/@Nouka/Data/Scripts/" : ARGV.shift
ARGV.clear

_extension = ".rb"
_scripts = Dir[_path + "*"]
_scripts.sort_by! {|f| /\[(.+)\]/.match(f)[-1].to_i }
_text = _scripts.join("\n")
def answer_question(args)
	str = "\e[H\e[2J" + args
	_input = ""
	while _input.empty?
		print(str)
		_input = gets.chomp.strip
	end
	return _input
end
unless _scripts.empty?
	_text << "\nEnter command :\nNew script (0)\nDelete Script (1) = "
	_input = answer_question(_text)
	_text << _input
	case _input.to_i
	when 0
		_text << "\nNew Script, enter script index above script = "
		_input = answer_question(_text)
		_text << _input + "\n"
		_input = _script_id = _input.to_i
		_index = _scripts.each_index.select{|i| 
			_temp = /\[(.+)\]/.match(_scripts[i])
			_temp && _temp[1].to_i == _input
		}[-1]
		_text << _scripts[_index] + "\nEnter script name = "
		_input = answer_question(_text)
		print("Creating file " + _input + " ...")
		File.open(_path + '[' + sprintf('%02d', _script_id.to_i + 1) + '] ' + _input  + _extension, 'w')
		_scripts[_index+1..-1].each {|f|
			_x = (f.gsub(/\[(.+)\]/){x = $1;  '[' + (x.scan(/\D/).empty? ? sprintf('%02d', x.to_i + 1) : x)+ ']'})
			File.rename(f, _x)
		}
	when 1
		_text << "\nDelete Script, enter script index to delete = "
		_input = answer_question(_text)
		_text << _input + "\n"
		_input = _input.to_i
		_index = _scripts.each_index.select{|i| 
			_temp = /\[(.+)\]/.match(_scripts[i])
			_temp && _temp[1].to_i == _input
		}[-1]
		_file = _scripts[_index]
		print("Deleting file " + _file + " ...")
		File.delete(_file)
		_scripts[_index+1..-1].each {|f|
			_x = (f.gsub(/\[(.+)\]/){x = $1;  '[' + (x.scan(/\D/).empty? ? sprintf('%02d', x.to_i - 1) : x)+ ']'})
			File.rename(f, _x)
		}
	else
		print ("\e[H\e[2JNothing !")
		system 'pause > nul'
		exit
	end
	print ("\e[H\e[2JSuccess !")
	system 'pause > nul'
else
	_text << "No scripts detected.\nPlease verify that #{_path} is the correct location."
	puts _text
	system 'pause'
end
rescue
p $!.message
p $!.backtrace
system 'pause'
end