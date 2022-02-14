class Entity
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	
	# Identity relatives
	attr_accessor :_id           # List index
	attr_accessor :map_id
	attr_accessor :team_id
	attr_reader   :type_id       # 1:Monster 2:Tower 3:Projectile 4:Object(Pannel, NPC)
	attr_reader   :class_id      # Class ID
	attr_reader   :variant_id    # Variant ID
	
	# Stats relatives
	attr_accessor :level
	attr_accessor :base_hp                 # Entity's base    Health  Points
	attr_accessor :base_atk                # Entity's base    Attack  Points
	attr_accessor :base_mag                # Entity's base    Magic   Points
	attr_accessor :base_def                # Entity's base    Defense Points
	attr_accessor :base_res                # Entity's base    Mag.Def Points
	attr_accessor :current_hp              # Entity's current Health  Points
	attr_accessor :current_atk             # Entity's current Attack  Points
	attr_accessor :current_mag             # Entity's current Magic   Points
	attr_accessor :current_def             # Entity's current Defense Points
	attr_accessor :current_res             # Entity's current Mag.Def Points
	
	# Map relatives
	attr_accessor :x
	attr_accessor :y
	attr_accessor :move_speed
	attr_accessor :base_detect_range       # Entity's base    Detect  Range
	attr_accessor :base_attack_range       # Entity's base    Attack  Range
	attr_accessor :base_volume_range       # Entity's base    Volume  Range
	attr_accessor :current_detect_range
	attr_accessor :current_attack_range
	attr_accessor :current_volume_range

	attr_accessor :summoning
	attr_accessor :summoning_time
	attr_accessor :move_route
	attr_reader   :roadblock
	attr_accessor :script
	attr_accessor :script_step
	attr_accessor :detectable
	
	attr_accessor :actions	
	attr_accessor :status
	attr_accessor :skills
	
	# Sprite relatives
	attr_accessor :sprite_z 
	attr_accessor :sprite_name             # Entity's Bitmap Path
	attr_accessor :sprite_frame            # Entity's Bitmap Pattern (0, 1 , 2, 3)
	attr_accessor :sprite_color            # Entity's Bitmap Color
	attr_accessor :sprite_zoom
	attr_accessor :sprite_hovered
	
	# Pathfinder
	attr_accessor :pathfinder

	# Quadtree
	attr_accessor :quadobject
	
	# Battle
	attr_accessor :init_battle
	attr_accessor :battle_dying
	attr_accessor :battle_damage
	
	#--------------------------------------------------------------------------
	# * Object Initialization		
	#--------------------------------------------------------------------------
	def initialize(_id, team_id, type_id, class_id, variant_id, m_x, m_y)
		# IDs set
		@_id  	  = _id
		@team_id  = team_id
		@type_id  = type_id
		@class_id = class_id
		@variant_id = variant_id
		
		# Stats
		@level = 1
		
		# Coordinates
		@x, @y = m_x, m_y
		
		# Programmed Movement
		# (0)GotoXY,(1)GotoCircle,(2)GotoMob
		@move_route = MoveRoute.new(self)
		
		# roadblock: act like a tile block; block: detectable even when in a battle 
		@roadblock = false
		# Entity's on-map code
		@script = nil
		@script_step = 0
		@detectable = true
		
		@base_hp, @base_atk, @base_def, @base_mag, @base_res,
		@current_hp, @current_atk, @current_def, @current_mag, @current_res = 
		*(Database::Entities::Classes[type_id][class_id][4]*2)
	end
	#-- Debug Purposes --#
	def marshal_dump
		return [ @_id, @type_id, @class_id, @team_id, @variant_id, @level, @x, @y, @move_route, @roadblock, @script, @script_step, @roadblock, @detectable,
		@base_hp, @base_atk, @base_def, @base_mag, @base_res,
		@current_hp, @current_atk, @current_def, @current_mag, @current_res]
	end
	def marshal_load(ary)
		@_id, @type_id, @class_id, @team_id, @variant_id, @level, @x, @y, @move_route, @roadblock, @script, @script_step, @roadblock, @detectable,
		@base_hp, @base_atk, @base_def, @base_mag, @base_res,
		@current_hp, @current_atk, @current_def, @current_mag, @current_res = ary
	end
	#--                --#
	
	# called on map
	def generate()
		_data = Entity.getData(@type_id,@class_id)
		# Sprite Data
		@sprite_name = _data[2]
		@sprite_frame = 0
		@sprite_z = 233 # 5 to 299
		@sprite_zoom = 1
		@sprite_hovered = []
		@sprite_color = Gosu::Color::WHITE
		@quadobject = nil
		
		# Movement
		@move_speed = _data[5]
		@move_frame_interval = 0
		@init_movement = false
		@movement = false
		@move_to_zone = [false, nil]
		@pathfinder = Pathfinding::Pathfinder.new(self)
		@pathfinder_stop=false
		
		# Battle
		@init_battle = false
		@battle_triggered = false
		@battle_frame_ratio = 0
		@battle_frequency = _data[6]
		@battle_ennemy = nil
		@battle_dying = false
		@battle_damage = 0
		@battle_pathfinder = Pathfinding::Pathfinder.new(self)
		@battle_find=false
		@battle_wait =0
		
		@detect_objects = []
		
		# Actions&Skills
		@actions = _data[7]
		@skills  = _data[8].map{|x|Skill.new(x[0],x[1])}

		# Ranges ~ Volume
		_v = _data[9]
		@base_volume_range = Rect.new(@x, @y, _v[0].to_f, _v[0].to_f, Global.teams[@team_id].color)
		@current_volume_range = @base_volume_range.clone
		
		@base_detect_range = Circle.new((_v[1]+0.5)*Database::Config::TileSize, 
		@x+Database::Config::TileSize/2, @y+Database::Config::TileSize/2, Database::Entities::RectColor[1])
		@current_detect_range = @base_detect_range.clone
		@base_attack_range = Circle.new((_v[2]+0.5)*Database::Config::TileSize,
		@x+Database::Config::TileSize/2, @y+Database::Config::TileSize/2, Database::Entities::RectColor[2])
		@current_attack_range = @base_attack_range.clone
		
		@summoning = (@summoning_time = _data[11].to_f) > 0 ? true : false
		
		@battle_active = _data[12]
		
		@move_route.update
		@try_detect = false
		
		if @roadblock && integer_coords
			Global.scene.map.e_grid[map_x][map_y].push(self)
		end
	end
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		unless @summoning
			update_move
			update_skills
			update_script
			update_battle 
			tryDetect
			tryWait
		end
	end
	
	def update_move
		if @init_movement
			if @pathfinder.running?
				if @pathfinder.resolved?
					if @pathfinder.solved?
						if @move_to_zone[0]
							_circle = @move_to_zone[1]
							_x = @pathfinder.current_action.x * Database::Config::TileSize
							_y = @pathfinder.current_action.y * Database::Config::TileSize
							_rect = Rect.new(_x,_y,Database::Config::TileSize,Database::Config::TileSize)
							while !Global.current_map.rDetectableBy?(_circle, _rect)
								break unless @pathfinder.read_action
								
								_x = @pathfinder.current_action.x * Database::Config::TileSize
								_y = @pathfinder.current_action.y * Database::Config::TileSize
								_rect = Rect.new(_x,_y,Database::Config::TileSize,Database::Config::TileSize)
							end
							
							@move_to_zone = [false,nil]
						end
						
						@movement = true
						@pathfinder.fragmentate_path(@move_speed)
						@pathfinder.reset_current_action
						@init_movement = false
						@pathfinder.stop		
					end
				end
			else
				@init_movement = false
			end
		end
		if @movement
		 
			if tryMove(@pathfinder.current_action)
				if !@pathfinder.read_action
					stopMove()
				end
			end
		end
	end
	
	def update_battle
		return unless @battle_active
		return unless @battle_triggered
		if @battle_ennemy.dead?
			freeBattle
			@move_route.update
			return
		end
		return unless self.active
		return if dead?
		if Global.current_map.rDetectableBy?(self.current_attack_range, @battle_ennemy.current_volume_range)#@current_attack_range.rCollision?(@battle_ennemy.current_volume_range)
			if @battle_frame_ratio == 0
				_id = Database::Entities::Classes[@type_id][@class_id][3][@variant_id][1]
				_p = Entity::Projectile.new(_id, self, @current_volume_range.center_x, @current_volume_range.center_y, @battle_ennemy.current_volume_range.center_x, @battle_ennemy.current_volume_range.center_y)
				Global.scene.addProjectile(_p)
			end
			@battle_frame_ratio = (@battle_frame_ratio + 1) % @battle_frequency
			
		elsif !@battle_find
			if self.has_action?(1)
				@battle_find=true
				_circle = Circle.new(@current_attack_range.radius, (@battle_ennemy.map_x+0.5)*16,(@battle_ennemy.map_y+0.5)*16)
				moveToZone(_circle, true)
			elsif !self.active
				freeBattle
			end
		end
	end

	def update_skills
		@skills.each{|s|s.update(self)}
	end
	def update_script
		return if Global.texting
		instance_eval(&@script) if @script
	end
	def tryWait()# wait action (standing)
		return if self.block
		@move_frame_interval += 1
		if @move_frame_interval > Database::Config::EFrameInterval
			@sprite_frame = (@sprite_frame + 1) % 2
			@move_frame_interval = 0
		end
	end
	def set_battle_ennemy(e)
		@battle_ennemy = e
		@init_battle = true
		@battle_triggered = true
	end
	def	tryDetect()
		if @battle_wait == 0
			_do = Global.quadtree.getObjects(@current_detect_range.rect)
			if @battle_ennemy
				_nbe = _do.find{|o|o.rbobject.block&&@pathfinder.include?(o.rbobject.map_x,o.rbobject.map_y)} 			
				if _nbe
					@battle_find = true
					_circle = Circle.new(@current_attack_range.radius, (_nbe.rbobject.map_x+0.5)*16,(_nbe.rbobject.map_y+0.5)*16)
					moveToZone(_circle, true)
					
					@move_route.actions.insert(@move_route.current_index, MoveRoute::Data.new(2, [@battle_ennemy]))
					
					set_battle_ennemy(_nbe.rbobject)
				end
			end
			return if _do.empty?
			return if @battle_ennemy||(!self.active&&!@try_detect)
			@detect_objects = _do
			@detect_objects.select!{|o|o.rbobject.detectable?&&o!=@quadobject&&Global.current_map.rDetectableBy?(self.current_detect_range, o.rect)}
			
			
			unless @detect_objects.empty?
			
				if !@battle_ennemy && !@try_detect
					_d = @detect_objects.select{|o|o.rbobject.team_id!=@team_id}
					unless _d.empty?
						s = _d.map{|o|Gosu.distance(@current_detect_range.x,@current_detect_range.y,o.rect.center_x,o.rect.center_y)}
						@battle_ennemy = _d[s.index(s.min)].rbobject
						set_battle_ennemy(@battle_ennemy) #if @battle_ennemy
					end
				end
			end
			@try_detect = false
		else
			@battle_wait-=1
		end
	end	
	
	def tryMove(ps)
	
		if @roadblock && integer_coords?
			Global.scene.map.e_grid[map_x][map_y].delete(self)
		end
		
		@x = ps.x * Database::Config::TileSize
		@y = ps.y * Database::Config::TileSize
		
		if @roadblock && integer_coords?
			Global.scene.map.e_grid[map_x][map_y].push(self)
		end
		
		@base_volume_range.x    = @x
		@base_volume_range.y    = @y
		@current_volume_range.x = @x
		@current_volume_range.y = @y
		
		_cx, _cy = center_x, center_y
		@base_detect_range.x    = _cx
		@base_detect_range.y    = _cy
		@current_detect_range.x = _cx
		@current_detect_range.y = _cy
		
		@base_attack_range.x    = _cx
		@base_attack_range.y    = _cy
		@current_attack_range.x = _cx
		@current_attack_range.y = _cy
	
		return true
	end
	
	def moveTo(x, y, p=false)
		return if x==@x&&y==@y
		@movement = false
		@init_movement = true
		@move_route.reading = false
		unless p #programmed
			@move_route = MoveRoute.new(self)
			@move_route.actions.push(MoveRoute::Data.new(0,[x,y]))
			if @init_battle
				@battle_wait=30
				freeBattle
			end
		end
		
		sp, ep = Point.new(map_x.to_f, map_y.to_f), Point.new(Ratio.map_convx(x).to_f, Ratio.map_convy(y).to_f)
		@pathfinder.start(sp, ep)
	end
	def moveToZone(c,p=false)
		moveTo(c.x,c.y,p)
		@move_to_zone=[true,c]
	end
	def stopMove
		
		@movement = false
		@move_to_zone=[false,nil]
		if @init_battle
			@battle_triggered = true
			@battle_find=false
		else
			#@battle_wait=30
			if @move_route.reading
				@move_route.jump
				@move_route.update
			else
				@move_route.update
			end
		end
	end
	def freeBattle()
		@init_battle = false
		@battle_triggered = false
		@battle_ennemy = nil
	end
	def die
		if @quadobject
			@quadobject.delete
			@quadobject = nil
			@current_hp = 0
			@battle_dying = true
		end
		self.roadblock = false if @roadblock
	end
	def getDamage(type, power, owner)
		case type
		when 0 # Physical
			_damage = power - @current_def
		when 1 # Magical
			_damage = power - @current_res
		end
		if _damage > 0
			@current_hp -= _damage
			@battle_damage = _damage
		end
		self.die() if @current_hp <= 0
	end
	def self.getData(t_id,c_id)
		return Database::Entities::Classes[t_id][c_id]
	end
	__PROPERTIES__={'flag'=>0,'class_name'=>1,'mana_cost'=>10,'active'=>12,'block'=>13,'description'=>14}
	__PROPERTIES__.each { |key, value|
		class_eval('def self.'+key+'(ti,ci);return Entity.getData(ti,ci)['+value.to_s+'];end')
		class_eval('def '+key+';return Entity.'+key+'(@type_id,@class_id);end')
	}
	def detect_objects(*team_id)
		if team_id.empty?
			return @detect_objects
		else
			return @detect_objects.select{|o|team_id.include?(o.team_id)}
		end
	end
	def has_skill?(arg)
		@skills.include?(arg)
	end
	def detected?(e)
		return detect_objects().include?(e.quadobject)
	end
	def detectable_by?(e)
		return e.detect_objects().include?(@quadobject)
	end
	def isInRCZone?(x, y, w, h)
		return @current_volume_range.cCollision?(x,y,w,h)
	end
	def isInRZone?(r)
		return isInRCZone?(r.x,r.y,r.width,r.height)
	end
	def has_detection_skill?
		@skills.any?{|s|Database::Entities::DetectionSkills.include?(s.index)}
	end
	def has_action?(arg)
		return @actions.include?(arg)
	end
	def heal(power=@base_hp)
		@current_hp = Math.min(@base_hp, @current_hp+power)
		@battle_damage = -power if @current_hp != @base_hp
	end
	def increase_level
		@level += 1
	end
	def dead?
		return @current_hp <= 0
	end
	def detectable?
		return false if dead?
		return @detectable
	end
	def moving?
		return @movement
	end
	def show_rect(obj)
		@sprite_hovered.push(obj)
	end
	def hide_rect(obj)
		@sprite_hovered.delete(obj)
	end
	def roadblock=(v)
		@roadblock=v
		if integer_coords?
			if @roadblock 
				Global.scene.map.e_grid[map_x][map_y].push(self)
			else
				Global.scene.map.e_grid[map_x][map_y].delete(self)
			end
		end
	end
	def selected=(value)
		if value
			@current_volume_range.color = Global.teams[@team_id].color
			show_rect(@current_volume_range)
		else
			@current_volume_range.color = Rect::RectColor
			hide_rect(@current_volume_range)
		end
	end
	def show_summon_rect
		show_rect()
	end
	def set_summoning_time(t)
		@summonning_time = t
		@summoning = (t > 0)
	end
	def integer_map_x?
		return ((@x/16.to_f)%1).zero?
	end
	def integer_map_y?
		return ((@y/16.to_f)%1).zero?
	end
	def integer_coords?
		return (integer_map_x? && integer_map_y?)
	end
	def map_x()
		return Ratio.map_convx(@x)
	end
	def map_y()
		return Ratio.map_convy(@y)
	end
	def center_x();return @x+Database::Config::TileSize/2;end
	def center_y();return @y+Database::Config::TileSize/2;end
	def s_produce_mana(power)
		Global.teams[@team_id].mana += power
	end
	def s_heal_area(power)
		@try_detect = true
		_os = detect_objects()#(Global.player_team_id)
		#_os = Global.quadtree.getObjects(@current_attack_range.rect)
		#_os.select!{|o|o.rbobject.team_id==@team_id&&@current_attack_range.rCollision?(o.rect)&&o!=@quadobject}
		_os.each{ |o|
			next unless o.rbobject.team_id == @team_id
			o.rbobject.heal(power)
		}
	end
	class Projectile
		def initialize(_id, owner, sx, sy, ex, ey)
			@x, @y = sx, sy
			@frame = 0
			@owner = owner
			
			@power = owner.current_mag
			@angle = Gosu.angle(sx, sy, ex, ey)
			@p = Rect.new(@x,@y,1,1)
			@speed_x = Gosu.offset_x(@angle, Database::Entities::Projectiles[_id][2])
			@speed_y = Gosu.offset_y(@angle, Database::Entities::Projectiles[_id][2])
			@angle   = Database::Entities::Projectiles[_id][1] ? (@angle + 180.0)%360.0 : 0.0
			@limit = @speed_x != 0 ? ex : ey#2*ex-sx : 2*ey-sy
			
			@bitmap = Array.new(2){ |i|
			Cache.tileset(Cache::GamePath.tileset(Database::Tilesets::Projectiles+i.to_s))[Database::Entities::Projectiles[_id][3]]}
		end
		def update
			@frame = (@frame + 1) % 2
			@x += @speed_x
			@y += @speed_y
			if @speed_x != 0
				if ((@x <=> @limit) == @speed_x.sgn)
					return true
				end
			else
				if ((@y <=> @limit) == @speed_y.sgn)
					return true
				end
			end
			
			_objects = Global.quadtree.getXYObjects(@x,@y)
			_objects.reject!{|o|o==@owner.quadobject||o.rbobject.team_id==@owner.team_id||!o.rbobject.detectable?}
			_objects.delete(@owner.quadobject)
			_objects.each {|o|
				if o.rect.xyCollision?(@x, @y)
					o.rbobject.getDamage(1, @power, @owner)
					return true
				end
			}
			#return true if Global.scene.map.rect.out_of_bounds?(@x,@y)
			return
		end
		def draw
			@bitmap[@frame].draw_rot(@x,@y,300,@angle,0.5,0.5)
		end
	end
	class Skill
		attr_reader :index
		def initialize(index, args)
			@index = index
			@args = args
			set_countdown
		end
		def update(owner)
			if @countdown > 0
				@countdown-=1
			else
				set_countdown
				case @index
				when 0 # Produce mana
					owner.s_produce_mana(@args[1])
				when 1 # Healing Area
					owner.s_heal_area(@args[1])
				end
			end
		end
		def set_countdown
			case @index
			when 0 # Produce mana
				@countdown = @args[0]
			when 1 # Healing Area
				@countdown = @args[0]
			end
		end
	end
	class MoveRoute
		class Data
			attr_accessor :index, :args
			def initialize(index, args)
				@index = index
				@args = args
			end
		end
		attr_accessor :current_index, :actions, :reading
		def initialize(owner)
			@current_index = 0
			@actions = []
			@reading = false
			@owner = owner
		end
		def update
		
			unless @actions.empty?
				case @actions[@current_index].index
				when 0 # MoveXY
					@owner.moveTo(*@actions[@current_index].args, true)
				when 1 # MoveCircle
					@owner.moveToZone(*@actions[@current_index].args, true)
				when 2 # MoveMob
					@owner.set_battle_ennemy(*@actions[@current_index].args)
					@actions.delete_at(@current_index)
					@current_index = 0 if @current_index == @actions.size
				end
				@reading = true
			end
		end
		def jump
			@current_index = (@current_index + 1) % @actions.size
		end
		def unjump
			@current_index = @current_index == 0 ? @actions.size - 1 : @current_index - 1
		end
		def reset
			@current_index = 0
			@actions.clear
			@reading = false
		end
	end
	class Team
		attr_accessor :name,:color,:mana,:leaders,:blocks,:summonable_entities,:objects
		def initialize(name, color)
			@name = name
			@color = color
			@mana = 0
			@leaders = []
			@blocks  = []
			@summonable_entities = []
			@objects = []
		end
	end
end


