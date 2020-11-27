import sympy
from time import time
import sys, getopt
from math import ceil,sqrt,floor
from decimal import Decimal,getcontext

def load_args(argv):
	maxp = 0 #Valores por defecto
	prec = 0
	try:
		opts, args = getopt.getopt(argv,"hm:m:p",["maxp=","precision="])
	except getopt.GetoptError:
		print('PrimesConstRecursive.py -m <maxp> -p <precision>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('PrimesConstRecursive.py -m <maxp> -p <precision>')
			sys.exit()
		elif opt in ("-m", "--maxp"):
			try:
				maxp=int(arg)
			except:
				print('Dato \'maxp\' introducido erroneamente')
				sys.exit(2)
		elif opt in ("-p", "--precision"):
			try:
				prec=int(arg)
			except:
				print('Dato \'precision\' introducido erroneamente')
				sys.exit(2)
	if maxp is 0 or prec is 0:
		print('PrimesConstRecursive.py -m <maxp> -p <precision>')
		sys.exit(2)
	if maxp > 169780:
		print('maxp no puede ser superior a 169780')
		sys.exit(2)
	if prec > 3000:
		print('precision no puede ser superior a 3000')
		sys.exit(2)
	return {'m':maxp,'p':prec}

def checkConst(const):
	if sympy.isprime(floor(const)):
		return checkConst(floor(const)*(const-floor(const)+1))
	else:
		print(str(floor(const))+" NO es primo.")
	
def calculateBestLimit(maxp):
	b = -996
	c = maxp
	raiz1,raiz2 = ((-b+sqrt(b**2-4*c))/2,(-b-sqrt(b**2-4*c))/2)
	if raiz1>raiz2:
		return ceil(raiz2)
	else:
		return ceil(raiz1)
	
def measureRecFuncLimit(maxp):
	vector = getVector(maxp,False,3)
	limit = calculateBestLimit(maxp)
	begin = time()
	acum = recFuncLimit(vector,limit)
	end = time()
	print("(Recursivo) Tiempo transcurrido para generar constante: " + str(end-begin))
	return acum

def recFuncLimit(vector,limit,acum=Decimal(0),dem=Decimal(0)):
	if len(vector) < limit:
		acum,dem = recFunc(vector,acum,dem)
		return acum
	else:
		acum,dem = recFunc(vector[:limit],acum,dem)
		return(recFuncLimit(vector[limit:],limit,acum,dem))

def recFunc(vector,acum,dem):
	if len(vector) is 0:
		return acum,dem
	elif dem == Decimal(0):
		return(recFunc(vector[1:],Decimal(vector[:1][0])-Decimal(1),Decimal(vector[:1][0])))
	else:
		try
			return(recFunc(vector[1:],acum + (Decimal(vector[:1][0])-Decimal(1))/dem,dem*Decimal(vector[:1][0])))
		except Overflow:
			return acum,dem
		
def getVector(maxp,measure,method):
	if measure:
		begin = time()
	if method is 1:
		vector = [sympy.prime(x) for x in range(1,maxp,1)]
	elif method is 2:
		vector = list(sympy.primerange(2,sympy.prime(maxp)))
	elif method is 3:
		vector = list(sympy.sieve.primerange(2,sympy.prime(maxp)))
	if measure:
		end = time()
		print("Time : " + str(end-begin))
	return vector
	
if __name__ == "__main__":
	datos=load_args(sys.argv[1:])
	getcontext().prec = datos["p"]
	const = measureRecFuncLimit(datos["m"])
	begin = time()
	checkConst(const)
	end = time()
	print("(Recursivo) Tiempo transcurrido para comprobar la constante: " + str(end-begin))