class WindowMessage < ButtonMultiWindow

	def initialize
		super(self, MsgX, MsgY, MsgWidth, 100)
		@_dprocs = []
		@_dtext  = []
		@_dindex = 0
		@_locked = false
		@_lock_condition = nil
		self.color_contents_on_over = false
		self.color_windowskin_on_over = false
		
		self.windowskin_visible = true
		self.set_windowskin(DefaultWindowskin, nil)
		self.set_type(MsgType)
		self.set_release_event(:next_text, [])
		self.set_windowskin_color(0, 255, 255, 255)
		self.set_text_size(MsgWidth-12)
		self.z = 3000
	end
	def update
		super
		if @_locked
			unlock if @_lock_condition.call
		end
	end
	def open
		self.windowskin_visible = true
		self.color_windowskin_to(FullColor, 4)
		self.color_contents_to(FullColor, 4)
		self.scale_to(MsgWidth, MsgHeight, 4)
		old_set_text(24, 12, 12, @_dtext[@_dindex])
	end
	def close
		self.color_windowskin_to(BlankColor, 4)
		self.color_contents_to(BlankColor, 4)
		self.scale_to(MsgWidth, 0, 4)
	end
	alias old_set_text set_text
	def set_text(*t)
		@_dtext = t
		@_dindex = 0
		@_dprocs = []
		old_set_text(24, 12, 12, @_dtext[0])
	end
	def next_text
		return_to_blank(self)
		return if @_locked
		unless @_dprocs.empty?
			@_dprocs[@_dindex].call if @_dprocs[@_dindex]
		end
		@_dindex += 1
		if @_dindex >= @_dtext.size
			Global.texting = false
			@_dtext = []
			@_dindex = 0
			@_dprocs = []
			close
		else
			old_set_text(24, 12, 12, @_dtext[@_dindex])
		end
	end
	def lock(block)
		@_locked = true
		@_lock_condition = block
	end
	def unlock
		@_locked = false
		@_lock_condition = nil
		next_text
	end
	
	def set_procs(*args)
		@_dprocs = args
	end
	def set_proc(i,arg)
		@_dprocs[i] = arg
	end
	# When pausing
	def save_text;@_stdata = [@_dindex,@_dtext,@_dprocs];end
	def load_text;@_dindex,@_dtext,@_dprocs=*@_stdata;end
end