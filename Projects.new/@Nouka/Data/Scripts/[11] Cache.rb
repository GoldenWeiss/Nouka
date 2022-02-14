

module Cache
	Data = Hash.new
	module GamePath
		BmpExtension = ".png"
		DataExtension = ".mif"
		FontExtension = ".ttf"
		Relative = Dir.pwd + "/Data/"
		def self.pathname(path, filename)
			return (Relative + path + filename)
		end
		def self.character(filename)
			return pathname("Graphics/Characters/", filename + BmpExtension)
		end
		def self.tileset(filename)
			return pathname("Graphics/Tilesets/", filename + BmpExtension)
		end
		def self.misc(filename)
			return pathname("Graphics/Miscs/", filename + BmpExtension)
		end
		def self.icon(filename)
			return pathname("Graphics/Icons/", filename + BmpExtension)
		end
		def self.game_data(filename)
			return pathname("GameData/", filename + DataExtension)
		end
		def self.windowskin(filename)
			return pathname("Graphics/Windowskins/", filename + BmpExtension)
		end
		def self.font(filename)
			return pathname("Fonts/", filename + FontExtension)
		end
	end
	def self.tileset(x)
		#x = GamePath.tileset(name) 
		#FAST LOAD
		if Data[x] == nil
			Data[x] = Gosu::Image.load_tiles(x, Database::Config::TileSize, Database::Config::TileSize, retro: true)
		end
		return Data[x]
	end
	def self.character(name) 
		x = GamePath.character(name)
		if Data[x] == nil
			Data[x] = Gosu::Image.load_tiles(x, Database::Config::TileSize, Database::Config::TileSize, retro: true)
		end
		return Data[x]
	end
	def self.windowskin(name)
		x = GamePath.windowskin(name)
		if Data[x] == nil
			Data[x] = Gosu::Image.new(x, retro: true)
		end
	end
	def self.font(name, h)
		x = GamePath.font(name)
		_ary = [x, h]
		if Data[_ary] == nil
			Data[_ary] = Gosu::Font.new(h, name: x)
		end
		return Data[_ary]
	end
	def self.icon(name)
		x = GamePath.icon(name)
		if Data[x] == nil
			Data[x] = Gosu::Image.new(x, retro: true)
		end
		return Data[x]
	end
	def self.misc(name)
		x = GamePath.misc(name)
		if Data[x] == nil
			Data[x] = Gosu::Image.new(x, retro: true)
		end
		return Data[x]
	end
end

