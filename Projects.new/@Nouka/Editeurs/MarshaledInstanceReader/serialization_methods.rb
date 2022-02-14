class Table
    def initialize(xsize, ysize = 1, zsize = 1, data = nil)
        @dimension = zsize > 1 ? 3 : (ysize > 1 ? 2 : 1) 
        @xsize = xsize
        @ysize = ysize
        @zsize = zsize
        if !data
            @data = Array.new(xsize * ysize * zsize)
        else
            @data = data
        end
    end
    def self._load(args)
        dimension, xsize, ysize, zsize, element_count, *elements = args.unpack('L5s*')
        return Table.new(xsize, ysize, zsize, elements)
    end
    #def self._dump
       # return [@dimension, @xsize, @ysize, @zsize, @data.size, @data].flatten.pack('L5s*')
    #end
end

class Color
	def initialize(r=0, g=0, b=0, a=255)
		@red, @blue, @green, @alpha = r.to_f, g.to_f, b.to_f, a.to_f
	end
	def self._load(args)
		return self.new(*args.unpack('d4'))
	end
	#def self._dump
	#	#[@red, @green, @blue, @alpha].pack('d4')
	#end
end

class Rect
	#-- Debug Purposes --#
	def marshal_dump
		return [@x, @y, @width, @height]
	end
	def marshal_load(ary)
		@x, @y, @width, @height = ary
		@color = "N/A"
	end
end
module Serializable
	class Tileset
		def marshal_load(ary)
			@frames, @filename, @width, @height, @data = ary
			init(@filename)
		end
		def init(f)
			#@filename = @frames > 1 ? (Array.new(@frames) {|i| Cache::GamePath.tileset(f + i.to_s)}) : [Cache::GamePath.tileset(f)]
			#@filename.each {|i| Cache.tileset(i) }
		end   
	end
end

# warn
if File.basename($0).downcase != 'mir.rb'
	puts 'Please run MIR.rb or Edit this file in Notepad.'
	system 'pause'
end