__author__  = "Ricardo Pérez Pardo"
__name__    = "generateJsonFromReplay"
__package__ = "dataExtraction"

from json import dump
from backendSourceCode_PracticaPI.dataExtraction import Parser
from backendSourceCode_PracticaPI.dataExtraction import ExtractBattleData

class generateJsonFromReplay:

	P = Parser.Parser()
	EBD = ExtractBattleData.ExtractBattleData()
	earlierThan=None
	laterThan=None
	
	TablesFuncs = { 
				"Joins" : P.parseJoinData,
				"AvatarsRatings" : P.parsePlayerData,
				"TeamSizes" : P.parseTeamSizesData,
				"GameType" : P.parseGametypeData,
				"Gen" : P.parseGenData,
				"Tier" : P.parseTierData,
				"Rated?" : P.parseRatedData,
				"Pokes" : P.parsePokeData,
				"Rules" : P.parseRuleData,
				"TeamPreview?" : P.parseTeampreviewData,
				"Inactive" : P.parseInactiveData,
				"RawMsgs" : P.parseRawData,
				"Winner" : P.parseWinnerData,
				"Chat" : P.parseChatData,
				"Message" : P.parseMessageData,
				"Turns" : P.parseTurnData,
		}
	
	def __init__(self,earlierThan=None,laterThan=None):
		self.earlierThan = earlierThan
		self.laterThan = laterThan
	
	def generateJson(self,dictTable):
		for u in dictTable.keys():
			if u in self.TablesFuncs.keys():
				for i in range(len(dictTable[u])):
					dictTable[u][i] = self.TablesFuncs[u](dictTable[u][i])
			
		return dictTable
		
	def generateJsonFromUrl(self,url):
		name = url.split("https://replay.pokemonshowdown.com/")[1]
		name = name.split(".json")[0]
		table = self.EBD.extractAll(url,self.earlierThan,self.laterThan)
		
		return self.generateJsonFromTable(table,name)
		
	def generateJsonFromTable(self,table,name):
		
		dictTable = {}
		dictTable["Battle ID"] = name
		dictTable["Battle"] = table
		
		dictTable["Battle"] = self.generateJson(dictTable["Battle"])
		
		if not name.endswith(".json"):
			name = name + ".json"
		
		#TODO:
		#with open(name,'w',encoding="utf-8") as jsonF:
		#	dump(dictTable,jsonF,ensure_ascii=False,indent=4)
			
		return dictTable