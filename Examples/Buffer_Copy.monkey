Strict

Public

' Imports:
Import regal.util.bufferview

' Functions:
Function Main:Int()
	Local Source:= New IntArrayView(32)
	Local Destination:= New ByteArrayView(8)
	
	'Source.Clear(127)
	
	For Local I:= 0 Until Source.Length
		Source.Set(I, (I * I))
	Next
	
	ArrayViewOperation<IntArrayView, ByteArrayView>.Copy(Source, 0, Destination, 0, Destination.Length)
	
	Print("Source:")
	ReportView(Source)
	
	Print("Destination:")
	ReportView(Destination)
	
	Return 0
End

Function ReportView:Void(View:IntArrayView)
	For Local I:= 0 Until View.Length
		Print("[" + I + "]: " + View.Get(I))
	Next
	
	Return
End