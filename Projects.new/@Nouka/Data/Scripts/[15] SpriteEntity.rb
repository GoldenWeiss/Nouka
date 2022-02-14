#==============================================================================
# ** SpriteEntity
#------------------------------------------------------------------------------
#   Print Bitmap of an Entity on screen.
#==============================================================================

class SpriteEntity
	
	def initialize(entity)
		@frame = 0
		@entity = entity
		@sprite_name = [entity.sprite_name + "0", entity.sprite_name + "1"]
		_index = Database::Entities::Classes[@entity.type_id][@entity.class_id][3][@entity.variant_id][0]
		@bitmap = [Cache.character(@sprite_name[0])[_index], Cache.character(@sprite_name[1])[_index]]
		@dying_frame = 0
		@damaging_frame = 0
		@summoning_frame = 0
		@hpbar_frame = 0
		@battle_hpbar = false
		@clip_rect=Rect.new
	end
			
	def draw
		if Global.show_entities_rect
			@entity.current_detect_range.draw
			@entity.current_attack_range.draw
		end
		if Global.show_teams_rect
			@entity.base_volume_range.draw 
		end
		x = @bitmap[@entity.sprite_frame]
		Gosu.clip_to(@entity.x,@entity.y,@clip_rect.width,@clip_rect.height){
		x.draw(@entity.x, @entity.y, @entity.sprite_z, @entity.sprite_zoom,@entity.sprite_zoom, @entity.sprite_color)}
		@clip_rect.set(@entity.x,@entity.y,@entity.current_volume_range.width,@entity.current_volume_range.height)
		if @entity.summoning
			tc = Global.teams[@entity.team_id].color
			t = @summoning_frame / @entity.summoning_time
			@entity.sprite_color = Gosu::Color.new(255, tc.red+(255-tc.red)*t,tc.green+(255-tc.green)*t,tc.blue+(255-tc.blue)*t)
			Gosu.translate(0,-3) {
				Gosu.clip_to(@entity.x, @entity.y, t * 16, 3) {
					Gosu.draw_quad(@entity.x, @entity.y, tc, @entity.x + 16, @entity.y, tc, 
					@entity.x + 16, @entity.y + 3, tc, @entity.x, @entity.y + 3, tc, 300)
				}
			}
			@clip_rect.height = @entity.current_volume_range.height/@entity.summoning_time*@summoning_frame
			if @summoning_frame == @entity.summoning_time
				@summoning_frame = 0
				@entity.summoning = false
			else
				@summoning_frame += 1
			end
		end
		if @entity.battle_dying
			@entity.sprite_color = Gosu::Color.new(@entity.sprite_color.alpha-42.5,255, @entity.sprite_color.green-42.5, @entity.sprite_color.blue-42.5)
			
			if @dying_frame == 6
				@dying_frame = 0
				@entity.battle_dying = false
				Global.scene.delEntity(@entity)
			else
				@dying_frame += 1
			end
		end
		if @entity.battle_damage != 0
			@battle_hpbar = true
			#if @entity.battle_damage > 0 # Not gaining Hp
				@entity.sprite_color = @entity.battle_damage > 0 ? Gosu::Color::RED : Gosu::Color::YELLOW
				if @damaging_frame == 1
					@damaging_frame = 0
					@entity.sprite_color = Gosu::Color::WHITE
					@entity.battle_damage = 0
				else
					@damaging_frame += 1
				end
			#end
		end
		if @battle_hpbar
			Gosu.translate(-3,-6) {
				Gosu.clip_to(@entity.x, @entity.y, @entity.current_hp/@entity.base_hp.to_f * 22, 3) {
					Gosu.draw_quad(@entity.x, @entity.y, Gosu::Color::RED, @entity.x + 22, @entity.y, Gosu::Color::YELLOW, 
					@entity.x + 22, @entity.y + 3, Gosu::Color::YELLOW, @entity.x, @entity.y + 3, Gosu::Color::RED, 300)
				}
			}
			if @entity.battle_damage == 0
				if @hpbar_frame == 120
					@hpbar_frame = 0
					@battle_hpbar = false
				end
				@hpbar_frame += 1
			end
		end
		@entity.sprite_hovered.each{|i|i.draw}
	end
end