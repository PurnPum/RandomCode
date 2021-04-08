def iterate(nums):
    numsp = list(range(1,len(nums)+1))
    rnums = nums[::-1]
    l = []
    for i in numsp:
        templ = [i]*rnums[i-1]
        l = l + templ
    return l
    
#TODO : Paralelization