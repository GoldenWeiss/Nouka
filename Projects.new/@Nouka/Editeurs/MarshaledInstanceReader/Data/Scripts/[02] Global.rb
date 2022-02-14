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
		attr_accessor 	:current_filename
		#----------------------------------------------------------------------
		#  Object Initialization
		#----------------------------------------------------------------------
		def init
			@current_filename = "" 
		end
	end
end