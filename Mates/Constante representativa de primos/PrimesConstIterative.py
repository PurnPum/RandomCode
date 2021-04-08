import sympy
from time import time
import sys, getopt
from math import ceil,sqrt,floor
from decimal import Decimal,getcontext,Overflow

def load_args(argv):
	maxp = 0 #Valores por defecto
	prec = 0
	try:
		opts, args = getopt.getopt(argv,"hm:m:p",["maxp=","precision="])
	except getopt.GetoptError:
		print('PrimesConstIterative.py -m <maxp> -p <precision>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('PrimesConstIterative.py -m <maxp> -p <precision>')
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
		print('PrimesConstIterative.py -m <maxp> -p <precision>')
		sys.exit(2)
	if maxp > 169780:
		print('maxp no puede ser superior a 169780')
		sys.exit(2)
	return {'m':maxp,'p':prec}

def checkConst(const):
	while(sympy.isprime(floor(const))):
		const = floor(const)*(const-floor(const)+1)
	print(str(floor(const))+" NO es primo.")

	
def measureRecFuncLimit(maxp):
	vector = getVector(maxp,False,3)
	begin = time()
	acum = iterFunc(vector)
	end = time()
	print("(Iterativo) Tiempo transcurrido para generar constante: " + str(end-begin))
	return acum

def iterFunc(vector):
	acum = Decimal(0)
	dem = Decimal(1)
	for i in vector:
		acum = acum + (Decimal(i) - Decimal(1))/dem
		try:
			dem = dem * Decimal(i)
		except Overflow:
			break
	return acum
	
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
	print("(Iterativo) Tiempo transcurrido para comprobar la constante: " + str(end-begin))