__author__  = "Ricardo Pérez Pardo"
__name__    = "Parser"
__package__ = "dataExtraction"

from re import sub

class Parser:
	
	def structDataSplit(self,structData,data,keyWords,split):
		while data.endswith(split):
			data = data[:-len(split)] #Por si acaso lo quitamos para evitar splits de más.
		splitData = data.split(split)
		
		if len(splitData) > (len(keyWords)-1): #Nos aseguramos de que no sobrepasamos el tamaño de la estructura
			if not ("Extras" in structData.keys()):
				structData["Extras"] = []
			structData[keyWords[len(keyWords)-1]].append(splitData[-(len(splitData)-(len(keyWords)-1)):])
			#La keyword "Extras" siempre se usará para almacenar posibles elementos con los que no se cuenta
			for i in range(len(keyWords)-1):
				if not (splitData[i] == ''):
					structData[keyWords[i]] = splitData[i]
		else:
			for i in range(len(splitData)):
				if not (splitData[i] == ''):
					structData[keyWords[i]] = splitData[i]
		return structData
	
	def onlyDigits(self,string):
		return float(sub('\D','',string))
		
	def parsePlayerData(self,playerdata):
		structData = { "Player" : {}}
		keyWords = { 
					0 : "PlayerNum",
					1 : "PlayerName",
					2 : "PlayerAvatar",
					3 : "PlayerRating",
					4 : "Extras",
					}
					
		structData["Player"] = self.structDataSplit(structData["Player"],playerdata,keyWords,'|')
		structData["Player"][keyWords[0]] = self.onlyDigits(structData["Player"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData

	def parseBasicData(self,basicdata,name): #Usamos esto para parsear las lineas básicas con 1 solo elemento esperado
		structData = { name : {}}
		keyWords = {
					0 : name,
					1 : "Extras",
					}
					
		structData[name] = self.structDataSplit(structData[name],basicdata,keyWords,'|')
		if not (keyWords[1] in structData.keys()):
			return structData[name][keyWords[0]]
		return structData[name]
		
	def parseGametypeData(self,gametypedata):
		
		return self.parseBasicData(gametypedata,"GameType")
		
	def parseGenData(self,gendata):
		
		return self.parseBasicData(gendata,"Gen")
		
	def parseTierData(self,tierdata):
		
		return self.parseBasicData(tierdata,"Tier")
		
	def parseJoinData(self,joindata):
		
		return self.parseBasicData(joindata,"Join")
		
	def parseRuleData(self,ruledata):
	
		return self.parseBasicData(ruledata,"Rule")
		
	def parseTeampreviewData(self,teampreviewdata):
		
		return self.parseBasicData(teampreviewdata[1:],"TeamPreview") #Se pone [1:] a los que empiezan por |
		
	def parseInactiveData(self,inactivedata):
		
		return self.parseBasicData(inactivedata,"Inactive")
		
	def parseRawData(self,rawdata):
		
		return self.parseBasicData(rawdata,"Raw")
		
	def parseWinnerData(self,winnerdata):
		
		return self.parseBasicData(winnerdata,"Winner")
		
	def parseMessageData(self,messagedata):
	
		return self.parseBasicData(messagedata,"Message")
		
	def parseRatedData(self,rateddata):
		structData = { "Rated" : {}}
		keyWords = {
					0 : "Rated",
					1 : "Type",
					2 : "Extras",
					}
		structData["Rated"] = self.structDataSplit(structData["Rated"],rateddata[1:],keyWords,'|')
		if not (keyWords[1] in structData.keys() and not keyWords[2] in structData.keys()):
			return structData["Rated"][keyWords[0]]
		return structData
		
	def parseTeamSizesData(self,teamsizesdata):
		structData = { "TeamSize" : {}}
		keyWords = { 
					0 : "PlayerNum",
					1 : "TeamSize",
					2 : "Extras",
					}
					
		structData["TeamSize"] = self.structDataSplit(structData["TeamSize"],teamsizesdata,keyWords,'|')
		structData["TeamSize"][keyWords[0]] = self.onlyDigits(structData["TeamSize"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
		
	def parseChatData(self,chatdata):
		structData = { "Chat" : {}}
		keyWords = { 
					0 : "PlayerName",
					1 : "Text",
					2 : "Extras",
					}
					
		structData["Chat"] = self.structDataSplit(structData["Chat"],chatdata,keyWords,'|')
		return structData
		
	def parsePokeData(self,pokedata):
		structData = { "Poke" : {}}
		keyWords = { 
					0 : "PlayerNum",
					1 : "Pokemon",
					2 : "PokemonLevel",
					3 : "PokemonGender",
					4 : "Extras",
					}
		
		structData["Poke"] = self.structDataSplit(structData["Poke"],pokedata,[keyWords[0],keyWords[1],keyWords[4]],'|')

		structData["Poke"][keyWords[2]] = 100 #Lo inicializamos
		tempstructData = structData["Poke"][keyWords[1]].split(", ")

		for k in range(len(tempstructData)):
			if k == 0:
				structData["Poke"][keyWords[1]] = tempstructData[k] #La especie va a estar siempre en el primer sitio
			elif (tempstructData[k].upper() == "M") or (tempstructData[k].upper() == "F"):
				structData["Poke"][keyWords[3]] = tempstructData[k]
			elif tempstructData[k].upper().startswith("L"):
				structData["Poke"][keyWords[2]] = self.onlyDigits(tempstructData[k]) #L50 -> 50
			else:
				if not (keyWords[4] in structData["Poke"].keys()):
					structData["Poke"][keyWords[4]] = []
				structData["Poke"][keyWords[4]].append(tempstructData[k])

		structData["Poke"][keyWords[0]] = self.onlyDigits(structData["Poke"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
		
	def parseTurnMoveData(self,movedata):
		structData = { "Move" : {}}
		keyWords = { 
					0 : "AttackingPlayer",
					1 : "Attack",
					2 : "AttackedPlayer",
					3 : "AttackingPokemonNickname",
					4 : "AttackedPokemonNickname",
					5 : "Extras",
					}
					
		structData["Move"] = self.structDataSplit(structData["Move"],movedata,[keyWords[0],keyWords[1],keyWords[2],keyWords[5]],'|')
		structData["Move"] = self.structDataSplit(structData["Move"],structData["Move"][keyWords[0]],[keyWords[0],keyWords[3],keyWords[5]],": ")
		if keyWords[2] in structData["Move"].keys():
			structData["Move"] = self.structDataSplit(structData["Move"],structData["Move"][keyWords[2]],[keyWords[2],keyWords[4],keyWords[5]],": ")
			structData["Move"][keyWords[2]] = self.onlyDigits(structData["Move"][keyWords[2]]) #p1a -> 1 , p2b -> 2
		structData["Move"][keyWords[0]] = self.onlyDigits(structData["Move"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
	
	def parseTurnSwitchData(self,switchdata):
		structData = { "Switch" : {}}
		keyWords = {
					0 : "SwitchingPlayer",
					1 : "SwitchedPokemon",
					2 : "SwitchedPokemonHP",
					3 : "SwitchedPokemonNickname",
					4 : "SwitchedPokemonGender",
					5 : "SwitchedPokemonShiny",
					6 : "SwitchedPokemonMaxHP",
					7 : "SwitchedPokemonLevel",
					8 : "SwitchedPokemonStatus",
					9 : "Extras",
					}
					
		structData["Switch"] = self.structDataSplit(structData["Switch"],switchdata,[keyWords[0],keyWords[1],keyWords[2],keyWords[9]],'|')
		structData["Switch"] = self.structDataSplit(structData["Switch"],structData["Switch"][keyWords[0]],[keyWords[0],keyWords[3],keyWords[9]],": ")
		#Puede llegar a haber 4 datos en el orden Especie,Nivel,Genero,Shiny.
		structData["Switch"][keyWords[5]] = False #Lo inicializamos
		structData["Switch"][keyWords[7]] = 100 #Lo inicializamos
		tempstructData = structData["Switch"][keyWords[1]].split(", ")
		
		for k in range(len(tempstructData)):
			if k == 0:
				structData["Switch"][keyWords[1]] = tempstructData[k] #La especie va a estar siempre en el primer sitio
			elif (tempstructData[k].upper() == "M") or (tempstructData[k].upper() == "F"):
				structData["Switch"][keyWords[4]] = tempstructData[k]
			elif tempstructData[k].lower() == "shiny":
				structData["Switch"][keyWords[5]] = True
			elif tempstructData[k].upper().startswith("L"):
				structData["Switch"][keyWords[7]] = self.onlyDigits(tempstructData[k]) #L50 -> 50
			else:
				if not (keyWords[9] in structData["Switch"].keys()):
					structData["Switch"][keyWords[9]] = []
				structData["Switch"][keyWords[9]].append(tempstructData[k])
				
		structData["Switch"][keyWords[0]] = self.onlyDigits(structData["Switch"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		if "\\/" in structData["Switch"][keyWords[2]]: #Formato algo distinto que a veces puede ocurrir, lo normal es "\/"
			structData["Switch"] = self.structDataSplit(structData["Switch"],structData["Switch"][keyWords[2]],[keyWords[2],keyWords[6],keyWords[9]],"\\/")
		elif "\/" in structData["Switch"][keyWords[2]]:
			structData["Switch"] = self.structDataSplit(structData["Switch"],structData["Switch"][keyWords[2]],[keyWords[2],keyWords[6],keyWords[9]],"\/")
		else: # "/"
			structData["Switch"] = self.structDataSplit(structData["Switch"],structData["Switch"][keyWords[2]],[keyWords[2],keyWords[6],keyWords[9]],"/")
		
		if ' ' in structData["Switch"][keyWords[6]]: #Si hay un espacio es que está separando a otro elemento que es el status
			structData["Switch"][keyWords[6]],structData["Switch"][keyWords[8]] = structData["Switch"][keyWords[6]].split(" ")
		
		structData["Switch"][keyWords[2]] = self.onlyDigits(structData["Switch"][keyWords[2]]) #"HP" -> HP (De string a int)
		if "fnt" not in structData["Switch"][keyWords[6]]:
			structData["Switch"][keyWords[6]] = self.onlyDigits(structData["Switch"][keyWords[6]]) #"MaxHP" -> MaxHP (De string a int excepto si es "fnt")
		
		return structData
			
	def parseTurnFaintData(self,faintdata):
		structData = { "Faint" : {}}
		keyWords = {
					0 : "FaintedPokemonPlayer",
					1 : "FaintedPokemonNickname",
					2 : "Extras",
					}
					
		structData["Faint"] = self.structDataSplit(structData["Faint"],faintdata,[keyWords[0],keyWords[2]],'|')
		structData["Faint"] = self.structDataSplit(structData["Faint"],structData["Faint"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[2]],": ")
		structData["Faint"][keyWords[0]] = self.onlyDigits(structData["Faint"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
	
	def parseTurnCantStatusData(self,cantdata):
		structData = { "CantStatus" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Status",
					3 : "Extras",
					}
		
		structData["CantStatus"] = self.structDataSplit(structData["CantStatus"],cantdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["CantStatus"] = self.structDataSplit(structData["CantStatus"],structData["CantStatus"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["CantStatus"][keyWords[0]] = self.onlyDigits(structData["CantStatus"][keyWords[0]])
		
		return structData
		
	def parseTurnCantNoppData(self,cantdata):
		structData = { "CantNopp" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Status",
					3 : "BlockedMove",
					4 : "Extras",
					}
		
		structData["CantNopp"] = self.structDataSplit(structData["CantNopp"],cantdata,[keyWords[0],keyWords[2],keyWords[3],keyWords[4]],'|')
		structData["CantNopp"] = self.structDataSplit(structData["CantNopp"],structData["CantNopp"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[4]],": ")
		structData["CantNopp"][keyWords[0]] = self.onlyDigits(structData["CantNopp"][keyWords[0]])
		
		return structData
	
	def parseTurnCantThroatData(self,cantdata):
		structData = { "CantThroat" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "BlockerMove",
					3 : "Extras",
					}
		
		structData["CantThroat"] = self.structDataSplit(structData["CantThroat"],cantdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["CantThroat"] = self.structDataSplit(structData["CantThroat"],structData["CantThroat"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["CantThroat"][keyWords[2]] = structData["CantThroat"][keyWords[2]].split(": ")[1] #Eliminamos el "move: " del mensaje
		structData["CantThroat"][keyWords[0]] = self.onlyDigits(structData["CantThroat"][keyWords[0]])
		
		return structData

	def parseTurnCantTruantData(self,cantdata):
		structData = { "CantTruant" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "BlockerAbility",
					3 : "Extras",
					}
		
		structData["CantTruant"] = self.structDataSplit(structData["CantTruant"],cantdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["CantTruant"] = self.structDataSplit(structData["CantTruant"],structData["CantTruant"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["CantTruant"][keyWords[2]] = structData["CantTruant"][keyWords[2]].split(": ")[1] #Eliminamos el "ability: " del mensaje
		structData["CantTruant"][keyWords[0]] = self.onlyDigits(structData["CantTruant"][keyWords[0]])
		
		return structData
	
	def parseTurnCantFocuspunchShelltrapData(self,cantdata):
		structData = { "CantFocuspunchShelltrap" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "BlockedMove",
					3 : "Extras",
					}
		
		structData["CantFocuspunchShelltrap"] = self.structDataSplit(structData["CantFocuspunchShelltrap"],cantdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["CantFocuspunchShelltrap"] = self.structDataSplit(structData["CantFocuspunchShelltrap"],structData["CantFocuspunchShelltrap"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["CantFocuspunchShelltrap"][keyWords[0]] = self.onlyDigits(structData["CantFocuspunchShelltrap"][keyWords[0]])
		
		return structData
	
	def parseTurnCantGravityTauntHealBlockImprisonData(self,cantdata):
		structData = { "CantGravityTauntHealBlockImprison" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "BlockerMove",
					3 : "BlockedMove",
					4 : "Extras",
					}
		structData["CantGravityTauntHealBlockImprison"] = self.structDataSplit(structData["CantGravityTauntHealBlockImprison"],cantdata,[keyWords[0],keyWords[2],keyWords[3],keyWords[4]],'|')
		structData["CantGravityTauntHealBlockImprison"] = self.structDataSplit(structData["CantGravityTauntHealBlockImprison"],structData["CantGravityTauntHealBlockImprison"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[4]],": ")
		structData["CantGravityTauntHealBlockImprison"][keyWords[2]] = structData["CantGravityTauntHealBlockImprison"][keyWords[2]].split(": ")[1] #Eliminamos el "move: " del mensaje
		structData["CantGravityTauntHealBlockImprison"][keyWords[0]] = self.onlyDigits(structData["CantGravityTauntHealBlockImprison"][keyWords[0]])
		
		return structData
	
	def parseTurnCantData(self,cantdata):
		structData = { "Cant" : {}}
		possibleCantFormats = { #Según el tipo de "cant" pueden tener formatos distintos, los identificamos con los JavaScripts
								0 : ["slp","par","frz","flinch","Attract","recharge"], #p: mon|status
								1 : ["nopp"], #p: mon|nopp|movimiento
								2 : ["Throat Chop"], #p: mon|move: movimiento
								3 : ["Truant"], #p: mon|ability: habilidad
								4 : ["Focus Punch","Shell Trap"], #p: mon|movimiento1|movimiento1 (se repite 1 vez el mismo movimiento)
								5 : ["Gravity","Taunt","Heal Block","Imprison"], #p: mon|move: movimiento1|movimiento2 (mov1 es el movimiento que evitó que mov2 se pudiera realizar)
								}
								
		parseCantFormarFunctions = {
									0 : self.parseTurnCantStatusData,
									1 : self.parseTurnCantNoppData,
									2 : self.parseTurnCantThroatData,
									3 : self.parseTurnCantTruantData,
									4 : self.parseTurnCantFocuspunchShelltrapData,
									5 : self.parseTurnCantGravityTauntHealBlockImprisonData,
									}
									
		for i in range(len(possibleCantFormats)):
			for k in range(len(possibleCantFormats[i])):
				if (possibleCantFormats[i][k] in cantdata):
					structData["Cant"] = parseCantFormarFunctions[i](cantdata)
					return structData
	
	def	parseTurnDamageAnyData(self,damagedata,structdata,keyWords):
					
		structData = self.structDataSplit(structdata,structdata[keyWords[0]],[keyWords[0],keyWords[1],keyWords[len(keyWords)-1]],": ")
		
		if "fnt" in structData[keyWords[2]]: #Esto implica que el daño debilitó al pokemon
			structData = self.structDataSplit(structData,structData[keyWords[2]],[keyWords[2],keyWords[3],keyWords[len(keyWords)-1]]," ")
		elif "\\/" in structData[keyWords[2]]: #Formato algo distinto que a veces puede ocurrir, lo normal es "\/"
			structData = self.structDataSplit(structData,structData[keyWords[2]],[keyWords[2],keyWords[3],keyWords[len(keyWords)-1]],"\\/")
		elif "\/" in structData[keyWords[2]]:
			structData = self.structDataSplit(structData,structData[keyWords[2]],[keyWords[2],keyWords[3],keyWords[len(keyWords)-1]],"\/")
		else: # "/"
			structData = self.structDataSplit(structData,structData[keyWords[2]],[keyWords[2],keyWords[3],keyWords[len(keyWords)-1]],"/")		

		if ' ' in structData[keyWords[3]]: #Si hay un espacio es que está separando a otro elemento que es el status
			structData[keyWords[3]],structData[keyWords[4]] = structData[keyWords[3]].split(" ")

		structData[keyWords[0]] = self.onlyDigits(structData[keyWords[0]])
		if len(keyWords) >= 7: #DamageFrom y DamageOf
			if "[from] " in structData[keyWords[6]]:
				structData[keyWords[6]] = structData[keyWords[6]].split("[from] ")[1] #Eliminamos el "[from] " del mensaje
			if ": " in structData[keyWords[6]]: #Si hay algo como "item:" o "ability:"
				structData[keyWords[5]],structData[keyWords[6]] = structData[keyWords[6]].split(": ")
			
		return structData
	
	def parseTurnDamageSimpleData(self,damagedata,structData):
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "PokemonHP",
					3 : "PokemonMaxHP",
					4 : "PokemonStatus",
					5 : "Extras",
					}
		
		structData = self.structDataSplit(structData,damagedata,[keyWords[0],keyWords[2],keyWords[5]],'|')
		
		structData = self.parseTurnDamageAnyData(damagedata,structData,keyWords)
		
		structData[keyWords[2]] = self.onlyDigits(structData[keyWords[2]]) #"HP" -> HP (De string a int)
		if "fnt" not in structData[keyWords[3]]:
			structData[keyWords[3]] = self.onlyDigits(structData[keyWords[3]]) #"MaxHP" -> MaxHP (De string a int excepto si es "fnt")
		
		return structData
		
	def parseTurnDamageFromData(self,damagedata,structData):
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "PokemonHP",
					3 : "PokemonMaxHP",
					4 : "PokemonStatus",
					5 : "SourceType",
					6 : "Source",
					7 : "Extras",
					}
		
		structData = self.structDataSplit(structData,damagedata,[keyWords[0],keyWords[2],keyWords[6],keyWords[7]],'|')
		structData = self.parseTurnDamageAnyData(damagedata,structData,keyWords)
		
		structData[keyWords[2]] = self.onlyDigits(structData[keyWords[2]]) #"HP" -> HP (De string a int)
		if "fnt" not in structData[keyWords[3]]:
			structData[keyWords[3]] = self.onlyDigits(structData[keyWords[3]]) #"MaxHP" -> MaxHP (De string a int excepto si es "fnt")
		
		return structData
		
	def parseTurnDamageOfData(self,damagedata,structData):
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "PokemonHP",
					3 : "PokemonMaxHP",
					4 : "PokemonStatus",
					5 : "SourceType",
					6 : "Source",
					7 : "PlayerSource",
					8 : "PokemonSource",
					9 : "Extras",
					}
					
		structData = self.structDataSplit(structData,damagedata,[keyWords[0],keyWords[2],keyWords[6],keyWords[7],keyWords[9]],'|')
		structData = self.parseTurnDamageAnyData(damagedata,structData,keyWords)
		structData[keyWords[7]] = structData[keyWords[7]].split("[of] ")[1]
		structData = self.structDataSplit(structData,structData[keyWords[7]],[keyWords[7],keyWords[8],keyWords[9]],": ")
		structData[keyWords[7]] = self.onlyDigits(structData[keyWords[7]])
		
		structData[keyWords[2]] = self.onlyDigits(structData[keyWords[2]]) #"HP" -> HP (De string a int)
		if "fnt" not in structData[keyWords[3]]:
			structData[keyWords[3]] = self.onlyDigits(structData[keyWords[3]]) #"MaxHP" -> MaxHP (De string a int excepto si es "fnt")
		
		return structData
		
	def parseTurnDamageData(self,damagedata):
		if "[of]" in damagedata: #Si contiene [of] es que el daño proviene de una abilidad del pokemon
			structData = { "DamageOf" : {}}
			structData["DamageOf"] = self.parseTurnDamageOfData(damagedata,structData["DamageOf"])
			
		elif "[from]" in damagedata: #Si contiene [from] es que el daño no proviene de un ataque
			structData = { "DamageFrom" : {}}
			structData["DamageFrom"] = self.parseTurnDamageFromData(damagedata,structData["DamageFrom"])
			
		else:
			structData = {"Damage" : {}}
			structData["Damage"] = self.parseTurnDamageSimpleData(damagedata,structData["Damage"])
			
		return structData

	def parseTurnHealData(self,healdata): #Muy similar a |-damage, pueden usar las mismas funciones
		if "[of]" in healdata: #Si contiene [of] es que la curacion proviene de una abilidad del pokemon
			structData = { "HealOf" : {}}
			structData["HealOf"] = self.parseTurnDamageOfData(healdata,structData["HealOf"])
			
			return structData
		elif "[from]" in healdata: #Si contiene [from] es que el daño no proviene de un ataque
			structData = { "HealFrom" : {}}
			structData["HealFrom"] = self.parseTurnDamageFromData(healdata,structData["HealFrom"])
			
			return structData
		else:
			structData = {"Heal" : {}}
			structData["Heal"] = self.parseTurnDamageSimpleData(healdata,structData["Heal"])
			
			return structData
	
	def parseTurnMessageData(self,messagedata):
		structData = { "Message" : {}}
		keyWords = { 
					0 : "Text",
					1 : "Extras",
					}
					
		structData["Message"] = self.structDataSplit(structData["Message"],messagedata,[keyWords[0],keyWords[1]],'|')
		
		return structData
	
	def parseTurnInactiveData(self,inactivedata):
		structData = { "Inactive" : {}}
		keyWords = { 
					0 : "Text",
					1 : "Extras",
					}
		
		structData["Inactive"] = self.structDataSplit(structData["Inactive"],inactivedata,[keyWords[0],keyWords[1]],'|')

		return structData
		
	def parseTurnRawData(self,rawdata):
		structData = { "Raw" : {}}
		keyWords = { 
					0 : "Text",
					1 : "Extras",
					}
					
		structData["Raw"] = self.structDataSplit(structData["Raw"],rawdata,[keyWords[0],keyWords[1]],'|')
	
		return structData
		
	def parseTurnEnditemData(self,enditemdata):
		structData = { "EndItem" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Item",
					3 : "Extras",
					}
					
		structData["EndItem"] = self.structDataSplit(structData["EndItem"],enditemdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["EndItem"] = self.structDataSplit(structData["EndItem"],structData["EndItem"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["EndItem"][keyWords[0]] = self.onlyDigits(structData["EndItem"][keyWords[0]])
		
		return structData
		
	def parseTurnItemData(self,itemdata): #Igual a Enditem, creamos otra función para tener los distintos diccionarios
		structData = { "Item" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Item",
					3 : "Extras",
					}
					
		structData["Item"] = self.structDataSplit(structData["Item"],itemdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["Item"] = self.structDataSplit(structData["Item"],structData["Item"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		structData["Item"][keyWords[0]] = self.onlyDigits(structData["Item"][keyWords[0]])
		
		return structData
		
	def parseTurnEffectivenessData(self,structData,efectivedata):
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Extras",
					}
					
		structData = self.structDataSplit(structData,efectivedata,[keyWords[0],keyWords[1],keyWords[2]],": ")
		structData[keyWords[0]] = self.onlyDigits(structData[keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
		
	def parseTurnSuperEffectiveData(self,supereffectivedata):
		structData = { "Supereffective" : {}}

		structData["Supereffective"] = self.parseTurnEffectivenessData(structData["Supereffective"],supereffectivedata)
		
		return structData
		
	def parseTurnResistedData(self,resisteddata): 
		structData = { "Resisted" : {}}

		structData["Resisted"] = self.parseTurnEffectivenessData(structData["Resisted"],resisteddata)
		
		return structData
		
	def parseTurnImmuneData(self,immunedata):
		structData = { "Immune" : {}}

		structData["Immune"] = self.parseTurnEffectivenessData(structData["Immune"],immunedata)
	
		return structData
	
	def parseTurnMissData(self,missdata):
		structData = { "Miss" : {}}
		keyWords = {
					0 : "MissingPlayer",
					1 : "MissingPokemonNickname",
					2 : "MissedPlayer",
					3 : "MissedPokemonNickname",
					4 : "Extras",
					}
		
		structData["Miss"] = self.structDataSplit(structData["Miss"],missdata,[keyWords[0],keyWords[2],keyWords[4]],'|')
		structData["Miss"] = self.structDataSplit(structData["Miss"],structData["Miss"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[4]],": ")
		structData["Miss"] = self.structDataSplit(structData["Miss"],structData["Miss"][keyWords[2]],[keyWords[2],keyWords[3],keyWords[4]],": ")
		
		structData["Miss"][keyWords[0]] = self.onlyDigits(structData["Miss"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		structData["Miss"][keyWords[2]] = self.onlyDigits(structData["Miss"][keyWords[2]]) #p1a -> 1 , p2b -> 2
		
		return structData
	
	def parseTurnStatusData(self,statusdata):
		structData = { "Status" : {}}
		keyWords = {
					0 : "AffectedPlayer",
					1 : "AffectedPokemon",
					2 : "Status",
					3 : "Extras",
					}
	
		structData["Status"] = self.structDataSplit(structData["Status"],statusdata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["Status"] = self.structDataSplit(structData["Status"],structData["Status"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		
		structData["Status"][keyWords[0]] = self.onlyDigits(structData["Status"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
	
	def parseTurnCritData(self,critData):
		structData = { "Crit" : {}}
		keyWords = {
					0 : "Player",
					1 : "PokemonNickname",
					2 : "Extras",
					}
					
		structData["Crit"] = self.structDataSplit(structData["Crit"],critData,[keyWords[0],keyWords[1],keyWords[2]],": ")
		structData["Crit"][keyWords[0]] = self.onlyDigits(structData["Crit"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
		
	def parseTurnBoostData(self,boostData):
		structData = { "Boost" : {}}
		keyWords = {
					0 : "BoostingPlayer",
					1 : "BoostingPokemonNickname",
					2 : "BoostedStat",
					3 : "BoostedAmount",
					4 : "Extras",
					}
		
		structData["Boost"] = self.structDataSplit(structData["Boost"],boostData,[keyWords[0],keyWords[2],keyWords[3],keyWords[4]],'|')
		structData["Boost"] = self.structDataSplit(structData["Boost"],structData["Boost"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[4]],": ")
	
		structData["Boost"][keyWords[0]] = self.onlyDigits(structData["Boost"][keyWords[0]]) #p1a -> 1 , p2b -> 2

		return structData
		
	def parseTurnUnboostData(self,unboostData):
		structData = { "Unboost" : {}}
		keyWords = {
					0 : "UnboostingPlayer",
					1 : "UnboostingPokemonNickname",
					2 : "UnboostedStat",
					3 : "UnboostedAmount",
					4 : "Extras",
					}
		
		structData["Unboost"] = self.structDataSplit(structData["Unboost"],unboostData,[keyWords[0],keyWords[2],keyWords[3],keyWords[4]],'|')
		structData["Unboost"] = self.structDataSplit(structData["Unboost"],structData["Unboost"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[4]],": ")
	
		structData["Unboost"][keyWords[0]] = self.onlyDigits(structData["Unboost"][keyWords[0]]) #p1a -> 1 , p2b -> 2

		return structData
		
	def parseTurnFailData(self,faildata):
		structData = { "Fail" : {}}
		keyWords = {
					0 : "FailedPlayer",
					1 : "FailedPokemonNickname",
					2 : "FailedAction",
					3 : "Extras",
					}
		
		structData["Fail"] = self.structDataSplit(structData["Fail"],faildata,[keyWords[0],keyWords[2],keyWords[3]],'|')
		structData["Fail"] = self.structDataSplit(structData["Fail"],structData["Fail"][keyWords[0]],[keyWords[0],keyWords[1],keyWords[3]],": ")
		
		structData["Fail"][keyWords[0]] = self.onlyDigits(structData["Fail"][keyWords[0]]) #p1a -> 1 , p2b -> 2
		
		return structData
		
	def parseTurnChatData(self,chatdata):
		structData = { "Chat" : {}}
		keyWords = {
					0 : "PlayerName",
					1 : "Text",
					2 : "Extras",
					}
					
		structData = self.structDataSplit(structData,chatdata,[keyWords[0],keyWords[1],keyWords[2]],"|")
		
		return structData
	
	def parseTurnJoinData(self,joindata):
		structData = { "Join" : {}}
		keyWords = {
					0 : "PlayerName",
					1 : "Extras",
					}
					
		structData = self.structDataSplit(structData,joindata,[keyWords[0],keyWords[1]],"|")
		
		return structData
	
	def parseTurnData(self,turndata):
		structData = { "Turn" : {}}
		keyWords = {
					0 : "|move|",
					1 : "|switch|",
					2 : "|faint|",
					3 : "|cant|",
					4 : "|-damage|",
					5 : "|-heal|",
					6 : "|-message|",
					7 : "|inactive|",
					8 : "|raw|",
					9 : "|-enditem|",
					10 : "|-item|",
					11 : "|-supereffective|",
					12 : "|-resisted|",
					13 : "|-immune|",
					14 : "|-miss|",
					15 : "|-status|",
					16 : "|-crit|",
					17 : "|-boost|",
					18 : "|-unboost|",
					19 : "|-fail|",
					20 : "|c|",
					21 : "|j|",
					22 : "|join|",
					}
		
		keyWordsFunctions = {
							"|move|" : self.parseTurnMoveData,
							"|switch|" : self.parseTurnSwitchData,
							"|faint|" : self.parseTurnFaintData,
							"|cant|" : self.parseTurnCantData,
							"|-damage|" : self.parseTurnDamageData,
							"|-heal|" : self.parseTurnHealData,
							"|-message|" : self.parseTurnMessageData,
							"|inactive|" : self.parseTurnInactiveData,
							"|raw|" : self.parseTurnRawData,
							"|-enditem|" : self.parseTurnEnditemData,
							"|-item|" : self.parseTurnItemData,
							"|-supereffective|" : self.parseTurnSuperEffectiveData,
							"|-resisted|" : self.parseTurnResistedData,
							"|-immune|" : self.parseTurnImmuneData,
							"|-miss|" : self.parseTurnMissData,
							"|-status|" : self.parseTurnStatusData,
							"|-crit|" : self.parseTurnCritData,
							"|-boost|" : self.parseTurnBoostData,
							"|-unboost|" : self.parseTurnUnboostData,
							"|-fail|" : self.parseTurnFailData,
							"|c|" : self.parseTurnChatData,
							"|j|" : self.parseTurnJoinData,
							"|join|" : self.parseTurnJoinData,
							}

		diff = 0 #Cuando vayamos borrando lo sobrante no queremos pasarnos de indexación
		for i in range(len(turndata)): #Todas las lineas en 1 turno que hay que iterar
			for k in range(len(keyWords)):
				if turndata[i-diff].lower().startswith(keyWords[k].lower()):
					try:
						parsedData = keyWordsFunctions[keyWords[k]](turndata[i-diff].split(keyWords[k])[1]) #Cada linea distinta llamará a una función distinta
						turndata[i-diff] = parsedData
						break #Si lo encontramos pasamos a la siguiente linea
					except:
						break
			if not isinstance(turndata[i-diff],dict):
				del turndata[i-diff]
				diff = diff + 1
				
					
		structData["Turn"] = turndata
		return structData