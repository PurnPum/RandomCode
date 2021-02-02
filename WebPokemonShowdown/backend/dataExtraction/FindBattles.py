__author__  = "Ricardo Pérez Pardo"
__name__    = "FindBattles"
__package__ = "dataExtraction"

from lxml.html import fromstring
from requests import get
from re import sub

class FindBattles():

	def __find(self,user_or_format,playerName=None,formatName=None):
		battles = []
		page = 1
		if playerName is None:
			name = formatName
		else:
			name = playerName
		while(True):
			response = (get('https://replay.pokemonshowdown.com/search/?'+user_or_format+'='+name+"&page="+str(page)))
			if response.text.find("<li>No results found</li>") is not -1:
				break
			htmldoc = fromstring(response.text)
			links = htmldoc.findall('.//a')
			for l in links:
				cont_str = l.text_content()
				cont_str = cont_str.replace(' ','').lower() #El mismo usuario puede aparecer con o sin espacios en el medio y mayúsculas
				href_str = l.get("href")
				if cont_str.find(name) is not -1:
					battles.append(href_str)
			page = page + 1
			if page == 26:
				break #El máximo siempre será 25 páginas
		if playerName is not None and formatName is not None:
			return self.filterByFormat(battles,formatName)
		return battles

	def findFormat(self,name):
		return self.__find("format",formatName=name)
		
	def findPlayer(self,name):
		return self.__find("user",playerName=name)
		
	def findBoth(self,playerName,formatName):
		return self.__find("user",playerName=playerName,formatName=formatName)
	
	#Este método solo se usa si buscamos por jugador y formato al mismo tiempo porque la página solo permite filtrar por un dato
	def filterByFormat(self,battles,formatName):
		filteredBattles = []
		reformattedFormatName = sub(' ','',formatName).lower() #Quitamos espacios y lo ponemos a minúsculas
		for b in battles:
			if reformattedFormatName in b:
				filteredBattles.append(b)
		return filteredBattles