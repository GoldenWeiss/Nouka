class BarWindow < MultiWindow

	def initialize()
		super()
		@_btn_width = 120
		@_btn_height = 30
		@_windows = SwitchableWindow.new
		@_buttons = CachableQueue.new
		
		
		@_move_window = false
		@_move_h = 0
		@_move_k = 0
		add_window(@_windows)
	end
	def update
		if @_move_window
			_x, _y = self.x, self.y
			self.x = ($mouse.real_mouse_x  - @_move_h)
			self.y = ($mouse.real_mouse_y  - @_move_k)		
		end
		super()
	end
	def update_buttons
		_i = -1
		@_buttons.each do |b|
			_i += 1
			b.set_dimensions(_i * @_btn_width, 0, @_btn_width, @_btn_height)
		end
	end
	def action_move_window(b)
		if !@_move_window
			@_move_window = true
			@_move_h = $mouse.real_mouse_x - @rect.x
			@_move_k = $mouse.real_mouse_y - @rect.y
		end
	end
	def action_stop_window(b)
		@_move_window = false
		return_to_blank(b)
	end
	def get_window(index); @_windows[index]; end
	def get_btn_width; return @_btn_width; end
	def get_btn_height; return @_btn_height; end
	def set_btn_width(v); @_btn_width = v; end
	def set_btn_height(v); @_btn_height = v; end
	def add_window_to_bar(wnd, title)
		@_windows.add_window(wnd)
		wnd.z = 3003
		btn = get_button(add_button(@_btn_width * (@_windows.size-1) + 2, 2, @_btn_width, @_btn_height))
		btn.set_centered_text(20, @_btn_height/2-10, title)
		btn.speed_color = 1
		btn.set_windowskin(DefaultWindowskin)
		btn.set_release_event(:set_current_window, [@_windows.size-1])
		#btn.color_windowskin_on_over = false
		#btn.color_contents_on_over = false
		btn.z = 3004
		@_buttons.push(btn)
	end
	def set_current_window(index)
		unless @_windows.current_index == index
			@_buttons[@_windows.current_index].force_new_state(Button::States[:blank])
			@_buttons[index].force_new_state(Button::States[:black])
			@_windows.update_current_window(index)
		end
	end
	def hide_window(index)
		#if @_windows.current_index == index
		#	set_current_window(Math.min())
		@_windows.hide_window(index)
		_b = @_buttons.cache(index)
		_b.hidden = true
		update_buttons
	end
	def show_window(index)
		@_windows.show_window(index)
		@_buttons.uncache(index)
		@_buttons[index].hidden = false
		update_buttons
	end
	[:width=, :height=].each do |s|
		define_method(s) do |*args|
			@_windows.each { |i| i.public_send(s, *args)}
			super(*args)
		end
	end
end