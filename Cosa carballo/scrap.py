from lxml.html import fromstring
from requests import get
from os.path import exists
from os import mkdir
from os import getcwd
from os import walk
from os import listdir
from os import chdir
from re import findall
import pandas as pd

def downloadTable(url,year,name):
	response = get(url)
	filename = name + '.xlsx'
	try:
		mkdir(getcwd() + '\\' + str(year))
	except FileExistsError:
		pass
	with open(getcwd()+'\\'+str(year)+'\\'+filename,'wb') as f:
		f.write(response.content)

def findLinks():
	base = "https://www.ine.es/"
	base2 = "https://www.ine.es/jaxi/"
	url = base + "dynt3/inebase/es/index.htm?type=pcaxis&file=pcaxis&path=%2Ft20%2Fe245%2Fp05%2F%2Fa"
	for year in range(1996,2011,1):
		count = 0
		print(year)
		if year == 1997:
			continue
		currUrl = url + str(year)
		print(currUrl)
		response = get(currUrl)
		htmldoc = fromstring(response.text)
		links = htmldoc.findall('.//a')
		for i in range(len(links)):
			l = links[i]
			text_content_str = l.text_content()
			if text_content_str is None:
				continue
			if "Población por sexo, municipio y grupo quinquenal de edad" in text_content_str or "Población por sexo, municipios y edad (grupos quinquenales)" in text_content_str:
				l = links[i-2]
				href_str = l.get("href")
				currUrl2 = base + href_str
				response2 = get(currUrl2)
				htmldoc2 = fromstring(response2.text)
				links2 = htmldoc2.findall('.//a')
				for l2 in links2:
					if "Excel: extensión XLSx" in l2.text_content():
						count = count + 1
						print(str(count)+" : "+l2.text_content())
						urlFinal = base2 + l2.get("href")
						downloadTable(urlFinal,year,str(count)+"_"+str(year))
						break
						
def combineExcels():
	subdirs = [x[0] for x in walk('.')]
	ogdir = getcwd()
	for subd in subdirs:
		if subd in '.':
			continue
		print(subd)
		name = findall("\d+",subd)[0]
		print(name)
		cwd = getcwd()+subd
		chdir(cwd)
		files = listdir(cwd)
		df = pd.DataFrame()
		for file in files:
			df = df.append(pd.read_excel(file), ignore_index=True)
		df.head()
		df.to_excel(name + '.xlsx')
		chdir(ogdir)