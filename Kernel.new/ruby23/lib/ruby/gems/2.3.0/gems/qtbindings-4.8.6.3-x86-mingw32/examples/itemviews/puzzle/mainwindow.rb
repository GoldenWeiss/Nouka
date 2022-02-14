=begin
**
** Copyright (C) 2004-2005 Trolltech AS. All rights reserved.
**
** This file is part of the example classes of the Qt Toolkit.
**
** This file may be used under the terms of the GNU General Public
** License version 2.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of
** this file.  Please review the following information to ensure GNU
** General Public Licensing requirements will be met:
** http://www.trolltech.com/products/qt/opensource.html
**
** If you are unsure which license is appropriate for your use, please
** review the following information:
** http://www.trolltech.com/products/qt/licensing.html or contact the
** sales department at sales@trolltech.com.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**

** Translated to QtRuby by Richard Dale
=end

require './piecesmodel.rb'
require './puzzlewidget.rb'

class MainWindow < Qt::MainWindow
    
    slots 'openImage(const QString&)', 'openImage()', 'setupPuzzle()'
    
    slots 'setCompleted()'
        
    def initialize(parent = nil)
        super(parent)
        setupMenus()
        setupWidgets()
    
        setSizePolicy(Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed))
        setWindowTitle(tr("Puzzle"))
        @puzzleImage = Qt::Pixmap.new
    end
    
    def openImage(path = "")
        fileName = path
    
        if fileName.empty?
            fileName = Qt::FileDialog.getOpenFileName(self,
                tr("Open Image"), "", "Image Files (*.png *.jpg *.bmp)")
        end
    
        if !fileName.nil?
            newImage = Qt::Pixmap.new
            if !newImage.load(fileName)
                Qt::MessageBox.warning(self, tr("Open Image"),
                                     tr("The image file could not be loaded."),
                                     Qt::MessageBox::Cancel, Qt::MessageBox::NoButton)
                return
            end
            @puzzleImage = newImage
            setupPuzzle()
        end
    end
    
    def setCompleted()
        Qt::MessageBox.information(self, tr("Puzzle Completed"),
            tr("Congratulations! You have completed the puzzle!\n" +
               "Click OK to start again."),
            Qt::MessageBox::Ok)
    
        setupPuzzle()
    end
    
    def setupPuzzle()
        size = [@puzzleImage.width(), @puzzleImage.height()].min
        @puzzleImage = @puzzleImage.copy((@puzzleImage.width() - size)/2,
            (@puzzleImage.height() - size)/2, size, size).scaled(400,
                400, Qt::IgnoreAspectRatio, Qt::SmoothTransformation)
    
		oldModel = @piecesList.model
		newModel = PiecesModel.new(self)
		@piecesList.model = newModel
		oldModel.dispose

		# srand(QCursor::pos().x() ^ QCursor::pos().y());
        Kernel.srand
        
		for y in 0...5
			for x in 0...5
                pieceImage = @puzzleImage.copy(x*80, y*80, 80, 80)
                newModel.addPiece(pieceImage, Qt::Point.new(x, y))
            end
        end
    
        @puzzleWidget.clear()
    end
    
    def setupMenus()
        fileMenu = menuBar().addMenu(tr("&File"))
    
        openAction = fileMenu.addAction(tr("&Open..."))
        openAction.shortcut = Qt::KeySequence.new(tr("Ctrl+O"))
    
        exitAction = fileMenu.addAction(tr("E&xit"))
        exitAction.shortcut = Qt::KeySequence.new(tr("Ctrl+Q"))
    
        gameMenu = menuBar().addMenu(tr("&Game"))
    
        restartAction = gameMenu.addAction(tr("&Restart"))
    
        connect(openAction, SIGNAL('triggered()'), self, SLOT('openImage()'))
        connect(exitAction, SIGNAL('triggered()'), $qApp, SLOT('quit()'))
        connect(restartAction, SIGNAL('triggered()'), self, SLOT('setupPuzzle()'))
    end
    
    def setupWidgets()
        frame = Qt::Frame.new
        frameLayout = Qt::HBoxLayout.new(frame)
    
		@piecesList = Qt::ListView.new
		@piecesList.dragEnabled = true
		@piecesList.viewMode = Qt::ListView::IconMode
		@piecesList.iconSize = Qt::Size.new(60, 60)
		@piecesList.gridSize = Qt::Size.new(80, 80)
		@piecesList.spacing = 10
		@piecesList.movement = Qt::ListView::Snap
		@piecesList.acceptDrops = true
		@piecesList.dropIndicatorShown = true
	
		model = PiecesModel.new(self)
		@piecesList.model = model

        @puzzleWidget = PuzzleWidget.new
    
        connect(@puzzleWidget, SIGNAL('puzzleCompleted()'),
                self, SLOT('setCompleted()'), Qt::QueuedConnection)
    
        frameLayout.addWidget(@piecesList)
        frameLayout.addWidget(@puzzleWidget)
        setCentralWidget(frame)
    end
end
