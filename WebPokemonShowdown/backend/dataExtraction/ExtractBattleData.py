__author__     = "Ricardo Pérez Pardo"
__name__    = "ExtractBattleData"
__package__ = "dataExtraction"

from requests import get

class ExtractBattleData:
	
	def extractDate(self,json_file):
		return (json_file['uploadtime']) # Formato Epoch
			
	def extractMeanRating(self,json_file):
		return (json_file['rating'])
		
	def extractPlayerNames(self,json_file):
		return (json_file['p1'],json_file['p2'])
	
	def extractPlayerIDs(self,json_file):
		return (json_file['p1id'],json_file['p2id'])
		
	def extractFormat(self,json_file):
		return (json_file['format'])
	
	def extractViews(self,json_file):
		return (json_file['views'])
		
	def extractLog(self,json_file):
		return (json_file['log'])
	
	def splitLog(self,log):
		JoinTable = []
		PlayerAvatarRatingTable = []
		TeamSizeTable = []
		GameTypeTable = []
		GenTable = []
		TierTable = []
		RatedTable = []
		PokeTable = []
		RuleTable = []
		TeamPreviewTable = []
		InactiveTable = []
		RawTable = []
		WinTable = []
		LeaveTable = []
		ChatTable = []
		MessageTable = []
		TurnTable = []
				
		keyWords = { 
					0 : "|j|",
					1 : "|join|", #Formato antiguo
					2 : "|player|",
					3 : "|teamsize|",
					4 : "|gametype|",
					5 : "|gen|",
					6 : "|tier|",
					7 : "|rated",
					8 : "|poke|",
					9 : "|rule|",
					10 : "|teampreview",
					11 : "|inactive|",
					12 : "|raw|",
					13 : "|win|",
					14 : "|c|",
					15 : "|-message|",
		}
		splitter = { 
					0 : JoinTable,
					1 : JoinTable,
					2 : PlayerAvatarRatingTable,
					3 : TeamSizeTable,
					4 : GameTypeTable,
					5 : GenTable,
					6 : TierTable,
					7 : RatedTable,
					8 : PokeTable,
					9 : RuleTable,
					10 : TeamPreviewTable,
					11 : InactiveTable,
					12 : RawTable,
					13 : WinTable,
					14 : ChatTable,
					15 : MessageTable,
		}
		splitlog = log.split("\n")
		
		if ("\n|start" in log and ("\n|win" in log or "\n|tie " in log or "\n|tie|" in log)):
			log2 = log.split("\n|start")
			log3 = log2[1].split("\n|win")
			if log3[0] == log2[1]:
				log3 = log2[1].split("\n|tie") #MUY raras veces en partidas antiguas puede haber empate por decisión de los jugardoes
			if "\n|turn|" in log3[0]:
				TurnTable = log3[0].split("\n|turn|")
				for l in range(len(TurnTable)):
					TurnTable[l] = TurnTable[l].split("\n")
				splitlog = log2[0].split("\n")
				splitlog.extend(("|win" + log3[1]).split("\n"))
		
		for i in range(len(splitlog)): #Extraemos toda la info a excepción de la info dentro de turnos (excepto joins y chat) que va aglomerada
			for k in range(len(keyWords)):
				if splitlog[i].lower().startswith(keyWords[k].lower()):
					if not (keyWords[k].startswith("|rated")) and not (keyWords[k].startswith("|teampreview")):
						splitter[k].append(splitlog[i].split(keyWords[k])[1])
					else: #Eliminamos la parte entre | | porque ya es innecesaria excepto con rated y teampreview.
						splitter[k].append(splitlog[i])
					break
				
		Tables = [JoinTable,PlayerAvatarRatingTable,TeamSizeTable,GameTypeTable,GenTable,TierTable,RatedTable,PokeTable,
		RuleTable,TeamPreviewTable,InactiveTable,RawTable,WinTable,ChatTable,MessageTable,TurnTable]
		
		Tables = { 
				"Joins" : JoinTable,
				"AvatarsRatings" : PlayerAvatarRatingTable,
				"TeamSizes" : TeamSizeTable,
				"GameType" : GameTypeTable,
				"Gen" : GenTable,
				"Tier" : TierTable,
				"Rated?" : RatedTable,
				"Pokes" : PokeTable,
				"Rules" : RuleTable,
				"TeamPreview?" : TeamPreviewTable,
				"Inactive" : InactiveTable,
				"RawMsgs" : RawTable,
				"Winner" : WinTable,
				"Chat" : ChatTable,
				"Message" : MessageTable,
				"Turns" : TurnTable,
		}
		
		return Tables
		
	def extractAll(self,url,earlierThan=None,laterThan=None):

		Tables = { 
				"UploadTime" : [],
				"MeanRating" : [],
				"PlayerNames" : [],
				"PlayerIDs" : [],
				"Format" : [],
				"Joins" : [],
				"AvatarsRatings" : [],
				"TeamSizes" : [],
				"GameType" : [],
				"Gen" : [],
				"Tier" : [],
				"Rated?" : [],
				"Pokes" : [],
				"Rules" : [],
				"TeamPreview?" : [],
				"Inactive" : [],
				"RawMsgs" : [],
				"Winner" : [],
				"Chat" : [],
				"Views" : [],
				"Message" : [],
				"Turns" : [],
		}
		response = get(url)
		json_file = response.json()
		Tables["UploadTime"] = self.extractDate(json_file)
		if earlierThan is not None:
			if laterThan is not None:
				if Tables["UploadTime"] > earlierThan:
					raise ValueError("Battle upload time (",Tables["UploadTime"],") outside of time segment (",earlierThan,"-",laterThan,")")
				if Tables["UploadTime"] < laterThan:
					raise EnvironmentError("Battle upload time (",Tables["UploadTime"],") outside of time segment (",earlierThan,"-",laterThan,")")
			else:
				if Tables["UploadTime"] > earlierThan:
					raise ValueError("Battle upload time (",Tables["UploadTime"],") outside of time segment (",earlierThan,"- Now)")
		else:
			if laterThan is not None:
				if Tables["UploadTime"] < laterThan:
					raise EnvironmentError("Battle upload time (",Tables["UploadTime"],") outside of time segment (Now - ,",laterThan,")")
					
		Tables["MeanRating"] = self.extractMeanRating(json_file)
		Tables["PlayerNames"] = self.extractPlayerNames(json_file)
		Tables["PlayerIDs"] = self.extractPlayerIDs(json_file)
		Tables["Format"] = self.extractFormat(json_file)
		Tables["Views"] = self.extractViews(json_file)
		
		LogTables = self.splitLog(json_file["log"])
		
		for u in LogTables.keys():
			Tables[u]=LogTables[u] #Rellenamos la tabla global con la que nos devolvió el divisor del log
			
		return Tables