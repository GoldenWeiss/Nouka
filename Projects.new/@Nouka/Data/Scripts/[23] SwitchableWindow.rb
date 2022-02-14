class SwitchableWindow
	__CURRENT__ = 
	[
	:visible?,
	:set_contents_color
	]
	__ABSOLUTE__ = 
	[
		:windowskin_visible=,
		:contents_visible=,
		:set_contents_color,
		:set_windowskin_color
	]
	def initialize
		@_windows  = CachableQueue.new
		@_current  = 0
	end
	def size; @_windows.size; end
	def update; return if @_windows.empty?; current_window.update; end;
	def draw; return if @_windows.empty?; current_window.draw; end;
	def hide_window(index); @_windows.cache(index); end
	def show_window(index); @_windows.uncache(index); end
	def cached?(index);@_windows.cached?(index);end
	def add_window(wnd); @_windows.push(wnd);end
	def [](index); @_windows[index]; end
	__CURRENT__.each do |s|
		class_eval("def #{s}(*args);return if @_windows.empty?;current_window.#{s} *args;end")
	end
	__ABSOLUTE__.each do |s|
		class_eval("def #{s}(*args);return if @_windows.empty?;@_windows.each{|w|w.#{s} *args};end")
	end
	def x; return 0 if @_windows.empty?; current_window.x; end
	def y; return 0 if @_windows.empty?; current_window.y; end
	def x=(arg); return if @_windows.empty?; @_windows.each{|w|w.x = arg}; end
	def y=(arg); return if @_windows.empty?; @_windows.each{|w|w.y = arg}; end
	def rect; return current_window.rect; end
	def current_index; return @_current; end
	def current_window; return @_windows[@_current]; end
	def update_current_window(index=@_windows.size-1)
		@_current = index
	end
	def each(&block)
		@_windows.each(&block)
	end
	def each_absolute(&block);
		@_windows.each_absolute(&block)
	end
end