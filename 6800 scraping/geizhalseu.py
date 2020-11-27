from lxml.html import fromstring
from playsound import playsound
from requests import get
from re import findall
from datetime import datetime
from time import sleep
from sys import argv

def findLinks(url):
	base = "https://geizhals.eu"
	if url == "":
		url = base + "/?cat=gra16_512&asuch=6800&bpmin=450&bpmax=800&v=l&hloc=at&hloc=de&hloc=pl&hloc=uk&hloc=eu&plz=&dist=&filter=update&mail="
	else:
		url = base + url
	response = get(url)
	htmldoc = fromstring(response.text)
	productList = htmldoc.find_class("filtercategory__productlist")
	if len(productList) is 1:
		articles = productList[0].find_class('row productlist__product')
		print("Hay " + str(len(articles)) + " artículos. \n")
		for a in articles:
			name = a.find_class("productlist__link")[0].text_content().strip("\n")
			price = a.find_class("gh_price")[0].text_content().strip("\n")
			print("Encontrada tarjeta disponible a las " + str(datetime.now()) + "\n")
			print("Tarjeta: " + name + "\n")
			print("Precio: " + price + "\n")
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