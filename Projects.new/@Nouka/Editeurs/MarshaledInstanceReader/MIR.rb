# Marshaled Instances Reader
puts('Marshaled Instances Reader')

# Debug Flag
$TEST = true
	
begin
	

	# Auto Install Qt
	# Gem.install("qtbindings") if Gem::Specification.find_all_by_name("qtbindings").empty?
	# Dependencies
	require("Qt")
	# Scripts loading
	_scripts = Dir["#{File.dirname($0)}/Data/Scripts/*"]
	_scripts.sort_by! {|f| /\[(.+)\]/.match(f)[1].to_i }
	_scripts.each {|f| load(f) }
	
	load ( $methodFile = "serialization_methods.rb")
	
	# 'Global' Variables initialization
	Global.init
	
	# Main Process
	$app = Qt::Application.new(ARGV)
	$main = MainWindow.new
	$main.show()
	code = $app.exec()
	
rescue Exception
	if $TEST
		p $!.class
		p $!.backtrace
		p $!.message
		system 'pause'
	end
end

