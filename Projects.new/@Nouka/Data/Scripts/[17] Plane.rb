class Plane
	attr_accessor :x, :y, :width, :height, :z
	def initialize(x, y, w, h, z, c)
		@_color = Gosu::Color.new(0, 0, 0, 0)
		@x, @y, @width, @height, @z = x, y, w, h, z
	end
	def set_color(a, r, g, b)
		@_color.alpha = a
		@_color.red = r
		@_color.green = g
		@_color.blue = b
	end
	def draw
		Gosu.draw_rect(@x, @y, @width, @height, @_color, @z)
	end
end