REM  *****  BASIC  *****
Sub Macros

End Sub

Function RunAll_Implementation()
	primas()
	cleanDailyTables()
	colorScores()
	RunAll_Implementation() = ""
End Function

Function cleanDailyTables()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(1).getCellRangeByName("AF10:AI303")
	data = range.GetDataArray()
	range2 = ThisComponent.Sheets(1).getCellRangeByName("AK10:AN303")
	data2 = range2.GetDataArray()
	Dim i,j,k,t As Integer
	Dim cell As Object
	j = 0
	k = 0
	i = ThisComponent.Sheets(1).getCellRangeByName("AI305").Value
	while j < i
		if data(k)(0) <> "" then
			for t = 0 to 3
				cell = ThisComponent.Sheets(1).getCellByPosition(47+t,9+j)
				cell.Value = data(k)(t)
				cell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
			next t
			j = j + 1
		End if
		k = k + 1
	WEnd
	j = 0
	k = 0
	i = ThisComponent.Sheets(1).getCellRangeByName("AN305").Value
	while j < i
		if data2(k)(0) <> "" then
			for t = 0 to 3
				cell = ThisComponent.Sheets(1).getCellByPosition(53+t,9+j)
				cell.Value = data2(k)(t)
				cell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
			next t
			j = j + 1
		End if
		k = k + 1
	WEnd
End Function

Function colorScores()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("AH10:AI303")
	data = range.GetDataArray()
	range2 = ThisComponent.Sheets(1).getCellRangeByName("E5:I5")
	data2 = range2.GetDataArray()
	
	Dim i,j,t As Integer
	Dim cell As Object
	Dim AColor(4) As Object
	
	AColor(0) = ThisComponent.Sheets(1).getCellByPosition(13,2) REM Prima 		->		+50
	AColor(1) = ThisComponent.Sheets(1).getCellByPosition(11,1) REM 1º 			->		+10
	AColor(2) = ThisComponent.Sheets(1).getCellByPosition(11,2) REM Empate 		->	 	  0
	AColor(3) = ThisComponent.Sheets(1).getCellByPosition(11,3) REM 2º 			-> 		-10
	AColor(4) = ThisComponent.Sheets(1).getCellByPosition(13,3) REM Prima en contra -> 	-50

	i = 0	
	while data(i)(0) <> ""
		for j = 0 To 1
			for k = 0 to 4
				t = svc.callFunction("LARGE",Array(Array(data2(0)),k+1)) REM Comparamos el dato con los 5 posibles valores
				if t = data(i)(j) then REM Si coincide asignamos color segun la pos k en el vector AColor
					cell = ThisComponent.Sheets(0).getCellByPosition(3+j,i+9)
					cell.CellBackColor = AColor(k).CellBackColor
					Exit for
				End if
			next k
		next j
		i = i + 1
	WEnd
End Function

Function primas()
	svc = createUnoService("com.sun.star.sheet.FunctionAccess")
	range = ThisComponent.Sheets(0).getCellRangeByName("D10:E303")

	data = range.GetDataArray()
	Dim i,j As Integer
	Dim oCell,oCell2 As Object
	i = 0
	while data(i)(0) <> ""
		for j = 0 to 1
			if data(i)(j) = 0 then
				oCell = ThisComponent.Sheets(0).getCellByPosition(33,i+9)
				oCell2 = ThisComponent.Sheets(0).getCellByPosition(34,i+9)
				if oCell.Value = 10 OR oCell.Value = -10 then
					oCell.Value = oCell.Value*5
					oCell.CharPosture = com.sun.star.awt.FontSlant.ITALIC
				end if
				if oCell2.Value = 10 OR oCell2.Value = -10 then
					oCell2.Value = oCell2.Value*5
					oCell2.CharPosture = com.sun.star.awt.FontSlant.ITALIC
				end if
			end if
		next j
		i = i + 1
	WEnd
End Function
