module Pathfinding
	
	class Object
		def initialize(obj)
			@_obj  = obj
			@_rect = getRect
		end
		def type
			@_obj
		end
		def rect
			return @_rect
		end
		def getRect
			case @_obj
			when Entity
				return @_obj.current_volume_range
			else
				
			end
		end
	end
	
	class Pathfinder
		attr_reader :start_node, :end_node
		def initialize(obj)
			@_obj 	    = Pathfinding::Object.new(obj)  
			@_readIndex = 0
			@_thread    = nil
			@_path 		= []
			@start_node,@end_node = nil,nil
			@stop=false
		end
		
		def start(start_node, end_node)
			@_path.clear
			@_readIndex = 0
			@start_node = start_node
			@end_node = end_node
			
			return if !pointValid(end_node)
			_open     = PriorityQueue.new
			_visited  = {}
			_cost     = {}
			
			_open.push(start_node, 0)
			_visited[start_node] = nil # Came from
			_cost[start_node] = 0 # Cost so far
			
			_m = Mutex.new
			@_thread = Thread.new {
				_m.synchronize {
					while !_open.empty?
						_current = _open.get
						break if _current == end_node
						gridNeightbours(_current).each { |point|
							_new_cost = _cost[_current] + gCost(_current, point)
							if !_cost.has_key?(point) || _new_cost < _cost[point]	
								_cost[point] = _new_cost
								_priority = _new_cost + hCost(end_node, point)
								_open.push(point, _priority)
								_visited[point] = _current
							end				
						}
					end
					if !_open.empty? 
						@_path = reconstruct_path(_visited, start_node, end_node) # no priority queue ...
					end
				}
			}
		end
		
		def reconstruct_path(visited, start_node, end_node)
			_path = [end_node]
			_current = end_node
			while _current != start_node
				_current = visited[_current]
				_path.push(_current)
			end
			return _path.reverse
		end
		def fragmentate_path(frequency=2.0)
			if @_readIndex > 0
				@_path = @_path[0..(@_readIndex)]
			end
			(@_path.size-1).times {|i|
				@_path[i] = Array.new(frequency) { |d| 
					Point.new(@_path[i].x-(@_path[i].x-@_path[i+1].x)*(d/frequency), 
					@_path[i].y-(@_path[i].y-@_path[i+1].y)*(d/frequency))#(frequency*(frequency-d+1.0)))
				}
			}
			@_path.flatten!
			
		end
		def gCost(parent, child)
			case @_obj.type
			when Entity
				return Database::Config::TileSize-1#if map
			end
		end
		def hCost(future_child, parent)
			return Gosu.distance(future_child.x,future_child.y,parent.x,parent.y)#(future_child.x-parent.x).abs**2+(future_child.y-parent.y).abs**2#
		end
		def pointValid(point)
			return Global.current_map.passable?(point.x, point.y)
		end
		def include?(x,y)
			return @_path[@_readIndex..(@_path.size-1)].any?{|p|p.x==x&&p.y==y}
		end
		def gridNeightbours(point)
			case @_obj.type
			when Entity
				_grid = Global.current_map
				_egrid = Global.scene.map
				_neightbours = []
				-1.upto(1){|oy|
					-1.upto(1) { |ox|
						
						if (oy.abs ^ ox.abs) == 1
							x, y = point.x+ox, point.y+oy
							if _grid.passable?(x, y) && _egrid.passable?(x,y,@_obj.type.team_id)
								_neightbours.push(Point.new((point.x + ox).to_f, (point.y + oy).to_f))
							end
						end
					}
				}
				return _neightbours
			end
		end
		def reset_current_action
			@_readIndex=0
		end
		def current_action
			return @_path[@_readIndex]
		end
		def read_action
			@_readIndex = (@_readIndex + 1)
			if @_readIndex < @_path.size
				return true
			else
				@_readIndex = 0
				return false
			end
		end
		def reading?
			return @_readIndex > 0
		end
		def path
			return @_path
		end
		def stop
			@_thread.join
			@_thread = nil
		end
		def running?
			return @_thread ? true : false
		end
		def resolved?
			return !@_thread.alive?
		end
		def solved?
			return !@_path.empty?
		end
	end
end