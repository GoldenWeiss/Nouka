module SubMethods
	include Database::Window
	def update
		if @windowskin_visible || @contents_visible
			@data.each { |i| i.update }
		end
		super
	end
	def draw
		super
		if @windowskin_visible || @contents_visible
			@data.each { |i| i.draw }
		end		
	end
	def add_button(x, y, width, height)
		_button = Button.new(self, x, y, width, height)
		_index = @data.size
		@data[_index] = _button
		return _index
	end
	def get_button(i); return @data[i]; end
	def remove_button(i);@data.delete_at(i);end
	def add_change_button(x, y, w, h, ts, om, oa, um, ua, f, cm, ca)
	
		b_center = get_button(add_button(x, y, w, h))
		b_center.set_windowskin(DefaultWindowskin)
		b_center.set_release_event(:return_to_blank, [b_center])
		b_center.set_over_event(om, [b_center, *oa], um, [b_center, *ua])
		b_center.color_windowskin_on_over = false
		
		b_left = get_button(add_button( x + w/2 - (f + ts), y + h/2 - ts/2 , ts, ts))
		b_left.set_centered_text(20, 0, "<")
		b_left.set_release_event(cm, [b_left, *ca, -1])
		b_left.color_contents_on_over = true
		
		b_right = get_button(add_button(x + w/2 + f, y + h/2 - ts/2, ts, ts))
		b_right.set_centered_text(20, 0, ">")
		b_right.set_release_event(cm, [b_right, *ca, 1])
		b_right.color_contents_on_over = true
		
		return [b_center, b_left, b_right]
	end
	def add_window(wnd)
		@data.push(wnd)
		return wnd
	end
	def set_dimensions(*args)
		@data.each { |i|
			i.x = args[0] + i.x - @rect.x
			i.y = args[1] + i.y - @rect.y
		}
		super(*args)
	end
	def z=(arg)
		@data.each { |i| i.z = arg }
		super(arg)
	end
	def x=(arg)
		@data.each { |i| i.x = arg + i.x - @rect.x }
		super(arg)
	end
	def y=(arg)
		@data.each { |i| i.y = arg + i.y - @rect.y }
		super(arg)
	end
	
	def return_to_blank(b)
		b.new_state(Button::States[:blank])
	end

	def set_windowskin_color(a, r, g, b)
		super
		@data.each { |i| i.set_windowskin_color(a, r, g, b)}
	end
	def set_contents_color(a, r, g, b)
		super
		@data.each { |i| i.set_contents_color(a, r, g, b) }
	end
end

class MultiWindow < TransitionWindow
	include SubMethods
	def initialize
		@data = []
		super
	end
end
class ButtonMultiWindow < Button
	include SubMethods
	def initialize(window, x, y, width, height)
		@data = []
		
		super
	end
end