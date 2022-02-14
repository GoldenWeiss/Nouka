#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  Start main process.
#==============================================================================

# Custom DEBUG flag
$TEST = TRUE

begin
	
	# Dependencies
	require('gosu')
	require('thread')
	
	# Scripts Loading
	
	Dir.chdir("Projects.new/@Nouka")
	_scripts = Dir["./Data/Scripts/*"]
	_scripts.sort_by! {|f| /\[(.+)\]/.match(f)[1].to_i }
	_scripts.each {|f| load(f) }
	
	# Start Game
	Global.init
	
rescue Exception
	unless $!.class == SystemExit
		# Print error
		if $TEST
			puts $!.class
			puts $!.backtrace
			puts $!.message
			system('pause')
		end
	end
end