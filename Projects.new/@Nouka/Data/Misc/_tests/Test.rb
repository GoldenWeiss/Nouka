class Array
	def swap(a, b)
		self[a], self[b] = self[b], self[a]
	end
end
def cafe(args=nil)
	if args
		p args
	else
		p "Time for a Coffee Break ! <,-,>"
	end
	system 'pause > nul'
end
class Point;def set(x,y);@x=x;@y=y;end;alias initialize set;end;
class Rect;def set(p1,p2);@p1=p1;@p2=p2;end;alias initialize set;
def x;@p1.x;end;def y;@p1.y;end;def w;(p1.x-p2.x).abs;end;def h;(p1.y-p2.y).abs;end;
attr_reader :p1,:p2;end;

class PriorityQuadtree
	class LinkedObject
		def initialize(index, point)
			@index = index
			@point = point
		end
	end
	def initialize(max_level,max_objects) # array of 4^level+1 size
		@data = [[max_level, max_objects], []]
	end
	
	def insert(obj, x=1) # prepare yourself to be amazed =p
		_x = x
		if splitted?(_x) #splitted
			
		else
			addObject(_x, obj)
			if full?(_x)
				createChilds(_x)
				
			end
		end
	end
	def addObject(_x, obj)
		@data[_x]<<(obj)
	end
	def createChilds(_x)
		x = _x*4
		x.upto(x+3) {|i| @data[i] = []}
	end
	def full?(_x)
		@data[_x].size>@data[0][1]
	end
	def splitted?(x)
		@data[_x*4]
	end
end


cafe("zeroday".chomp("1"))#- "1")
