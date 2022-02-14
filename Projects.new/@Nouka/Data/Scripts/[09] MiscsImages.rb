module SharedFunction
	def static?
		return @static
	end
	def update_color(c)
		
		@_color = Gosu::Color.merge(c, @real_color)
	end
	def unmerged_color()
		c = @_color.unmerge(@real_color)
		return c
	end
end
class FontImage
	include SharedFunction
	attr_accessor :x, :y, :static, :ox, :oy
	attr_reader :real_color
	def initialize(f, s, c, x, y, t, static=true)
		@font = Cache.font(f, s)
		@real_color = c
		@_color = Gosu::Color.new(*c.to_a)
		@x, @y = x, y
		@ox, @oy = 0, 0
		@_text = t
		@static = static
	end
	def draw(z)
		@font.draw_rel(@_text, @x, @y, z, @ox, @oy, 1, 1, @_color)
	end
	def text_width
		return @font.text_width(@_text).to_i
	end
	def set_font(f, s)
		@font = Cache.font(f, s)
	end
	def set_text(t)
		@_text = t
	end
	def real_color=(c)
		@real_color=c
	end
end
class IconImage
	include SharedFunction
	attr_accessor :x, :y, :real_color, :static, :ox, :oy
	def initialize(n, c, x, y, zoom=1, static=true)
		@icon = Cache.icon(n)
		@real_color = c
		@_color = Gosu::Color.new(*c.to_a)
		@x, @y = x, y
		@ox, @oy = 0, 0
		@zoom = zoom
		@static = static
	end
	def draw(z)
		@icon.draw_rot(@x, @y, z, 0, @ox, @oy, @zoom, @zoom, @_color)
	end
end