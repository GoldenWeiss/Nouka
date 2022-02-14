class WindowOptions < MultiWindow
	def initialize
		super
		@unover_text = "Modifier les options."
		@buttons_texts = 
		{
			
			:msg => "Message ",
			:wnd => "Fenetre ",
			:btn => "Bouton ",
		}
		
		self.windowskin_visible = false
		self.set_windowskin(DefaultWindowskin)
		self.set_dimensions(OpnX, OpnY, OpnWidth, 0)
		self.set_windowskin_color(BlankColor.alpha, BlankColor.red, BlankColor.green, BlankColor.blue)
		self.set_contents_color(BlankColor.alpha, BlankColor.red, BlankColor.green, BlankColor.blue)
		
		_image = self.add_font_image(:title, DefaultFont, 28, Gosu::Color::WHITE, 
		Database::Config::DefaultWidth/2, 60, "Options")
		_image.ox = 0.5 
		
		create_buttons
		self.z = 3002
		self.register(:windows)
	end

	def create_buttons
		set_text_size(20)
		_height = 36
		_iy = 8
		_f2 = 6
		@b = Hash.new
		@b[:msg] = add_change_button(_f2, _f2+0*_height+0*_iy, OpnWidth - 2*_f2, _height, get_text_size,
		:set_info_text, ["Changer l'apparence de la fenêtre des messages."], 
		:set_info_text, [@unover_text],
		76, :action_msg_type, [[Global.scene.get_window(:msg)]])[0]

		@b[:wnd] = add_change_button(_f2, _f2+1*_height+1*_iy, OpnWidth - 2*_f2, _height, get_text_size,
		:set_info_text, ["Changer l'apparence des fenêtres du jeu."], 
		:set_info_text, [@unover_text],
		76, :action_wnd_type, [@@_registered_windows[:windows]])[0]
		
		@b[:btn] = add_change_button(_f2, _f2+2*_height+2*_iy, OpnWidth - 2*_f2, _height, get_text_size,
		:set_info_text, ["Changer l'apparence des boutons."], 
		:set_info_text, [@unover_text],
		76, :action_btn_type, [@@_registered_windows[:buttons]])[0]
		@b[:ok] = get_button(add_button(_f2, OpnHeight - (_height + _f2), OpnWidth - 2*_f2, _height))
		@b[:ok].set_windowskin(DefaultWindowskin)
		@b[:ok].set_centered_text(20, @b[:ok].rect.height/2-get_text_size()/2, "Valider")
		@b[:ok].set_release_event(:action_valid, [@b[:ok]])
		@b[:ok].set_over_event(:set_info_text, [nil, "Valider les changements apportés et\nretourner au menu précédent."], 
		:set_info_text, [nil, @unover_text]) # la mémoire ce n'est pas mon fort ... =)
	end
	
	
	def update_button_message(pw, w)
		@b[pw].set_centered_text(20, @b[pw].rect.height/2-get_text_size()/2, @buttons_texts[pw] + w.get_type.to_s)
	end
	def open
		self.windowskin_visible = true
		self.color_contents_to(FullColor, 7)
		self.color_windowskin_to(FullColor, 7)
		self.scale_to(OpnWidth, OpnHeight, 7)
		
		_wnd = Global.scene.get_window(:msg)
		
		update_button_message(:msg, _wnd)
		update_button_message(:wnd, @@_registered_windows[:windows][0])
		update_button_message(:btn, @@_registered_windows[:buttons][0])
		
		_wnd.set_text(@unover_text)
		_wnd.open
	end
	def close
		self.color_contents_to(BlankColor, 7)
		self.color_windowskin_to(BlankColor, 7)
		self.scale_to(OpnWidth, 0, 7)
		_wnd = Global.scene.get_window(:msg)
		_wnd.set_text("")
		_wnd.close
	end
	def change_type(b, w, inc)
		return_to_blank(b)
		w.each { |i| i.set_type((i.get_type() + inc) % Windowskins::SkinNumber) }
	end
	def set_info_text(b, t)
		_wnd = Global.scene.get_window(:msg)
		_wnd.set_text(t)
	end
	def action_valid(b)
		return_to_blank(b)
		close
		Global.scene.open_window(:pause)
	end
	def action_msg_type(b, w, inc)
		change_type(b, w, inc)
		update_button_message(:msg, Global.scene.get_window(:msg))
	end
	def action_wnd_type(b, w, inc)
		change_type(b, w, inc)
		update_button_message(:wnd, @@_registered_windows[:windows][0])
	end
	def action_btn_type(b, w, inc)
		change_type(b, w, inc)
		update_button_message(:btn, @@_registered_windows[:buttons][0])
	end
	
end