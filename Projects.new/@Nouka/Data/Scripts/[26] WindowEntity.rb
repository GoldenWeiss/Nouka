class WindowEntity < BarWindow
	
	def initialize()
		super
		@_names = ["A", "S", "O"]
		@_entities = []
		set_dimensions(EtnX, EtnY, EtnWidth, 0)
		
		set_btn_width (EtnWidth/3)
		set_btn_height(30)
		
		@_dwindow = self.add_window(DescriptionWindow.new)
		@_swindow = self.add_window(SummonableEntitiesWindow.new(self))
		
		add_window_to_bar( WindowActions.new(self), @_names[0] )
		add_window_to_bar(  WindowSkills.new(self), @_names[1] )
		add_window_to_bar(    WindowPath.new(self), @_names[2] )
		set_current_window(0)
		#_image = self.add_font_image(:title, DefaultFont, 28, Gosu::Color::WHITE, 
		#Database::Config::DefaultWidth/2, 60, "Options")
		#_image.ox = 0.5 
		
	end
	def set_current_window(index)
		super(index)
		get_window(0).release_current_action()
	end
	def get_absolute
		return @_windows.current_window.get_absolute
	end
	def get_entities
		return @_entities
	end
	def set_entities(entities)
		unless @_entities == entities
			@_entities = entities
			if @_entities.any?{|e|e.team_id != Global.player_team_id}
				hide_window(0)
				set_current_window(1) if @_windows.current_index == 0
			else
				if @_windows.cached?(0)
					show_window(0)
					set_current_window(0)# if @_windows.current_index == 0
				end
			end
			@_windows.each{|w|w.set_entities}
			update_entities
		end
	end
	def update_entities
		close if @_entities[0].dead?
		@_windows.each {|w| w.update_entities}
	end
	def update
		
		super
		update_entities if !@_entities.empty?
	end
	def open
		self.windowskin_visible = true
		self.color_windowskin_to(FullColor, 2)
		self.color_contents_to(FullColor, 2)
		self.scale_to(EtnWidth, EtnHeight, 2)
	end
	def close
		get_window(0).release_current_action()
		self.color_windowskin_to(BlankColor, 2)
		self.color_contents_to(BlankColor, 2)
		self.scale_to(EtnWidth, 0, 2)
	end
	def show_action_description(i)
		@_dwindow.hidden = false
		_title = Database::Entities::Actions[i][0]
		_color = Global.teams[@_entities[0].team_id].color
		_text  = Database::Entities::Actions[i][3]
		@_dwindow.set_description(_title,_color,_text)
	end
	def show_entity_description(e)
		@_dwindow.hidden = false
		_title = Entity.class_name(*e)
		_color = Global.teams[@_entities[0].team_id].color
		_text  = Entity.description(*e)
		@_dwindow.set_description(_title,_color,_text)
	end
	def hide_description
		@_dwindow.hidden = true
	end
	def show_summonable
		@_swindow.show
	end
	def hide_summonable
		@_swindow.hide
	end
	class DescriptionWindow < TransitionWindow
		def initialize
			super
			self.hidden=true
			self.set_windowskin(DefaultWindowskin)
			self.set_type(DefaultType)
			self.set_dimensions(EtnX,EtnY,100,100)
			
			self.windowskin_visible = true
			self.register(:windows)
			self.add_font_image(:title, DefaultFont, 22, Gosu::Color::WHITE, EtnX+19, EtnY+4, '', false)
			self.z = 3020
		end
		def set_description(title, tcolor, text)
			_ftitle = self.get_image(:title)
			_s = 20
			_d = 7
			_f = Cache.font(DefaultFont,_s)
			_stext = text.split(/\n/)
			_stext.map!{|x|_f.text_width(x)}
			_twidth = _stext.max
			self.set_text_size(_twidth)
			self.width = _twidth + _d * 2
			_ftitle.real_color = tcolor
			_ftitle.update_color(@contents_color)
			_ftitle.set_text(title)
			
			set_text(20, _d, 26, text)
			self.height = self.get_contents.size*_s + 22			
		end
		def update
			super
			unless @hidden
				self.x = Input.mouse.real_mouse_x
				self.y = Input.mouse.real_mouse_y
			end
		end
	end
	class SummonableEntitiesWindow < ButtonMultiWindow
		def initialize(parent)
			super(parent,-DesWidth,0,DesWidth,EtnHeight)
			self.hidden=true
			@_selectedb = nil
			self.set_windowskin(DefaultWindowskin)
			self.set_type(DefaultType)
			self.color_windowskin_on_over = false
			self.color_contents_on_over = false
			self.windowskin_visible = false
			self.set_release_event(:return_to_blank, [self])
			self.register(:windows)
			self.z = 3004
		end
		def set_summoning_entity(b,e)
			return_to_blank(@_selectedb) if @_selectedb
			hide_description
			@_selectedb = b
			Global.current_action[1][1] = e
		end
		def show_description(e)
			@_window.show_entity_description(e)
		end
		def hide_description
			@_window.hide_description
		end
		def show
			self.hidden=false
			_hx ,_ky= 4,0
			Global.teams[@_window.get_entities[0].team_id].summonable_entities.each_with_index do |e, i|
				_b = self.get_button(self.add_button(_hx, (_ky+i*(IcoDim+6)).to_i, IcoDim, IcoDim))
				_b.z = 3009
				_b.set_windowskin(DefaultWindowskin)
				#_b.add_icon_image(:bgsprite, Database::Entities::Actions[i][1], EtnTextColor, _b.x, _b.y, IcoDim/24, false)
				_b.set_over_event(:show_description,[e],:hide_description,[])
				_b.set_release_event(:set_summoning_entity,[_b,e])
			end
		end
		def hide
			@data.clear
			self.hidden=true
		end
	end
	# 
	# create_buttons
	class WindowActions < ButtonMultiWindow
		def initialize(parentbar)
			super(parentbar, 0, 0, EtnWidth, EtnHeight)
			
			self.set_windowskin(DefaultWindowskin, :windows)
			self.set_type(DefaultType)
			
			self.set_release_event(:action_stop_window, [self])
			self.set_trigger_event(:action_move_window, [self])
			
			self.color_windowskin_on_over = false
			self.windowskin_visible = false
			self.add_font_image(:name, DefaultFont, 20, EtnTextColor, 
			EtnX + 17, EtnY + parentbar.get_btn_height + 10,"", false)
			self.add_font_image(:level, DefaultFont, 20, EtnTextColor, 
			EtnX + 17, EtnY + parentbar.get_btn_height + 24,"", false)
			_hp = self.add_font_image(:hp, DefaultFont, 20, EtnTextColor, 
			EtnX + 184, EtnY + parentbar.get_btn_height + 10,"", false)
			_hp.ox = 1
			
			create_buttons()
		end
		def show_description(i)
			@_window.show_action_description(i)
		end
		def hide_description
			@_window.hide_description
		end
		def create_buttons
			@_actions = Array.new
			_hx, _ky = 14, @_window.get_btn_height + 46
			_ary = Database::Entities::Actions
			_ary.size.times do |i|
				_b = self.get_button(self.add_button(_hx + i % 3 * (IcoDim+14), _ky + (i - i % 3) / 3 * (IcoDim+14), IcoDim, IcoDim))
				_b.color_contents_on_over = true
				_b.z = 30099
				_b.set_windowskin(DefaultWindowskin)
				_b.add_icon_image(:bgsprite, Database::Entities::Actions[i][1], EtnTextColor, _b.x, _b.y, IcoDim/24, false)
				_b.set_release_event(_ary[i][2],[_b])
				_b.set_over_event(:show_description,[i],:hide_description,[])
				@_actions.push(_b)
			end
		end
		def update_buttons
			_ary = Database::Entities::Actions
			_entities = @_window.get_entities
			if _entities.size == 1 && _entities.any?{|e|e.team_id == Global.player_team_id}
				_hx, _ky, _i = 14, @_window.get_btn_height + 46, 0
				@_actions.each_with_index do |b, n|
					if _entities[0].actions.include?(n)
						b.hidden = false
						b.x = self.x + _hx + _i % 3 * (IcoDim+14)
						b.y = self.y + _ky + (_i - _i % 3) / 3 * (IcoDim+14)
						_i += 1
						if n==0
							team = Global.teams[_entities[0].team_id]
							_locked = false
							if team.summonable_entities.empty? || team.mana <= 0
								_locked = true
							else
								c = team.summonable_entities.map{|e|Entity.mana_cost(*e)}
								if c.min > team.mana
									_locked = true
								end
							end
							if _locked
								b.force_new_state( Button::States[:locked])
							elsif b.onState?(Button::States[:locked])
								return_to_blank(b)
							end
						end
						#if _entities[0].dead?
						#	b.force_new_state( Button::States[:locked])
						#end
					else
						b.hidden = true
					end
				end
			else
				@_actions.each {|b| b.hidden = true}
				
			end
		end
		def set_entities
			_e = @_window.get_entities[0]
			get_image(:name).real_color = Global.teams[_e.team_id].color
			get_image(:level).real_color = Global.teams[_e.team_id].color
		end
		def update_entities
			_e = @_window.get_entities[0]
			get_image(:name).set_text(_e.class_name)
			
			get_image(:level).set_text("Lvl " + _e.level.to_s)
			
			get_image(:hp).set_text(_e.current_hp.to_s + "/" + _e.base_hp.to_s)
			update_buttons
		end
		def action_summon(b)
			release_current_action()
			@_window.show_summonable
			
			Global.current_action[0] = 0
			Global.current_action[1] = [b,nil]
			
		end
		def action_move(b)
			release_current_action()
			Global.current_action[0] = 1
			Global.current_action[1] = [b]

		end
		def action_hp_up(b)
			release_current_action()
			if !@_window.get_entities[0].dead?
				@_window.get_entities[0].current_hp = @_window.get_entities[0].base_hp#increase_level
				@_window.update_entities
			end
			return_to_blank(b)
			
		end
		def action_build(b)
			release_current_action()
			return_to_blank(b)
			
		end
		def action_delete(b)
			release_current_action()
			_e = @_window.get_entities[0]
			if !_e.dead?
				
				_e.die()
				Global.teams[_e.team_id].mana += (_e.mana_cost/3).floor
			end
			return_to_blank(b) 
		end
		def release_current_action
			if Global.current_action[1][0]
				return_to_blank(Global.current_action[1][0])
			end
			@_window.hide_description
			@_window.hide_summonable
		end
	end
	class WindowSkills < ButtonMultiWindow
		Statsary = [:atk, :def, :mag, :res]
		def initialize(parentbar)
			super(parentbar, 0, 0, EtnWidth, EtnHeight)
			self.set_windowskin(DefaultWindowskin, :windows)
			self.set_type(DefaultType)
			self.set_release_event(:action_stop_window, [self])
			self.set_trigger_event(:action_move_window, [self])
			self.color_windowskin_on_over = false

			self.add_font_image(:name, DefaultFont, 20, EtnTextColor, 
			EtnX + 17, EtnY + parentbar.get_btn_height + 10,"", false)
			self.add_font_image(:level, DefaultFont, 20, EtnTextColor, 
			EtnX + 17, EtnY + parentbar.get_btn_height + 24,"", false)
			_hp = self.add_font_image(:hp, DefaultFont, 20, EtnTextColor, 
			EtnX + 184, EtnY + parentbar.get_btn_height + 10,"", false)
			_hp.ox = 1
			Statsary.each_with_index do |n, i|
				_x = self.add_font_image(n.upcase, DefaultFont, 20, EtnTextColor, 
				EtnX + 52, EtnY + parentbar.get_btn_height + 48 + i*20,
				n.to_s.capitalize + ' :', false)
				_x.ox = 1
				self.add_font_image(n, DefaultFont, 20, EtnTextColor, 
				EtnX + 67, EtnY + parentbar.get_btn_height + 48 + i*20,
				'', false)
				
			end
		end
		def set_entities
			_e = @_window.get_entities[0]
			get_image(:name).real_color = Global.teams[_e.team_id].color
			get_image(:level).real_color = Global.teams[_e.team_id].color
		end
		def update_entities
			_e = @_window.get_entities[0]
			get_image(:name).set_text(_e.class_name)
			get_image(:level).set_text("Lvl " + _e.level.to_s)
			get_image(:hp).set_text(_e.current_hp.to_s + "/" + _e.base_hp.to_s)
			Statsary.each {|n|get_image(n).set_text(_e.send('current_' + n.to_s).to_s)}
		end
	end  
	class WindowPath < ButtonMultiWindow
		def initialize(parentbar)
			super(parentbar, 0, 0, EtnWidth, EtnHeight)
			self.set_windowskin(DefaultWindowskin, :windows)
			self.set_type(DefaultType)
			
			
			self.set_release_event(:action_stop_window, [self])
			self.set_trigger_event(:action_move_window, [self])
			
			self.color_windowskin_on_over = false
	
			self.add_font_image(:title1, DefaultFont, 20, EtnTextColor, 
			EtnX + 7, EtnY + parentbar.get_btn_height + 20 * 1,
			"Trajectoires programmées", false)
			self.add_font_image(:title2, DefaultFont, 20, EtnTextColor, 
			EtnX + 7, EtnY + parentbar.get_btn_height + 20 * 2,
			"(" + Megacafe + ")", false)
			
		end
		def update_entities
	
		end
		def set_entities
		
		end
	end
end