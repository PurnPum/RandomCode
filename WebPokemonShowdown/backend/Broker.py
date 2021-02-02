__author__  = "Ricardo Pérez Pardo"
__name__    = "Broker"

from .dataExtraction import FindBattles
from .dataExtraction import GenerateJsonFromReplay
from .analysis import MultiBattleAnalyzer

class Broker:
	
	FB = FindBattles.FindBattles()
	GEN = None
	MBA = None
	playerName = str
	formatName = str
	earlierThan = None
	laterThan = None
	battles = []
	funcList = []
	
	def __init__(self,playerName,formatName,funcList,earlierThan=None,laterThan=None):
		self.playerName = playerName
		self.formatName = formatName
		self.funcList = funcList
		self.earlierThan = earlierThan
		self.laterThan = laterThan
		self.GEN = GenerateJsonFromReplay.generateJsonFromReplay(self.earlierThan,self.laterThan)
		
	def executePlayerFormat(self):
		self.battles = self.FB.findBoth(self.playerName,self.formatName)
		return self.execute()
	
	def executePlayer(self):
		self.battles = self.FB.findPlayer(self.playerName)
		return self.execute()
		
	def executeFormat(self):
		self.battles = self.FB.findFormat(self.formatName)
		return self.execute()
	
	def execute(self):
		dictsList = []
		for i in range(len(self.battles)):
			url = "https://replay.pokemonshowdown.com" + self.battles[i] + ".json"
			try:
				dictsList.append(self.GEN.generateJsonFromUrl(url))
			except EnvironmentError:
				break #El resto ya no podrán cumplir la premisa debido a que están ordenadas
			except ValueError:
				continue
		#TODO : Generar Jsons para almacenar en la BD (TODO : Hacer la BD)
		if dictsList == []: #Ninguna batalla cumplió las condiciones de tiempo
			return dictsList
		dataFrameList = []
		self.MBA = MultiBattleAnalyzer.MultiBattleAnalyzer(dictsList,self.playerName,self.formatName)
		funcTranslator = {
					"analyzeResults" : self.MBA.analyzeResults,
					"analyzeResultsForfeits" : self.MBA.analyzeResultsForfeits,
					"analyzeForfeitRatios" : self.MBA.analyzeForfeitRatios,
					"analyzePerfectResults" : self.MBA.analyzePerfectResults,
					"analyzeFaintAverage" : self.MBA.analyzeFaintAverage,
					"analyzeELO" : self.MBA.analyzeELO,
					"analyzeMaxTurns" : self.MBA.analyzeMaxTurns,
					"analyzeSweeps" : self.MBA.analyzeSweeps,
					"analyzePokemonUsage" : self.MBA.analyzePokemonUsage,
					"analyzeItemUsage" : self.MBA.analyzeItemUsage,
					"analyzePartner" : self.MBA.analyzePartner,
					"analyzeTypings" : self.MBA.analyzeTypings,
					"analyzeStats" : self.MBA.analyzeStats,
					"analyzeSizes" : self.MBA.analyzeSizes,
					"analyzeMovesByPokemon" : self.MBA.analyzeMovesByPokemon,
					"analyzeEffectivenessByPokemon" : self.MBA.analyzeEffectivenessByPokemon,
					"analyzeFailsByPokemon" : self.MBA.analyzeFailsByPokemon,
					"analyzeFaintsByPokemon" : self.MBA.analyzeFaintsByPokemon,
					"analyzeStatusByPokemon" : self.MBA.analyzeStatusByPokemon,
					"analyzeCantMoveByPokemon" : self.MBA.analyzeCantMoveByPokemon,
					"analyzeVictimsByPokemon" : self.MBA.analyzeVictimsByPokemon,
					"analyzeCriticalsByPokemon" : self.MBA.analyzeCriticalsByPokemon,
					"analyzeDamageByPokemon" : self.MBA.analyzeDamageByPokemon,
					"analyzeCoverageOfPokemon" : self.MBA.analyzeCoverageOfPokemon,
					"analyzeTurnAverage" : self.MBA.analyzeTurnAverage,
					"analyzeTurnAverageUntilFirstVictim" : self.MBA.analyzeTurnAverageUntilFirstVictim,
					"analyzeVictimsByMove" : self.MBA.analyzeVictimsByMove,
					"analyzeMissesByMove" : self.MBA.analyzeMissesByMove,
					"analyzeBattlesByFormat" : self.MBA.analyzeBattlesByFormat,
					"analyzeELOByFormat" : self.MBA.analyzeELOByFormat,
					}
					
		for f in range(len(self.funcList)):
			dataFrameList.append(funcTranslator[self.funcList[f]]())
		return dataFrameList