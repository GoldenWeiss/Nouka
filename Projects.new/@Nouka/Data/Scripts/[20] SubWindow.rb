class SubWindow
	def initialize(window); @_window = window;end
	def set_windowskin_color(a, r, g, b)
		_c = @_window.windowskin_color
		_a, _r, _g, _b = a * _c.alpha / 255, r * _c.red / 255, g * _c.green / 255, b * _c.blue / 255
		super(_a, _r, _g, _b)
	end
	def set_contents_color(a, r, g, b)
		_c = @_window.contents_color
		_a, _r, _g, _b = a * _c.alpha / 255, r * _c.red / 255, g * _c.green / 255, b * _c.blue / 255
		super(_a, _r, _g, _b)
	end
end
