#==============================================================================
# ** Quadtree
#------------------------------------------------------------------------------
#   Used for collision detection.
#------------------------------------------------------------------------------
# There is the class 'Object' which represents the rect of a ruby
# object in a node, and Node who represent a zone in space.
# Main code is defined in class 'Node'.
#==============================================================================

class Quadtree
	
	MaxObjects = 5
	MaxLevels  = 6
	class Object
		attr_accessor :rect, :nodes, :rbobject
		def initialize(nodes, rect, rbobject)
			@nodes = nodes
			@rect = rect
			@rbobject = rbobject
		end
		def delete
			@nodes.each{|n|n.getAllObjects.delete(self)}
			_parents = @nodes.collect {|n|n.parent}
			_parents.uniq!
			_parents.each{|p|p.reform}
		end
	end
	
	class Node
		attr_accessor :rect
		attr_accessor :parent
		
		# NorthWest [0]; NorthEast [1]; SouthEast [2]; SouthWest [3]
		def initialize(level=0, parent=nil, rect)
			@level = level
			@rect  = rect
			@nodes   = []
			@objects = []
			@splitted = false
			@parent = parent ? parent : self
		end
		def split
			_x, _y = @rect.x, @rect.y
			_mw, _mh = @rect.width/2, @rect.height/2
			if @nodes.empty?
				@nodes[0] = Node.new(@level+1, self, Rect.new(_x, _y, _mw, _mh))
				@nodes[1] = Node.new(@level+1, self, Rect.new(_x + _mw, _y, _mw, _mh))
				@nodes[2] = Node.new(@level+1, self, Rect.new(_x + _mw, _y + _mh, _mw, _mh))
				@nodes[3] = Node.new(@level+1, self, Rect.new(_x, _y + _mh, _mw, _mh))
			end
			@splitted = true
		end

		def splitted?
			return !@nodes.empty?
		end
		def getChildNodeIndex(objrc)
			_index = []
			_mw, _mh = @rect.center_x, @rect.center_y
			_west  = objrc.x < _mw
			_east  = objrc.x > _mw || objrc.x + objrc.width > _mw
			if objrc.y < _mh
				_index.push(0) if _west
				_index.push(1) if _east
			end
			if objrc.y > _mh || objrc.y + objrc.height > _mh
				_index.push(2) if _east
				_index.push(3) if _west
			end
			return _index
		end
		def getXYChildNodeIndex(x,y)
			return y < @rect.center_y ? (x < @rect.center_x ? 0 : 1) : (x < @rect.center_x ? 3 : 2)
		end
		def giveNode(obj)
			_index = getChildNodeIndex(obj.rect)
			obj.nodes.clear
			_index.each {|i|
				obj.nodes.push(@nodes[i])
				@nodes[i].insert(obj)
			}
		end
		def insert(obj)
			if splitted?
				giveNode(obj)
			else
				obj.nodes.push(self)
				@objects.push(obj)
				if @objects.size > MaxObjects && @level < MaxLevels
					split()
					@objects.size.times { giveNode(@objects.shift) } 
				end
			end
		end
		def getObjects(objrc)
			if splitted?
				_objects = *getChildNodeIndex(objrc).collect{|i|@nodes[i].getObjects(objrc)}#each{|i|_objects.push(*@nodes[i].getObjects(objrc))}
				_objects.flatten!
				_objects.uniq!
				return _objects
			else
				return @objects.clone
			end
		end
		def getXYObjects(x,y)
			if splitted?
				_objects = [*@nodes[getXYChildNodeIndex(x,y)].getXYObjects(x,y)]
				_objects.uniq!
				return _objects
			else
				return @objects.clone
			end
		end
		def getAllObjects
			return @objects
		end
		def reform
			_objects = @nodes.collect{|n|n.getAllObjects}
			_objects.flatten!
			_objects.uniq!
			if _objects.size <= MaxObjects
				clear()
				_objects.each{|o|o.nodes.push(self)}
			end
		end
		def clear
			@objects.each{|o|o.nodes.clear}
			@objects.clear
			if splitted?
				@nodes.each {|n| n.clear}
				@nodes.clear
				@splitted = false
			end
		end
		def draw # Debug Purpose
			@rect.draw
			@nodes.each {|n| n.draw}
		end
	end
end


