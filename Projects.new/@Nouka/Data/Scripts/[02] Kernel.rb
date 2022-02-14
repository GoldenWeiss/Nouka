module Kernel
	ESC		   = "\n"
	Megacafe   = "x='V'=x"
	Deadcafe   = "<,-,>"
	Shieldcafe = "(..)"
	Smartcafe  = "z'z"
	
	_carray    = [Megacafe, Deadcafe, Shieldcafe, Smartcafe]
	Loremcafe = ESC + _carray.join(ESC) + ESC + _carray.reverse.join(ESC)
	@@_count = Hash.new {|h, k| h[k] = 0}
	def comment(*args, &block);end
	alias c comment
	def uncomment(*args, &block); block.call(*args); end
	alias uc uncomment
	def multistring(*args)
		args.join(ESC)
	end
	def pause(text=true)
		system(text ? 'pause' : 'pause > nul')
	end
	def cafe(args=nil)
		p (args ? args : "\nTime for a Coffee Break ! " + Deadcafe + " (" + @@_count[Deadcafe].to_s + ")")
		@@_count[Deadcafe] += 1
		Kernel::pause(false)
	end
	def cash(args=nil)
		return unless $TEST
		if args
			$_ = "\n" + args.to_s 
			@@_count[Megacafe] = 0 
		else
			$_ = "\nZero money " + Megacafe + " (" + @@_count[Megacafe].to_s + ")"
			@@_count[Megacafe] += 1
		end
		print()
	end
	def loadData(f)
		File.open(f, "rb") { |filename| m = Marshal.load(filename)}
	end
	def saveData(f, obj)
		File.open(f, "wb") { |file| file.write(Marshal.dump(obj))}
	end
	def loadGameData(f)
		loadData(Cache::GamePath.game_data(f))
	end
	def saveGameData(f, obj)
		saveData(Cache::GamePath.game_data(f), obj)
	end
end
module Math
	def self.max(a,b);a>b ? a:b;end
	def self.min(a,b);a<b ? a:b;end
	def self.lerp(a,b,t);a+(b-a)*t;end
end
class Integer
	def sgn
		self <=> 0
	end
	def absceil;self;end
end
class Float
	def sgn
		self <=> 0
	end
	def absceil
		return self.ceil if self > 0.0
		return self.floor if self < 0.0
		return self
	end
end