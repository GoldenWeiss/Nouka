class Camera
	attr_accessor :rect, :zoom
	def initialize(rect, zoom=1)
		@rect = rect
		@zoom = zoom
	end#Database::Config::ZoomFactor, Database::Config::ZoomFactor
	def draw
		Gosu.translate(@rect.x, @rect.y){Gosu.scale(@zoom){yield}}
	end
end