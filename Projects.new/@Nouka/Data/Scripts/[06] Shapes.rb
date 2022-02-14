class Point
	Color = Gosu::Color.argb(0xff_ff0000) #red
	attr_accessor :x, :y
	def set(x=0, y=0, c=nil);@x, @y= x, y, c ? c : (@color ? @color : Color);end
	alias initialize set
	def ==(p);@x==p.x&&@y==p.y;end
	alias eql? ==
	def hash;@x.to_i^@y.to_i;end
	def to_a;[@x,@y];end
	def to_s;to_a.to_s;end
end

class Rect
	RectColor = Gosu::Color.argb(0xff_ff0000) #red
	attr_accessor :x, :y, :width, :height, :color
	def set(x=0, y=0, w=0, h=0, c=nil)
		@x, @y, @width, @height, @color = x, y, w, h, c ? c : (@color ? @color : RectColor)
	end
	alias initialize set
	alias reset set
	def lock
		@x, @y = 0, 0
	end
	def moveC(x, y)
		@x, @y = x, y
	end
	def moveR(x, y)
		@x, @y = @x + x, @y + y
	end
	def scaleC(w, h)
		@width, @height = w, h
	end
	def scaleR(w, h)
		@width, @height = @width + w, @height + h
	end
	def draw
		# Top
		Gosu.draw_line(@x, @y, @color,
		@x + @width, @y, @color, 300)
		# Bottom
		Gosu.draw_line(@x, @y + @height, @color,
		@x + @width, @y + @height, @color, 300)
		# Left
		Gosu.draw_line(@x, @y, @color,
		@x, @y + @height, @color, 300)
		# Right
		Gosu.draw_line(@x + @width, @y, @color,
		@x + @width, @y + @height, @color, 300)
	end
	def center_x;return @x + @width/2;end
	def center_y;return @y + @height/2;end
	def x2;return @x+@width;end
	def y2;return @y+@height;end
	def cCollision?(x, y, width, height)
		return (@x < x + width) && (@x + @width > x) && (@y < y + height) && (@y + @height > y)
	end
	def rCollision?(rect)
		return cCollision?(rect.x, rect.y, rect.width, rect.height)
	end
	def xyCollision?(x, y)
		return (@x < x) && (@x + @width > x) && (@y < y) && (@y + @height > y)
	end
	def pCollision?(point)
		return xyCollision?(point.x, point.y)
	end
	
	def out_of_bounds?(rect)
		p @x
		return (@x>rect.x)#||(@y>rect.y)||(@x+@width<rect.x+rect.width)||(@y+@height<rect.y+rect.height)
	end
	
	def to_a
		return [@x, @y, @width, @height]
	end
	#-- Debug Purposes --#
	def marshal_dump
		return [@x, @y, @width, @height]
	end
	def marshal_load(ary)
		@x, @y, @width, @height = ary
		@color = RectColor
	end
end

class Circle
	attr_accessor :color
	attr_reader   :radius
	attr_reader   :x, :y
	attr_reader   :rect
	def initialize(r, x, y, c=nil)
		@ox, @oy = 0.5, 0.5
		@color = c ? c : Gosu::Color::RED
		@cache = nil
		@zoom = 1.0
		@x, @y = x, y
		self.radius = r
	end
	def create_cache
		d = @radius * 2
		@cache = Cache.misc("wcircle")
		#@cache = Gosu.record(d, d) {
			#d.times { |x|
				#cy = Math.sqrt(@radius**2 - (x - @radius)**2).ceil
				#(@radius - cy).upto(@radius + cy) { |y|
				#	Gosu.draw_rect(x, y, 1, 1, @color)
				#}
			#}
		#}
	end
	def create_rect
		@rect = Rect.new(@x - @radius, @y - @radius, diameter, diameter)
	end
	def x=(a);@x = a;@rect.x = a - @radius;end
	def y=(b);@y = b;@rect.y = b - @radius;end
	def diameter;return @radius * 2;end
	def radius=(s)
		return if @radius == s.to_i
		@radius = s.to_i
		@zoom =  @radius / 200.0
		create_rect
		create_cache
	end
	def draw
		@cache.draw_rot(@x, @y, 200, 0, @ox, @oy, @zoom, @zoom, @color)
	end
	def xyCollision?(x, y)
		return ((@y - y)**2 + (@x - x)**2 < @radius**2)
	end
	def pCollision?(point);return xyCollision?(point.x, point.y);end
	def cCollision?(x, y, w, h)
		return xyCollision?(Math.max(x, Math.min(@x, x + w)), Math.max(y, Math.min(@y, y + h)))
	end
	def rCollision?(rect); return cCollision?(rect.x, rect.y, rect.width, rect.height);end
	
end
