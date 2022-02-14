#==============================================================================
# ** Loader
#------------------------------------------------------------------------------
#  Debug purposes.
#  Generates maps and tilesets from module MapData.
#==============================================================================

uc {
# generates tilesets
b = Array.new(Database::Tilesets::Names.size){|i|
	ti = i#(i == Database::Tilesets::Names.size-1) ? 2 : i
	t = Serializable::Tileset.new(Database::Tilesets::Names[ti][0], Database::Tilesets::Names[ti][3],Database::Tilesets::Names[ti][4],Database::Tilesets::Names[ti][1])
	
	MapData::TPassages[ti].each_with_index {|dat, s|
		x = s%Database::Tilesets::Names[ti][3]
		y = (s-x)/Database::Tilesets::Names[ti][3]
		t.data[y][x] = [0,0,(dat==0)]#]
	}
	t
}

# generates maps
tiledids = Database::Tilesets::Names.map{|o|o[2]}
a = Array.new(MapData::MData.size) {|map_id|
	map_data = MapData::MData[map_id]
	w, h = *map_data[0]
	m = Serializable::Map.new( Rect.new(0, 0, w, h) )
	map_data[1].each_with_index { |table, z|
		table.size.times { |i|
		
			x = i%w
			y = (i-x)/w
			
			tileset_id = -1
			tiledids.each_with_index {|id,n|tileset_id = n if table[i]>=id}
			tile = tileset_id == -1 ? 0 : table[i]-tiledids[tileset_id]
			m.data[y][x][z] = [tileset_id,tile]
			
		}
	}
	m
}
saveGameData("Maps", a)
saveGameData("Tilesets", b)
}