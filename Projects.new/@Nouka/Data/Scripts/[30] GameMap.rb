module N
	
	class Map
		attr_accessor :rect
		attr_accessor :e_grid
		def initialize(map)
			@map = map
			@rect = Rect.new(0, 0, 
			@map.width * Database::Config::TileSize,
			@map.height * Database::Config::TileSize)
			create_map_cache
			@move_frame_ratio = 0
			
			Global.camera = @camera = Camera.new(Rect.new(0,0,Database::Config::DefaultWidth,Database::Config::DefaultHeight), Database::Config::ZoomFactor)
			@e_quadtree = Global.quadtree = Quadtree::Node.new(1, @rect)
			# Entities
			@e_data = Global.entities = []
			@e_sprites = []
			@e_selected, @e_selected_new = [], false
			@e_grid = Array.new(@map.width) {Array.new(@map.height){[]}}
			@map.entities.each {|e| addEntity(e)}
			
			@p_data = []
		end
		def passable?(x,y,tid)
			return !@e_grid[x][y].any?{|e|e.team_id!=tid}
		end
		def entities;@e_data;end
		def selectedEntities;@e_selected;end
		def selectedEntities?;!@e_selected.empty?;end
		def create_map_cache
			@map_frame_interval = 0
			@framecache = 0
			@mapcache = Array.new(2) {|f| 
				Array.new(Database::Maps::Layers) {|z| 
					Gosu.record(@map.width, @map.height)  {
						@map.height.times {|y| 
							@map.width.times {|x|
								drawTile(x, y, z, @map.data[y][x][z], f)
							}
						}
					}
				}
			}
		end
		def update
			
			@e_quadtree.clear
			@e_data.each{|e|Global.quadtree.insert(e.quadobject) if e.quadobject}
			@p_data.delete_if{|p|p.update;}
			@e_data.each{|e|e.update}
			@map_frame_interval += 1
			if @map_frame_interval > Database::Config::MFrameInterval
				@framecache = (@framecache + 1) % 2
				@map_frame_interval = 0
			end
			
		end
		def quadtree;return @e_quadtree;end
		def addEntity(entity)
			registerEntity(entity)
			entity.quadobject = Quadtree::Object.new([@e_quadtree], entity.current_volume_range, entity)
									
			@e_quadtree.insert(entity.quadobject)
			
		end
		def registerEntity(entity)
			entity._id = @e_data.size if entity._id < 0
			entity.generate()
			@e_data[entity._id] = entity
			@e_sprites[entity._id] = SpriteEntity.new(entity)
		end
		def delEntity(entity)
			@e_data.delete(entity)
			@e_data[entity._id..-1].each{|e|e._id-=1}
			@e_sprites.delete_at(entity._id)
		end
		def updateSelectedEntities
			_rc = Input.mouse.getDragRect
			_objects = @e_quadtree.getObjects(_rc)
			_entities = []
			_objects.each { |o| _entities.push(o.rbobject) if o.rect.rCollision?(_rc)}
			
			@e_selected_new = false
			if @e_selected != _entities
				@e_selected_new = true
				@e_selected.each {|e| e.selected = false if e }
				_entities.each {|e| e.selected = true}
				@e_selected = _entities
			end
		end
		def newSelectedEntities?; return @e_selected_new; end;
		def clearSelectedEntities
			if !@e_selected.empty?
				@e_selected.each {|o| o.selected = false}
				@e_selected.clear
			end
		end
		def setSelectedEntities(entities)
			if @e_selected != entities
				@e_selected.each {|o| o.selected = false}
				entities.each {|e| e.selected = true}
				@e_selected = entities
			end
		end
		def addProjectile(p);@p_data.push(p);end
		def draw
			@camera.draw {
				@e_quadtree.draw if Global.test
				@mapcache[@framecache].each_with_index{|c, z|c.draw(0,0,z)}
				@e_sprites.each{|e|e.draw}
				@p_data.each{|p|p.draw}
				Input.mouse.draw
			}
		end
	
		def drawTile(x, y, z, d, f)
			if d[0] != -1
				_x = x * Database::Config::TileSize
				_y = y * Database::Config::TileSize
				_frame = (Global.tilesets[d[0]].frames < f+1) ? 0 : f
				_tile = Cache.tileset(Global.tilesets[d[0]].filename[_frame])[d[1]]
				_tile.draw(_x, _y, z)
			end
		end
		
	end
end