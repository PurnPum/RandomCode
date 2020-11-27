from lxml.html import fromstring
from playsound import playsound
from requests import get
from re import findall
from datetime import datetime
from time import sleep
from sys import argv

def findLinks(url,namepage):
	base = "https://www.pccomponentes.com"
	url = base + url
	page = 0
	while(True):
		if page is not 0:
			url = url.replace(namepage+str(page-1)+"&",namepage+str(page)+"&")
		response = get(url)
		sleep(5)
		htmldoc = fromstring(response.text)
		articles = htmldoc.findall('.//article')
		if len(articles) is 0:
			break
		print("Página Nº " + str(page) + ", hay " + str(len(articles)) + " artículos. \n")
		
		for i in range(len(articles)):
			d = articles[i].attrib.get('data-stock-web')
			if d is not None and d not in '4' and d not in '9999':
				print(articles[i].attrib)
				print("Encontrada tarjeta disponible a las " + str(datetime.now()) + "\n")
				print("Tarjeta: " + articles[i].attrib.get('data-name') + "\n")
				print("Precio: " + articles[i].attrib.get('data-price') + "\n")
				playsound("bell.wav")
		page = page + 1
		
def main():
	count = 1
	while(True):
		ahora = datetime.now()
		print("Iniciando búsqueda nº " + str(count) + " a las " + str(ahora) + "\n")
		argu = ""
		for i, arg in enumerate(argv):
			if i == 1:
				argu=arg
		try:
			if argu.upper().find("AMD") is -1:
				url = "/listado/ajax?idFilters%5B%5D=7498&page=0&order=relevance&gtmTitle=Tarjetas%20Gr%C3%A1ficas%20-%20Black%20Friday%20GeForce%20RTX%203080%20Series&idFamilies%5B%5D=6"
				namepage = "&page="
				findLinks(url,namepage)
			else:
				url = "/buscar/?query=6800+XT+Radeon#pg-0&or-search&fm-6"
				namepage = "#pg-"
				findLinks(url,namepage)
		except:
			print("Error de ejecución")
			pass
		ahora2 = datetime.now()
		print("Finalizada búsqueda nº " + str(count) + " a las " + str(ahora2) + "\n")
		diff = ahora2 - ahora
		print("La búsqueda tardó " + str(diff.total_seconds()) + " segundos en completarse. \n")
		count = count + 1
		sleep(60)
		
if __name__ == "__main__":
	main()