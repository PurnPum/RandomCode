from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from requests import get
from os import mkdir
from os import getcwd
import sys
import getopt
from selenium.common.exceptions import TimeoutException

def load_args(argv):
	courseUrl = ''
	courseName = ''
	email = ''
	password = ''
	try:
		opts, args = getopt.getopt(argv,"hm:c:n:e:p",["CourseURL=","CourseName=","EmailLogin=","Password="])
	except getopt.GetoptError:
		print('linkedinVideoExtractor.py -c <CourseURL> -n <CourseName> -e <EmailLogin> -p <Password>')
		exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('linkedinVideoExtractor.py -c <CourseURL> -n <CourseName> -e <EmailLogin> -p <Password>')
			exit()
		elif opt in ("-c", "--CourseURL"):
			try:
				courseUrl=str(arg)
			except:
				print('Dato \'CourseURL\' introducido erroneamente')
				exit(2)
		elif opt in ("-n", "--CourseName"):
			try:
				courseName=str(arg)
			except:
				print('Dato \'CourseName\' introducido erroneamente')
				exit(2)
		elif opt in ("-e", "--Email"):
			try:
				email=str(arg)
			except:
				print('Dato \'EmailLogin\' introducido erroneamente')
				exit(2)
		elif opt in ("-p", "--Password"):
			try:
				password=str(arg)
			except:
				print('Dato \'Password\' introducido erroneamente')
				exit(2)
	return {'c':courseUrl,'n':courseName,'e':email,'p':password}

def login(username,password,driv):
	driv.get("https://www.linkedin.com/learning-login/")
	email = WebDriverWait(driv, 20).until(EC.presence_of_element_located((By.NAME, 'email')))
	email.send_keys(username)
	continue1 = WebDriverWait(driv, 3).until(EC.element_to_be_clickable((By.ID, 'auth-id-button')))
	continue1.click()
	passwordinput = WebDriverWait(driv, 20).until(EC.presence_of_element_located((By.ID, 'password')))
	splits = password.split('^')
	
	for s in range(len(splits)):
		passwordinput.send_keys(splits[s])
		if s+1 < len(splits):
			passwordinput.send_keys(Keys.LEFT_SHIFT + Keys.SEMICOLON)
			passwordinput.send_keys(Keys.LEFT + Keys.LEFT + Keys.DELETE + Keys.RIGHT)
			
	continue2 = WebDriverWait(driv, 5).until(EC.element_to_be_clickable((By.CLASS_NAME, 'btn__primary--large')))
	continue2.click()
	
def goThroughCourse(url,course,driv,driv2):
	driv.get(url)
	content = WebDriverWait(driv, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "classroom-nav__sidebar-toggle")))
	if 'false' in content.get_attribute("aria-expanded"):
		content.click()
	try:	
		elements = WebDriverWait(driv, 5).until(EC.presence_of_all_elements_located((By.CLASS_NAME, "classroom-toc-chapter--collapsed")))
		for e in elements:
			e.click()
	except TimeoutException:
		pass
	
	hrefs = WebDriverWait(driv, 5).until(EC.presence_of_all_elements_located((By.XPATH, ".//a[@data-control-name='toc_item']")))
	for h in hrefs:
		getVideo(h,driv2,course)
			
	getExercises(url,driv,course)
	
def getVideo(href,driv2,course):
	driv2.get(href.get_attribute('href'))
	try:
		video = WebDriverWait(driv2, 20).until(EC.presence_of_element_located((By.XPATH, './/video')))
		videoUrl = video.get_attribute('src')
		nameSplits = href.get_attribute('href').split('/learning/')[-1]
		filename = nameSplits.split('/')[-1].split('?')[0]
		downloadFile(videoUrl,filename + ".mp4",course)
	except TimeoutException:
		pass
	
def downloadFile(file_url,filename,course):
	response = get(file_url)
	try:
		mkdir(getcwd() + '\\' + course)
	except FileExistsError:
		pass
	with open(getcwd() + '\\' + course + '\\' + filename,'wb') as f:
		f.write(response.content)
		
def getExercises(courseUrl,driv,course):
	driv.get(courseUrl)
	button = WebDriverWait(driv, 10).until(EC.element_to_be_clickable((By.XPATH, ".//button[@data-control-name='exercise_files_modal']")))
	button.click()
	aUrl = WebDriverWait(driv, 20).until(EC.presence_of_element_located((By.CLASS_NAME, 'classroom-exercise-files-modal__exercise-file-download')))
	url = aUrl.get_attribute('href')
	filename = url.split('?')[0].split('/')[-1]
	downloadFile(url,filename,course)
	
def main():
	datos=load_args(sys.argv[1:])
	DRIVER_PATH = "./chromedriver87.exe"
	driver = webdriver.Chrome(executable_path=DRIVER_PATH)
	driver2 = webdriver.Chrome(executable_path=DRIVER_PATH)
	try:
		login(datos["e"],datos["p"],driver)
		login(datos["e"],datos["p"],driver2)
		goThroughCourse(datos["c"],datos["n"],driver,driver2)
	finally:
		driver.close()
		driver2.close()

if __name__ == "__main__":
	main()