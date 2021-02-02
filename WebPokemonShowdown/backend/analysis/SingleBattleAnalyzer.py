__author__  = "Ricardo Pérez Pardo"
__name__    = "SingleBattleAnalyzer"
__package__ = "analysis"

from pokebase import pokemon as pbpokemon #Librería para usar la API PokeAPI https://github.com/PokeAPI/pokebase
from pokebase import move as pbmove
from pandas import merge
from pandas import DataFrame as df
from pandas import Series as ser
from itertools import product
from operator import itemgetter

class SingleBattleAnalyzer:

	data = dict
	battle = str
	
	def __init__(self,data):
		self.data = data
		self.battle = self.data["Battle ID"]
	
	# Battle ID | Winner
	def analyzeBattleWinner(self):
		indexVec = ["Battle ID","Winner"]
		if "Battle" in self.data and "Winner" in self.data["Battle"] and len(self.data["Battle"]["Winner"]) > 0:
			w = self.data["Battle"]["Winner"][0].replace(' ','').lower()
		return ser([self.battle,w],index=indexVec)

	# Battle ID | Tier | Fancy
	def analyzeBattleFormat(self):
		indexVec = ["Battle ID","Format","Fancy"]
		f = self.data["Battle"]["Format"]
		fancy = self.data["Battle"]["Tier"][0]
		return ser([self.battle,f,fancy],index=indexVec)
		
	# Battle ID | Forfeit(bool) | Disconnect(bool) | Timeout(bool) | Normal(bool)
	def analyzeBattleForfeitDisconnect(self):
		indexVec = ["Battle ID","Forfeit","Disconnect","Timeout","Normal"]
		forfeit = False
		disconnect = False
		timeout = False
		normal = False
		if len(self.data["Battle"]["Turns"]) > 0:
			m = self.data["Battle"]["Turns"][-1:][0]["Turn"]
			for i in range(len(m)):
				if "Message" in m[i]:
					forfeit = ("forfeit" in m[i]["Message"]["Text"].lower()) or forfeit
					timeout = ("lost due to inactivity" in m[i]["Message"]["Text"].lower()) or timeout
				elif "Inactive" in m[i]:
					disconnect = ("reconnect!" in m[i]["Inactive"]["Text"].lower()) or disconnect
		else:
			m = self.data["Battle"]
			for k in range(len(m["Message"])):
				if isinstance(m["Message"][k],str): #Formato simple
					forfeit = ("forfeit" in m["Message"][k].lower()) or forfeit #Una vez que se ponga True no cambiará
					timeout = ("lost due to inactivity" in m["Message"][k].lower()) or timeout
				elif isinstance(m["Message"][k],dict): #Formato Message:{Text:str}
					forfeit = ("forfeit" in m["Message"][k]["Message"]["Text"].lower()) or forfeit
					timeout = ("lost due to inactivity" in m["Message"][k]["Message"]["Text"].lower()) or timeout
			for t in range(len(m["Inactive"])):
				if isinstance(m["Inactive"][k],str): #Formato simple
					disconnect = ("reconnect!" in m["Inactive"][t].lower()) or disconnect
				elif isinstance(m["Inactive"][k],dict): #Formato Inactive:{Text:str}
					disconnect = ("reconnect!" in m["Inactive"][t]["Inactive"]["Text"].lower()) or disconnect
				#Será True solo si el último mensage "Inactive" contiene "reconnect!"
				#Partida finalizada porque un jugador se desconectó y su tiempo para poder volver se acabó
				#El otro caso sería una partida finalizada porque a un jugador se le agotó el tiempo para hacer una jugada
		normal = not(forfeit or disconnect or timeout)
		#Este "nor" nos pondrá "normal" a True solo si los otros 3 booleanos son False
		return ser([self.battle,forfeit,disconnect,timeout,normal],index=indexVec)
	
	#  Battle ID	Player Num		Player Name		Player Avatar		Player Rating
	#0
	#1
	
	def analyzeBattlePlayers(self):
		columnsVec = ["Battle ID","Player Number","Player Name","Player Avatar","Player Rating"]
		dictPlayer = {}
		for i in range(len(columnsVec)):
			dictPlayer[columnsVec[i]] = []
		dictTranslator = {
						"PlayerNum" : "Player Number",
						"PlayerName" : "Player Name",
						"PlayerAvatar" : "Player Avatar",
						"PlayerRating" : "Player Rating",
						}
		
		players = self.data["Battle"]["AvatarsRatings"]
		for i in range(len(players)):
			p = players[i]["Player"]
			if dictPlayer["Player Number"].count(p["PlayerNum"]) >= 1: #Evitamos repetidos que pueden suceder a veces
				continue
			dictPlayer["Battle ID"].append(self.battle)
			for j in p.keys():
				if j in "PlayerName":
					p[j] = p[j].replace(' ','').lower() #Limpieza de mayúsculas y espacios que no diferencian usuarios
				dictPlayer[dictTranslator[j]].append(p[j])
			if dictPlayer["Player Rating"] == []:
				dictPlayer["Player Rating"] = 0
		return df(dictPlayer,columns=columnsVec)
	
	# Battle ID | AverageRating
	def analyzeBattleELOAverage(self):
		indexVec = ["Battle ID","Average Rating"]
		return ser([self.battle,self.data["Battle"]["MeanRating"]],index=indexVec)
	
	# Battle ID | Elo Gain
	def analyzeBattleELOGain(self):
		indexVec = ["Battle ID","ELO Gain"]
		r = self.data["Battle"]["RawMsgs"]
		ELO = 0
		for k in range(len(r)):
			if ("for winning" in r[k] and "(" in r[k]):
				ELO = r[k].split(" for winning")[0].split("(")[1]
		
		return ser([self.battle,ELO],index=indexVec)
		
	# Battle ID | Turns 
	def analyzeBattleTurnsNeeded(self):
		indexVec = ["Battle ID","Turns"]
		return ser([self.battle,len(self.data["Battle"]["Turns"])],index=indexVec)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID
	#0
	#1
	#...
	def analyzeBattlePokes(self):
		columnsVecdS = ["Pokemon","Pokemon Nickname","Player"]
		columnsVecdP = ["Pokemon","Player"]
		
		dictSwitch = {}
		for i in range(len(columnsVecdS)):
			dictSwitch[columnsVecdS[i]] = []
		
		dictPoke = {}
		for i in range(len(columnsVecdP)):
			dictPoke[columnsVecdP[i]] = []
		
		if len(self.data["Battle"]["TeamPreview?"]) > 0:
			cpokes = len(self.data["Battle"]["Pokes"])
			for i in range(cpokes):
				dictPoke["Pokemon"].append(self.data["Battle"]["Pokes"][i]["Poke"]["Pokemon"])
				dictPoke["Player"].append(self.data["Battle"]["Pokes"][i]["Poke"]["PlayerNum"])
		#Habrá que ir mirando en los Switches dentro de los turnos a qué nickname corresponde cada poke
		tupVec = []
		turns = self.data["Battle"]["Turns"] 
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Switch" in turns[j]["Turn"][k]:
					s = turns[j]["Turn"][k]["Switch"]
					tupVec.append((s["SwitchedPokemonNickname"],s["SwitchingPlayer"],s["SwitchedPokemon"]))
		sSet = set(tupVec) #Eliminamos duplicados
		for t in range(len(sSet)):
			(nick,player,poke) = sSet.pop()
			dictSwitch["Player"].append(player)
			dictSwitch["Pokemon"].append(poke)
			dictSwitch["Pokemon Nickname"].append(nick)
		
		dS = df(dictSwitch,columns=columnsVecdS)
		dP = df(dictPoke,columns=columnsVecdP)
		if len(dP) > 0: #Si es 0 es que no entramos en el primer if
			dMerge = merge(dP,dS,how="left",on=["Player","Pokemon"],sort=False)
		else:
			dMerge = dS
			
		dictBattleID = {}
		dictBattleID["Battle ID"] = []
		for x in range(len(dMerge)):
			dictBattleID["Battle ID"].append(self.battle)
			
		return merge(dMerge,df(dictBattleID,columns=["Battle ID"]),how="left",right_index=True,left_index=True,sort=False)
		
		#Un Nickname "NaN" implica que nunca se pudo saber porque el pokemon no se usó
		
	#	Pokemon		Player		Pokemon Nickname	Battle ID	Attack	Victim Nickname		Victim Player
	#0
	#1
	#2
	#...
	def analyzeBattleVictimsByPokemon(self):
		dictVictim = {}
		columnsVec = ["Player","Pokemon Nickname","Move","Victim Nickname","Victim Player","Turn"]
		for i in range(len(columnsVec)):
			dictVictim[columnsVec[i]] = []
		
		pokes = self.analyzeBattlePokes()
		turns = self.data["Battle"]["Turns"]
		lastMove = {}
		tupVec = [] # (Jugador Atacante , Pokemon Atacante, Victima)
		
		for j in range(len(turns)):
			lastMove = {} #Lo reseteamos para que no se utilice entre turnos distintos
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					lastMove = turns[j]["Turn"][k]["Move"]
				if "Faint" in turns[j]["Turn"][k]:
					faint = turns[j]["Turn"][k]["Faint"]
					if len(lastMove) > 0:
						if "AttackedPokemonNickname" in lastMove and "FaintedPokemonNickname" in faint and "AttackedPlayer" in lastMove and "FaintedPokemonPlayer" in faint:
							if lastMove["AttackedPokemonNickname"] == faint["FaintedPokemonNickname"]:
								if lastMove["AttackedPlayer"] == faint["FaintedPokemonPlayer"]:
									tupVec.append((lastMove["AttackingPlayer"],lastMove["AttackingPokemonNickname"],lastMove["Attack"],faint["FaintedPokemonNickname"],faint["FaintedPokemonPlayer"],j))
		
		sSet = set(tupVec)
		for i in range(len(sSet)):
			(Player,Poke,Attack,Victim,VPlayer,Turn) = sSet.pop()
			dictVictim["Player"].append(Player)
			dictVictim["Pokemon Nickname"].append(Poke)
			dictVictim["Move"].append(Attack)
			dictVictim["Victim Nickname"].append(Victim)
			dictVictim["Victim Player"].append(VPlayer)
			dictVictim["Turn"].append(Turn)
		
		victims = df(dictVictim,columns=columnsVec)
		
		return merge(pokes,victims,how="right",on=["Player","Pokemon Nickname"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Victims		Max Victims in a row
	#0
	#1
	#2
	#...	
	def analyzeBattleVictimsInARow(self):
		columnsVec = ["Player","Pokemon Nickname","Victims","Max Victims in a row"]
		dictVictim = {}
		for i in range(len(columnsVec)):
			dictVictim[columnsVec[i]] = []
		
		pokes = self.analyzeBattlePokes()
		turns = self.data["Battle"]["Turns"]
		lastMove = {}
		tupVec = []
		gotAFaint = False
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					lastMove = turns[j]["Turn"][k]["Move"]
				if "Faint" in turns[j]["Turn"][k]:
					faint = turns[j]["Turn"][k]["Faint"]
					if len(lastMove) > 0:
						if "AttackedPokemonNickname" in lastMove and "FaintedPokemonNickname" in faint and "AttackedPlayer" in lastMove and "FaintedPokemonPlayer" in faint:
							if lastMove["AttackedPokemonNickname"] == faint["FaintedPokemonNickname"]:
								if lastMove["AttackedPlayer"] == faint["FaintedPokemonPlayer"]:
									gotAFaint = True
									tupVec.append((lastMove["AttackingPlayer"],lastMove["AttackingPokemonNickname"]))
				if "Switch" in turns[j]["Turn"][k] and gotAFaint:
					pswitch = turns[j]["Turn"][k]["Switch"]["SwitchingPlayer"]
					(pattk,pokeattk) = tupVec[-1:][0]
					if pswitch == pattk:
						tupVec.append((pswitch,pokeattk,"Switch"))
						gotAFaint = False
		
		sSet = set(tupVec)
		for t in range(len(sSet)):
			element = sSet.pop()
			if len(element) == 2: # No tenemos en cuenta los que tengan el 3er elemento "Switch"
				player,poke = element
				dictVictim["Player"].append(player)
				dictVictim["Pokemon Nickname"].append(poke)
				dictVictim["Victims"].append(tupVec.count(element))
				if tupVec.count((player,poke,"Switch")) == 0: #Nunca hizo switch por lo que num victims = max
					dictVictim["Max Victims in a row"].append(tupVec.count(element))
				else:
					posFaints = [index for index, value in enumerate(tupVec) if value == (player,poke)]
					posSwitch = [index for index, value in enumerate(tupVec) if value == (player,poke,"Switch")]
					#Ahora operamos entre ambos vectores para buscar la mayor distancia = mayor cantidad de victimas seguidas
					vector = []
					vector.append(posFaints)
					for i in range(len(posSwitch)):
						vector.append([x for x in posFaints if x > posSwitch[i]])
					
					vector2 = []
					for l in range(len(vector)-1):
						vector2.append([x for x in vector[i] if x not in vector[i+1]])
					vector2.append(vector[len(vector)-1])
					dictVictim["Max Victims in a row"].append(len(max(vector2,key=len)))
		result = df(dictVictim,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Player","Pokemon Nickname"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Item
	#0
	#1
	#2
	#...	
	def analyzeBattleItemUsage(self):
		columnsVec = ["Pokemon Nickname","Player","Item"]
		dictItem = {}
		for i in range(len(columnsVec)):
			dictItem[columnsVec[i]] = []
		tupVec = []
		preventDups = []
		pokes = self.analyzeBattlePokes()
		#Primero miramos si el item es un item de curación o daño corresponiente al HealFrom/DamageFrom
		turns = self.data["Battle"]["Turns"] 
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				stri = ["HealFrom","DamageFrom"]
				for t in range(len(stri)):
					if stri[t] in turns[j]["Turn"][k]:
						h = turns[j]["Turn"][k][stri[t]]
						if "SourceType" in h:
							if "item" in h["SourceType"].lower():
								if not (h["PokemonNickname"],h["Player"]) in preventDups:  #Ignoramos duplicados con items distintos
									preventDups.append((h["PokemonNickname"],h["Player"]))
									tupVec.append((h["PokemonNickname"],h["Player"],h["Source"]))
		#Luego miramos si el item aparece en EndItem cuando se consume o en Item
				stri2 = ["EndItem","Item"]
				for u in range(len(stri2)):
					if stri2[u] in turns[j]["Turn"][k]:
						ei = turns[j]["Turn"][k][stri2[u]]
						if not (ei["PokemonNickname"],ei["Player"]) in preventDups:
							preventDups.append((ei["PokemonNickname"],ei["Player"]))
							tupVec.append((ei["PokemonNickname"],ei["Player"],ei["Item"]))

		for v in range(len(tupVec)):
			(nick,player,item) = tupVec[v]
			dictItem["Pokemon Nickname"].append(nick)
			dictItem["Player"].append(player)
			dictItem["Item"].append(item)
		result = df(dictItem,columns=columnsVec)

		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
	
	def __pokemonAPITypeData(self,dictAPIData,species,poke):
		typeList = poke.types
		dictAPIData["Pokemon"].append(species)
		dictAPIData["Type 1"].append(typeList[0].type.name)
		if len(typeList) == 2:
			dictAPIData["Type 2"].append(typeList[1].type.name)
		else:
			dictAPIData["Type 2"].append(None)
		return dictAPIData
	
	def __pokemonAPIStatData(self,dictAPIData,species,poke):
		nameTranslator= {
						"hp" : "HP",
						"attack" : "Attack",
						"defense" : "Defense",
						"special-attack" : "S. Attack",
						"special-defense" : "S. Defense",
						"speed" : "Speed",
						}
						
		statList = poke.stats
		dictAPIData["Pokemon"].append(species)
		for j in range(len(statList)):
			statname = statList[j].stat.name
			basestat = statList[j].base_stat
			dictAPIData[nameTranslator[statname]].append(basestat)
		return dictAPIData
	
	def __pokemonAPISizeData(self,dictAPIData,species,poke):
		weight = poke.weight
		height = poke.height
		dictAPIData["Pokemon"].append(species)
		dictAPIData["Weight (kg)"].append(weight/10)
		dictAPIData["Height (m)"].append(height/10)
		return dictAPIData
		
	def __pokemonAPIBroker(self,columnsVec,func): # Pokebase cachea las peticiones así que aunque se haga en tres funciones solo hacemos una peticion a la API
		pokes = self.analyzeBattlePokes()
		species = ser(pokes["Pokemon"])
		dictAPIData = {}
		for i in range(len(columnsVec)):
			dictAPIData[columnsVec[i]] = []
		
		for i in range(len(species)):
			name = species[i].lower()
			name.replace(" ","-") #La api usa - para representar espacios
			try:
				poke = pbpokemon(name)
			except ValueError:
				print("The provided pokemon name ('",name,"') couldn't be found")
				continue
			except Exception as e:
				print("Error trying to get data from the API about a pokemon with name '",name,"'")
				print(e)
				continue
			try:
				dictAPIData = func(dictAPIData,species[i],poke)
			except:
				continue
		
		result = df(dictAPIData,columns=columnsVec)
		
		return merge(pokes.drop(columns="Pokemon Nickname"),result.drop_duplicates(),how="right",on=["Pokemon"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Type 1		Type 2
	#0
	#1
	#2
	#...
	
	def analyzeBattlePokemonAPITypeData(self):
		columnsVec = ["Pokemon","Type 1","Type 2"]
		
		return self.__pokemonAPIBroker(columnsVec,self.__pokemonAPITypeData)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	HP	Attack	Defense		...
	#0
	#1
	#2
	#...
	
	def analyzeBattlePokemonAPIStatData(self):
		columnsVec = ["Pokemon","HP","Attack","Defense","S. Attack","S. Defense","Speed"]
		
		return self.__pokemonAPIBroker(columnsVec,self.__pokemonAPIStatData)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Weight	Height
	#0
	#1
	#2
	#...
	
	def analyzeBattlePokemonAPISizeData(self):
		columnsVec = ["Pokemon","Weight (kg)","Height (m)"]
		
		return self.__pokemonAPIBroker(columnsVec,self.__pokemonAPISizeData)

	#	Pokemon		Pokemon Nickname	Player		Battle ID	Move 1	Move 2 ...
	#0
	#1
	#2
	#...
	def analyzeBattleMoveUsage(self):
		columnsVec = ["Pokemon Nickname","Player","Move 1","Move 2","Move 3","Move 4"]
		
		dictMove = {}
		for i in range(len(columnsVec)):
			dictMove[columnsVec[i]] = []
		moveIndexer= {
					0 : "Move 1",
					1 : "Move 2",
					2 : "Move 3",
					3 : "Move 4",
					}
		tupVec = []
		pokes = self.analyzeBattlePokes()
		
		turns = self.data["Battle"]["Turns"] 
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					m = turns[j]["Turn"][k]["Move"]
					if "Attack" in m and "AttackingPokemonNickname" in m and "AttackingPlayer" in m:
						if not m["Attack"].lower().startswith("max "): #Ignoramos Ataques Dynamax 
							if not "struggle" in m["Attack"].lower(): #Ignoramos Struggle
								if "Extras" in m: #Ignoramos ataques llamados por otros ataques (Metronome y Assist)
									if any("metronome" in s.lower() for s in m["Extras"][0]):
										continue
									elif any("assist" in s.lower() for s in m["Extras"][0]):
										continue
									elif any("[zeffect]" in s.lower() for s in m["Extras"][0]): # Ignoramos z-moves también
										continue
								tupVec.append((m["AttackingPlayer"],m["AttackingPokemonNickname"],m["Attack"]))

		sSet = set(tupVec)
		sSet2 = set([(a,b) for (a,b,c) in sSet if (a,b,c) in sSet])
		positions = []
		for u in range(len(sSet2)):
			player,poke = sSet2.pop()
			positions.append([index for index,(a,b,c) in enumerate(sSet) if b == poke and a == player])

		lList = list(sSet)
		for i in range(len(positions)):
			moves = []
			dictMove["Player"].append(lList[positions[i][0]][0])
			dictMove["Pokemon Nickname"].append(lList[positions[i][0]][1])
			for ii in range(len(positions[i])):
				moves.append(lList[positions[i][ii]][2])
			for mov in range(len(moveIndexer)):
				if len(moves) > mov:
					dictMove[moveIndexer[mov]].append(moves[mov])
				else:
					dictMove[moveIndexer[mov]].append(None)
					
		result = df(dictMove,columns=columnsVec)

		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Move	Supereffective Attacks	Resisted Attacks	Ineffective Attacks
	#0
	#1
	#2
	#...
	def	analyzeBattleMoveEffectiveness(self):
		columnsVec = ["Player","Pokemon Nickname","Move","Neutral Attacks","Supereffective Attacks","Resisted Attacks","Ineffective Attacks"]
		pokes = self.analyzeBattlePokes()
		dictEffective = {}
		for i in range(len(columnsVec)):
			dictEffective[columnsVec[i]] = []
		tupVec = []
		effectiveIndex = {
							0 : "Supereffective",
							1 : "Resisted",
							2 : "Immune",
							}
		effectiveTranslator = {
							"Supereffective" : "Supereffective Attacks",
							"Resisted" : "Resisted Attacks",
							"Immune" : "Ineffective Attacks",
							}
							
		turns = self.data["Battle"]["Turns"] 
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					m = turns[j]["Turn"][k]["Move"]
					if "AttackingPokemonNickname" in m and "AttackingPlayer" in m and "Attack" in m:
						if (len(turns[j]["Turn"]) > k+1): #El siguiente elemento al "Move" debería ser la efectividad
							for e in range(len(effectiveIndex)): #Si no es ninguna de estas 3 es que fue neutro
								if effectiveIndex[e] in turns[j]["Turn"][k+1]:
									tupVec.append((m["AttackingPlayer"],m["AttackingPokemonNickname"],m["Attack"],effectiveTranslator[effectiveIndex[e]]))
									break
								tupVec.append((m["AttackingPlayer"],m["AttackingPokemonNickname"],m["Attack"],"Neutral Attacks"))
		
		sSet = set(tupVec)
		sSet2 = set([(a,b,c) for (a,b,c,d) in sSet if (a,b,c,d) in sSet])
		sList1 = ["Neutral Attacks","Supereffective Attacks","Resisted Attacks","Ineffective Attacks"]
		tempProd = list(product(list(sSet2),sList1))
		prod = [(a,b,c,d) for ((a,b,c),d) in tempProd if ((a,b,c),d) in tempProd]
		tempCol1 = [a for (a,b,c) in sSet2 if (a,b,c) in sSet2]
		tempCol2 = [b for (a,b,c) in sSet2 if (a,b,c) in sSet2]
		tempCol3 = [c for (a,b,c) in sSet2 if (a,b,c) in sSet2]
		
		for i in range(len(prod)):
			amount = tupVec.count(prod[i])
			dictEffective[prod[i][3]].append(amount)
		dictEffective["Player"] = tempCol1
		dictEffective["Pokemon Nickname"] = tempCol2
		dictEffective["Move"] = tempCol3
		
		result = df(dictEffective,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
		
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Move	Times Used	Times Missed	Times Failed
	#0
	#1
	#2
	#...
	def analyzeBattleMoveFailure(self):
		columnsVec = ["Player","Pokemon Nickname","Move","Times Used","Times Missed","Times Failed"]
		tupVec = []
		dictFailure = {}
		for i in range(len(columnsVec)):
			dictFailure[columnsVec[i]] = []
		pokes = self.analyzeBattlePokes()
		
		turns = self.data["Battle"]["Turns"]
		for j in range(len(turns)):
			lastMove = {}
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					m = turns[j]["Turn"][k]["Move"]
					if "AttackingPokemonNickname" in m and "AttackingPlayer" in m and "Attack" in m:
						tupVec.append(("Move",m["AttackingPlayer"],m["AttackingPokemonNickname"],m["Attack"]))
				if "Miss" in turns[j]["Turn"][k]:
					if k > 0 and "Move" in turns[j]["Turn"][k-1]:
						miss = turns[j]["Turn"][k]["Miss"]
						move = turns[j]["Turn"][k-1]["Move"]
						if "Extras" in move and k > 1 and "Move" in turns[j]["Turn"][k-2]:
							move = turns[j]["Turn"][k-2]["Move"] #Si el movimiento contiene extras y hay otro movimiento justo antes es que un movimiento causó otro movimiento, solo nos interesa el primero
						if "MissingPokemonNickname" in miss and "AttackingPokemonNickname" in move and "MissingPlayer" in miss and "AttackingPlayer" in move and "Attack" in move:
							if "MissedPokemonNickname" in miss and "AttackedPokemonNickname" in move and "MissedPlayer" in miss and "AttackedPlayer" in move:
								if miss["MissingPokemonNickname"] in move["AttackingPokemonNickname"] and miss["MissingPlayer"] == move["AttackingPlayer"]:
									if miss["MissedPokemonNickname"] in move["AttackedPokemonNickname"] and miss["MissedPlayer"] == move["AttackedPlayer"]:
										tupVec.append(("Miss",miss["MissingPlayer"],miss["MissingPokemonNickname"],move["Attack"]))
					
				elif "Fail" in turns[j]["Turn"][k]:
					if k > 0 and "Move" in turns[j]["Turn"][k-1]:
						fail = turns[j]["Turn"][k]["Fail"]
						move = turns[j]["Turn"][k-1]["Move"]
						if "Extras" in move and k > 1 and "Move" in turns[j]["Turn"][k-2]:
							move = turns[j]["Turn"][k-2]["Move"]
						if "FailedPokemonNickname" in fail and "AttackingPokemonNickname" in move and "FailedPlayer" in fail and "AttackingPlayer" in move and "Attack" in move:
							if fail["FailedPokemonNickname"] in move["AttackingPokemonNickname"] and fail["FailedPlayer"] == move["AttackingPlayer"]:	
								tupVec.append(("Fail",fail["FailedPlayer"],fail["FailedPokemonNickname"],move["Attack"]))
					
		sList = list(set(tupVec))
		for i in range(len(sList)):
			type,player,nick,move = sList[i]
			amountFail = tupVec.count(("Fail",player,nick,move))
			amountMiss = tupVec.count(("Miss",player,nick,move))
			amountUsed = tupVec.count(("Move",player,nick,move))
			dictFailure["Player"].append(player)
			dictFailure["Pokemon Nickname"].append(nick)
			dictFailure["Move"].append(move)
			dictFailure["Times Used"].append(amountUsed)
			dictFailure["Times Missed"].append(amountMiss)
			dictFailure["Times Failed"].append(amountFail)
			
		result = df(dictFailure,columns=columnsVec)
		
		return merge(pokes,result.drop_duplicates(),how="right",on=["Pokemon Nickname","Player"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Status
	#0
	#1
	#2
	#...
	def analyzeBattlePokemonStatus(self):
		columnsVec = ["Player","Pokemon Nickname","Status"]
		tupVec = []
		dictStatus = {}
		for i in range(len(columnsVec)):
			dictStatus[columnsVec[i]] = []
		pokes = self.analyzeBattlePokes()
		statusTranslator = {
							"tox" : "Toxic Poison",
							"psn" : "Poison",
							"brn" : "Burn",
							"par" : "Paralisis",
							"frz" : "Freeze",
							"slp" : "Sleep",
							}
		
		turns = self.data["Battle"]["Turns"]
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Status" in turns[j]["Turn"][k]:
					status = turns[j]["Turn"][k]["Status"]
					if "AffectedPokemon" in status and "AffectedPlayer" in status and "Status" in status:
						tupVec.append((status["AffectedPlayer"],status["AffectedPokemon"],status["Status"]))
						
		for i in tupVec:
			player,nick,status = i
			dictStatus["Player"].append(player)
			dictStatus["Pokemon Nickname"].append(nick)
			dictStatus["Status"].append(statusTranslator[status])
			
		result = df(dictStatus,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Times Flinched	Times Fully Paralyzed
	#0
	#1
	#2
	#...
	def analyzeBattleParaFlinch(self):
		columnsVec = ["Player","Pokemon Nickname","Times Flinched","Times Fully Paralyzed"]
		tupVec = []
		dictParaflinch = {}
		for i in range(len(columnsVec)):
			dictParaflinch[columnsVec[i]] = []
		pokes = self.analyzeBattlePokes()
		
		turns = self.data["Battle"]["Turns"]
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Cant" in turns[j]["Turn"][k]:
					if "CantStatus" in turns[j]["Turn"][k]["Cant"]:
						cant = turns[j]["Turn"][k]["Cant"]["CantStatus"]
						if "Player" in cant and "PokemonNickname" in cant and "Status" in cant:
							tupVec.append((cant["Player"],cant["PokemonNickname"],cant["Status"].lower()))
		
		sList = list(set(tupVec))
		for i in range(len(sList)):
			player,nick,status = sList[i]
			amountFlinch = tupVec.count((player,nick,"flinch"))
			amountPara = tupVec.count((player,nick,"par"))
			dictParaflinch["Player"].append(player)
			dictParaflinch["Pokemon Nickname"].append(nick)
			dictParaflinch["Times Flinched"].append(amountFlinch)
			dictParaflinch["Times Fully Paralyzed"].append(amountPara)
			
		result = df(dictParaflinch,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
		
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Player hit by a Critical	Pokemon Nickname hit by a Critical	Move that was a crit	Did the Pokemon Faint from the critical?
	#0
	#1
	#2
	#...
	def analyzeBattleCriticals(self):
		columnsVec = ["Player","Pokemon Nickname","Player hit by a Critical","Pokemon Nickname hit by a Critical","Move that was a Critical","Did the Pokemon Faint from the critical?","Turn"]
		tupVec = []
		dictCrit = {}
		for i in range(len(columnsVec)):
			dictCrit[columnsVec[i]] = []
		pokes = self.analyzeBattlePokes()
		
		turns = self.data["Battle"]["Turns"]
		for j in range(len(turns)):
			lastMove = {} #Lo reseteamos para que no se utilice entre turnos distintos
			playerWhoGotCritted = None
			nickPokeThatGotCritted = None
			faint = False
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					if "AttackingPokemonNickname" in turns[j]["Turn"][k]["Move"] and "AttackingPlayer" in turns[j]["Turn"][k]["Move"] and "Attack" in turns[j]["Turn"][k]["Move"]:
						lastMove = turns[j]["Turn"][k]["Move"]
				if "Crit" in turns[j]["Turn"][k]:
					if "Player" in turns[j]["Turn"][k]["Crit"] and "PokemonNickname" in turns[j]["Turn"][k]["Crit"] and len(lastMove) > 0:
						playerWhoGotCritted = turns[j]["Turn"][k]["Crit"]["Player"]
						nickPokeThatGotCritted = turns[j]["Turn"][k]["Crit"]["PokemonNickname"]
						tupVec.append((playerWhoGotCritted,nickPokeThatGotCritted,lastMove["AttackingPlayer"],lastMove["AttackingPokemonNickname"],lastMove["Attack"],False,j))
				if "Faint" in turns[j]["Turn"][k]:
					if playerWhoGotCritted is not None and nickPokeThatGotCritted is not None:
						f = turns[j]["Turn"][k]["Faint"]
						if len(lastMove) > 0 and "AttackedPlayer" in lastMove and "AttackedPokemonNickname" in lastMove:
							if lastMove["AttackedPlayer"] == f["FaintedPokemonPlayer"] and lastMove["AttackedPokemonNickname"] == f["FaintedPokemonNickname"]: #Por si hubo otro turno distinto en el medio
								faint = (playerWhoGotCritted == f["FaintedPokemonPlayer"] and nickPokeThatGotCritted == f["FaintedPokemonNickname"])
								try:
									tupVec.remove((playerWhoGotCritted,nickPokeThatGotCritted,lastMove["AttackingPlayer"],lastMove["AttackingPokemonNickname"],lastMove["Attack"],False,j)) #Limpiamos el insertado en el if de Crit
								except:
									pass
								tupVec.append((playerWhoGotCritted,nickPokeThatGotCritted,lastMove["AttackingPlayer"],lastMove["AttackingPokemonNickname"],lastMove["Attack"],faint,j))
								playerWhoGotCritted = None
								nickPokeThatGotCritted = None
								lastMove = {} #Lo reseteamos porque el movimiento ya surtió su efecto
								continue
								
		for i in range(len(tupVec)):
			playerGotCrit,nickPokeGotCrit,playerCrit,nickPokeCrit,move,faint,turn = tupVec[i]
			dictCrit["Player"].append(playerCrit)
			dictCrit["Pokemon Nickname"].append(nickPokeCrit)
			dictCrit["Player hit by a Critical"].append(playerGotCrit)
			dictCrit["Pokemon Nickname hit by a Critical"].append(nickPokeGotCrit)
			dictCrit["Move that was a Critical"].append(move)
			dictCrit["Did the Pokemon Faint from the critical?"].append(faint)
			dictCrit["Turn"].append(turn)
			
		result = df(dictCrit,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
		
	#	Pokemon		Pokemon Nickname	Player		Battle ID	HP Change/Max HP (+% heal/-%damage)		Pokemon Source	Player Source	Other Source	Other Source Type (item,ability)	Turn
	#0
	#1
	#2
	#...
	def analyzeBattleHPChange(self):
		columnsVec = ["Player","Pokemon Nickname","HP","Max HP","% HP Changed","Pokemon Source","Player Source","Other Source","Other Source Type","Turn"]
		tupVec = []
			
		pokes = self.analyzeBattlePokes()
		
		types = ["Damage","Heal"]
		typesOfFrom = ["DamageFrom","DamageOf","HealFrom","HealOf"]
		
		turns = self.data["Battle"]["Turns"]
		keys = ["Player","PokemonNickname","PokemonHP","PokemonMaxHP","PokemonSource","PlayerSource","Source","SourceType"]
		for j in range(len(turns)):
			lastMove = {} #Lo reseteamos para que no se utilice entre turnos distintos
			for k in range(len(turns[j]["Turn"])):
				if "Move" in turns[j]["Turn"][k]:
					if "AttackingPokemonNickname" in turns[j]["Turn"][k]["Move"] and "AttackingPlayer" in turns[j]["Turn"][k]["Move"] and "Attack" in turns[j]["Turn"][k]["Move"]:
						lastMove = turns[j]["Turn"][k]["Move"]
				for y in range(len(types)):
					if types[y] in turns[j]["Turn"][k]:
						d = turns[j]["Turn"][k][types[y]]
						pkmnSource = None
						playerSource = None
						source = None
						otherSourceType = None
						if len(lastMove) > 0:
							pkmnSource = lastMove["AttackingPokemonNickname"]
							playerSource = lastMove["AttackingPlayer"]
							source = lastMove["Attack"]
							otherSourceType = "Move"
						tupVec.append([d["Player"],d["PokemonNickname"],d["PokemonHP"],d["PokemonMaxHP"],pkmnSource,playerSource,source,otherSourceType,j])
						lastMove = {}
				for w in range(len(typesOfFrom)):
					if typesOfFrom[w] in turns[j]["Turn"][k]:
						d = turns[j]["Turn"][k][typesOfFrom[w]]
						t = [d[x] if x in d else None for x in keys]
						t = [*t,j]
						tupVec.append(t)
		
		tupVec.sort(key=itemgetter(1,8)) #Ordenamos primero por pokemon y luego por turno
		
		name = None
		lasthp = None
		maxhp = None
		for i in range(len(tupVec)): #Hay que añadir la columna del cambio de daño en porcentaje a partir de HP y MaxHP
			if name is not None and name in tupVec[i][1]:
				diff = tupVec[i][2]-lasthp
				percentile = (diff/maxhp) #Si diff es positivo es que fue una curación
				lasthp = tupVec[i][2]
				tupVec[i].insert(4,percentile)
			else: #Nuevo o primer Pokemon
				if isinstance(tupVec[i][3],str) and "fnt" in tupVec[i][3]: #Caso de debilitado el único turno que recibió daño
					tupVec[i].insert(4,-1.0) # -1 -> -100%
				else: #Caso general de nuevo Pokemon con daño (el primer caso nunca puede ser curación)
					lasthp = tupVec[i][2]
					maxhp = tupVec[i][3]
					name = tupVec[i][1]
					percentile = (lasthp-maxhp)/maxhp
					tupVec[i].insert(4,percentile)
		
		result = df(tupVec,columns=columnsVec)
		
		return merge(pokes,result,how="right",on=["Pokemon Nickname","Player"],sort=False)
		
	
	def __movePowerData(self,move,dictPower,moveTranslator,j):
		if move is None:
			dictPower[moveTranslator[j]].append(None)
			return dictPower
		powerMove = move.power
		if powerMove is not None and powerMove is not 0:
			dictPower[moveTranslator[j]].append(powerMove)
		else:
			dictPower[moveTranslator[j]].append(None)
		return dictPower
	def __moveCoverageData(self,move,dictCoverage,moveTranslator,j,l,types):
		if move is None:
			dictCoverage[moveTranslator[j]].append(None)
			return dictCoverage
		typeMove = move.type.name.lower()
		row = types[types.Pokemon == l["Pokemon"]]
		if row.size > 0: #Si es 0 es que row es una Serie vacía debido a un Pokemon que no se pudo encontrar por la API
			typePokemon1 = row["Type 1"].iloc[0]
			typePokemon2 = row["Type 2"].iloc[0]
			if typePokemon1 is not None and typePokemon1.lower() not in typeMove: #Vemos que no coincida el primer tipo
				if typePokemon2 is None or typePokemon2.lower() not in typeMove: #Vemos que no coincida el segundo tipo, si es None ya cumplimos la premisa
					dictCoverage[moveTranslator[j]].append(typeMove)
					return dictCoverage
					
		dictCoverage[moveTranslator[j]].append(None)
		return dictCoverage
		
	def __moveDataBroker(self,columnsVec,func,moveTranslator,moves,types=None):
		dictMoveData = {}
		for i in range(len(columnsVec)):
			dictMoveData[columnsVec[i]] = []
			
		l = moves.loc
		
		for i in range(len(moves)):
			dictMoveData["Pokemon"].append(l[i]["Pokemon"])
			dictMoveData["Player"].append(l[i]["Player"])
			for j in moveTranslator:
				if l[i][j] is not None:
					name = l[i][j].lower()
					name = name.replace(" ","-") #La api usa - para representar espacios
					try:
						move = pbmove(name)
					except ValueError:
						print("The provided move name ('",name,"') couldn't be found")
						move = None
					except Exception as e:
						print("Error trying to get data from the API about a move with name '",name,"'")
						print(e)
						move = None
					if move is None or 'status' not in move.damage_class.name.lower(): #Ataques de status no se cuentan como Coverage ni Power
						if "coverage" in func.__name__.lower():
							dictMoveData = func(move,dictMoveData,moveTranslator,j,l[i],types)
						else:
							dictMoveData = func(move,dictMoveData,moveTranslator,j)
						continue
				dictMoveData[moveTranslator[j]].append(None)
				
		result = df(dictMoveData,columns=columnsVec)
		
		return result
	
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Pokemon Type	Coverage Type 1		Coverage Type 2 ...
	#0
	#1
	#2
	#...	
	def analyzeBattleMoveCoverage(self):
		columnsVec = ["Player","Pokemon","Coverage Type 1","Coverage Type 2","Coverage Type 3","Coverage Type 4"]
		moveTranslator = {
						"Move 1" : "Coverage Type 1",
						"Move 2" : "Coverage Type 2",
						"Move 3" : "Coverage Type 3",
						"Move 4" : "Coverage Type 4",
						}
		moves = self.analyzeBattleMoveUsage()
		types = self.analyzeBattlePokemonAPITypeData()
		
		result = self.__moveDataBroker(columnsVec,self.__moveCoverageData,moveTranslator,moves,types=types)
		
		return merge(types,result,how="left",on=["Pokemon","Player"],sort=False)
		
	#	Pokemon		Pokemon Nickname	Player		Battle ID	Power Move 1	Power Move 2	...
	#0
	#1
	#2
	#...
	def analyzeBattleMovePower(self):
		columnsVec = ["Player","Pokemon","Power Move 1","Power Move 2","Power Move 3","Power Move 4"]
		moveTranslator = {
						"Move 1" : "Power Move 1",
						"Move 2" : "Power Move 2",
						"Move 3" : "Power Move 3",
						"Move 4" : "Power Move 4",
						}
		moves = self.analyzeBattleMoveUsage()
		
		result = self.__moveDataBroker(columnsVec,self.__movePowerData,moveTranslator,moves)
		
		return merge(moves,result,how="left",on=["Pokemon","Player"],sort=False)
		
	#	Battle ID	Player	Switching Pokemon	Turn
	#0
	#1
	#2
	#...
	def analyzeBattleSwitches(self):
		columnsVec = ["Battle ID","Player","Switched Pokemon","Turn"]
		dictSwitch = {}
		for i in range(len(columnsVec)):
			dictSwitch[columnsVec[i]] = []
		
		turns = self.data["Battle"]["Turns"]
		for j in range(len(turns)):
			for k in range(len(turns[j]["Turn"])):
				if "Switch" in turns[j]["Turn"][k]:
					s = turns[j]["Turn"][k]["Switch"]
					dictSwitch["Battle ID"].append(self.battle)
					dictSwitch["Player"].append(s["SwitchingPlayer"])
					dictSwitch["Switched Pokemon"].append(s["SwitchedPokemon"])
					dictSwitch["Turn"].append(j)
		
		return df(dictSwitch,columns=columnsVec)
	
	def __moveAPIPowerData(self,move):
		return move.power
		
	def __moveAPIAccuracyData(self,move):
		accuracy = move.accuracy
		if accuracy is not None:
			accuracy = accuracy / 100
		return accuracy
		
	def __moveAPICategoryData(self,move):
		return move.damage_class.name

	def __moveAPITypeData(self,move):
		return move.type.name
		
	def __moveAPIDataBroker(self,columnsVec,func):
		moves = self.analyzeBattleMoveUsage()
		loc = moves.loc[:,"Move 1":"Move 4"]
		dictMoveData = {}
		for i in range(len(columnsVec)):
			dictMoveData[columnsVec[i]] = []
		doneMoves = []
		tupVec = []

		for j in loc:
			listMoves = loc[j].values.tolist()
			for k in listMoves:
				if k is not None and k not in doneMoves:
					doneMoves.append(k)
					name = k.lower()
					name = name.replace(" ","-") #La api usa - para representar espacios
					try:
						move = pbmove(name)
					except ValueError:
						print("The provided move name ('",name,"') couldn't be found")
						continue
					except Exception as e:
						print("Error trying to get data from the API about a move with name '",name,"'")
						print(e)
						continue
					
					try:
						data = func(move)
					except Exception as e:
						print("Error trying to get data from the API about a move with name '",name,"'")
						print(e)
						continue
			
					tupVec.append((k,data))
		
		return df(tupVec,columns=columnsVec)
		
	def __moveData(self):
		columnsVec = ["Battle ID","Player","Pokemon","Move"]
		moves = self.analyzeBattleMoveUsage()
		dictMoveData = {}
		
		for i in range(len(columnsVec)):
			dictMoveData[columnsVec[i]] = []
		loc = moves.loc
		locMoves = moves.loc[:,"Move 1":"Move 4"]
		
		for j in range(len(moves)):
			row = loc[j]
			for k in locMoves:
				if row[k] is not None:
					dictMoveData["Move"].append(row[k])
					dictMoveData["Battle ID"].append(self.battle)
					dictMoveData["Player"].append(row["Player"])
					dictMoveData["Pokemon"].append(row["Pokemon"])
					
		return df(dictMoveData,columns=columnsVec)
		
	#	Battle ID	Player	Pokemon		Move	Power
	#0
	#1
	#2
	#...
		
	def analyzeBattleMoveAPIPower(self):
		columnsVec = ["Move","Power"]
		moves = self.__moveData()
		power = self.__moveAPIDataBroker(columnsVec,self.__moveAPIPowerData)
		
		return merge(moves,power,how="left",on=["Move"],sort=False)
	
	#	Battle ID	Player	Pokemon		Move	Accuracy (%)
	#0
	#1
	#2
	#...
	
	def analyzeBattleMoveAPIAccuracy(self):
		columnsVec = ["Move","Accuracy (%)"]
		moves = self.__moveData()
		accuracy = self.__moveAPIDataBroker(columnsVec,self.__moveAPIAccuracyData)
		
		return merge(moves,accuracy,how="left",on=["Move"],sort=False)
	
	#	Battle ID	Player	Pokemon		Move	Category
	#0
	#1
	#2
	#...
	
	def analyzeBattleMoveAPICategory(self):
		columnsVec = ["Move","Category"]
		moves = self.__moveData()
		category = self.__moveAPIDataBroker(columnsVec,self.__moveAPICategoryData)
		
		return merge(moves,category,how="left",on=["Move"],sort=False)
	
	#	Battle ID	Player	Pokemon		Move	Type
	#0
	#1
	#2
	#...
	
	def analyzeBattleMoveAPIType(self):
		columnsVec = ["Move","Type"]
		moves = self.__moveData()
		typedf = self.__moveAPIDataBroker(columnsVec,self.__moveAPITypeData)
		
		return merge(moves,typedf,how="left",on=["Move"],sort=False)