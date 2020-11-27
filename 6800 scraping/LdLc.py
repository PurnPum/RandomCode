from lxml.html import fromstring
from playsound import playsound
from requests import get
from re import findall
from datetime import datetime
from time import sleep
from sys import argv

def findLinks(url):
	base = "https://www.ldlc.com/es-es/informatica/piezas-de-informatica/tarjeta-grafica"
	if url == "":
		url = base + "/c4684/+ftxt-6800+fdi-1+fv1026-5800.html"
	else:
		url = base + url
	response = get(url)
	htmldoc = fromstring(response.text)
	
	if htmldoc.text_content().find("¡No coincide ningún producto!") is -1:
			
		divs = htmldoc.findall('.//div')
		listado = None
		for i in range(len(divs)):
			d = divs[i].attrib.get('class')
			if d is not None and "listing-product" in d:
				listado = divs[i]
				break
		
		articles = listado.findall('.//li')
		
		print("Se encontraron " + str(len(articles)) + " artículos. \n")
		
		for i in range(len(articles)):
			liAs = articles[i].findall('.//a')
			for j in range(len(liAs)):
				if '6800' in liAs[j].text_content():
					print("Encontrada tarjeta disponible a las " + str(datetime.now()) + "\n")
					print("Tarjeta: " + liAs[j].text_content() + "\n")
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