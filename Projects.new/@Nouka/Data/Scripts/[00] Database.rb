# 2 = Bas, 4 = Gauche, 6, = Droite, 8 = Haut

module Database
	module Config
		DefaultWidth   = 1280
		DefaultHeight  = 640
		UpdateInterval = 40
		EFrameInterval = 500 / UpdateInterval  # Entity
		MFrameInterval = 1000 / UpdateInterval # Map
		ZoomFactor     = 3.0
		TileSize       = 16
		StartLevel     = 0
		
		_title = "Nouka"
		unless $TEST
			DefaultTitle   = _title
			DefaultScene   = :SceneTitle
		else
			DefaultScene   = :SceneMap
			DefaultTitle   = _title + " [Debug Mode F2]"
		end
		
		#-- Debug Purposes --#
		
	end
	States = 
	{
		:play => 0,
		:pause => 1
	}
	module Window
		DefaultWindowskin = "GUI1"
		DefaultType       = 4
		DefaultButtonType = 14
		DefaultOpacity    = 200
		DefaultFont		  = "Messe Duesseldorf"
		
		# WindowMessage
		MsgWidth  = 500
		MsgHeight = 180
		MsgX      = Database::Config::DefaultWidth / 2 - MsgWidth / 2
		MsgY      = Database::Config::DefaultHeight - (MsgHeight + 20)
		MsgOpacity= 245
		MsgType   = 14
		#MsgTextColor = Gosu::Color.new()
		
		# WindowPause
		PauWidth     = 320
		PauHeight    = 200
		PauX         = Database::Config::DefaultWidth / 2 - PauWidth / 2
		PauY         = Database::Config::DefaultHeight / 2 - PauHeight / 2
		BorderColor  = Gosu::Color.new(160, 0, 0, 0)# PauseBorderColor
		
		# WindowOptions
		OpnWidth     = 320
		OpnHeight    = 220
		OpnX         = Database::Config::DefaultWidth / 2 - OpnWidth / 2
		OpnY         = Database::Config::DefaultHeight/ 2 - OpnHeight / 2
		
		# WindowEntity
		EtnWidth     = 200
		EtnHeight    = 170
		EtnX         = Database::Config::DefaultWidth - (EtnWidth + 300)
		EtnY         = (Config::DefaultHeight-EtnHeight)/2
		EtnTextColor = Gosu::Color.new(255, 255, 255, 255)
		IcoDim       = 24 * 1.5 # 24x24
		DesWidth     = 80
		
		# WindowHUD
		HudWidth = 200
		HudHeight = 40
		HudX = 0
		HudY = Database::Config::DefaultHeight - HudHeight
		
	end
	module Maps
		MoveSpeed      = Database::Config::TileSize*2
		Layers         = 3
		
		WheelZoomInc   = 1.0
		MaxZoomFactor  = 3.0      
		MinZoomFactor  = 2.0       
	end
	module Tilesets
	    #(0)Name,(1)frames,(2)TiledIndex,3(Rows),4(Columns)
		Names = [["Floor",1,1,21,39],["Pit",2,820,8,32],["Decor",2,1076,8,22],["Ground",2,1252,8,7],["Wall",1,1308,20,51],["Door",2,2328,8,6],["Tree",2,2376,12,36]]
		Projectiles = "Effect"
	end
	module Entities
		Types = [ "Monster", "Tower", "Projectile", "Object" ]
		Classes = 
		[
			# (0)Flag,(1)Name,(2)File,(3)[[VarBmp,VarProjec]],(4)[Hp,Atk,Def,Mag,Res], 
			# (5)MapSpeed,(6)ProjecFreq,(7)[Actions],(8)[[SkillID,SkillArg]],
			# (9)[vRect,dRect,aRect],(10)Cost,(11)SummonTime(12)Active/Passive,(13)block?,(14)Description
			
			[ # TYPE 0 Classes (Monster) FLAGS : 0 or 1 (Player/Monster)#3*7*8+7
				[0, 'Summoner','Player',[[119,0]],[300, 8, 7, 8, 7],3.0, # 0, 0
				8, [0, 1, 2], [], [16, 5, 3], 0, 0,true,false,
				"A courageous magician who summons creatures."],           # 0, 1
				[1, 'Shinigami','Undead',[[40,1],[41,1],[42,0]],[20, 8, 7, 8, 7],4.0,
				10, [1, 4], [], [16, 4, 3], 100, 120,true,false,
				"A Shinigami."],
				[1, 'Spadassin','Player',[[58,3]],[20, 8, 7, 8, 7],2.0,
				8, [1, 4], [], [16, 4, 3], 100, 120,true,false,
				"The ultimate boomerang master."]
			],
			[ # TYPE 1 Classes (Tower) FLAGS : 2 or 3 (Attack/Effect)
				[2, 'Monk','Player',[[7,2]],[240, 8, 8, 9, 7],2.0,         # 1, 0
				16, [4], [[0,[125,50]]], [16, 5, 5], 300, 180,true,false,
				"A wise creature who can produce Mana."],
				[3, 'Angel','Humanoid',[[128,2]],[240, 8, 8, 7, 7],2.0,    # 1, 1
				10, [4], [[1,[10,5]]], [16, 5, 5], 50, 120,true,false,
				"Shine bright like a diamond <,-,>"]
			],
			[ # TYPE 2 Classes (Object) FLAGS : 4 or 5 (Undamagable/Damagable)
				[4, 'Chest', 'Chest', [[1, 0]], [50, 0, 0, 0, 0],2.0,     # 2, 0
				1, [],[],[16,1,1],0,0,false,true,"A Chest full of Mana!"],
				[5, 'Door', 'Door', [[0,0],[2,0]], [100, 0, 0, 0, 0],2.0,        # 2, 1
				1,[],[],[16,0,0],0,0,false,true,"A Weak Door."],
				[6, 'Fountain', 'Decor', [[169,0]], [300,0,7,0,7],1.0,
				1,[],[],[16,0,0],0,0,false,false,"The legendary fountain!"]
			]
		]
		# (0)Name,(1)File,(2)Function,(3)Description
		Actions = 
		[
			[ "Summon", "001", :action_summon,
			"Summon an Entity.\nThis Entity Level can affect the summoned Entity Level."],
			
			[   "Move", "002", :action_move,
			"Move this Entity.\nMoving an Entity cost nothing."],
			
			[  "HP Max", "003", :action_hp_up,
			"Restore this Entity's HP."],
			
			[  "Build", "004", :action_build,
			"Build an tower.\nAvailable towers may varies if other Entities are in this tower range."],
			
			["Self Destruct", "005", :action_delete,
			"Delete this Entity. Give 1/3 of his cost."]
		] 
		Talents = # Skills
		[
			["Mana Producer", "006", "This unit can produce mana."], # 0
			["Healing Area",  "006", "Heals friends in radius."]    # 1
		]
		DetectionSkills = [1]
		# (0)Static/Seek,(1)Rotationable,(2)Speed,(3)Frame
		Projectiles = 
		[
			[ false, true,  6, 168],  # SFireball
			[ false, false, 6, 175],  # BEnergyball
			[ false, false, 8, 182],  # BLightball
			[ false, true,  8, 199]
		]
		# (0)SelectionRect,(2)vRect,(3)dRect,(4)aRect
		RectColor = [Gosu::Color::YELLOW, Gosu::Color.new(100, 0, 0, 255), Gosu::Color.new(100, 0, 255, 0), Gosu::Color.new(100, 255, 255, 0)]
		Teams = 
		[
			[ "Moobyte", Gosu::Color.new(255, 135, 206, 250)],
			[ "Bahamut", Gosu::Color.new(255, 255,   0,   0)],
			[ "Altaris", Gosu::Color.new(255, 0,   255,   0)],
			[ "Kahyla" , Gosu::Color.new(255, 255,   0, 255)]
		]
	end

	#ClassesName = ["Summoner", "Sage", "Dragon", "Mercenary", "Swordmaster",
	#"Archer", "Assassin", "Tranner"]
	#["Sage", "Dragon"]
	# Enchanter, Sorcerer
	#ObjectsName = ["Chest"]
	#TowersName = ["Mana Stone", "Mana Tower", ""]
	#ActionName = ["Spawning", "Summoning", "Standing", "Moving", "Attacking", "WaitingDamage", "TakingDamage", "Dying"]
	# Entities' Types
	# Entities' Classes
	# [0:Name],[1:File],[2:FramesVariant],[2:ManaCost],[3:SummonTime],[4:HP],[5:ATK],[6:MAG],[7;DEF],[8;DEFMAG],[9:SPEED]
	# [10:DeteckRange],[11:AttackRange],[12:VolumeRange],[13:ActionList]
	# Entities' States ID
	# [0:None],[1:Summoning],[2:Moving],[3:Burning],[4:Damaged],[5:Dying]
	# Entities' Actions
	# [0:Summon],[1:Move],[2;+Level],[3:Build],[4:Option]
	# Buttons' States
	# [0:Unused],[1:Using],[2:Used]
	# Levels' Data
	# (0)[[StartMap],[StartMapX],[StartMapY]],(1)[Code]

	Levels = 
	[
		[
			[0, -3 * Config::TileSize * Config::ZoomFactor, -18 * Config::TileSize * Config::ZoomFactor],
			
			<<~_code_
				case @_cstep
				when 0 # Init Level
					@_cstep = 1
					@time = 0
					# Team Stats
					@tmana = [0,0,0,0]
					@tleaders = [
					[
					Entity.new(-1, Global.player_team_id, 0, 0, 0, Database::Config::TileSize * 16, Database::Config::TileSize * 24)],[],[],[]]
					@tblocks = [
					[
						Entity.new(-1, 1, 2, 1, 1, Database::Config::TileSize * 30, Database::Config::TileSize * 13),
						Entity.new(-1, 1, 2, 0, 0, Database::Config::TileSize * 42, Database::Config::TileSize * 31)
					],[],[],[]]
					@tsummonable = [[[1,0],[1,1]],[],[],[]]
					Global.teams.each_with_index{ |t,i|
						t.mana    = @tmana[i]
						t.blocks  = @tblocks[i]
						t.leaders = @tleaders[i]
						t.summonable_entities = @tsummonable[i]
					}
					@tentities=[[
					Entity.new(-1,Global.player_team_id,1,1,0,Database::Config::TileSize * 17,Database::Config::TileSize * 12),
					Entity.new(-1,1, 2, 1, 0, Database::Config::TileSize * 55, Database::Config::TileSize * 18)
					],[],[],[]]
					add_limit_rect(Rect.new(0,0,30*Database::Config::TileSize,46*Database::Config::TileSize))
					
					@tentities[0][0].script = Proc.new {
					
if @script_step == 0					
	@try_detect = true
	if detected?(Global.scene.tleaders[0][0])
		Global.scene.clear_limit_rects
		Global.scene.add_limit_rect(Rect.new(0,0,44*Database::Config::TileSize,46*Database::Config::TileSize))
		Global.show_entities_rect=true
		Global.show_teams_rect=true
		Global.can_select=false
		Global.can_act = false
		Global.can_scroll=true
		Global.can_zoom=false
		Global.scene.show_message(
"Chaque entité possède un rayon de
détection & d'attaque et une équipe.
On peut afficher visuellement ces données.
• Touche R : rayons d'attaque & détection
• Touche T : Équipe des entités",

"Chaque entité possède aussi ses propres
talents et compétences, comme l'ange qui guéri.
Vous pouvez avoir un apperçu des autres
statistiques d'une entité dans la section «S»
de la fenêtre Entité.",

"J'espère que vous vous amuserez bien dans ce jeu!"
)
		Global.scene.set_message_procs(
		Proc.new{Global.show_entities_rect=false;Global.show_teams_rect=false;Global.scene.map.setSelectedEntities([self]);w=Global.scene.get_window(:entity);w.open;w.set_current_window(1);w.set_entities([self])},
		Proc.new{Global.can_zoom=true;Global.can_select=true;Global.can_act=true;Global.scene.map.setSelectedEntities([Global.scene.tleaders[0][0]]);w=Global.scene.get_window(:entity);w.open;w.set_entities([Global.scene.tleaders[0][0]]);w.set_current_window(0);Global.texting=false},
		Proc.new{Global.scene.set_code_step(2)}
		)
		
		@script_step = 1
	end
end
}
Global.scene.tentities[0][1].script = Proc.new {
case @script_step
when 0
	@current_detect_range.radius = 3.5*Database::Config::TileSize
	@script_step = 1
when 1
	
	@try_detect = true
	if detected?(Global.scene.tleaders[0][0])
		
		Global.scene.show_message("Certaines portes peuvent être défoncées...\nCe ne sont pas toutes les portes qui ont une serrure.")
		Global.texting = false
		@script_step = -1
	end
end

}
Global.scene.tblocks[0][0].detectable = false
Global.scene.tblocks[0][0].script = Proc.new {
case @script_step
when 0
	@current_detect_range.radius = 3.5*Database::Config::TileSize
	@script_step = 1
when 1
	@try_detect = true
	if detected?(Global.scene.tleaders[0][0])
		Global.scene.clear_limit_rects
		Global.scene.add_limit_rect(Rect.new(0,0,47*Database::Config::TileSize,46*Database::Config::TileSize))
		Global.scene.show_message("Il semblerait que le passage ici soit bloqué...\nIl va falloir trouver la clé.")
		Global.texting = false
		@script_step = -1
	end
when 2
	@try_detect = true
	@script_step = 1 unless detected?(Global.scene.tleaders[0][0])
when 3
	@try_detect = true
	if detected?(Global.scene.tleaders[0][0])
		Global.scene.clear_limit_rects
		@sprite_frame = (@sprite_frame + 1)%2
		@script_step = -1
	end
end
}
Global.scene.tblocks[0][1].detectable = false
Global.scene.tblocks[0][1].script = Proc.new {
case @script_step
when 0
	@try_detect = true
	
	if detected?(Global.scene.tleaders[0][0])
		@sprite_frame = (@sprite_frame + 1)%2
		Global.scene.tblocks[0][0].script_step = 3
		Global.can_select = false
		Global.scene.show_message(
"Et hop!\nCe que contient ce coffre au trésor va nous être\ngrandement utile, j'en sûr!",
"...\nC'est trop simple, n'est-ce pas?\nAllez, pour plus d'action j'ajoute des ennemis.\nOn a qu'à appeler ça une embusquade, d'accord ?\n<,-,>"
)
		Global.scene.set_message_proc(0, Proc.new{
Global.can_select = true
Global.texting = false
_e1 = Entity.new(-1, 1, 0, 1, 0, 35*Database::Config::TileSize, 27*Database::Config::TileSize)
_e2 = Entity.new(-1, 1, 0, 1, 1, 36*Database::Config::TileSize, 26*Database::Config::TileSize)
_a = Entity::MoveRoute::Data.new(2, [Global.scene.tleaders[0][0]])
_e1.move_route.actions.push(_a)
_e2.move_route.actions.push(_a)
Global.scene.map.addEntity(_e1)
Global.scene.map.addEntity(_e2)
})
		Global.scene.tblocks[0][0].roadblock = false
		@script_step = -1
	end
end
}
					Global.scene.tleaders.each{|a|a.each{|e|@map.addEntity(e)}}
					Global.scene.tblocks.each{|a|a.each{|e|@map.addEntity(e);e.roadblock=true}}
					Global.scene.tentities.each{|a|a.each{|e|@map.addEntity(e);e.set_summoning_time(0)}}
					@map.entities[0].current_hp = 200
					cash(Loremcafe)
					Global.can_pause = false
					Global.can_select = false
					Global.can_scroll = false
					Global.can_zoom = false
					close_window(:hud)
					show_message(
"Bienvenue sur le Action RPG Nouka.
Créé par Frédéric Gosselin en 2017-2018
Pour plus de renseignements, consulter le fichier
Nodoc.docx du fichier 'Informations sur le projet'.
Appuyez sur Espace ou cliquez sur cette 
boite de dialogue pour continuer.",

"Le mode Debug est actuellement " + ($TEST ? "[ACTIVÉ]." : "[DÉSACTIVÉ].") + "
Pour passer en mode Debug, il faut assigner
la valeur TRUE à la variable $TEST (fichier main.rb)
et appuyer sur la touche F2. Il permet de voir
les FPS et enlève certaines limites
(coût invocations,etc.)",

"Voici un petit récapitulatif des commandes :
• Touches WASD/Flèchées : champ de vision
• Roulette Souris : zoomer la carte de jeu
• Touche Échap : accéder au menu pause
• Touches Alt+Entrée : plein écran
• Touche F12 : reset",

"Essayez de sélectionner une entité.
Il suffit de cliquer sur la carte puis
de glisser la souris sur l'objectif.
Pour annuler une sélection : clic droit.",

"Bien! Maintenant, essayez de déplacer
l'entité vers l'ange. Il suffit de cliquer
à l'endroit désiré, sans glisser la souris."


)

					
					set_message_procs(nil,
					Proc.new{Global.can_scroll=true;Global.can_pause=true;Global.can_zoom=true},
					Proc.new{Global.can_select=true;lock_message(Proc.new{@map.selectedEntities?&&@mouse.released?})},
					Proc.new{lock_message(Proc.new{Global.scene.tleaders[0][0].detectable_by?(Global.scene.tentities[0][0])})})
				when 2
					
					if Global.scene.tleaders[0][0].isInRCZone?(61*Database::Config::TileSize,31*Database::Config::TileSize,3*Database::Config::TileSize,2*Database::Config::TileSize)
						set_code_step(-1)
						show_message "Super!\nVous avez complété le niveau tutoriel.\nPassons au niveau 1 maintenant!"
						
						set_message_procs(Proc.new{set_level(1)})
					
					end
				end
			_code_
		],
		[
			[1, -10 * Config::TileSize * 2, -30 * Config::TileSize * 2],
			<<~_code_
			case @_cstep
			when 0
					@_cstep = 1
					@time = 0
					# Team Stats
					@tmana = [1000,0,0,0]
					@tleaders = [
					[
					Entity.new(-1, Global.player_team_id, 0, 0, 0, Database::Config::TileSize * 24, Database::Config::TileSize * 50)],[],[],[]]
					@tblocks = [
					[
						Entity.new(-1, 0, 2, 2, 0, Database::Config::TileSize * 29, Database::Config::TileSize * 58),
						Entity.new(-1, 0, 2, 1, 0, Database::Config::TileSize * 24, Database::Config::TileSize * 53),
						Entity.new(-1, 0, 2, 1, 0, Database::Config::TileSize * 37, Database::Config::TileSize * 45),
						Entity.new(-1, 0, 2, 1, 0, Database::Config::TileSize * 38, Database::Config::TileSize * 57),
						Entity.new(-1, 0, 2, 1, 0, Database::Config::TileSize * 31, Database::Config::TileSize * 66)
					],[],[],[]]
					@tsummonable = [[[0,2]],[],[],[]]
					Global.teams.each_with_index{ |t,i|
						t.mana    = @tmana[i]
						t.blocks  = @tblocks[i]
						t.leaders = @tleaders[i]
						t.summonable_entities = @tsummonable[i]
					}
					@tentities=[[],[Entity.new(-1, 1, 0, 1, 0, Database::Config::TileSize * 31, Database::Config::TileSize * 56)],[],[]]
					Global.scene.tleaders.each{|a|a.each{|e|@map.addEntity(e)}}
					Global.scene.tblocks.each{|a|a.each{|e|@map.addEntity(e);e.roadblock=true}}
					Global.scene.tentities.each{|a|a.each{|e|@map.addEntity(e);e.set_summoning_time(0)}}
					Global.camera.zoom = 2.0
					add_limit_rect(Rect.new(0,30*Database::Config::TileSize,54*Database::Config::TileSize,66*Database::Config::TileSize))
					@windows[:hud].open
					
					#Global.can_pause = false
					Global.can_select = false
					#Global.can_scroll = false
					#Global.can_zoom = false
					@tblocks[0][1].detectable = false
					@tblocks[0][1].team_id = 2
					show_message("Oh non!\nNos ennemis on découvert la fontaine sacrée.
Comment sommes-nous supposés protéger
le village si nous n'avons qu'un seul combattant?",
"Mais oui!
Vous pouvez utiliser votre pouvoir d'invocation
pour appeler un courageux guerrier!
Vous possédez actuellement " + Global.teams[0].mana.to_s + " points de mana.",
"Génial!\nMaintenant passons à l'attaque!")
					set_message_procs(Proc.new{Global.scene.map.setSelectedEntities([Global.scene.tleaders[0][0]]);w=Global.scene.get_window(:entity);w.open;w.set_entities([Global.scene.tleaders[0][0]]);lock_message(Proc.new{@mouse.released?&&Global.current_action[0]==0&&Global.current_action[1][1]&&!@mouse.dragged?})},
					Proc.new{Global.can_select = true;@tblocks[0][1].detectable=true;@tblocks[0][1].team_id = Global.player_team_id;@_cstep=1;Global.scene.clear_limit_rects})
			when 1
c {
			
}
			end
			_code_
		],
		[
	[1, -10 * Config::TileSize * 2, -30 * Config::TileSize * 2],
	<<~_code_

	
_code_
		
	]
	]
end


=begin
	if Global.scene.tentities[0][0].dead?
					@_cstep = 2
					@_time = 60
					show_message "Je me demande d'où venais cet ennemi ...\n En tout cas, il faut défendre le village pendant quelque temps.",
					"Mission : Defendez le village face à l'attaque des ennemis pendant " + @_time.to_s + " frames."  
				end
			when 2
				@_time -= 1
				if @_time%10 == 0 
					_e = Entity.new(-1, 1, 0, 1, 0, Database::Config::TileSize * 55, Database::Config::TileSize * 36)
					@map.addEntity(_e)
					_a = Entity::MoveRoute::Data.new(2, [Global.scene.tblocks[0][0]])
					_e.move_route.actions.push(_a)
				end
				if @_time == 0
					@_cstep = 3
					show_message ("Bien! Maintenant que vous avez protéger le village de l'invasion ennemie, essayez de détruire la base ennemie.")
					clear_limit_rects
				end
			when 3
file : Entity.rb
def stopMove
# light
		uc {
			_v = Database::Entities::Classes[@type_id][@class_id][9]
			_detect_radius = _v[1]
			_center_x, _center_y = map_x - _detect_radius, map_y - _detect_radius
			@_cc = Gosu.record(_detect_radius*2*Database::Config::TileSize, _detect_radius*2*Database::Config::TileSize) {
					
					(_detect_radius * 2).times { |x|
						(Math.sqrt(_detect_radius**2 - (x-_detect_radius)**2).ceil * 2).times { |y|
							_x, _y = (_center_x + x).floor, (_center_y + y).floor
							
							if !Global.current_map.passable?(_x, _y)
								if (x < _detect_radius) ^ (y < _detect_radius)
									x1 = 16 * (x - (y == _detect_radius ? -0.5 :  0.5))
									y1 = 16 * (y - (x == _detect_radius ? -0.5 : +0.5))
									x2 = 16 * (x + 0.5)
									y2 = 16 * (y + 0.5)
								else
									x1 = 16 * (x - 0.5)
									y1 = 16 * (y + 0.5)
									x2 = 16 * (x + 0.5)
									y2 = 16 * (y - 0.5)
									if x == _detect_radius
										y1 = 16 * (y - 0.5)
									end
									if y == _detect_radius
										x2 = 16 * (x - 0.5)
									end
								end
								Gosu.draw_quad(x1,y1,Gosu::Color.new(255,rand(255),rand(255),rand(255)),x2,y2,Gosu::Color.new(255,rand(255),rand(255),rand(255)),_detect_radius*Database::Config::TileSize,_detect_radius*Database::Config::TileSize,Gosu::Color.new(255,rand(255),rand(255),rand(255)),_detect_radius*Database::Config::TileSize,_detect_radius*Database::Config::TileSize,Gosu::Color.new(255,rand(255),rand(255),rand(255)),300)
								#Gosu.draw_quad(x1,y1,Gosu::Color::RED,x1+1,y1+1,Gosu::Color::RED,_detect_radius*Database::Config::TileSize,_detect_radius*Database::Config::TileSize,Gosu::Color::RED,_detect_radius*Database::Config::TileSize+1,_detect_radius*Database::Config::TileSize+1,Gosu::Color::RED,300)
								#Gosu.draw_quad(x2,y2,Gosu::Color::RED,x2+1,y2+1,Gosu::Color::RED,_detect_radius*Database::Config::TileSize,_detect_radius*Database::Config::TileSize,Gosu::Color::RED,_detect_radius*Database::Config::TileSize+1,_detect_radius*Database::Config::TileSize+1,Gosu::Color::RED,300)
							end
						}
					}
				}
				
			x = Sprite.new(@_cc)
			x.x = @x-_detect_radius*Database::Config::TileSize+Database::Config::TileSize/2
			x.y = @y-_detect_radius*Database::Config::TileSize+Database::Config::TileSize/2
			x.z = 300
			show_rect(x)
		}
end
=end