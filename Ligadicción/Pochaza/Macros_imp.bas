REM  *****  BASIC  *****
Sub Macros

End Sub

Function RunAll_Implementation()
	OperacionPtsPocha("AVERAGE",true,"AF2")
	OperacionPtsPocha("AVERAGE",false,"AF3")
	OperacionPtsPocha("MIN",true,"AF4")
	OperacionPtsPocha("MAX",false,"AF7")
	Diff(1,4,true,"AM2")
	Diff(1,4,false,"AM3")
	CantDiff(1,2,"AM5")
	CantDiff(3,4,"AM6")
	REM getLeaguePoints()
	fixTies()
	RunAll_Implementation() = ""
End Function

Function auxTiesColor(OCell as Object,i as Integer,Value As Integer)
	Dim k As Integer
	Dim cell As Object
	for k = 0 to 3
		cell = ThisComponent.Sheets(0).getCellByPosition(k+2,i+9)
		if cell.Value = Value then
			cell.CellBackColor = OCell.CellBackColor
		End if
	next k
End Function

Function fixTiesColor()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("C10:F303")
	data = range.GetDataArray()	
	Dim i,j,k As Integer
	Dim cell As Object
	i = 0
	while data(i)(0) <> ""
		for j = 0 to 3
			k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(data(i)(j))))
			Select Case k
				Case 2 REM Dos resultados iguales
					if svc.callFunction("LARGE",Array(Array(data(i)),4)) = data(i)(j) then REM 3º
						auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(12,3),i,data(i)(j))
					else REM 2º
						auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(12,2),i,data(i)(j))
					End If
				Case 3 REM Empate triple
					auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(13,2),i,data(i)(j))
			End Select
		next j
		i = i + 1
	WEnd
End Function

Function colorScores_Implementation()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("C10:F303")
	data = range.GetDataArray()
	
	Dim i,j As Integer
	Dim APos(3) As Integer
	Dim cell As Object
	Dim AColor(3) As Object
	
	AColor(0) = ThisComponent.Sheets(1).getCellByPosition(11,1)
	AColor(1) = ThisComponent.Sheets(1).getCellByPosition(11,2)
	AColor(2) = ThisComponent.Sheets(1).getCellByPosition(11,3)
	AColor(3) = ThisComponent.Sheets(1).getCellByPosition(11,4)

	i = 0
	
	while data(i)(0) <> ""
		for j = 0 To 3
			APos(j) = svc.callFunction("LARGE",Array(Array(data(i)),j+1))	
			for k = 0 to 3
				if Apos(j) = data(i)(k) then
					cell = ThisComponent.Sheets(0).getCellByPosition(2+k,i+9)
					cell.CellBackColor = AColor(j).CellBackColor
					Exit for
				End if
			next k
		next j
		i = i + 1
	WEnd
	fixTiesColor()
End Function

Function auxTies(i as Integer,Value as Integer,col as Integer)
	Dim k As Integer
	Dim cell As Object
	for k = 0 to 3
		cell = ThisComponent.Sheets(0).getCellByPosition(33+k,i+9)
		if cell.Value = Value then
			cell.Value = ThisComponent.Sheets(0).getCellByPosition(col,5).Value
		End if
	next k
End Function

Function fixTies()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("AH10:AK303")

	data = range.GetDataArray()	
	Dim i,j,k As Integer
	Dim cell As Object
	i = 0
	while data(i)(0) <> ""
		j = ThisComponent.Sheets(0).getCellByPosition(12,2).Value
		k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(j))) REM Empate 2º
		Select Case k
			Case 2
				auxTies(i,15,11)
			Case 3
				auxTies(i,15,16)
		End Select
		j = ThisComponent.Sheets(0).getCellByPosition(13,2).Value
		k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(j))) REM Empate 3º
		if k = 2 then
			auxTies(i,30,12)
		end if
		i = i + 1
	WEnd
End Function

Function getLeaguePoints()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("U10:X303")

	data = range.GetDataArray()
	Dim i,j,k As Integer
	Dim cell As Object
	Dim cell2 As Object
	Dim APos(3) As Integer
	i = 0
	while data(i)(0) <> ""		
		for j = 0 To 3
			APos(j) = svc.callFunction("LARGE",Array(Array(data(i)),j+1))	
			for k = 0 to 3
				if Apos(j) = data(i)(k) then
					cell = ThisComponent.Sheets(0).getCellByPosition(33+k,i+9)
					cell2 = ThisComponent.Sheets(0).getCellByPosition(11+j,2)
					cell.Value = cell2.Value
					Exit for
				End if
			next k
		next j
		i = i + 1
	WEnd
	fixTies()
End Function
		

Function Diff(Elem1 As Integer, Elem2 As Integer, hl As Boolean, cell As String)
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("U10:X303")
	
	Dim CurrValue,i,Valor As integer
	Dim AFX As Object
	i = 0
	data = range.GetDataArray()
	
	if hl then
		Valor = -1000
	else
		Valor = 1000
	end if
    
	while data(i)(0) <> ""
		CurrValue = svc.callFunction("LARGE",Array(Array(data(i)),Elem1))
		CurrValue = CurrValue - svc.callFunction("LARGE",Array(Array(data(i)),Elem2))
		if hl then
			if Valor < CurrValue Then
				Valor = CurrValue
			End if
		Else
			if Valor > CurrValue Then
				Valor = CurrValue
			End if
		End if
		i = i + 1
	WEnd
	AFX = ThisComponent.Sheets(0).getCellRangeByName(cell)
	AFX.Value = Valor
End Function

Function CantDiff(Elem1 As Integer, Elem2 As Integer, cell As String)
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("U10:X303")
	
	Dim CurrValue,i,Valor As integer
	Dim AFX As Object
	i = 0
	Valor = 0
	data = range.GetDataArray()
    
	while data(i)(0) <> ""
		CurrValue = svc.callFunction("LARGE",Array(Array(data(i)),Elem1))
		CurrValue = CurrValue - svc.callFunction("LARGE",Array(Array(data(i)),Elem2))
		if CurrValue = 5 Then
			Valor = Valor + 1
		End if
		i = i +1
	WEnd
	AFX = ThisComponent.Sheets(0).getCellRangeByName(cell)
	AFX.Value = Valor
End Function

Function OperacionPtsPocha(op As String, hl As Boolean, cell As String)
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("U10:X303")
	
	Dim CurrValue,i,Valor As integer
	Dim AFX As Object
	i = 0
	data = range.GetDataArray()
	
	if hl then
		Valor = -1000
	else
		Valor = 1000
	end if
	while data(i)(0) <> ""
		CurrValue = svc.callFunction(op,data(i))
		if hl then
			if Valor < CurrValue Then
				Valor = CurrValue
			End if
		Else
			if Valor > CurrValue Then
				Valor = CurrValue
			End if
		End if
		i = i + 1
	WEnd
	AFX = ThisComponent.Sheets(0).getCellRangeByName(cell)
	AFX.Value = Valor
End Function
