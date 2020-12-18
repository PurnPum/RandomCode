REM  *****  BASIC  *****
Sub Macros

End Sub

Function RunAll_Implementation()
	fixTies()
	primas()
	cleanDailyTables()
	colorScores()
	RunAll_Implementation() = ""
End Function

Function cleanDailyTables()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("AT10:AX303")
	data = range.GetDataArray()
	range2 = ThisComponent.Sheets(1).getCellRangeByName("AZ10:BD303")
	data2 = range2.GetDataArray()
	Dim i,j,k,t As Integer
	Dim cell As Object
	j = 0
	k = 0
	i = ThisComponent.Sheets(1).getCellRangeByName("AX305").Value
	while j < i
		if data(k)(0) <> "" then
			for t = 0 to 4
				cell = ThisComponent.Sheets(1).getCellByPosition(64+t,9+j)
				cell.Value = data(k)(t)
				cell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
			next t
			j = j + 1
		End if
		k = k + 1
	WEnd
	j = 0
	k = 0
	i = ThisComponent.Sheets(1).getCellRangeByName("BD305").Value
	while j < i
		if data2(k)(0) <> "" then
			for t = 0 to 4
				cell = ThisComponent.Sheets(1).getCellByPosition(71+t,9+j)
				cell.Value = data2(k)(t)
				cell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
			next t
			j = j + 1
		End if
		k = k + 1
	WEnd
End Function

Function auxTiesColor(OCell as Object,i as Integer,Value As Integer)
	Dim k As Integer
	Dim cell As Object
	for k = 0 to 2
		cell = ThisComponent.Sheets(0).getCellByPosition(k+2,i+9)
		if cell.Value = Value then
			cell.CellBackColor = OCell.CellBackColor
		End if
	next k
End Function

Function fixTiesColor()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("C10:E303")
	data = range.GetDataArray()	
	Dim i,j,k As Integer
	Dim cell As Object
	i = 0
	while data(i)(0) <> ""
		for j = 0 to 2
			k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(data(i)(j))))
			if k = 2 then REM Dos resultados iguales
				if svc.callFunction("SMALL",Array(Array(data(i)),1)) = data(i)(j) then REM 1º
					auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(12,1),i,data(i)(j))
				else REM 3º
					auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(12,3),i,data(i)(j))
				End if
			End if
			k = data(i)(j)
			t = svc.callFunction("COUNTIF",Array(Array(data(i)),"=4")) REM Colectivo?
			if k = 0 AND t = 2 then REM Doble prima
				auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(13,2),i,data(i)(j))
			elseif (t = 2 AND k <> 4) OR k = 0 then REM Simple prima
				auxTiesColor(ThisComponent.Sheets(1).getCellByPosition(13,1),i,data(i)(j))
				
			end if
		next j
		i = i + 1
	WEnd
End Function

Function colorScores()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("C10:E303")
	data = range.GetDataArray()
	
	Dim i,j As Integer
	Dim APos(2) As Integer
	Dim cell As Object
	Dim AColor(2) As Object
	
	AColor(0) = ThisComponent.Sheets(1).getCellByPosition(11,1)
	AColor(1) = ThisComponent.Sheets(1).getCellByPosition(11,2)
	AColor(2) = ThisComponent.Sheets(1).getCellByPosition(11,3)

	i = 0
	
	while data(i)(0) <> ""
		for j = 0 To 2
			APos(j) = svc.callFunction("SMALL",Array(Array(data(i)),j+1))	
			for k = 0 to 2
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
	Dim oCell As Object
	for k = 0 to 2
		oCell = ThisComponent.Sheets(0).getCellByPosition(33+k,i+9)
		if oCell.Value = Value then
			oCell.Value = ThisComponent.Sheets(0).getCellByPosition(col,5).Value
			oCell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
		End if
	next k
End Function

Function fixTies()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("AH10:AJ303")

	data = range.GetDataArray()	
	Dim i,j,k As Integer
	Dim cell As Object
	i = 0
	while data(i)(0) <> ""
		j = ThisComponent.Sheets(0).getCellByPosition(11,2).Value
		k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(j))) REM Empate 1º
		if k = 2 then
			auxTies(i,0,11)
		End if
		j = ThisComponent.Sheets(0).getCellByPosition(12,2).Value
		k = svc.callFunction("COUNTIF",Array(Array(data(i)),"="&CStr(j))) REM Empate 3º
		if k = 2 then
			auxTies(i,1,12)
		end if
		i = i + 1
	WEnd
End Function

Function primas()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("C10:E303")

	data = range.GetDataArray()
	Dim i,j,k,t As Integer
	Dim oCell As Object
	i = 0
	while data(i)(0) <> ""
		for j = 0 to 2
			k = data(i)(j)
			t = svc.callFunction("COUNTIF",Array(Array(data(i)),"=4")) REM Colectivo?
			if k = 0 AND t = 2 then
REM la celda en la que estamos gano con 0 pts y con colectivo (dos tienen cuatro puntos)
				oCell = ThisComponent.Sheets(0).getCellByPosition(33+j,i+9)
				if oCell.Value >= 0 then REM Evitamos hacer esta operacion mas de una vez
					oCell.Value = oCell.Value-2
					oCell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
				end if
			elseif (t = 2 AND k <> 4) OR k = 0 then
REM la celda en la que estamos gano con colectivo (dos tienen cuatro puntos)
REM O gano con 0 puntos
				oCell = ThisComponent.Sheets(0).getCellByPosition(33+j,i+9)
				if oCell.Value >= 0 then REM Evitamos hacer esta operacion mas de una vez
					oCell.Value = oCell.Value-1
					oCell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
				end if
			end if
		next j
		i = i + 1
	WEnd
End Function
