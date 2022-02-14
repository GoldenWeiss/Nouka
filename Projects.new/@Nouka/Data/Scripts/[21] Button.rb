class Button < TransitionWindow
	
	attr_reader :rect
	attr_reader :saved_windowskin_color
	attr_reader :saved_contents_color
	
	attr_accessor :color_windowskin_on_over,
				  :color_contents_on_over
	attr_accessor :speed_color
	
	States = 
	{
		:blank => 0,
		:grey => 1,
		:red => 2,
		:black => 3,
		:locked=> 4
	}
	
	Colors = 
	{
		:blank => Gosu::Color.new(255, 255, 255, 255), # White
		:grey => Gosu::Color.new(255, 200, 200, 200),  # Lightgray
		:red => Gosu::Color.new(255, 255, 69, 0),      # Orange Red
		:black => Gosu::Color.new(255, 0, 255, 69),
		:locked => Gosu::Color.new(255, 200, 200, 200)  		
	}
	
	def initialize(window, x, y, width, height)
		super()
		
		@_type = DefaultButtonType
		
		@_window = window
		@_description = nil
		
		set_dimensions(x, y, width, height)
		set_text_size(width)
		
		@_state = States[:blank]
		
		@color_windowskin_on_over = true
		@color_contents_on_over   = false
		
		@speed_color = 2
		
		_c = Colors[:blank].to_a
		set_windowskin_color(*_c)
		set_contents_color(*_c)
		
		@_trigger_event  = false
		@_trigger_method = nil
		@_trigger_args   = nil
		
		@_release_event  = false
		@_release_method = nil
		@_release_args   = nil
		
		@_over_event  = false
		@_over_method = nil
		@_over_args   = nil
		
		@_unover_method = nil
		@_unover_args = nil
		
		@_absolute = false # Start Drag in this button
	end
	def get_absolute
		return @_absolute
	end
	def get_saved_color
		return Colors[States.key(@_state)]
	end
	def update
		if self.visible? && !@hidden
			if @_state != States[:locked]
				if @rect.xyCollision?($mouse.real_mouse_x, $mouse.real_mouse_y)
					if @_state != States[:black]
						@_absolute = @_state == States[:red] || @rect.xyCollision?($mouse.real_start_x, $mouse.real_start_y)
						if $mouse.triggered? && @_absolute
							triggerEvent()
						else
							if $mouse.released? && @_absolute
								releaseEvent()
							else
								overEvent()
							end
						end
					end
				else
					
					outEvent() 	
				end
			end
		end
		super
	end
	def onState?(arg)
		return @_state==arg
	end
	def new_state(arg)
		if @_state != arg
			@_state = arg 
			color_windowskin_to(@_window.windowskin_color, @speed_color) if @color_windowskin_on_over
			color_contents_to(@_window.contents_color, @speed_color) if @color_contents_on_over
			return true
		end
		return false
	end
	def force_new_state(arg)
		@_state = arg
		color_windowskin_to(@_window.windowskin_color, @speed_color)
		color_contents_to(@_window.contents_color, @speed_color)
	end
	def triggerEvent
		if new_state(States[:red])
			if @_trigger_event
				@_window.send(@_trigger_method, *@_trigger_args)
			end
		end
	end
	def releaseEvent
		if new_state(States[:black])
			if @_release_event
				@_window.send(@_release_method, *@_release_args)
			end
		end
	end
	def overEvent
		
		if new_state(States[:grey])
			Global.selected_windows = true if !$mouse.triggered? && self.contents_visible
			if @_over_event
				@_window.send(@_over_method, *@_over_args)
			end
		end
	end
	def outEvent
		if @_state != States[:black]
			if new_state(States[:blank])
				Global.selected_windows = false if !$mouse.triggered? && self.contents_visible
				if @_over_event
					@_window.send(@_unover_method, *@_unover_args)
				end
			end
		end
	end
	def get_relative_x; return @rect.x - @_window.rect.x; end
	def get_relative_y; return @rect.y - @_window.rect.y; end
	
	def set_trigger_event(tm, ta)
		@_trigger_event  = true
		@_trigger_method = tm
		@_trigger_args   = ta
	end
	
	def set_release_event(rm, ra)
		@_release_event = true
		@_release_method = rm
		@_release_args = ra
	end
	
	def set_over_event(om, oa, um, ua)
		@_over_event = true
		@_over_method = om
		@_over_args = oa
		@_unover_method = um
		@_unover_args = ua
	end
	
	def set_windowskin(arg=nil, group=:buttons)
		super(arg)
		self.register(group) if group
	end
	def set_windowskin_color(a, r, g, b)
		if @color_windowskin_on_over
			super(*(Gosu::Color.merge(Gosu::Color.new(a, r, g, b), get_saved_color()).to_a))
		else
			super(a,r,g,b)
		end
		if !self.visible?
			Global.selected_windows = false 
		#elsif @rect.xyCollision?($mouse.real_mouse_x, $mouse.real_mouse_y)
		#	Global.selected_windows = true
		end
	end
	def set_contents_color(a, r, g, b)
		if @color_contents_on_over
			super(*(Gosu::Color.merge(Gosu::Color.new(a, r, g, b), get_saved_color()).to_a))
		else
			super(a,r,g,b)
		end
		if !self.visible?
			Global.selected_windows = false
		#elsif @rect.xyCollision?($mouse.real_mouse_x, $mouse.real_mouse_y)
		#	Global.selected_windows = true
		end
	end
	def set_dimensions(x, y, w, h)
		super(x + @_window.rect.x, y + @_window.rect.y, w, h)
	end
end