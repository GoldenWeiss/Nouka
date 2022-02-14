#==============================================================================
# ** Ratio
#------------------------------------------------------------------------------
#  Stretches dimensions methods.
#=============================================================================

module Ratio
	def self.map_convx(x);(x/Database::Config::TileSize).to_i;end
	def self.map_convy(y);(y/Database::Config::TileSize).to_i;end
	def self.screen_convx(x);x/Global.camera.zoom;end
	def self.screen_convy(y);y/Global.camera.zoom;end
end