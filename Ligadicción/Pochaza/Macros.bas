REM  *****  BASIC  *****

Sub Main

End Sub

Function RunAll()
	If NOT BasicLibraries.isLibraryLoaded("Macrazos") Then
		BasicLibraries.LoadLibrary("Macrazos")
	End If
	RunAll = RunAll_Implementation()
End Function

Function colorScores()
	If NOT BasicLibraries.isLibraryLoaded("Macrazos") Then
		BasicLibraries.LoadLibrary("Macrazos")
	End If
	colorScores = colorScores_Implementation()
End Function
