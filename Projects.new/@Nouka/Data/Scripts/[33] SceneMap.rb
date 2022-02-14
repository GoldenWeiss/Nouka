class SceneMap
	attr_reader :map
	attr_reader :tleaders,:tmana,:tsummonable,:tentities,:tblocks
	def init()
		
		@mouse = Input.mouse
		@keyboard = Input.keyboard
		@mouse.showDragRect
		@windows = Hash.new
		@windows[:msg]    = WindowMessage.new
		@windows[:pause]  = WindowPause.new
		@windows[:option] = WindowOptions.new
		@windows[:entity] = WindowEntity.new
		@windows[:hud]    = WindowHUD.new
		set_level(Database::Config::StartLevel)
		_plane_width = Database::Config::DefaultWidth
		@windows[:p_border_up] = AnimatedPlane.new(0, 0, Database::Config::DefaultWidth, _plane_width, 2999, Window::BlankColor)
	
	end
	def set_level(index)
		Global.current_level = index
		@level  = Database::Levels[Global.current_level]
		@mapID  = @level[0][0]
		@code   = @level[1]
		@_cstep = 0
		@_limit_rects = CachableQueue.new
		@map    = N::Map.new(Global.current_map)
		
		Global.state  = Database::States[:play]
		Global.camera.rect.x = @level[0][1]#+#@map.rect.width/2*Global.camera.zoom
		Global.camera.rect.y = @level[0][2]#+#@map.rect.height/2*Global.camera.zoom
		
		@windows[:entity].close
		@map.clearSelectedEntities
	end
	
	def update
		
		@mouse.update
		@map.update
		
		windows_update
		if Global.state == Database::States[:play]
			keyboard_event_update
			wheel_event_update
			mouse_event_update
		#selse
			
		end
		@mouse.unrelease
		
		eval(@code)
	end
	def set_code_step(n)
		@_cstep = n
	end
	def draw
		windows_draw
		@map.draw
	end
	
	def wheel_event_update
		return unless Global.can_zoom
		_dir = @mouse.wheel
		if _dir != 0
			_newzoom = Global.camera.zoom + _dir
			if _newzoom.between?(Database::Maps::MinZoomFactor, Database::Maps::MaxZoomFactor)
				#x = @mouse.real_mouse_x - Global.camera.rect.x#* Global.camera.zoom #- Global.camera.rect.x
				#y = @mouse.real_mouse_y - Global.camera.rect.y#* Global.camera.zoom #- Global.camera.rect.y
				Global.camera.zoom = _newzoom
				#x2 = @mouse.real_mouse_x * Global.camera.zoom - x
				#y2 = @mouse.real_mouse_y * Global.camera.zoom - y
				#Global.camera.rect.moveC(x,y)
				#(Global.game.mouse_x - Global.camera.rect.x)*_newzoom
				#Global.camera.rect.moveR(-(@mouse.real_mouse_x - Global.camera.rect.x) * _inc, -(@mouse.real_mouse_y - Global.camera.rect.y) * _inc)
				
			end
			@mouse.updateWheel
		end
	end
	
	def keyboard_event_update
		return unless Global.can_scroll
		_dir = @keyboard.coords8
		_v = Database::Maps::MoveSpeed * Global.camera.zoom / Database::Config::ZoomFactor
		Global.camera.rect.moveR(-_dir[0] * _v, -_dir[1] * _v)
		Global.camera.rect.moveR(@mouse.vx * _v, @mouse.vy * _v)
		
		Global.camera.rect.x = Global.camera.rect.width - @map.rect.width*Global.camera.zoom if Global.camera.rect.x < Global.camera.rect.width - @map.rect.width*Global.camera.zoom
		Global.camera.rect.y = Global.camera.rect.height- @map.rect.height*Global.camera.zoom if Global.camera.rect.y < Global.camera.rect.height - @map.rect.height*Global.camera.zoom
		Global.camera.rect.x = 0 if Global.camera.rect.x > 0
		Global.camera.rect.y = 0 if Global.camera.rect.y > 0
		@_limit_rects.each	{|r|
			Global.camera.rect.x = Global.camera.rect.width - (r.width+r.x)*Global.camera.zoom if Global.camera.rect.x < Global.camera.rect.width-(r.width+r.x)*Global.camera.zoom
			Global.camera.rect.y = Global.camera.rect.height - (r.height+r.y)*Global.camera.zoom if Global.camera.rect.y < Global.camera.rect.height-(r.height+r.y)*Global.camera.zoom
			Global.camera.rect.x = -r.x*Global.camera.zoom if r.x*Global.camera.zoom > -Global.camera.rect.x
			Global.camera.rect.y = -r.y*Global.camera.zoom if r.y*Global.camera.zoom > -Global.camera.rect.y
		}
	end
	def add_limit_rect(rect)
		@_limit_rects.push(rect)
	end
	def show_limit_rect(id)
		@_limit_rects.uncache(id)
	end
	def hide_limit_rect(id)
		@_limit_rects.cache(id)
	end
	def clear_limit_rects
		@_limit_rects.clear
	end
	def mouse_event_update
		@mouse.hideDragRect
		if !Global.selected_windows
			if @mouse.triggered?&&Global.can_select
				
				if @mouse.dragged?
					@mouse.showDragRect
					@map.updateSelectedEntities
				else
					@map.updateSelectedEntities if Global.current_action[0] < 0 #|| (Global.current_action[0]==1&&!Global.current_action[1][0])
					Global.reset_current_action if @map.newSelectedEntities?
				end
			end
			if @mouse.released?&&Global.can_act
				
					if @map.selectedEntities? # Selected many entities
					
						case Global.current_action[0]
						when 0 # Summon
							
							get_window(:entity).get_window(0).release_current_action()
							get_window(:entity).hide_summonable
							_x = (@mouse.x/Database::Config::TileSize).floor.to_f*Database::Config::TileSize
							_y = (@mouse.y/Database::Config::TileSize).floor.to_f*Database::Config::TileSize
							
							if Global.current_map.xyDetectableBy?(@map.selectedEntities[0].current_detect_range, _x+Database::Config::TileSize/2, _y+Database::Config::TileSize/2)
								_edata = Global.current_action[1][1]
								if _edata
									if Global.teams[Global.player_team_id].mana >= Entity.mana_cost(*_edata)
										_e = Entity.new(-1, Global.player_team_id, _edata[0],_edata[1], 0, _x, _y)
									
										@map.addEntity(_e)
										Global.teams[Global.player_team_id].mana -= Entity.mana_cost(*_edata)
									end
								end
							end
						when 1 # Move
							
							unless @mouse.dragged?
							
								get_window(:entity).get_window(0).release_current_action()
								@map.selectedEntities.each {|e| e.moveTo(@mouse.x, @mouse.y) if e.has_action?(1) && e.team_id == Global.player_team_id}
							end
						when 2
						
						when 3
						
						when 4
						 
						when 5
						
						end
						Global.reset_current_action
						Global.current_action[0] = 1
						close_window(:msg) unless Global.texting
						@windows[:entity].set_entities(@map.selectedEntities) #if @map.newSelectedEntities?
						open_window(:entity)
					else
						
						# Exit Selection
						close_window(:entity)
						
						Global.reset_current_action
						
					end
				@mouse.unrelease
			end
		end
	end
	def show_message(*t)
		Global.texting = true
		@windows[:msg].set_text(*t)
		open_window(:msg)
	end
	def lock_message(p)
		@windows[:msg].lock(p)
	end
	def set_message_procs(*p)
		@windows[:msg].set_procs(*p)
	end
	def set_message_proc(i,p)
		@windows[:msg].set_proc(i,p)
	end
	def clearSelectedEntities
		close_window(:entity)
		@map.clearSelectedEntities
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
	
	def pause
		return unless Global.can_pause
		$mouse.release
		$mouse.unrelease
		
		if Global.state == Database::States[:pause]
			Global.state = Database::States[:play]
			@windows[:pause].close  if @windows[:pause].visible?
			@windows[:option].close if @windows[:option].visible?
			if Global.texting
				@windows[:msg].load_text
				@windows[:msg].open
			end
			@windows[:p_border_up].color_to(Window::BlankColor, 7)
			@windows[:entity].open if @map.selectedEntities?
		else
			Global.state = Database::States[:pause]
			@windows[:pause].open
			@windows[:p_border_up].color_to(Window::BorderColor, 7)
			if @windows[:msg].visible?
				@windows[:msg].close
				@windows[:msg].save_text
			end
			@windows[:entity].close if @windows[:entity].visible?
		end
		
	end
	def addProjectile(p);@map.addProjectile(p);end
	def delEntity(e);@map.delEntity(e);end
end