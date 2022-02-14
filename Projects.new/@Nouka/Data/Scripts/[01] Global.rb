#==============================================================================
# ** Global
#------------------------------------------------------------------------------
#  Global variables container.
#==============================================================================

module Global
	
	class << self
		#----------------------------------------------------------------------
		#  Public Instances variables
		#----------------------------------------------------------------------
		attr_accessor :game,
					  :scene,
					  :test,
					  :camera,
					  :state,
					  
					  # Teams related
					  :player_team_id,
					  :teams,
					  
					  # Serializable objects
					  :maps,
					  :tilesets,
					  
					  # Map related
					  :texting,
					  :can_pause,
					  :can_select,
					  :can_scroll,
					  :can_zoom,
					  :can_act,#use entitites actions?
					  :show_entities_rect,
					  :show_teams_rect,
					  :current_level,
					  :selected_windows,
					  :current_action,
					  :quadtree,
					  :entities
					  
		#----------------------------------------------------------------------
		#  Game Initialization
		#----------------------------------------------------------------------
		def init
			# Variables Initialization
			@scene  = nil

			@test   = $TEST ? true : false
			@camera = Camera.new(Rect.new, 1.0)
			
			@state = 0
			
			@teams = Array.new(Database::Entities::Teams.size){|i|
			Entity::Team.new(*Database::Entities::Teams[i])}
			
			@player_team_id = 0
			
			# Data loading
			@maps = loadGameData("Maps")
			@tilesets = loadGameData("Tilesets")
			#@save = loadGameData("Save")
			
			# Maps Related
			@texting = false
			@can_pause = true
			@can_select = true
			@can_scroll = true
			@can_zoom = true
			@can_act = true
			@current_level = -1
			@selected_windows = false
			@current_action = [-1,[nil]] # Actions, parameters
			@quadtree = nil
			@show_entities_rect = false
			@show_team_rect = false
			
			$mouse = Input.mouse
			$keyboard = Input.keyboard
			
			# Start Game
			@game = Game.new
			@game.show
		end
		def current_map
			return Global.maps[Database::Levels[Global.current_level][0][0]]
		end
		def reset_current_action
			@current_action[0] = -1
			@current_action[1] = [nil]
		end
	end
end