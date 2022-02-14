class TransitionWindow < Window
	
				  
	def initialize
		super
		
		# Transition related
		@_delta = false

		@_delta_coordinates = false
		@_start_x, @_end_x  = self.rect.x, self.rect.x
		@_start_y, @_end_y  = self.rect.y, self.rect.y
		@speed_coordinates = 0
		
		@_delta_dimensions = false
		@_start_width, @_end_width = self.rect.width, self.rect.width
		@_start_height, @_end_height = self.rect.height, self.rect.height
		@speed_dimensions = 0
		
		@_delta_contents_color = false
		@_start_contents_color, @_end_contents_color = @contents_color, @contents_color
		@speed_contents_color = 0
		
		@_delta_windowskin_color = false
		@_start_windowskin_color, @_end_windowskin_color = @windowskin_color, @windowskin_color
		@speed_windowskin_color = 0
	end
	
	def update
		if @_delta
			if @_delta_coordinates
				if @speed_coordinates > 0
					self.x = rfunc_transition(self.rect.x, @_end_x, @speed_coordinates)
					self.y = rfunc_transition(self.rect.y, @_end_y, @speed_coordinates)
					@speed_coordinates -= 1
				else
					@_delta_coordinates = false
				end
			end
			if @_delta_dimensions
				if @speed_dimensions > 0
					self.width = rfunc_transition(self.rect.width, @_end_width, @speed_dimensions)
					self.height = rfunc_transition(self.rect.height, @_end_height, @speed_dimensions)
					@speed_dimensions -= 1
				else
					@_delta_dimensions = false
				end
			end
			if @_delta_windowskin_color
				if @speed_windowskin_color > 0
					_a = @_end_windowskin_color.alpha == self.windowskin_color.alpha ? @_end_windowskin_color.alpha : rfunc_transition(self.windowskin_color.alpha, @_end_windowskin_color.alpha, @speed_windowskin_color)
					_r = @_end_windowskin_color.red == self.windowskin_color.red ? @_end_windowskin_color.red : rfunc_transition(self.windowskin_color.red, @_end_windowskin_color.red, @speed_windowskin_color)
					_g = @_end_windowskin_color.green == self.windowskin_color.green ? @_end_windowskin_color.green : rfunc_transition(self.windowskin_color.green, @_end_windowskin_color.green, @speed_windowskin_color)
					_b = @_end_windowskin_color.blue == self.windowskin_color.blue ? @_end_windowskin_color.blue : rfunc_transition(self.windowskin_color.blue, @_end_windowskin_color.blue, @speed_windowskin_color)
					self.set_windowskin_color(_a, _r, _g, _b)
					@speed_windowskin_color -= 1
				else
					@_delta_color = false
				end
			end
			if @_delta_contents_color
				if @speed_contents_color > 0
					_a = @_end_contents_color.alpha == self.contents_color.alpha ? @_end_contents_color.alpha : rfunc_transition(self.contents_color.alpha, @_end_contents_color.alpha, @speed_contents_color)
					_r = @_end_contents_color.red == self.contents_color.red ? @_end_contents_color.red : rfunc_transition(self.contents_color.red, @_end_contents_color.red, @speed_contents_color)
					_g = @_end_contents_color.green == self.contents_color.green ? @_end_contents_color.green : rfunc_transition(self.contents_color.green, @_end_contents_color.green, @speed_contents_color)
					_b = @_end_contents_color.blue == self.contents_color.blue ? @_end_contents_color.blue : rfunc_transition(self.contents_color.blue, @_end_contents_color.blue, @speed_contents_color)
					self.set_contents_color(_a, _r, _g, _b)
					@speed_contents_color -= 1
				else
					@_delta_contents_color = false
				end
			end
			
			@_delta = (@_delta_coordinates || @_delta_dimensions || @_delta_windowskin_color || @_delta_contents_color)
		end
	end
	
	def rfunc_transition(s1, s2, vt)
		return (s2 - s1) / vt + s1
	end
	
	def move_to_from(ex, ey, sx, sy, sp=@speed_coordinates)
		@_delta = true
		@_delta_coordinates = true
		@speed_coordinates = sp
		@_end_x, @_end_y = ex, ey
		self.rect.x = sx
		self.rect.y = sy
	end
	def scale_to_from(ew, eh, sw, sh, sp=@speed_dimensions)
		@_delta = true	
		@_delta_dimensions = true
		@speed_dimensions = sp
		@_end_width, @_end_height = ew, eh
		
		self.rect.width  = sw
		self.rect.height = sh
	end
	def color_windowskin_to_from(ec, sc, sp=@speed_color)
		@_delta = true
		@_delta_windowskin_color = true
		@speed_windowskin_color  = sp
		@_end_windowskin_color = ec
		self.set_windowskin_color(sc.alpha, sc.red, sc.green, sc.blue)
	end
	def color_contents_to_from(ec, sc, sp=@speed_color)
		@_delta = true
		@_delta_contents_color = true
		@speed_contents_color  = sp
		@_end_contents_color = ec
		self.set_contents_color(sc.alpha, sc.red, sc.green, sc.blue)
	end
	
	def move_to(ex, ey, sp=@speed_coordinates)
		move_to_from(ex, ey, self.rect.x, self.rect.y, sp)
	end
	def scale_to(ew, eh, sp=@speed_dimensions)
		scale_to_from(ew, eh, self.rect.width, self.rect.height, sp)
	end
	def color_windowskin_to(ec, sp=@speed_windoskin_color)
		color_windowskin_to_from(ec, self.windowskin_color, sp)
	end
	def color_contents_to(ec, sp=@speed_contents_color)
		color_contents_to_from(ec, self.contents_color, sp)
	end
	#def open
	#end
	#def close
	#end
end