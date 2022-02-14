class WindowHUD < BarWindow
	def initialize
		super
		set_dimensions(HudX,HudY,HudWidth,HudHeight)
		set_btn_width(80)
		set_btn_height(40)
		
		_window = WTeam.new(self, Global.player_team_id)
		add_window_to_bar(_window, Global.teams[_window.team].name)
		set_current_window(0)
		
		@_buttons[0].set_contents_color(*Global.teams[_window.team].color)
		@_buttons[0].windowskin_visible = false
		@_buttons[0].color_windowskin_on_over = false
		@_buttons[0].color_contents_on_over = false
		self.windowskin_visible = true
		#_window.windowskin_visible = false
	end
	def close
		self.windowskin_visible = false
	end
	def open
		self.windowskin_visible = true
	end
	def get_absolute
		return @_windows.current_window.get_absolute
	end
	class WTeam < ButtonMultiWindow
		attr_reader :team
		def initialize(p, t)
			super(p, 0, 0, HudWidth, HudHeight)
			@team = t
			self.set_windowskin(DefaultWindowskin,:windows)
			self.set_type(DefaultType)
			self.set_release_event(:action_stop_window, [self])
			self.set_trigger_event(:action_move_window, [self])
			self.color_windowskin_on_over = false
			mana = add_font_image(:mana, DefaultFont, 20, Global.teams[@team].color, HudX+HudWidth-31, HudY+HudHeight/2, '', false)
			mana.ox = 1
			mana.oy = 0.5
			manaico = add_icon_image(:manaico, 'm' + @team.to_s.rjust(3, '0'), Gosu::Color::WHITE, HudX+HudWidth-27, HudY+HudHeight/2, 1, false)
			manaico.oy = 0.5
			
		end
		def update
			super
			get_image(:mana).set_text(Global.teams[@team].mana)
		end
		def draw
			super
			
		end
	end
end
