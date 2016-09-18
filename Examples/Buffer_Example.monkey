Strict

Public

' Imports:
Import regal.util.bufferview
Import regal.util.meta
Import regal.sizeof

' Functions:
Function Main:Int()
	Local Buffer:= New ShortArrayView(16)
	
	Print("The allocated buffer is " + Buffer.Size + " bytes long, and " + Buffer.Length + " elements in length.")
	
	' This is not supported by default Monkey:
	#If MONKEYLANG_TYPE_EXTENSIONS
		Print("Elements are " + TypeAsString(Buffer.NIL) + "s, which have s detectable size of " + SizeOf(Buffer.NIL))
	#End
	
	Local Value:= 134
	Local Index:= 12
	
	Print("")
	
	Print("Storing the value '" + Value + "' at index " + Index + ".")
	
	Buffer.Set(Index, Value)
	
	Print("Retrieving the value stored at index " + Index + ":")
	
	Local RetValue:= Buffer.Get(Index)
	
	Print(RetValue)
	
	Print("")
	
	If (Value = RetValue) Then
		Print("| Both values match. |")
		Print("// (" + RetValue + ") \\")
	Else
		Print(": The value retreived does not match the original value :")
		Print("\\ {" + String(Value) + " vs. " + String(RetValue) + "} //")
	Endif
	
	Print("~nSquaring the value stored at index " + Index + ":")
	
	Local Current:= Buffer.Get(Index)
	Local Square:= Buffer.Sq(Index)
	
	Print(String(Current) + " -> " + String(Square))
	
	Local NewData:= New Int[Buffer.Length] ' 0, 2, 4, 6, 8, ...
	
	For Local I:= 0 Until NewData.Length
		NewData[I] = (I * 2)
	Next
	
	Buffer.SetArray(0, NewData, NewData.Length)
	
	Local NewTestIndex:= 3
	
	Print("~nChecking index " + NewTestIndex + ":~n")
	
	Local NewValue:= NewData[NewTestIndex]
	Local NewRetValue:= Buffer.Get(NewTestIndex)
	Local NewRetValueAlt:= Buffer.GetArray(NewTestIndex, 1)[0]
	
	Print("NewData[" + NewTestIndex + "] = " + NewValue)
	Print("Buffer[" + NewTestIndex + "] = " + NewRetValue)
	Print("Alternate access of Buffer[" + NewTestIndex + "] = " + NewRetValueAlt)
	
	Print("")
	
	If (NewValue = NewRetValue) Then
		Print("| Both values are the same. |")
	Else
		Print(": The two values are different. :")
	Endif
	
	Return 0
End