#

class MainWindow < Qt::MainWindow
	
	def initialize(parent = nil)
		super(parent)
		
		@currentFile = ""
		@width, @height = 800, 480
		setMinimumSize(@width, @height)
		resize(@width, @height)
		setWindowTitle(Database::Config::DefaultTitle);
		setWindowIcon(Qt::Icon.new("Data/Icons/mir.png"))
		
		@tabBar = Qt::TabWidget.new
		setCentralWidget(@tabBar)
		createMenu
		createToolBar
	end
	
	def createSlot(n)
		slot = n.kind_of?(Symbol) ? n.to_s + "()" : n
		MainWindow.q_slot(slot)
		return SLOT(slot)
	end
	
	def newFile
		m 'New File'
	end
	def openFile
		$loadingFile = Qt::FileDialog.getOpenFileName(self)
		if $loadingFile

			obj = MIRMarshal.load(File.open($loadingFile, 'rb') { |f| f.read })
			if MIRMarshal.gotError?
				Qt::MessageBox.warning(self, Database::Config::DefaultTitle, MIRMarshal.getErrorMessage)
				return
			end
			@currentFile = $loadingFile
			setWindowTitle("#{$loadingFile} - #{Database::Config::DefaultTitle}")
			@tabBar.widget(@tabBar.addTab(Qt::TextEdit.new, File.basename(@currentFile))).setPlainText(obj.inspect)
			
		end
	end
	def openCurrentFileDirectory()
		puts 'Open current file directory'
		Qt::DesktopServices.openUrl(Qt::Url.fromLocalFile(File.dirname(@currentFile)))
	end
	def saveFile
		m 'Saving File'
	end
	def saveAs
		m 'Saving File As'
	end
	def closeFile
		puts 'Closing File'
		@currentFile = ""
		setWindowTitle(Database::Config::DefaultTitle)
	end
	def createMenu
		@menuBar = []
		# File Menu
		@menuBar[0] = menuBar().addMenu(tr("&File"))
		# Open File
		action = @menuBar[0].addAction("&Open...")
		action.shortcut = Qt::KeySequence.new("Ctrl+O")
		connect(action, SIGNAL(:triggered), self, createSlot("openFile()"))
		# Open Current File Directory
		action = @menuBar[0].addAction("&Open current file directory")
		connect(action, SIGNAL(:triggered), self, createSlot("openCurrentFileDirectory()"))
		# Save File
		action = @menuBar[0].addAction(tr("&Save"))
		action.shortcut = Qt::KeySequence.new("Ctrl+S")
		connect(action, SIGNAL(:triggered), self, createSlot("saveFile()"))
		# Save As
		action = @menuBar[0].addAction(tr("&Save As..."))
		action.shortcut = Qt::KeySequence.new("Ctrl+Alt+S")
		connect(action, SIGNAL(:triggered), self, createSlot("saveAs()"))
		# Close
		action = @menuBar[0].addAction(tr("&Close"))
		action.shortcut = Qt::KeySequence.new("Ctrl+W")
		connect(action, SIGNAL(:triggered), self, createSlot("closeFile()"))
		# Menu Separator
		@menuBar[0].addSeparator()
		# Quit
		action = @menuBar[0].addAction(tr("&Quit"))
		action.shortcut = Qt::KeySequence.new("Alt+F4")
		connect(action, SIGNAL(:triggered), self, createSlot("close()"))
	end
	def createToolBar
		@toolBar = addToolBar('')
		# New File
		action = @toolBar.addAction(Qt::Icon.new("Data/Icons/mir.png"), "New")
		connect(action, SIGNAL(:triggered), self, createSlot("newFile()"))
		# Open File
		action = @toolBar.addAction(Qt::Icon.new("Data/Icons/mir.png"), "Open")
		connect(action, SIGNAL(:triggered), self, createSlot("openFile()"))
		# Save File
		action = @toolBar.addAction(Qt::Icon.new("Data/Icons/mir.png"), "Save")
		connect(action, SIGNAL(:triggered), self, createSlot("saveFile()"))
	end
end