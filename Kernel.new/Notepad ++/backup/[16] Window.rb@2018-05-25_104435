#==============================================================================
# ** Window
#------------------------------------------------------------------------------
#  Window class (message & buttons).
#==============================================================================

class Window
	include Database::Window
	
	@@_registered_windows = Hash.new { |h, k| h[k] = Array.new }
	
	FullColor  = Gosu::Color.new(MsgOpacity, 255, 255, 255)
	BlankColor = Gosu::Color.new(0, 0, 0, 0)
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_reader   :rect 
	attr_accessor :z
	
	
	attr_reader   :windowskin_color
	attr_accessor :windowskin_visible
	
	attr_reader   :contents_color
	attr_accessor :contents_visible
	
	attr_accessor :hidden
	
	#--------------------------------------------------------------------------
	# * Object Initialization		
	#--------------------------------------------------------------------------
	def initialize
		@_type = DefaultType
		
		@rect = Rect.new(0, 0, 16, 16)
		@z = 3000
		@font = nil
		
		@contents = nil#[]
		@contents_visible = false
		@contents_color = Gosu::Color.new(DefaultOpacity, 255, 255, 255)
		@text_size = @rect.width
		@_images = {}
		
		@windowskin = nil
		@windowskin_visible = false
		@windowskin_color = Gosu::Color.new(DefaultOpacity, 255, 255, 255)
		
		@hidden = false
		
		update_x2
		update_y2
	end
	
	def draw()	
		return if @hidden
		Gosu.clip_to(@rect.x, @rect.y, @rect.width, @rect.height) do
			Gosu.translate(@rect.x, @rect.y) do
				if @windowskin && @windowskin_visible
					@_skin[0].draw_tiled(  0,   0, @rect.width, @rect.height,          @z, 1, 1, @windowskin_color)
					@_skin[1].draw_tiled(  0,   0, @rect.width, @_skin[1].height, @z, 1, 1, @windowskin_color)
					@_skin[2].draw_tiled(  0, @y2, @rect.width, @_skin[2].height, @z, 1, 1, @windowskin_color)
					@_skin[3].draw_tiled(  0,   0, @_skin[3].width, @rect.height, @z, 1, 1, @windowskin_color)
					@_skin[4].draw_tiled(@x2,   0, @_skin[4].width, @rect.height, @z, 1, 1, @windowskin_color)
					
					@_skin[5].draw(0  , 0  , @z, 1, 1, @windowskin_color)
					@_skin[6].draw(@x2, 0  , @z, 1, 1, @windowskin_color)
					@_skin[7].draw(0  , @y2, @z, 1, 1, @windowskin_color)
					@_skin[8].draw(@x2, @y2, @z, 1, 1, @windowskin_color)
				end
				
				if @contents_visible && @contents
					@contents.each {|i| i[0].draw(i[3], i[1], i[2], @z, 1, 1, @contents_color) }
				end
			end
		end
		if !@_images.empty? && @contents_visible
			@_images.each {|k, v| v.draw(@z)}
		end
	end
	def visible?;return @windowskin_visible||@contents_visible;end
	def update_skin
		_s = Windowskins.cache[@windowskin][1]
		@_skin = [:fill, :fr_u, :fr_d, :fr_l, :fr_r, :cr_ul, :cr_ur, :cr_dl, :cr_dr].map { |i| _s[[@_type, i]]}
	end
	def set_windowskin(arg=nil)
		@windowskin = arg
		update_skin
	end
	def get_type()
		return @_type
	end
	def set_type(arg)
		@_type = arg
		update_skin
	end

	def set_contents(arg)
		@contents = arg
	end
	def get_contents
		return @contents
	end
	def set_text_size(arg)
		@text_size = arg
	end
	def get_text_size
		return @text_size
	end
	def structure_text(f, t)
		
		_text = t.clone
		_x = t.split(/\n/)
		_x.map! do |line|
			_ratio = f.text_width(line) / @text_size
			_count = 0
			if _ratio != 0
				Array.new(_ratio.floor + 1) { |i|
					_index    = (line.size * (i + 1) / _ratio).to_i
					_linesize = f.text_width(line[_count.._index]).to_i
					while _linesize > @text_size
						_index -= 1 
						_linesize = f.text_width(line[_count.._index]).to_i
					end
					a = line[_count.._index]
					_count = _index+1
					a
				}
			end
		end
		return _x.flatten                                                      
	end
	def set_text(s, x, y, t)
		_font = Cache.font(DefaultFont, s)
		_text = structure_text(_font, t)
		_contents = Array.new(_text.size) { |i|
			[_font, x, y + i * s, _text[i]]
		}
		set_contents(_contents)
	end
	def set_centered_text(s, y, t)
		_font = Cache.font(DefaultFont, s)
		_text = structure_text(_font, t)
		_contents = Array.new(_text.size) { |i|
			[_font, @rect.width/2 - _font.text_width(_text[i]).to_i/2, y + i * s, _text[i]]
		}
		set_contents(_contents)
	end
	def get_image(n); return @_images[n]; end
	def images; return @_images;end
	def add_font_image(n, f, s, c, x, y, t, static=true)
		@_images[n] = FontImage.new(f, s, c ? c : @contents_color, x, y, t, static)
	end
	def add_icon_image(n, f, c, x, y, zoom, static=true)
		@_images[n] = IconImage.new(f, c ? c : @contents_color, x, y, zoom, static)
	end
	def update_x2; @x2 = @rect.width -  Windowskins::Rects[:cr_dl][6]; end
	def update_y2; @y2 = @rect.height - Windowskins::Rects[:cr_dl][7]; end
	def set_dimensions(*args)
		@_images.each { |k, v|
			v.x = arg + v.x - @rect.x
			v.y = arg + v.y - @rect.y 
		}
		@rect.x, @rect.y, @rect.width, @rect.height = args
		update_x2
		update_y2
	end
	def x;return @rect.x;end
	def y;return @rect.y;end

	def x=(arg)
		@_images.each { |k, v| v.x = arg + v.x - @rect.x unless v.static?}
		@rect.x = arg
		update_x2
	end
	def y=(arg)
		@_images.each { |k, v| v.y = arg + v.y - @rect.y unless v.static?}
		@rect.y = arg
		update_y2
	end
	def width=(arg)
		@rect.width = arg
		update_x2
	end
	def height=(arg)
		@rect.height = arg
		update_y2
	end
	def set_text_color(a, r, g, b)
		@contents_color.alpha = a
		@contents_color.red = r
		@contents_color.green = g
		@contents_color.blue = b
		self.contents_visible = !a.zero?
	end
	def set_contents_color(a, r, g, b)
		set_text_color(a, r, g, b)
		@_images.each {|k, v| v.update_color(@contents_color)}
	end
	def set_windowskin_color(a, r, g, b)
		@windowskin_color.alpha = a
		@windowskin_color.red = r
		@windowskin_color.green = g
		@windowskin_color.blue = b
		self.windowskin_visible = !a.zero?
	end
	def register(group)
		@@_registered_windows[group].push(self) if @windowskin
	end
	def unregister(group)
		@@_registered_windows[group].delete(self)
	end
	module Windowskins
		@@skin_cache = Hash.new { |h, k| h[k] = cache_skin(k)}
		Rects = {
			# sx, sy, nx, ny, ix, iy, v, v
			:fill  => [2, 8, 4, 4, 4, 3, 16, 16], 
			:cr_ul => [1, 7, 4, 4, 4, 3, 16, 16],
			:cr_ur => [3, 7, 4, 4, 4, 3, 16, 16],
			:cr_dl => [1, 9, 4, 4, 4, 3, 16, 16],
			:cr_dr => [3, 9, 4, 4, 4, 3, 16, 16],
			:fr_u  => [2, 7, 4, 4, 4, 3, 16, 16],
			:fr_d  => [2, 9, 4, 4, 4, 3, 16, 16],
			:fr_l  => [1, 8, 4, 4, 4, 3, 16, 16],
			:fr_r  => [3, 8, 4, 4, 4, 3, 16, 16]
		}
		SkinNumber = 16
		def self.create_subimage(windowskin, type, name)
			_rc = Rects[name]
			_bmp = (@@skin_cache[windowskin][0].subimage(
			(_rc[0] + (type % _rc[2]) * _rc[4]) * 16,
			(_rc[1] + (type - type % _rc[3])/4 * _rc[5]) * 16,
			_rc[6], _rc[7]))
			return _bmp
		end
		def self.cache_skin(windowskin)
			
			_img = Cache.windowskin(windowskin)
			_hash = Hash.new { |h, k| h[k] = create_subimage(windowskin, *k)}
			@@skin_cache[windowskin] = [_img, _hash]
		end
		def self.cache
			return @@skin_cache
		end
	end
end