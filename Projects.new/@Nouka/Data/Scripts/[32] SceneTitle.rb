class SceneTitle
	def init
		@mouse = Input.mouse
		@windows = Hash.new
		@windows[:msg] = WindowMessage.new
		@windows[:option] = WindowOptions.new
		@windows[:pause] = WindowTitle.new
		@windows[:pause].open
	end
	def update
		@mouse.update
		windows_update
	end
	def draw
		windows_draw
	end
	def pause
		exit
	end
	def windows_update;@windows.each{|k,i|i.update};end
	def windows_draw;@windows.each{|k,i|i.draw};end
	def get_window(w);@windows[w];end
	def close_window(wnd)
		@windows[wnd].close
	end
	def open_window(wnd)
		@windows[wnd].open
	end
end

class WindowTitle < MultiWindow
	
	def initialize
		super
		@_names = ["Démarrer", "Options", "Commandes", "Quitter"]
		@_actions = [:action_resume, :action_options, :action_help, :action_quit]
		
		self.windowskin_visible = false
		self.set_windowskin(DefaultWindowskin)
		
		self.set_dimensions(PauX, PauY, PauWidth, 0)
		self.set_windowskin_color(BlankColor.alpha, BlankColor.red, BlankColor.green, BlankColor.blue)
		self.set_contents_color(BlankColor.alpha, BlankColor.red, BlankColor.green, BlankColor.blue)
		
		_image = self.add_font_image(:title, DefaultFont, 28, Gosu::Color::WHITE, 
		Database::Config::DefaultWidth/2, 60, "Nouka v3")
		_image.ox = 0.5
		
		create_buttons
		self.z = 3001
		self.register(:windows)
	end
	
	def create_buttons
		_hb = 36
		_iy = 2
		_f2 = 6
		@_names.size.times do |i|
			_index = add_button(_f2, _f2+i*(_hb+_iy), PauWidth-2*_f2, _hb)
			@data[_index].set_windowskin(DefaultWindowskin)
			@data[_index].set_text_size(@data[_index].rect.width-2)
			@data[_index].set_centered_text(20, 4, @_names[i])
			@data[_index].set_release_event(@_actions[i], [@data[_index]])
		end
	end
	
	def action_resume(b)
		b.new_state(Button::States[:blank])
		self.unregister(:windows)
		Global.selected_windows = false
		Global.game.set_scene(:SceneMap)
	end
	def action_options(b)
		b.new_state(Button::States[:blank])
		close
		Global.scene.open_window(:option)
	end
	def action_help(b)
		b.new_state(Button::States[:blank])
		close
		Global.scene.open_window(:command)
	end
	def action_quit(b)
		b.new_state(Button::States[:blank])
		Global.game.set_scene(nil)
	end
	def open
		self.windowskin_visible = true
		self.color_contents_to(FullColor, 7)
		self.color_windowskin_to(FullColor, 7)
		self.scale_to(PauWidth, PauHeight-40, 7)
	end
	def close
		self.color_contents_to(BlankColor, 7)
		self.color_windowskin_to(BlankColor, 7)
		self.scale_to(PauWidth, 0, 7)
	end
end
class WindowCommand < MultiWindow
end