Strict

Public

' Imports:
Import regal.util.buffers
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
	
	Print("Storing the value '" + Value + "' at index " + Index)
	
	Buffer.Set(Index, Value)
	
	Print("Retrieving the value stored at index " + Index + ":")
	
	Local RetValue:= Buffer.Get(Index)
	
	Print(RetValue)
	
	Print("~n") ' Two lines.
	
	If (Value = RetValue) Then
		Print("| Both values match. |")
		Print("// (" + RetValue + ") \\")
	Else
		Print(": The value retreived does not match the original value :")
		Print("\\ {" + String(Value) + " vs. " + String(RetValue) + "} //")
	Endif
	
	Print("Squaring the value stored at index " + Index + ":")
	
	Local Current:= Buffer.Get(Index)
	Local Square:= Buffer.Sq(Index)
	
	Print(String(Current) + " -> " + String(Square))
	
	Return 0
End