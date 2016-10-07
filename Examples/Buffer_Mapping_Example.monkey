Strict

Public

' Imports:
Import brl.databuffer

Import regal.sizeof
Import regal.util.bufferview

' Functions:
Function Main:Int()
	' This specifies then number of elements we'll be allocating.
	Local Count:= 4
	
	' Allocate 'Count' 16-bit integers.
	Local RawBuffer:= New DataBuffer(Count * SizeOf_Short)
	
	' Allocate a view of 16-bit integers starting at the beginning of 'RawBuffer'.
	Local BaseView:= New ShortArrayView(RawBuffer)
	
	' Calculate an index to begin our 'OffsetView' object on.
	Local OffsetIndex:= (Count / 4) ' Max(1, ...)
	
	' Get the index before 'OffsetIndex' for the sake of demonstration.
	Local DemoIndex:= (OffsetIndex-1)
	
	' Create a view of 16-bit integers starting 'OffsetIndex' 16-bit integers from the beginning of 'RawBuffer'. (Converted to bytes from indices)
	Local OffsetView:= New ShortArrayView(RawBuffer, BaseView.IndexToAddress(OffsetIndex), (Count / 2)) ' (OffsetIndex * 2)
	
	For Local I:= 0 Until Count
		BaseView.Set(I, (I + 1)) ' 1, 2, 3, ...
	Next
	
	Print("The length of 'BaseView' is: (" + BaseView.Length + ") {Size: " + BaseView.Size + "}")
	Print("The length of 'OffsetView' is: (" + OffsetView.Length + ") {Size: " + OffsetView.Size + ", Offset: " + OffsetView.Offset + "}")
	Print("")
	
	Print("Printing the contents of 'BaseView':")
	
	ReportView(BaseView)
	
	Print("")
	
	Print("Printing the contents of 'OffsetView':")
	
	ReportView(OffsetView)
	
	Print("")
	Print("//// CONTENTS \\\\")
	
	Print("BaseView[" + DemoIndex + "]: " + BaseView.Get(DemoIndex))
	Print("OffsetView[0]: " + OffsetView.Get(0))
	
	DemoIndex += 1 ' <-- 'OffsetIndex'
	
	Print("BaseView[" + DemoIndex + "]: " + BaseView.Get(DemoIndex))
	
	Print("~nClearing 'OffsetView'...~n")
	
	OffsetView.Clear()
	
	Print("Printing the contents of 'BaseView':")
	
	ReportView(BaseView)
	
	Return 0
End

Function ReportView:Void(View:ShortArrayView) ' IntArrayView
	For Local I:= 0 Until View.Length
		Print("[" + I + "]: " + View.Get(I))
	Next
	
	Return
End