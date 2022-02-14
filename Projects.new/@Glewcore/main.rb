#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  25/09/2018 Neural Network 2
#==============================================================================

# custom debug flag
$TEST = TRUE

# dependencies
require('matrix')
require('gosu')

Dir.chdir("Projects.new/@Glewcore")

module Kernel
	def pause(*args)
		puts(args)
		system(args.empty? ? 'pause' : 'pause > nul')
	end
	def sigmoid(x)
		return 1.0 / ( 1.0 + Math.exp(-x))
	end
	def sigmoid_derivative(x)
		return x * (1.0 - x)
	end
	alias activation_function sigmoid
	alias backpropagation_function sigmoid_derivative
	def load_image(filename) 
		return Gosu::Image.new(filename).to_blob
	end
end
module Loader
	module StringPath
		Relative = Dir.pwd + "/Data/"
		BmpExtension = ".bmp"
		def self.basepath(pathname)
			return Relative + pathname
		end
		def self.path(pathname,filename)
			return basepath(pathname) + filename
		end
		def self.layer(rep_index, filename)
			return path("Layer/" + index.to_s + "/", filename + BmpExtension)
		end
	end
	def self.layer(rep_index, filename)
		return load_image(StringPath.layer(rep_index, filename))
	end
end
module Db
	module Layer
		LineSize = 100*100
		Input = Matrix[
		[ 0, 0, 1 ],
		[ 0, 1, 1 ],
		[ 1, 0, 1 ],
		[ 1, 1, 1 ]]
		Output = Matrix.column_vector [ 0, 1 , 1, 0]
	end
	
	Cache = Hash.new {|h, k| h[k] = Hash.new {|d, p| pause p; d[p] = Loader.send(k, *p)}}
	Seed = Random.new(1)
end

class Matrix
	def dimension
		return "Matrix" + "[" +row_size.to_s + 'x' + column_size.to_s + "]\n"
	end
	def to_s
		return  dimension + to_a.map { |e| e * ' '} * "\n\n"
	end
	def self.combine(*matrices) # ruby 2.5+ only
	   x = matrices.first
	  rows = Array.new(x.row_count) do |i|
		Array.new(x.column_count) do |j|
		  yield matrices.map{|m| m[i,j]}
		end
	  end
	  new rows, x.column_count
	end
	def abs
		return map { |e| e.abs }
	end
	def mean
		return inject(:+)/ ( column_size * row_size )
	end
end
            

begin
	puts('Loading data')
	
	Dir[Loader::StringPath.basepath("Layer/")].glob('**/*').select {|f| File.directory?(f)} 
	
	
	
	synapse0 = Matrix.build(Db::Layer::Input.column_size, Db::Layer::Input.row_size) { 2 * Db::Seed.rand() - 1 }
	synapse1 = Matrix.build(Db::Layer::Input.row_size, Db::Layer::Output.column_size) { 2 * Db::Seed.rand() - 1 }
	layer1, layer2  = nil, nil
	
	puts('Error mean :')
	60_000.times do |t|
		layer0 = (Db::Layer::Input * synapse0).map { |e| activation_function(e) }
		layer1 = (layer0 * synapse1).map { |e| activation_function(e) }
		
		# error margin
		error1 = (Db::Layer::Output - layer1)
		puts("(" + (t / 10_000).to_s + ") " + error1.abs.mean().to_s) if t % 10_000 == 0
		
		wheight1 = layer1.map { |e| backpropagation_function(e) }
		# check how strong the change needs to be
		delta1 = Matrix.combine(error1, wheight1) { |a, b| a * b }
		
		error0 = delta1 * synapse1.t
		wheight0 = layer0.map { |e| backpropagation_function(e) }
		delta0 = Matrix.combine(error0, wheight0) { |a, b| a * b }

		# adjust weights
		synapse1 += layer0.t * delta1		
		synapse0 += Db::Layer::Input.t * delta0
	end
	
	pause("Output after training :\n" + layer1.to_s)
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