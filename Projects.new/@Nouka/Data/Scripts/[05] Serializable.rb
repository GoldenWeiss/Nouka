#==============================================================================
# ** Serializable
#------------------------------------------------------------------------------
#   Serializable classes definition.
#------------------------------------------------------------------------------
# Within this module, data objects of the game are serialized in the marshal
# format to be reused later.
#==============================================================================

module Serializable
	class Map # Serializable Map
		attr_accessor :entities
		attr_accessor :data
		attr_accessor :rect
		def initialize(dimensions)
			@rect = dimensions
			# Array of Basic Entities (NPC, pannel, chest, etc...)
			@entities = []
			# Tiles Data 
			# [@height[@width[Layers[tileset_id, tile_id]]]
			@data = Array.new(@rect.height) { Array.new(@rect.width) { Array.new(Database::Maps::Layers) {[0, 0]}}}
			
		end
		
		def width;@rect.width;end;def height;@rect.height;end
		def get_tile_data(x, y, z)
			_d = @data[y][x][z]
			return Tileset::VoidTileData if _d[0] == -1
			_x = _d[1]%Global.tilesets[_d[0]].width
			_y = (_d[1]-_x)/Global.tilesets[_d[0]].width
			return Global.tilesets[_d[0]].data[_y][_x]
		end
		def passable?(x, y)
			return false if x >= @rect.width || x < 0
			return false if y >= @rect.height || y < 0
			Database::Maps::Layers.times do |z| 
				if !get_tile_data(x, y, z)[2]
					return false
				end
			end
			return true
		end
		def detectableBy?(ex, ey, px, py)
=begin
			_ts = Database::Config::TileSize.to_f
			_ex, _ey = px/_ts, py/_ts
			_sx, _sy = entity.current_detect_range.x/_ts, entity.current_detect_range.y/_ts
			_d = Math.max((_ex - _sx).abs.ceil.to_f, (_ey-_sy).abs.ceil.to_f)
			_d.to_i.times do |s|
				_t = s / _d
				_x, _y = Math.lerp(_sx, _ex, _t).floor, Math.lerp(_sy, _ey, _t).floor
				return false unless passable?(_x, _y)
			end
			return true
=end
			_mx, _my = (ex/Database::Config::TileSize).to_i,(ey/Database::Config::TileSize).to_i
			_w, _h = px - ex, py - ey
			_slope = _w.zero? ? 0 : _h / _w.to_f#_w.zero? ? 1 : _h / _w.to_f
			_limit = ((_w-(Database::Config::TileSize/2)*_w.sgn)/Database::Config::TileSize).absceil
			_limit = 0 if _limit.abs == 1
			_break = false
			_fix = (_w.sgn - 1) / 2
			0.step(_limit,_w.zero? ? 1 : _w.sgn) do |x|
				s_y =  (_slope * x).to_i
				e_y = x.abs >= _limit.abs ? (((_h-(Database::Config::TileSize/2)*_h.sgn)/Database::Config::TileSize).absceil.to_i) : (_slope.abs == 1 ? s_y : ((_slope * (x + _w.sgn)).to_i))
				(s_y).step(e_y, _h.zero? ? 1 : _h.sgn) do |y|
					_x = x + _mx
					_y = y + _my
					unless passable?(_x, _y)
						_break = true
						break
					end
					if _w.abs == _h.abs
						if !passable?(_x-_w.sgn,_y) && !passable?(_x, _y-_h.sgn)
							_break = true
							break
						end
					end
#Gosu.draw_quad(x*16+_w.abs, y*16+_h.abs, Gosu::Color::YELLOW, (x+_w.sgn)*16+_w.abs, (y)*16+_h.abs, Gosu::Color::RED, (x)*16+_w.abs, (y+_h.sgn)*16+_h.abs, Gosu::Color::RED,(x+_w.sgn)*16+_w.abs, (y+_h.sgn)*16+_h.abs, Gosu::Color::RED,300)
				end
				break if _break
			end
			return !_break
		end
		
		def xyDetectableBy?(c, px, py)
			return false if !c.xyCollision?(px, py)
			
			return detectableBy?(c.x, c.y, px, py)
		end
		def rDetectableBy?(c, rect)
			return false if !c.rCollision?(rect)
			return detectableBy?(c.x, c.y, rect.center_x, rect.center_y)
		end
		def findTileInRadius(radius, sx, sy, center_x, center_y)
			
			_angle = Gosu.angle(sx, sy, center_x, center_y)
			_x = center_x - (Gosu.offset_x(_angle, radius)/16).to_i*16
			_y = center_y - (Gosu.offset_y(_angle, radius)/16).to_i*16
			unless (detectableBy?(_x, _y, center_x, center_y))
				_xl,_xr = _x,_x
				loop do
					
					_lreverse = _xl-16 < center_x-radius
					_xl = _lreverse ? _xl + 16 : _xl - 16
					_rreverse = _xr+16 > center_x+radius
					_xr = _rreverse ? _xr - 16 : _xr + 16
					
					
					_yl = center_y + (Math.sqrt(radius**2-(_xl-center_x)**2)/16).ceil * (((sy > center_y) ^ _lreverse) ? 16 : -16)
					_yr = center_y + (Math.sqrt(radius**2-(_xr-center_x)**2)/16).ceil * (((sy > center_y) ^ _rreverse) ? 16 : -16)
					cash([sx/16,sy/16].to_s)
					#cash([_xr,_yr].to_s)
					return [_xl,_yl] if detectableBy?(_xl, _yl, center_x, center_y)
					return [_xr,_yr] if detectableBy?(_xr, _yr, center_x, center_y)
				end
			else
				return [_x,_y]
			end
		end
		
		# Frame Update
=begin
		def update
			@data.each { |h|
				h.each { |w|
					w.each { |z|
						if $dataTilesets[z[0]].frames > 1
							z[2] = z[2] + 1 % 2
						end
					}
				}
			}
		end
=end
	end
	
	class Tileset
		attr_accessor :filename
		attr_accessor :data
		attr_accessor :width
		attr_accessor :height
		attr_reader   :frames
		VoidTileData = [ 0, 0, true]
		def initialize(f="", w = 0, h = 0, setsize = 1)
			@frames = setsize
			@width, @height = w, h
			# [Terrain Tag, ???, Passable]
			@data = Array.new(h) { Array.new(w) { [0, 0, true]}}
			init(f)
		end
		def marshal_dump
			[@frames, File.basename(@filename[0],".*").chomp("0"), @width, @height, @data]
		end
		def marshal_load(ary)
			@frames, @filename, @width, @height, @data = ary
			init(@filename)
		end
		def init(f)
			
			@filename = @frames > 1 ? (Array.new(@frames) {|i| Cache::GamePath.tileset(f + i.to_s)}) : [Cache::GamePath.tileset(f)]
			@filename.each {|i| Cache.tileset(i) }
		end
	end
end