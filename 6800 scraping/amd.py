from lxml.html import fromstring
from playsound import playsound
from cfscrape import create_scraper
from re import findall
from datetime import datetime
from time import sleep
from sys import argv

def findLinks(url):
	base = "https://www.amd.com/es/shop/es/Graphics%20Cards?"
	if url == "":
		url = base + "keyword=6800+XT"
	else:
		url = base + url
	scraper = create_scraper()
	response = scraper.get(url)
	htmldoc = fromstring(response.text)
	
	if htmldoc.text_content().find("Nothing here matches your search") is -1:
			
		articles = htmldoc.find_class("view-content")[0]
		articleList = articles.find_class("views-row")
		print("Se encontraron " + str(len(articleList)) + " artículos. \n")
		
		for art in articleList:
			elem = art.find_class("shop-details")[0]
			name = elem.find_class("field--name-title")[0].text_content()
			price = elem.find_class("shop-price")[0].text_content()
			print("Encontrada tarjeta disponible a las " + str(datetime.now()) + "\n")
			print("Tarjeta: " + name + "\n")
			print("Precio: " + price + "€\n")
			playsound("bell.wav")
		
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
			findLinks(argu)
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