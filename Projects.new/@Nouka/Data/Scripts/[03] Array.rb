#==============================================================================
# ** Array
#------------------------------------------------------------------------------

class Array
	def swap(a, b)
		self[a], self[b] = self[b], self[a]
	end
end
#------------------------------------------------------------------------------
# ** PriorityQueue
#------------------------------------------------------------------------------
#  	Classes an Array's elements in order.
#------------------------------------------------------------------------------
# Max-heap priority Queue
# q.pop  => retrieve and delete biggest element
# q.get  => retrieve and delete smallest element
#------------------------------------------------------------------------------

class PriorityQueue
	attr_reader :data
	def initialize
		@data = [nil]
	end
	def heapify_up(index)
		unless index <= 1	
			_parent = index/2
			if @data[_parent][0] < @data[index][0]
				@data.swap(_parent, index)
				if @data[_parent*2][0] < @data[index][0]
					@data.swap(_parent*2, index)
				end
				heapify_up(_parent)
			end
		end
	end
	def heapify_down(index)
		_child = index * 2
		return if _child > @data.size-1
		_child += 1 if _child < @data.size-1 && @data[_child+1][0] > @data[_child][0]
		if @data[_child][0] > @data[index][0]
			@data.swap(index, _child)
			heapify_down(_child)
		end
	end
	def <<(obj,priority)
		@data<<[priority,obj]
		heapify_up(@data.size-1)
	end
	alias :push :<<
	def pop 
		@data.swap(1, @data.size-1)
		_obj = @data.pop
		heapify_down(1)
		return _obj[1]
	end
	def get
		return @data.pop[1]
	end
	def clear
		@data.clear
	end
	def empty?
		return @data.size < 2
	end
	def size
		return @data.size-1
	end
end

class CachableQueue
	include Enumerable
	
	def clear
		@data = []
		@size = 0
	end
	alias initialize clear

	def <<(obj)
		@data.push([@size, true, obj]) #[realIndex, visible?, object]
		@size += 1
	end
	alias :push :<<
	
	def cache(index)
		_i = @data.find {|o| o[0] == index}	
		_i[1] = false
		return _i[2]
	end
	def uncache(index)
		_i = @data.find {|o| o[0] == index}	
		_i[1] = true
		return _i[2]
	end
	def each(&block) 
		@data.each{|v| block.call(v[2]) if v[1]}#map{|ary| ary[2] if ary[1]}.compact.each(&block)
	end
	def size
		@data.size
	end
	def empty?
		@data.empty?
	end
	def [](index)
		@data.find {|o| o[0] == index}[2]
	end
	
	def cached?(index)
		return !(@data.find {|o| o[0] == index}[1])
	end
end
