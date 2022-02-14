#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Miscellaneous functions.
#==============================================================================

module Kernel
	# Print message on the screen in a message box
	def m(*args)
		a = Qt::MessageBox.new($main)
		a.setWindowTitle(Database::Config::DefaultTitle)
		a.setText(args.map{|i| i.inspect.scan(/.{1,66}/).join("\n")}.join("\n"))
		a.exec()
	end
	def cash(args)
		p(args) if $TEST
	end
	def cafe(args=nil)
		if args
			cash args
		else
			cash "Time for a Coffee Break ! <,-,>"
		end
		system 'pause > nul'
		return args
	end
	# Clear Screen
	def cls
		print("\e[H\e[2J")
	end
end