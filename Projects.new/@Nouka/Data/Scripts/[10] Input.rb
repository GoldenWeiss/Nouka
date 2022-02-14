module Input
	
	class Mouse
		attr_reader :start_x, :start_y
		attr_accessor :camera
		def initialize
			# Mouse coordinates
			@start_x, @start_y, @end_x, @end_y = 0, 0, 0, 0
			
			@_triggered = false # Check if Mouse is currently pressed
			@_dragging  = false # Check if Mouse is currently dragging
			@_dragged   = false # Check if Mouse was dragged at least one time
			@_released  = true

			@_show_drag_rect = false # Mouse.showDragRect()|Mouse.hideDragRect()
			@_drag_rect = Rect.new(0, 0, 0, 0, Gosu::Color::RED)	   
			@_vx, @_vy = 0, 0
			@_wheel = 0
		end
		def x;@end_x;end;def y;@end_y;end
		def real_mouse_x;Global.game.mouse_x;end
		def real_mouse_y;Global.game.mouse_y;end
		def real_start_x;@start_x*Global.camera.zoom+Global.camera.rect.x;end
		def real_start_y;@start_y*Global.camera.zoom+Global.camera.rect.y;end
		def absolute_mouse_x;Ratio.screen_convx(Global.game.mouse_x);end
		def absolute_mouse_y;Ratio.screen_convy(Global.game.mouse_y);end
		def relative_mouse_x;Ratio.screen_convx(Global.game.mouse_x - Global.camera.rect.x);end
		def relative_mouse_y;Ratio.screen_convy(Global.game.mouse_y - Global.camera.rect.y);end
		def vx;@_vx;end;def vy;@_vy;end
		def sx;@_sx;end;def sy;@_sy;end
		
		# When mouse is starting or releasing
		def trigger
			@_triggered = true
			@_dragged   = false
			@_dragging  = false
			@_released  = false
			
			@start_x = relative_mouse_x
			@start_y = relative_mouse_y
			@end_x, @end_y = @start_x, @start_y
			@_vx, @_vy = 0, 0
			
			#update_drag_rect
		end
		def release
			@_triggered = false
			@_dragging = false
			@_released = true
			@_show_drag_rect = false
			
			@end_x = relative_mouse_x
			@end_y = relative_mouse_y
			@_vx, @_vy = 0, 0
		end
		def update
			if @_triggered
				@end_x = relative_mouse_x
				@end_y = relative_mouse_y
				@_dragging = (@end_x != @start_x) || (@end_y != @start_y)
				@_dragged = @_dragging if !@_dragged
				update_drag_rect if @_dragging
			end
		end
		def update_drag_rect 
			if (@start_x < @end_x)
				_x, _w = @start_x, @end_x - @start_x
				@_vx = Global.game.mouse_x - Database::Config::DefaultWidth > 0 ? -1 : 0
			else
				_x, _w = @end_x, @start_x - @end_x
				@_vx = absolute_mouse_x < 0 ? 1 : 0
			end
			if (@start_y < @end_y)
				_y, _h = @start_y, @end_y - @start_y
				@_vy = Global.game.mouse_y > Database::Config::DefaultHeight ? -1 : 0
			else
				_y, _h = @end_y, @start_y - @end_y
				@_vy = absolute_mouse_y < 0 ? 1 : 0 
			end
			@_drag_rect.set(_x, _y, _w, _h)
		end
		def draw
			return if !(@_triggered and @_dragging and @_show_drag_rect)
			@_drag_rect.draw
		end
		def wheelUp; @_wheel = 1; end
		def wheelDown; @_wheel = -1; end
		def wheel;@_wheel; end
		def wheelUp?; @_wheel == 1; end
		def wheelDown?; @_wheel == 2; end
		def updateWheel; @_wheel = 0; end
		
		def getDragRect
			return @_drag_rect
		end
		def showDragRect
			@_show_drag_rect = true
		end
		def hideDragRect
			@_show_drag_rect = false
		end
		def triggered?
			return @_triggered
		end
		def unrelease
			@_released = false
		end
		def released?
			return @_released
		end
		def drag
			@_dragged = true
		end
		def dragged?
			return @_dragged
		end
		def dragging?
			return @_dragging
		end
	end
	
	class Keyboard
		def initialize
			@_keys = {}
		end
		def trigger(key)
			if !@_keys.key?(key)
				@_keys[key] = [true, false]
			end
			@_keys[key][0] = false
			@_keys[key][1] = true
		end
		def release(key)
			@_keys[key][1] = false
			@_keys[key][0] = true
		end
		def triggered?(key)
			return false if !@_keys.key?(key)
			return @_keys[key][1]
		end
		def released?(key)
			if @_keys.key?(key)
				if @_keys[key][1]
					@_keys[key][1] = false
					return @_keys[key][0]
				end
			end
			return false
		end
		def coords8
			_up, _down = triggered?(Gosu::KbUp), triggered?(Gosu::KbDown)
			_left, _right = triggered?(Gosu::KbLeft), triggered?(Gosu::KbRight)
			if    _down && _left
				return -1, 1  # 1
			elsif _down && _right 
				return  1, 1  # 3
			elsif _down 
				return  0, 1  # 2 
			elsif _up && _right
				return  1,-1  # 7
			elsif _up && _left
				return -1,-1  # 9
			elsif _up
				return 0, -1  # 8
			elsif _left
				return -1, 0  # 4
			elsif _right 
				return  1, 0  # 6 
			else
				return  0, 0  # 0
			end
		end
	end
	@mouse = Mouse.new
	@keyboard = Keyboard.new
	class << self;attr_reader :mouse, :keyboard;end
end