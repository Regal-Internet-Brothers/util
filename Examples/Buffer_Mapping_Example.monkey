Strict

Public

' Imports:
Import brl.databuffer

Import regal.sizeof
Import regal.util.bufferview

' Functions:
Function Main:Int()
	' This specifies then number of elements we'll be allocating.
	Local Count:= 8
	
	' Allocate 'Count' 16-bit integers.
	Local RawBuffer:= New DataBuffer(Count * SizeOf_Short)
	
	' Allocate a view of 16-bit integers starting at the beginning of 'RawBuffer'.
	Local BaseView:= New ShortArrayView(RawBuffer)
	
	' Allocate a view of 16-bit integers starting 2 bytes (16-bits) from the beginning of 'RawBuffer'.
	Local OffsetView:= New ShortArrayView(RawBuffer, ((Count / 4) * SizeOf_Short), (Count / 2)) ' (1 * 2)
	'New(Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
	
	For Local I:= 0 Until Count
		BaseView.Set(I, (I + 1)) ' 1, 2, 3, ...
	Next
	
	Print("The length of 'BaseView' is: " + BaseView.Length + "{" + BaseView.Size + " bytes}")
	Print("The length of 'OffsetView' is: " + OffsetView.Length + "{" + OffsetView.Size + " bytes}")
	Print("")
	Print("The first entry of 'BaseView' is: " + BaseView.Get(0))
	Print("The first entry of 'OffsetView' is: " + OffsetView.Get(0))
	Print("The second entry of 'BaseView' is: " + BaseView.Get(1))
	Print("")
	Print("Clearing 'OffsetView'...")
	
	OffsetView.Clear()
	
	Print("Printing the contents of 'BaseView':")
	
	For Local I:= 0 Until BaseView.Length
		Print("[" + I + "]: " + BaseView.Get(I))
	Next
	
	Return 0
End