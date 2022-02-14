
class AnimatedPlane < Plane
	def initialize(x, y, w, h, z, c)
		super(x, y, w, h, z, c)
		@_delta_color = false
		@_end_color = Gosu::Color.new(@_color.alpha, @_color.red, @_color.green, @_color.blue)
		@_speed_color = 0
	end
	
	def update
		if @_delta_color
			if @_speed_color > 0
				_a = @_end_color.alpha == @_color.alpha ? @_end_color.alpha : rfunc_transition(@_color.alpha, @_end_color.alpha, @_speed_color)
				_r = @_end_color.red == @_color.red ? @_end_color.red : rfunc_transition(@_color.red, @_end_color.red, @_speed_color)
				_g = @_end_color.green == @_color.green ? @_end_color.green : rfunc_transition(@_color.green, @_end_color.green, @_speed_color)
				_b = @_end_color.blue == @_color.blue ? @_end_color.blue : rfunc_transition(@_color.blue, @_end_color.blue, @_speed_color)
				self.set_color(_a, _r, _g, _b)
				@_speed_color -= 1
			else
				@_delta = false
			end
		end
	end
	
	def color_to(ec, sp=@_speed)
		@_delta_color = true
		@_end_color = ec
		@_speed_color = sp
	end
	
	def rfunc_transition(s1, s2, vt)
		return (s2 - s1) / vt + s1
	end
end