Strict

Public

' Imports:
Import regal.util.bufferview

' Functions:
Function Main:Int()
	Print("Creating array-views... (A & B)")
	
	Local A:= New IntArrayView(4)
	Local B:= New ShortArrayView(A.Length * 2)
	
	Print("A is " + A.Size + " bytes long. {" + A.ElementSize + " bytes per element}")
	Print("B is " + B.Size + " bytes long. {" + B.ElementSize + " bytes per element}")
	
	Print("~nGiving the array-views appropriate data:")
	
	' Give 'A' and 'B' appropriate content:
	
	' Set the contents of 'A' to multiples of 'A_ClearMultiple':
	Local A_ClearMultiple:= 10 ' 65535
	
	Print("Providing 'A' with multiples of " + A_ClearMultiple + "...")
	
	For Local I:= 0 Until A.Length
		A.Set(I, ((I + 1) * A_ClearMultiple)) ' 10, 20, ...
	Next
	
	' Zero-initialize the contents of 'B':
	Local B_ClearValue:= 42
	
	Print("Setting the contents of 'B' to " + B_ClearValue + "...")
	
	B.Clear(B_ClearValue) ' 42, 42, ...
	
	Print("~n")
	
	Print("The contents of 'A' are: ")
	
	ReportView(A)
	
	Print("~nThe contents of 'B' are: ")
	
	ReportView(B)
	
	Print("~nPerforming a raw transfer from 'A' into 'B'...")
	
	A.Transfer(0, B, 0, A.Length)
	
	Print("~nThe contents of 'B' are now: ")
	
	ReportView(B)
	
	Return 0
End

Function ReportView:Void(View:IntArrayView) ' ShortArrayView
	For Local I:= 0 Until View.Length
		Print("[" + I + "]: " + View.Get(I))
	Next
	
	Return
End