#==============================================================================
# ** Game
#------------------------------------------------------------------------------
#  Manage Main Game Window
#==============================================================================

class Game < Gosu::Window
	include Database
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		# Create window object
		super Database::Config::DefaultWidth,
			  Database::Config::DefaultHeight,
			  false, Database::Config::UpdateInterval
		self.caption = Database::Config::DefaultTitle
		
		Global.current_level = 0
		@mouse = Input.mouse
		set_scene(Database::Config::DefaultScene)
		
	end
	
	def needs_cursor?; return true; end
	
	def update
		# Update title
		if Global.test
			self.caption = Database::Config::DefaultTitle + " - " + Gosu.fps.to_s + " FPS "
		end
		@scene.update
	end
	
	def draw
		@scene.draw
	end
	
	def button_down(id)
		case id
			when Gosu::MsLeft
				@mouse.trigger
			when Gosu::MsRight
				
			when Gosu::KbUp,Gosu::KbDown,Gosu::KbLeft,Gosu::KbRight
				Input.keyboard.trigger(id)
			when Gosu::KbA
				Input.keyboard.trigger(Gosu::KbLeft)
			when Gosu::KbS
				Input.keyboard.trigger(Gosu::KbDown)
			when Gosu::KbW
				Input.keyboard.trigger(Gosu::KbUp)
			when Gosu::KbD
				Input.keyboard.trigger(Gosu::KbRight)
			when Gosu::KbF12
				set_scene(Database::Config::DefaultScene)
			else
				super
		end
	end
	
	def button_up(id)
		case id
			when Gosu::MsWheelDown
				@mouse.wheelDown
			when Gosu::MsWheelUp
				@mouse.wheelUp
			when Gosu::MsLeft
				@mouse.release
			when Gosu::MsRight 
				#@mouse.release
				@scene.clearSelectedEntities if Global.state==States[:play]&&@scene.is_a?(SceneMap)&&Global.can_select #Didn't implemented right click
			when Gosu::KbF2
				if $TEST
					Global.test = !Global.test
					if Global.test
						#Global.show_entities_rect = true
						self.caption = Database::Config::DefaultTitle + " - " + Gosu.fps.to_s + " FPS "
					else
						#Global.show_entities_rect = false
						self.caption = Database::Config::DefaultTitle
					end	
				end
			when Gosu::KbR
				Global.show_entities_rect = !Global.show_entities_rect
			when Gosu::KbT
				Global.show_teams_rect = !Global.show_teams_rect
			when Gosu::KbSpace
				@scene.get_window(:msg).next_text
			when Gosu::KbEscape
				@scene.pause
			when Gosu::KbUp,Gosu::KbDown,Gosu::KbLeft,Gosu::KbRight
				Input.keyboard.release(id)
			when Gosu::KbA
				Input.keyboard.release(Gosu::KbLeft)
			when Gosu::KbS
				Input.keyboard.release(Gosu::KbDown)
			when Gosu::KbW
				Input.keyboard.release(Gosu::KbUp)
			when Gosu::KbD
				Input.keyboard.release(Gosu::KbRight)
		end
	end
	def set_scene(scene)
		if scene == nil
			exit
		end
		Global.scene = @scene = Kernel.const_get(scene).allocate
		@scene.init
	end
end