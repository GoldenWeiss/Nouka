module Gosu
	class Color
		def self.merge(c1, c2)
			_alpha = c1.alpha * c2.alpha / 255
			_red   = c1.red   * c2.red   / 255
			_green = c1.green * c2.green / 255
			_blue  = c1.blue  * c2.blue  / 255
			return self.new(_alpha, _red, _green, _blue)
		end
		def merge(c)
			return Color.merge(self, c)
		end
		def to_a
			return [self.alpha, self.red, self.green, self.blue]
		end
		def unmerge(rc)
			_alpha = self.alpha / rc.alpha.to_f * 255
			_red   = self.red / rc.red.to_f * 255
			_green = self.green / rc.green.to_f * 255
			_blue  = self.blue / rc.blue.to_f * 255
			return Gosu::Color.new(_alpha, _red, _green, _blue)
		end
		def set_alpha(c,x)
			return Gosu::Color.new(c, x.red, x.green, x.blue)
		end
		def set_red(c,x)
			return Gosu::Color.new(x.alpha, c, x.green, x.blue)
		end
		def set_green(c,x)
			return Gosu::Color.new(x.alpha, x.red, c, x.blue)
		end
		def set_blue(c,x)
			return Gosu::Color.new(x.alpha, x.red, x.green, c)
		end
	end
	class Image # credits to gosu-rgss
		def draw_tiled(x, y, w, h, z, zx=1, zy=1, c=Gosu::Color::WHITE)
			_mw, _mh = x + w, y + h
			_ix, _iy = self.width * zx, self.height * zy
			_x = x
			Gosu.clip_to(x, y, w, h) {
				while _x < _mw
					_y = y
					while _y < _mh
						draw(_x, _y, z, zx, zy, c)
						_y += _iy
					end
					_x += _ix
				end
			}
		end
	end
end