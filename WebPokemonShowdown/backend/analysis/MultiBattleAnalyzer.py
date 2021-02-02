__author__  = "Ricardo Pérez Pardo"
__name__    = "MultiBattleAnalyzer"
__package__ = "analysis"

#TODO : Limpiar, optimizar y hacer este código mucho más eficiente. Probablemente no pueda hacerlo antes de la entrega.

from pandas import merge
from pandas import DataFrame as df
from pandas import Series as ser
from numpy import add as npadd
from collections import Counter
from backendSourceCode_PracticaPI.analysis import SingleBattleAnalyzer as SBA

class MultiBattleAnalyzer:
	
	battles = []
	playerName = str
	formatName = str
	
	def __init__(self,battles,playerName=None,formatName=None):
		self.battles = battles
		self.playerName = playerName
		self.formatName = formatName
	
	#  Format	Wins	Defeats		Total Matches	Win Rate (%)
	#0
	#1
	#...
	
	def analyzeResults(self): #Aquí y en todos los métodos de resultados solo analizamos si el jugador no es None
		resultDict = df()
		if self.playerName is not None:
			seriesVictories = df()
			seriesFormats = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			
			mergedData = merge(seriesFormats,seriesVictories,how="left",on=["Battle ID"],sort=False)
			indexVec = ["Format","Wins","Defeats","Total Matches","Win Rate (%)"]
			
			for name,group in mergedData.groupby("Fancy"):
				wins = group[group["Winner"] == self.playerName].shape[0]
				matches = len(group)
				defeats = matches-wins
				winrate = wins/matches * 100
				resultDict = resultDict.append(ser([name,wins,defeats,matches,winrate],index=indexVec),ignore_index=True)
			
			keysTranslator = {
				0 : "Defeats",
				1 : "Total Matches",
				2 : "Wins",
			}
			for i in range(len(keysTranslator)):
				if keysTranslator[i] in resultDict:
					resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype(int)
			if "Win Rate (%)" in resultDict:
				resultDict = resultDict.round({"Win Rate (%)":2})
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Win Rate (%)" in resultDict:
					resultDict = resultDict.sort_values(by=["Win Rate (%)"],ascending=False)
			
		return resultDict
	
	#  Format	Forfeit Wins (%)	Forfeit Defeats (%)		Disconnect Wins (%)		Disconnect Defeats (%)	Timeout Wins (%)	Timeout Defeats (%)	
	#0
	#1
	#...
	
	def analyzeResultsForfeits(self):
		resultDict = df()
		if self.playerName is not None:
			seriesVictories = df()
			seriesFormats = df()
			seriesForfeits = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				seriesForfeits = seriesForfeits.append(tempSBA.analyzeBattleForfeitDisconnect(),ignore_index=True)
			
			mergedData = merge(seriesFormats,seriesVictories,how="left",on=["Battle ID"],sort=False)
			mergedData = merge(mergedData,seriesForfeits,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Normal Wins (%)","Normal Defeats (%)","Forfeit Wins (%)","Forfeit Defeats (%)","Disconnect Wins (%)","Disconnect Defeats (%)","Timeout Wins (%)","Timeout Defeats (%)"]
			
			for name,group in mergedData.groupby("Fancy"):
				wins = group[group["Winner"] == self.playerName]
				loses = group[group["Winner"] != self.playerName]
				v = ["Normal","Forfeit","Disconnect","Timeout"]
				
				l = []
				l.append(name)
				for i in v:
					vWins = wins[i].sum()
					vLoses = loses[i].sum()
					if int(vLoses + vWins) == 0:
						l.append(0.0)
						l.append(0.0)
					else:
						l.append(vWins / (vLoses+vWins) * 100)
						l.append(100 - (vWins / (vLoses+vWins)) * 100)
				
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)

			resultDict = resultDict.round(2)
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Normal Wins (%)" in resultDict:
					resultDict = resultDict.sort_values(by=["Normal Wins (%)"],ascending=False)
			
		return resultDict
		
	#  Format	Direct Forfeits (%)		Disconnects (%)		Timeouts (%)	
	#0
	#1
	#...
		
	def analyzeForfeitRatios(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			seriesForfeits = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				seriesForfeits = seriesForfeits.append(tempSBA.analyzeBattleForfeitDisconnect(),ignore_index=True)
			
			mergedData = merge(seriesFormats,seriesForfeits,how="left",on=["Battle ID"],sort=False)
			mergedData = mergedData[mergedData["Normal"] != 1.0] #No queremos las que acabaron normal
			
			indexVec = ["Format","Direct Forfeits (%)","Disconnects (%)","Timeouts (%)"]
			
			for name,group in mergedData.groupby("Fancy"):
				v = ["Disconnect","Timeout"]
				
				l = []
				l.append(name)
				for i in v:
					vGroup = group[i].sum()
					if int(vGroup) == 0:
						l.append(0.0)
					else:
						l.append(vGroup / (len(group)) * 100)
				l.insert(1,(1-(group["Timeout"].sum() / len(group)))*100) #Forfeits sin Timeouts
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)

			resultDict = resultDict.round(2)
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Direct Forfeits (%)" in resultDict:
					resultDict = resultDict.sort_values(by=["Direct Forfeits (%)"],ascending=False)
		return resultDict
		
	#  Format	Perfect Wins	Perfect Defeats		Total Matches
	#0
	#1
	#...
		
	def analyzePerfectResults(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			dataFramesVictims = df()
			dataFramesPlayers = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
				dataFramesVictims = dataFramesVictims.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
			
			mergedData = merge(dataFramesVictims,seriesFormats,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Perfect Wins","Perfect Defeats","Total Matches"]
			
			for name,group in mergedData.groupby("Fancy"):
				perfWins = 0
				perfDefeats = 0
				for name2,group2 in group.groupby("Battle ID"):
					if group2["Victim Player"].nunique() == 1: #Si es 1 es que es victoria o derrota perfecta ya que solo 1 jugador perdió pokemon
						num = int(group2["Victim Player"].values[0])
						row = dataFramesPlayers[dataFramesPlayers["Battle ID"] == group2["Battle ID"].values[0]]
						names = row[row["Player Number"] == num]
						if self.playerName in names["Player Name"].values[0]:
							perfDefeats = perfDefeats + 1
						else:
							perfWins = perfWins + 1
							
				resultDict = resultDict.append(ser([name,perfWins,perfDefeats,group["Battle ID"].nunique()],index=indexVec),ignore_index=True)

			keysTranslator = {
				0 : "Perfect Wins",
				1 : "Perfect Defeats",
				2 : "Total Matches",
			}
			for i in range(len(keysTranslator)):
				if keysTranslator[i] in resultDict:
					resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype(int)
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Total Matches" in resultDict:
					resultDict = resultDict.sort_values(by=["Total Matches"],ascending=False)
		return resultDict
	
	#  Format	Own Pokemon fainted per Victory (Avg)	Opposite Pokemon fainted per Defeat (Avg)
	#0
	#1
	#...
	
	def analyzeFaintAverage(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			dataFramesVictims = df()
			dataFramesPlayers = df()
			seriesVictories = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
				dataFramesVictims = dataFramesVictims.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
				
			mergedData = merge(dataFramesVictims,seriesFormats,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Own Pokemon fainted per Victory (Avg)","Opposite Pokemon fainted per Defeat (Avg)"]
			
			for name,group in mergedData.groupby("Fancy"):
				faintedOwn = 0
				faintedOpp = 0
				for name2,group2 in group.groupby("Battle ID"):
					winner = seriesVictories[seriesVictories["Battle ID"] == group2["Battle ID"].values[0]]
					victims1 = group2[group2["Victim Player"] == 1.0].shape[0]
					victims2 = group2["Victim Player"].shape[0] - victims1
					tempPlayers = dataFramesPlayers[dataFramesPlayers["Battle ID"] == group2["Battle ID"].values[0]]
					winner = tempPlayers[tempPlayers["Player Name"] == winner["Winner"].values[0]]
					if self.playerName in winner["Player Name"].values:
						if int(winner["Player Number"].values[0]) == 1:
							faintedOwn = faintedOwn + victims1
						else:
							faintedOwn = faintedOwn + victims2
					else:
						if int(winner["Player Number"].values[0]) == 1:
							faintedOpp = faintedOpp + victims1
						else:
							faintedOpp = faintedOpp + victims2
				totBattles = group["Battle ID"].nunique()
				avgFaintedOwn = faintedOwn/totBattles
				avgFaintedOpp = faintedOpp/totBattles
				
				resultDict = resultDict.append(ser([name,avgFaintedOwn,avgFaintedOpp],index=indexVec),ignore_index=True)
			
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Own Pokemon fainted per Victory (Avg)" in resultDict:
					resultDict = resultDict.sort_values(by=["Own Pokemon fainted per Victory (Avg)"],ascending=False)
			
		return resultDict
		
	#  Format	Highest Elo Disparity (Victory)		Highest Elo Disparity (Defeat)	Highest Elo Average (Victory)	Highest Elo Average (Defeat)	Highest Elo Gain (Victory)	Highest Elo Loss (Defeat)
	#0
	#1
	#...
		
	def analyzeELO(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			dataFramesPlayers = df()
			seriesVictories = df()
			seriesELOAvg = df()
			seriesELOGain = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesELOAvg = seriesELOAvg.append(tempSBA.analyzeBattleELOAverage(),ignore_index=True)
				seriesELOGain = seriesELOGain.append(tempSBA.analyzeBattleELOGain(),ignore_index=True)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
				
			mergedData = merge(dataFramesPlayers,seriesFormats,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Highest Elo Disparity (Victory)","Highest Elo Disparity (Defeat)","Highest Elo Average (Victory)","Highest Elo Average (Defeat)","Highest Elo Gain (Victory)","Highest Elo Loss (Defeat)"]
					
			for name,group in mergedData.groupby("Fancy"):
				maxDispW = 0
				maxDispD = 0
				maxAvgW = 0
				maxAvgD = 0
				maxGainW = 0
				maxLossD = 0
				for name2,group2 in group.groupby("Battle ID"):
					disparity = int(group2["Player Rating"].max()) - int(group2["Player Rating"].min())
					winner = seriesVictories[seriesVictories["Battle ID"] == group2["Battle ID"].values[0]]
					tempPlayers = dataFramesPlayers[dataFramesPlayers["Battle ID"] == group2["Battle ID"].values[0]]
					winner = tempPlayers[tempPlayers["Player Name"] == winner["Winner"].values[0]]
					avg = seriesELOAvg[seriesELOAvg["Battle ID"] == group2["Battle ID"].values[0]]
					avg = int(avg["Average Rating"].values[0])
					gain = seriesELOGain[seriesELOGain["Battle ID"] == group2["Battle ID"].values[0]]
					gain = int(gain["ELO Gain"].values[0])
					if self.playerName in winner["Player Name"].values:
						if disparity >= maxDispW:
							maxDispW = disparity
						if avg >= maxAvgW:
							maxAvgW = avg
						if gain >= maxGainW:
							maxGainW = gain
					else:
						if disparity >= maxDispD:
							maxDispD = disparity
						if avg >= maxAvgD:
							maxAvgD = avg
						if gain >= maxLossD:
							maxLossD = gain
							
				resultDict = resultDict.append(ser([name,maxDispW,maxDispD,maxAvgW,maxAvgD,maxGainW,maxLossD],index=indexVec),ignore_index=True)
			
			keysTranslator = {
				0 : "Highest Elo Disparity (Victory)",
				1 : "Highest Elo Disparity (Defeat)",
				2 : "Highest Elo Average (Victory)",
				3 : "Highest Elo Average (Defeat)",
				4 : "Highest Elo Gain (Victory)",
				5 : "Highest Elo Loss (Defeat)",
			}
			for i in range(len(keysTranslator)):
				if keysTranslator[i] in resultDict:
					resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype(int)
			
			resultDict = resultDict.loc[(resultDict!=0).all(axis=1)]
			
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Highest Elo Disparity (Victory)" in resultDict:
					resultDict = resultDict.sort_values(by=["Highest Elo Disparity (Victory)"],ascending=False)
					
		return resultDict
		
	#  Format	Highest amount of turns (Victory)	Highest amount of turns (Defeat)
	#0
	#1
	#...
		
	def analyzeMaxTurns(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			seriesVictories = df()
			seriesTurns = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				seriesTurns = seriesTurns.append(tempSBA.analyzeBattleTurnsNeeded(),ignore_index=True)
				
			mergedData = merge(seriesTurns,seriesFormats,how="left",on=["Battle ID"],sort=False)
			
			mergedData = merge(mergedData,seriesVictories,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Highest amount of turns (Victory)","Highest amount of turns (Defeat)"]
			
			for name,group in mergedData.groupby("Fancy"):
				wins = group[group["Winner"] == self.playerName]
				defeats = group[group["Winner"] != self.playerName]
				maxTurnsW = wins["Turns"].max()
				maxTurnsD = defeats["Turns"].max()
				resultDict = resultDict.append(ser([name,maxTurnsW,maxTurnsD],index=indexVec),ignore_index=True)
			
			keysTranslator = {
				0 : "Highest amount of turns (Victory)",
				1 : "Highest amount of turns (Defeat)",
			}
			for i in range(len(keysTranslator)):
				if keysTranslator[i] in resultDict:
					resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype('Int16')
			
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Highest amount of turns (Victory)" in resultDict:
					resultDict = resultDict.sort_values(by=["Highest amount of turns (Victory)"],ascending=False)
					
		return resultDict
		
	#  Format	Pokemon		Sweeps (Victory)	Sweeps (Defeat)		Unstopped Sweeps (Victory)	Unstopped Sweeps (Defeat)
	#0
	#1
	#...
		
	def analyzeSweeps(self):
		resultDict = df()
		if self.playerName is not None:
			seriesFormats = df()
			dataFramesVictimsRow = df()
			seriesVictories = df()
			for i in self.battles:
				tempSBA = SBA.SingleBattleAnalyzer(i)
				seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
				dataFramesVictimsRow = dataFramesVictimsRow.append(tempSBA.analyzeBattleVictimsInARow(),ignore_index=True)
				seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
				
			mergedData = merge(dataFramesVictimsRow,seriesFormats,how="left",on=["Battle ID"],sort=False)
			
			indexVec = ["Format","Pokemon","Sweeps (Victory)","Sweeps (Defeat)","Unstopped Sweeps (Victory)","Unstopped Sweeps (Defeat)"]
				
			for name,group in mergedData.groupby("Fancy"):					
				dictPokes = {}
				for name2,group2 in group.groupby("Battle ID"):
					check = group2[group2["Victims"] == 6]
					if not check.empty: #Si algún Pokemon se cargó a 6 enemigos (solo puede haber 1 si lo hay)
						poke = check["Pokemon"].values[0]
						if 6 in check["Max Victims in a row"].values:
							unstop = 1
						else:
							unstop = 0
						win = self.playerName in seriesVictories[seriesVictories["Battle ID"] == check["Battle ID"].values[0]].values
						if poke in dictPokes:
							if win:
								dictPokes[poke] = tuple(npadd(dictPokes[poke],(1,0,unstop,0))) #Sumamos si se repiten casos
							else:
								dictPokes[poke] = tuple(npadd(dictPokes[poke],(0,1,0,unstop)))
						else:
							if win:
								dictPokes[poke] = (1,0,unstop,0)
							else:
								dictPokes[poke] = (0,1,0,unstop)
				for i in dictPokes:
					l = [name] + [i] + list(dictPokes[i])
					resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
					
			keysTranslator = {
				0 : "Sweeps (Victory)",
				1 : "Sweeps (Defeat)",
				2 : "Unstopped Sweeps (Victory)",
				3 : "Unstopped Sweeps (Defeat)",
			}
			for i in range(len(keysTranslator)):
				if keysTranslator[i] in resultDict:
					resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype('Int16')
			
			if len(resultDict)>0:
				resultDict = resultDict[indexVec]
				if "Format" in resultDict and "Pokemon" in resultDict:
					resultDict = resultDict.sort_values(by=["Format","Pokemon"],ascending=False)
			
		return resultDict

	#  Format	Pokemon		Usage (%)	Winrate (%)
	#0
	#1
	#...
		
	def analyzePokemonUsage(self): #Estas funciones sí que se harán tanto si es un jugador o muchos jugadores
		resultDict = df()
		dataFramesPlayers = df()
		seriesFormats = df()
		seriesVictories = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			seriesVictories = seriesVictories.append(tempSBA.analyzeBattleWinner(),ignore_index=True)
			
		mergedData = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)
		mergedData = merge(mergedData,seriesVictories,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Pokemon","Usage (%)","Winrate (%)"]
			
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			dictPokesWins = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,winner,numplayer in group2[["Pokemon","Winner","Player"]].values:
					if poke in dictPokes:
						dictPokes[poke] = dictPokes[poke] + 1
					else:
						dictPokes[poke] = 1
					if self.playerName is not None:
						if self.playerName in winner:
							if poke in dictPokesWins:
								dictPokesWins[poke] = dictPokesWins[poke] + 1
							else:
								dictPokesWins[poke] = 1
					else:
						row = dataFramesPlayers[dataFramesPlayers["Player Name"] == winner]
						numwin = row["Player Number"].values[0]
						if numwin == numplayer:
							if poke in dictPokesWins:
								dictPokesWins[poke] = dictPokesWins[poke] + 1
							else:
								dictPokesWins[poke] = 1
			totBattles = group["Battle ID"].nunique() #Cantidad de batallas por formato
			for i in dictPokes:
				mult = 100 # Estamos calculando la cantidad de veces que aparece el Pokemon por equipo, no por batalla, por eso 100%/2 = 50
				if self.playerName is None:
					mult = 50
				wins = 0
				if i in dictPokesWins:
					wins = dictPokesWins[i]
				l = [name] + [i] + [dictPokes[i]/totBattles*mult] + [wins / dictPokes[i] * mult]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		if "Winrate (%)" in resultDict:
			resultDict = resultDict.round({"Winrate (%)":2})
		if "Usage (%)" in resultDict:
			resultDict = resultDict.round({"Usage (%)":2})
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Usage (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Usage (%)"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Item	Usage (%)
	#0
	#1
	#...
		
	def analyzeItemUsage(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesItems = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesItems = dataFramesItems.append(tempSBA.analyzeBattleItemUsage(),ignore_index=True)
			
		mergedData = merge(dataFramesItems,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Pokemon","Item","Usage (%)"]
			
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,item in group2[["Pokemon","Item"]].values:
					if poke not in dictPokes:
						dictPokes[poke] = {}
					if item in dictPokes[poke]:
						dictPokes[poke][item] = dictPokes[poke][item] + 1
					else:
						dictPokes[poke][item] = 1
						
			for poke in dictPokes:
				totalUsages = sum(dictPokes[poke].values())
				for item in dictPokes[poke]:
					num = dictPokes[poke][item]
					l = [name] + [poke] + [item] + [num / totalUsages * 100]
					resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		if "Usage (%)" in resultDict:
			resultDict = resultDict.round({"Usage (%)":2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Usage (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Usage (%)"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Most common partner		Frecuency (%)
	#0
	#1
	#...
		
	def analyzePartner(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			
		mergedData = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Pokemon","Most common partner","Frecuency (%)"]
			
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for name3,group3 in group2.groupby("Player"): #Separamos los equipos en dos ya que comparamos pokemon del mismo equipo
					for poke in group3["Pokemon"].values:
						if poke not in dictPokes:
							dictPokes[poke] = []
						dictPokes[poke] = dictPokes[poke] + list(group3["Pokemon"].values)
			
			for poke in dictPokes:
				flatlist = dictPokes[poke]
				flatlist.remove(poke) # Eliminamos los casos de que el compañero y pokemon sean el mismo
				if len(flatlist) == 0:
					continue
				listCounter = Counter(flatlist)
				mostCommonPartner = max(flatlist, key=listCounter.get)
				timesSeen = listCounter[mostCommonPartner]
				l = [name] + [poke] + [mostCommonPartner] + [timesSeen/len(flatlist) * 100]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Frecuency (%)" in resultDict:
			resultDict = resultDict.round({"Frecuency (%)":2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Usage (%)" in resultDict and "Frecuency (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Usage (%)","Frecuency (%)"],ascending=False)
		
		return resultDict
	
	#  Format	Type	Frecuency (%)
	#0
	#1
	#...
		
	def analyzeTypings(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesTypes = df()
		count = 0
		for i in self.battles:
			count = count + 1
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			print("USING POKEAPI! Analyzing battle number ", count)
			dataFramesTypes = dataFramesTypes.append(tempSBA.analyzeBattlePokemonAPITypeData(),ignore_index=True)
			
		mergedData = merge(dataFramesTypes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Type","Frecuency (%)"]
			
		for name,group in mergedData.groupby("Fancy"):
			group = group.drop_duplicates("Pokemon") #Eliminamos duplicados por formato
			typeList = []
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for type1,type2 in group2[["Type 1","Type 2"]].values:
					if type1 is None:
						continue
					if type2 is None:
						typeList = typeList + [type1]
					else:
						typeList = typeList + [type1] + [type2]
						
			if len(typeList) == 0:
				continue
			listCounter = Counter(typeList)
			for i in listCounter:
				l = [name] + [i] + [listCounter[i]/len(typeList) * 100]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		if "Frecuency (%)" in resultDict:
			resultDict = resultDict.round({"Frecuency (%)":2})
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Frecuency (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Frecuency (%)"],ascending=False)
		
		return resultDict
		
	#  Format	Average HP	Average Attack	Average Defense	Average	Sp. Attack	Average Sp. Defense	Average Speed
	#0
	#1
	#...

	def analyzeStats(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesStats = df()
		count = 0
		for i in self.battles:
			count = count + 1
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			print("USING POKEAPI! Analyzing battle number ", count)
			dataFramesStats = dataFramesStats.append(tempSBA.analyzeBattlePokemonAPIStatData(),ignore_index=True)
			
		mergedData = merge(dataFramesStats,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Average HP","Average Attack","Average Defense","Average Sp. Attack","Average Sp. Defense","Average Speed"]
			
		for name,group in mergedData.groupby("Fancy"):
			group = group.drop_duplicates("Pokemon") #Eliminamos duplicados por formato
			statList = [0,0,0,0,0,0]
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for stats in group2[["HP","Attack","Defense","S. Attack","S. Defense","Speed"]].values:
					if stats is None:
						continue
					statList = [sum(x) for x in zip(statList,stats)]
						
			if len(statList) == 0:
				continue
			avgStatList = [x / len(group) for x in statList]
			l = [name] + avgStatList
			resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict:
				resultDict = resultDict.sort_values(by=["Format"],ascending=False)
		
		return resultDict
	
	#  Format	Average Height	Average Weight
	#0
	#1
	#...
	
	def analyzeSizes(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesSizes = df()
		count = 0
		for i in self.battles:
			count = count + 1
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			print("USING POKEAPI! Analyzing battle number ", count)
			dataFramesSizes = dataFramesSizes.append(tempSBA.analyzeBattlePokemonAPISizeData(),ignore_index=True)
			
		mergedData = merge(dataFramesSizes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Average Height","Average Weight"]
			
		for name,group in mergedData.groupby("Fancy"):
			group = group.drop_duplicates("Pokemon") #Eliminamos duplicados por formato
			sizeList = [0,0]
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for sizes in group2[["Weight (kg)","Height (m)"]].values:
					if sizes is None:
						continue
					sizeList = [sum(x) for x in zip(sizeList,sizes)]
						
			if len(sizeList) == 0:
				continue
			avgSizeList = [x / len(group) for x in sizeList]
			l = [name] + avgSizeList
			resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict:
				resultDict = resultDict.sort_values(by=["Format"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Move	Usage (%)
	#0
	#1
	#...
	
	def analyzeMovesByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesMoves = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesMoves = dataFramesMoves.append(tempSBA.analyzeBattleMoveUsage(),ignore_index=True)
			
		mergedData = merge(dataFramesMoves,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Pokemon","Move","Usage (%)"]
			
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,move1,move2,move3,move4 in group2[["Pokemon","Move 1","Move 2","Move 3","Move 4"]].values:
					moves = [move1,move2,move3,move4]
					if poke not in dictPokes:
						dictPokes[poke] = {}
					for i in moves:
						if i is not None:
							if i in dictPokes[poke]:
								dictPokes[poke][i] = dictPokes[poke][i] + 1
							else:
								dictPokes[poke][i] = 1
						
			for poke in dictPokes:
				totalAttacks = sum(dictPokes[poke].values())
				for attack in dictPokes[poke]:
					num = dictPokes[poke][attack]
					l = [name] + [poke] + [attack] + [num / totalAttacks * 100]
					resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Usage (%)" in resultDict:
			resultDict = resultDict.round({"Usage (%)":2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Usage (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Usage (%)"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Neutral Hits (%)	SuperEffective Hits (%)		Resisted Hits (%)	Ineffective Hits (%)
	#0
	#1
	#...
	
	def analyzeEffectivenessByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesEffectives = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesEffectives = dataFramesEffectives.append(tempSBA.analyzeBattleMoveEffectiveness(),ignore_index=True)
			
		mergedData = merge(dataFramesEffectives,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Pokemon","Neutral Hits (%)","SuperEffective Hits (%)","Resisted Hits (%)","Ineffective Hits (%)"]
		
		attackTranslator = {
							0 : "Neutral",
							1 : "SuperEffective",
							2 : "Resisted",
							3 : "Ineffective",
							}
		
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,neutral,superEff,resist,immune in group2[["Pokemon","Neutral Attacks","Supereffective Attacks","Resisted Attacks","Ineffective Attacks"]].values:
					attacks = [neutral,superEff,resist,immune]
					if poke not in dictPokes:
						dictPokes[poke] = {}
					for i in range(len(attacks)):
						key = attackTranslator[i]
						if key in dictPokes[poke]:
							dictPokes[poke][key] = dictPokes[poke][key] + attacks[i]
						else:
							dictPokes[poke][key] = attacks[i]
							
			for poke in dictPokes:
				totalUsages = sum(dictPokes[poke].values())
				l = [name] + [poke]
				for attack in dictPokes[poke]:
					num = dictPokes[poke][attack]
					l = l + [num / totalUsages * 100]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		keysTranslator = {
				0 : "Neutral Hits (%)",
				1 : "SuperEffective Hits (%)",
				2 : "Resisted Hits (%)",
				3 : "Ineffective Hits (%)",
			}
		for i in range(len(keysTranslator)):
			if keysTranslator[i] in resultDict:
				resultDict = resultDict.round({keysTranslator[i]:2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Pokemon" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Pokemon"],ascending=False)
				
		return resultDict
		
	#  Format	Pokemon		Moves Missed (%)	Moves Failed (%)
	#0
	#1
	#...
	
	def analyzeFailsByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesFailures = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesFailures = dataFramesFailures.append(tempSBA.analyzeBattleMoveFailure(),ignore_index=True)
			
		mergedData = merge(dataFramesFailures,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Pokemon","Moves Missed (%)","Moves Failed (%)"]
		
		attackTranslator = {
							0 : "Total",
							1 : "Missed",
							2 : "Failed",
							}
		
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,total,miss,fail in group2[["Pokemon","Times Used","Times Missed","Times Failed"]].values:
					times = [total,miss,fail]
					if poke not in dictPokes:
						dictPokes[poke] = {}
					for i in range(len(times)):
						key = attackTranslator[i]
						if key in dictPokes[poke]:
							dictPokes[poke][key] = dictPokes[poke][key] + times[i]
						else:
							dictPokes[poke][key] = times[i]
							
			for poke in dictPokes:
				total = dictPokes[poke]["Total"]
				numMiss = dictPokes[poke]["Missed"]
				numFail = dictPokes[poke]["Failed"]
				l = [name] + [poke] + [numMiss / total * 100] + [numFail / total * 100]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Moves Missed (%)" in resultDict:
			resultDict = resultDict.round({"Moves Missed (%)":2})
		if "Moves Failed (%)" in resultDict:
			resultDict = resultDict.round({"Moves Failed (%)":2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Pokemon" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Pokemon"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Num battles	Faint ratio per battle
	#0
	#1
	#...
	
	def analyzeFaintsByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesFaints = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesFaints = dataFramesFaints.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
			
		mergedData = merge(dataFramesFaints,seriesFormats,how="left",on=["Battle ID"],sort=False)
		mergedData = merge(mergedData,dataFramesPokes,how="left",left_on=["Battle ID","Victim Nickname","Victim Player"],right_on=["Battle ID","Pokemon Nickname","Player"],suffixes=('_attacker', '_victim'),sort=False)
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		dictFormats = {}
		
		indexVec = ["Format","Pokemon","Num battles","Faint ratio per battle"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player_victim"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke in group2["Pokemon_victim"].values:
					if str(poke).lower() not in "nan":
						if not poke in dictPokes:
							dictPokes[poke] = 1
						else:
							dictPokes[poke] = dictPokes[poke] + 1
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				numTimes = dictPokes[poke]
				l = [name] + [poke] + [total] + [numTimes / total]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		if "Num battles" in resultDict:
			resultDict["Num battles"] = resultDict["Num battles"].astype(int)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)
		
		return resultDict
		
	#  Format	Pokemon		Num battles	Times Paralized		Times Badly Poisoned	Times Poisoned		Times Asleep	Times Burnt		Times Frozen
	#0
	#1
	#...
	
	def analyzeStatusByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesStatus = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesStatus = dataFramesStatus.append(tempSBA.analyzeBattlePokemonStatus(),ignore_index=True)
			
		mergedData = merge(dataFramesStatus,seriesFormats,how="left",on=["Battle ID"],sort=False)
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		dictFormats = {}

		statusTranslator = {
							0 : "Paralisis",
							1 : "Toxic Poison",
							2 : "Poison",
							3 : "Sleep",
							4 : "Burn",
							5 : "Freeze",
							}
							
		indexVec = ["Format","Pokemon","Num battles","Times Paralized","Times Badly Poisoned","Times Poisoned","Times Asleep","Times Burnt","Times Frozen"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,status in group2[["Pokemon","Status"]].values:
					if not poke in dictPokes:
						dictPokes[poke] = {}
					if not status in dictPokes[poke]:
						dictPokes[poke][status] = 1
					else:
						dictPokes[poke][status] = dictPokes[poke][status] + 1
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				l = [name] + [poke] + [total]
				for i in range(len(statusTranslator)):
					if statusTranslator[i] in dictPokes[poke]:
						l = l + [dictPokes[poke][statusTranslator[i]]]
					else:
						l = l + [0]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		keysTranslator = {
				0 : "Num battles",
				1 : "Times Paralized",
				2 : "Times Badly Poisoned",
				3 : "Times Poisoned",
				4 : "Times Asleep",
				5 : "Times Burnt",
				6 : "Times Frozen",
			}
		for i in range(len(keysTranslator)):
			if keysTranslator[i] in resultDict:
				resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype(int)

		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)

		return resultDict
		
	#  Format	Pokemon		Num battles	Times flinched per battle		Times Fully Paralized per battle
	#0
	#1
	#...
	
	def analyzeCantMoveByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesParaFlinch = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesParaFlinch = dataFramesParaFlinch.append(tempSBA.analyzeBattleParaFlinch(),ignore_index=True)
			
		mergedData = merge(dataFramesParaFlinch,seriesFormats,how="left",on=["Battle ID"],sort=False)
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		dictFormats = {}
		
		statusTranslator = {
							0 : "Flinches",
							1 : "Paralisis",
							}
		
		indexVec = ["Format","Pokemon","Num battles","Times Flinched per battle","Times Fully Paralized per battle"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,flinches,fullyparas in group2[["Pokemon","Times Flinched","Times Fully Paralyzed"]].values:
					if not poke in dictPokes:
						dictPokes[poke] = {}
					cants = [flinches,fullyparas]
					for i in range(len(statusTranslator)):
						if not statusTranslator[i] in dictPokes[poke]:
							dictPokes[poke][statusTranslator[i]] = cants[i]
						else:
							dictPokes[poke][statusTranslator[i]] = dictPokes[poke][statusTranslator[i]] + cants[i]
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				l = [name] + [poke] + [total]
				for i in range(len(statusTranslator)):
					if statusTranslator[i] in dictPokes[poke]:
						l = l + [dictPokes[poke][statusTranslator[i]]/total]
					else:
						l = l + [0]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Num battles" in resultDict:
			resultDict["Num battles"] = resultDict["Num battles"].astype(int)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)


		return resultDict

	#  Format	Pokemon		Num battles	Victims per battle
	#0
	#1
	#...
	
	def analyzeVictimsByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesVictims = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesVictims = dataFramesVictims.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
			
		mergedData = merge(dataFramesVictims,seriesFormats,how="left",on=["Battle ID"],sort=False)
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		dictFormats = {}

		indexVec = ["Format","Pokemon","Num battles","Victims per battle"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke in group2["Pokemon"].values:
					if not poke in dictPokes:
						dictPokes[poke] = 1
					else:
						dictPokes[poke] = dictPokes[poke] + 1
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				l = [name] + [poke] + [total] + [dictPokes[poke]/total]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Num battles" in resultDict:
			resultDict["Num battles"] = resultDict["Num battles"].astype(int)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)

		return resultDict
		
	#  Format	Pokemon		Num battles		Crits taken		Crits dealt		Faints by a crit	Victims by a crit
	#0
	#1
	#...
	
	def analyzeCriticalsByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesCrits = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesCrits = dataFramesCrits.append(tempSBA.analyzeBattleCriticals(),ignore_index=True)
		
		mergedData = merge(dataFramesCrits,seriesFormats,how="left",on=["Battle ID"],sort=False)
		mergedData = merge(mergedData,dataFramesPokes,how="left",left_on=["Battle ID","Pokemon Nickname hit by a Critical","Player hit by a Critical"],right_on=["Battle ID","Pokemon Nickname","Player"],suffixes=('_attacker', '_victim'),sort=False)
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		dictFormats = {}

		indexVec = ["Format","Pokemon","Num battles","Crits taken","Crits dealt","Faints by a crit","Victims by a crit"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			num = None
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
				for victim,attacker,critFaint,playerVictim,playerAttacker in group2[["Pokemon_victim","Pokemon_attacker","Did the Pokemon Faint from the critical?","Player_victim","Player_attacker"]].values:
					pokes = [victim,attacker]
					for poke in pokes:
						if not poke in dictPokes:
							dictPokes[poke] = {}
							dictPokes[poke]["critsTaken"] = 0
							dictPokes[poke]["critsDealt"] = 0
							dictPokes[poke]["faintsByCrit"] = 0
							dictPokes[poke]["victimsByCrit"] = 0
					
					if num is not None:
						if num == playerVictim:
							dictPokes[victim]["critsTaken"] = dictPokes[victim]["critsTaken"] + 1
							if critFaint == 1.0:
								dictPokes[victim]["faintsByCrit"] = dictPokes[victim]["faintsByCrit"] + 1
						else:
							dictPokes[attacker]["critsDealt"] = dictPokes[attacker]["critsDealt"] + 1
							if critFaint == 1.0:
								dictPokes[attacker]["victimsByCrit"] = dictPokes[attacker]["victimsByCrit"] + 1
					else:
						dictPokes[victim]["critsTaken"] = dictPokes[victim]["critsTaken"] + 1
						dictPokes[attacker]["critsDealt"] = dictPokes[attacker]["critsDealt"] + 1
						if critFaint == 1.0:
							dictPokes[victim]["faintsByCrit"] = dictPokes[victim]["faintsByCrit"] + 1
							dictPokes[attacker]["victimsByCrit"] = dictPokes[attacker]["victimsByCrit"] + 1
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				l = [name] + [poke] + [total] + [dictPokes[poke]["critsTaken"]] + [dictPokes[poke]["critsDealt"]] + [dictPokes[poke]["faintsByCrit"]] + [dictPokes[poke]["victimsByCrit"]]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		keysTranslator = {
				0 : "Num battles",
				1 : "Crits taken",
				2 : "Crits dealt",
				3 : "Faints by a crit",
				4 : "Victims by a crit",
			}
		for i in range(len(keysTranslator)):
			if keysTranslator[i] in resultDict:
				resultDict[keysTranslator[i]] = resultDict[keysTranslator[i]].astype(int)

		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)
				
		return resultDict
		
	#  Format	Pokemon		Num battles		Damage done (%)		Damage taken (%)	Recoil damage taken (%)		Damage healed (%)	Damage healed by items (%)
	#0
	#1
	#...
	
	def analyzeDamageByPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesDamage = df()
		dataFramesPokes = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			dataFramesDamage = dataFramesDamage.append(tempSBA.analyzeBattleHPChange(),ignore_index=True)
		
		mergedData = merge(dataFramesDamage,seriesFormats,how="left",on=["Battle ID"],sort=False)
		mergedData = merge(mergedData,dataFramesPokes,how="left",left_on=["Battle ID","Pokemon Source","Player Source"],right_on=["Battle ID","Pokemon Nickname","Player"],suffixes=('_victim','_attacker'),sort=False)

		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)

		dictFormats = {}

		indexVec = ["Format","Pokemon","Num battles","Damage taken (%)","Recoil damage taken (%)","Damage done (%)","Damage healed (%)","Damage healed by items (%)"]

		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
						
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			num = None
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
				for victim,victimPlayer,hpChange,source,sourceType,attackerPlayer,attacker in group2[["Pokemon_victim","Player_victim","% HP Changed","Other Source","Other Source Type","Player_attacker","Pokemon_attacker"]].values:
					pokes = [victim,attacker]
					for poke in pokes:
						if not poke in dictPokes and str(poke).lower() not in "nan":
							dictPokes[poke] = {}
							dictPokes[poke]["dealt"] = 0
							dictPokes[poke]["taken"] = 0
							dictPokes[poke]["recoil"] = 0
							dictPokes[poke]["healed"] = 0
							dictPokes[poke]["item"] = 0
					if num is not None: #Si buscamos 1 jugador num no será None. Entonces solo operamos basándonos en el num.
						if hpChange < 0: # Un valor negativo significa daño, un valor positivo significa curación.
							if num == victimPlayer:
								if source is not None and source in "Recoil": #Si recibimos daño recibido normal o de recoil, el normal se aumenta independientemente
									dictPokes[victim]["recoil"] = dictPokes[victim]["recoil"] + (hpChange * 100)
								dictPokes[victim]["taken"] = dictPokes[victim]["taken"] + (hpChange * 100)
							elif attackerPlayer is not None and str(attackerPlayer).lower() not in "nan": #El jugador es el que realizó el daño (attacker), nos aseguramos de que exista
								dictPokes[attacker]["dealt"] = dictPokes[attacker]["dealt"] + (hpChange * 100)
						else: #Curación
							if num == victimPlayer:
								if sourceType is not None and "item" in sourceType:
									dictPokes[victim]["item"] = dictPokes[victim]["item"] + (hpChange * 100)
								dictPokes[victim]["healed"] = dictPokes[victim]["healed"] + (hpChange * 100)
					else: #Si nos da igual el jugador
						if hpChange < 0:
							if source is not None and source in "Recoil": #Si recibimos daño recibido normal o de recoil, el normal se aumenta independientemente
								dictPokes[victim]["recoil"] = dictPokes[victim]["recoil"] + (hpChange * 100)
							dictPokes[victim]["taken"] = dictPokes[victim]["taken"] + (hpChange * 100)
							if attacker is not None and str(attacker).lower() not in "nan":
								dictPokes[attacker]["dealt"] = dictPokes[attacker]["dealt"] + (hpChange * 100) #Aquí metemos los daños realizados aprovechando la misma línea
						else:
							if sourceType is not None and "item" in sourceType:
								dictPokes[victim]["item"] = dictPokes[victim]["item"] + (hpChange * 100)
							dictPokes[victim]["healed"] = dictPokes[victim]["healed"] + (hpChange * 100)
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				taken = dictPokes[poke]["taken"] / total
				recoil = dictPokes[poke]["recoil"] / total
				dealt = abs(dictPokes[poke]["dealt"] / total) # Este mejor en positivo
				healed = dictPokes[poke]["healed"] / total
				item = dictPokes[poke]["item"] / total
				if sum([taken,recoil,dealt,healed,item]) == 0:
					continue #Si la suma de todo da 0 es que nunca se llegó a utilizar, importante en el caso de analizar un solo jugador
				l = [name] + [poke] + [total] + [taken] + [recoil] + [dealt] + [healed] + [item]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		keysTranslator = {
				0 : "Damage taken (%)",
				1 : "Recoil damage taken (%)",
				2 : "Damage done (%)",
				3 : "Damage healed (%)",
				4 : "Damage healed by items (%)",
			}
		for i in range(len(keysTranslator)):
			if keysTranslator[i] in resultDict:
				resultDict = resultDict.round({keysTranslator[i]:2})
	
		if "Num battles" in resultDict:
			resultDict["Num battles"] = resultDict["Num battles"].astype(int)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)

		return resultDict
		
	#  Format	Pokemon		Coverage Type	Frecuency (%)
	#0
	#1
	#...
	
	def analyzeCoverageOfPokemon(self):
		resultDict = df()
		if self.playerName is not None:
			dataFramesPlayers = df()
		seriesFormats = df()
		dataFramesCoverages = df()
		dataFramesPokes = df()
		count = 0
		for i in self.battles:
			count = count + 1
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			if self.playerName is not None:
				dataFramesPlayers = dataFramesPlayers.append(tempSBA.analyzeBattlePlayers(),ignore_index=True)
			print("USING POKEAPI! Analyzing battle number ", count)
			dataFramesCoverages = dataFramesCoverages.append(tempSBA.analyzeBattleMoveCoverage(),ignore_index=True)
			dataFramesPokes = dataFramesPokes.append(tempSBA.analyzeBattlePokes(),ignore_index=True)
			
		mergedData = merge(dataFramesCoverages,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		pokesFormatsDF = merge(dataFramesPokes,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Pokemon","Coverage Type","Frecuency (%)"]
		dictFormats = {}
		
		for name,group in pokesFormatsDF.groupby("Fancy"):
			dictFormats[name] = {}
			for name2,group2 in group.groupby("Battle ID"):
				for poke in group2["Pokemon"]:
					if poke not in dictFormats[name]:
						dictFormats[name][poke] = 1
					else:
						dictFormats[name][poke] = dictFormats[name][poke] + 1
			
		for name,group in mergedData.groupby("Fancy"):					
			dictPokes = {}
			for name2,group2 in group.groupby("Battle ID"):
				if self.playerName is not None:
					row = dataFramesPlayers[dataFramesPlayers["Player Name"] == self.playerName]
					num = row["Player Number"].values[0]
					group2 = group2[group2["Player"] == num] # Si estamos analizando 1 único jugador no contamos pokemon utilizados por otros jugadores
				for poke,type1,type2,cov1,cov2,cov3,cov4 in group2[["Pokemon","Type 1","Type 2","Coverage Type 1","Coverage Type 2","Coverage Type 3","Coverage Type 4"]].values:
					types = [type1,type2]
					coverages = [cov1,cov2,cov3,cov4]
					if not poke in dictPokes:
						dictPokes[poke] = {}					
					for cov in coverages:
						if cov is not None and str(cov).lower() not in "nan" and not cov == type1 and (type2 is not None or not cov == type2):
							if cov not in dictPokes[poke]:
								dictPokes[poke][cov] = 1
							else:
								dictPokes[poke][cov] = dictPokes[poke][cov] + 1
							
			for poke in dictPokes:
				total = dictFormats[name][poke]
				for t in dictPokes[poke]:
					l = [name] + [poke] + [t] + [dictPokes[poke][t]/total * 100]
					resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		if "Frecuency (%)" in resultDict:
			resultDict = resultDict.round({"Frecuency (%)":2})
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Frecuency (%)" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Frecuency (%)"],ascending=False)

		return resultDict
		
	#  Format	Forfeited?	Average Turns
	#0
	#1
	#...
	
	def analyzeTurnAverage(self): # A partir de esta función no filtramos por jugador porque ya es implícito (Si tenemos un jugador el conjunto de datos solo tendrá partidas de ese jugador)
		resultDict = df()
		seriesFormats = df()
		seriesTurns = df()
		seriesForfeits = df()
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			seriesForfeits = seriesForfeits.append(tempSBA.analyzeBattleForfeitDisconnect(),ignore_index=True)
			seriesTurns = seriesTurns.append(tempSBA.analyzeBattleTurnsNeeded(),ignore_index=True)
			
		mergedData = merge(seriesForfeits,seriesFormats,how="left",on=["Battle ID"],sort=False)
		mergedData = merge(mergedData,seriesTurns,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Forfeited","Average Turns"]
			
		for name,group in mergedData.groupby("Fancy"):
			forfeits = []
			nonforfeits = []
			for forfeit,turns in group[["Forfeit","Turns"]].values:
				if forfeit == 1.0:
					forfeits.append(turns)
				else:
					nonforfeits.append(turns)
			if len(forfeits) > 0:
				l1 = [name] + ["Yes"] + [sum(forfeits)/len(forfeits)]
				resultDict = resultDict.append(ser(l1,index=indexVec),ignore_index=True)
			if len(nonforfeits) > 0:
				l2 = [name] + ["No"] + [sum(nonforfeits)/len(nonforfeits)]
				resultDict = resultDict.append(ser(l2,index=indexVec),ignore_index=True)
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Average Turns" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Average Turns"],ascending=False)

		return resultDict
		
	#  Format	Max Turns until first faint		Average Turns until first faint
	#0
	#1
	#...
	
	def analyzeTurnAverageUntilFirstVictim(self):
		resultDict = df()
		seriesFormats = df()
		dataFramesVictims = df()
		
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesVictims = dataFramesVictims.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
			
		mergedData = merge(dataFramesVictims,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Max Turns until first faint","Average Turns until first faint"]
	
		for name,group in mergedData.groupby("Fancy"):
			maxTurns = 0
			avgTurns = []
			for name2,group2 in group.groupby("Battle ID"):
				group2 = group2[group2["Turn"] == group2["Turn"].min()] # Solo nos interesa el primer faint (menor turno)
				turn = group2["Turn"].values[0]
				if turn > maxTurns:
					maxTurns = turn
				avgTurns.append(turn)
			l = [name] + [int(maxTurns)] + [sum(avgTurns)/len(avgTurns)]
			resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Average Turns until first faint" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Average Turns until first faint"],ascending=False)

		return resultDict
		
	#  Format	Move	Victims per battle
	#0
	#1
	#...
	
	def analyzeVictimsByMove(self):
		resultDict = df()
		seriesFormats = df()
		dataFramesVictims = df()
		
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesVictims = dataFramesVictims.append(tempSBA.analyzeBattleVictimsByPokemon(),ignore_index=True)
			
		mergedData = merge(dataFramesVictims,seriesFormats,how="left",on=["Battle ID"],sort=False)

		indexVec = ["Format","Move","Victims per battle"]
		
		for name,group in mergedData.groupby("Fancy"):
			dictAttacks = {}
			numBattles = len(group["Battle ID"].drop_duplicates())
			for name2,group2 in group.groupby("Battle ID"):
				for move in group2["Move"].values:
					if move not in dictAttacks:
						dictAttacks[move] = 1
					else:
						dictAttacks[move] = dictAttacks[move] + 1
						
			for attack in dictAttacks:
				l = [name] + [attack] + [dictAttacks[attack]/numBattles]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Victims per battle" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Victims per battle"],ascending=False)
		
		return resultDict
		
	#  Format	Move	Times used	Miss rate (%)	Fail rate (%)
	#0
	#1
	#...
	
	def analyzeMissesByMove(self):
		resultDict = df()
		seriesFormats = df()
		dataFramesMisses = df()
		
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			dataFramesMisses = dataFramesMisses.append(tempSBA.analyzeBattleMoveFailure(),ignore_index=True)
		
		attackTranslator = {
							0 : "Used",
							1 : "Missed",
							2 : "Failed",
		}
		
		mergedData = merge(dataFramesMisses,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Move","Times Used","Miss rate (%)","Fail rate (%)"]
			
		for name,group in mergedData.groupby("Fancy"):
			dictAttacks = {}
			numBattles = len(group["Battle ID"].drop_duplicates())
			for name2,group2 in group.groupby("Battle ID"):
				for move,used,missed,failed in group2[["Move","Times Used","Times Missed","Times Failed"]].values:
					times = [used,missed,failed]
					if move not in dictAttacks:
						dictAttacks[move] = {}
						for i in attackTranslator:
							dictAttacks[move][attackTranslator[i]] = 0
					for i in attackTranslator:
						dictAttacks[move][attackTranslator[i]] = dictAttacks[move][attackTranslator[i]] + times[i]
						
			for attack in dictAttacks:
				l = [name] + [attack] + [dictAttacks[attack]["Used"]] + [dictAttacks[attack]["Missed"]/dictAttacks[attack]["Used"]*100] + [dictAttacks[attack]["Failed"]/dictAttacks[attack]["Used"]*100]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Miss rate (%)" in resultDict:
			resultDict = resultDict.round({"Miss rate (%)":2})
		
		if "Fail rate (%)" in resultDict:
			resultDict = resultDict.round({"Fail rate (%)":2})
		
		if "Times Used" in resultDict:
			resultDict["Times Used"] = resultDict["Times Used"].astype(int)
		
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Times Used" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Times Used"],ascending=False)
		
		return resultDict
		
	#  Format	Num battles
	#0
	#1
	#...
	
	def analyzeBattlesByFormat(self):
		resultDict = df()
		seriesFormats = df()
		
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			
		indexVec = ["Format","Num battles"]
		for name,group in seriesFormats.groupby("Fancy"):
			numBattles = len(group["Battle ID"])
			l = [name] + [numBattles]
			resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Num battles" in resultDict:
			resultDict["Num battles"] = resultDict["Num battles"].astype(int)
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Num battles" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Num battles"],ascending=False)
		
		return resultDict
		
	#  Format	Average ELO 	Max ELO
	#0
	#1
	#...
	
	def analyzeELOByFormat(self):
		resultDict = df()
		seriesFormats = df()
		seriesELO = df()
		
		for i in self.battles:
			tempSBA = SBA.SingleBattleAnalyzer(i)
			seriesFormats = seriesFormats.append(tempSBA.analyzeBattleFormat(),ignore_index=True)
			seriesELO = seriesELO.append(tempSBA.analyzeBattleELOAverage(),ignore_index=True)
		
		mergedData = merge(seriesELO,seriesFormats,how="left",on=["Battle ID"],sort=False)
		
		indexVec = ["Format","Average ELO","Max ELO"]
			
		for name,group in mergedData.groupby("Fancy"):
			maxELO = 0
			ELOs = []
			for average in group["Average Rating"].values:
				if not average == 0: #Si es 0 no lo contamos
					if average > maxELO:
						maxELO = average
					ELOs.append(average)
			if len(ELOs) > 0:
				l = [name] + [sum(ELOs)/len(ELOs)] + [maxELO]
				resultDict = resultDict.append(ser(l,index=indexVec),ignore_index=True)
		
		if "Max ELO" in resultDict:
			resultDict["Max ELO"] = resultDict["Max ELO"].astype(int)
		if "Average ELO" in resultDict:
			resultDict = resultDict.round({"Average ELO":2})
			
		if len(resultDict)>0:
			resultDict = resultDict[indexVec]
			if "Format" in resultDict and "Average ELO" in resultDict:
				resultDict = resultDict.sort_values(by=["Format","Average ELO"],ascending=False)
		
		return resultDict