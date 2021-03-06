from lxml.html import fromstring
from playsound import playsound
from cfscrape import create_scraper
from re import findall
from datetime import datetime
from time import sleep
from sys import argv

def findLinks(url):
	base = "https://www.scan.co.uk/shop/computer-hardware"
	if url == "":
		url = base + "/gpu-amd/amd-radeon-rx-6800-xt-pcie-40-graphics-cards"
	else:
		url = base + url
	scraper = create_scraper()
	response = scraper.get(url)
	htmldoc = fromstring(response.text)
	uls = htmldoc.find_class("productColumns")
	ulRel = htmldoc.find_class("productColumns related")
	uls.remove(ulRel[0])
	articles = uls[0].findall('.//li')
	
	print("Hay " + str(len(articles)) + " artículos. \n")
	for a in articles:
		price = a.find_class("price")
		if len(price) > 0:
			print(a.attrib)
			print("Encontrada tarjeta disponible a las " + str(datetime.now()) + "\n")
			print("Tarjeta: " + a.attrib.get('data-description') + "\n")
			print("Precio: " + price[0].text_content() + "\n")
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