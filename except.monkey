Strict

Public

' Imports (Private):
Private

Import regal.typetool
Import regal.retrostrings

Import brl.stream
Import brl.databuffer

Import bufferview

Public

' Classes:

#Rem
	Class Exception Extends Throwable
		' ...
	End
#End

' This is used to catch (And throw) an unspecific allocation exception.
Class AllocationException Extends Throwable
	' Constructor(s):
	Method New(RequestedSize:UInt)
		Self.RequestedSize = RequestedSize
	End
	
	' Methods:
	Method ToString:String()
		Return "An error occurred while allocating a dynamic area of memory. {" + RequestedSize + " bytes}"
	End
	
	' Fields:
	Field RequestedSize:UInt
End

' This is used to catch (And throw) specific allocation exceptions.
Class BulkAllocationException<ContainerType> Extends AllocationException
	' Global variable(s) (Private):
	Private
	
	Global NIL:ContainerType
	
	Public
	
	' Constructor(s):
	Method New(Data:ContainerType=NIL, Size:UInt)
		Super.New(Size)
		
		Self.Data = Data
	End
	
	' Fields:
	Field Data:ContainerType
End

Class InvalidViewOperation Extends Throwable Abstract ' InvalidBufferViewOperation
	' Functions:
	Function ConvertAddress:String(Address:UInt)
		Return HexBE(Address)
	End
	
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Self.View = View
		Self.Address = Address
		Self.Count = Count
	End
	
	' Methods:
	Method ToString:String() Abstract
	
	' This reports the number of bytes the operation intended to work with.
	Method PostCount:String()
		Return "{" + Count + " bytes}"
	End
	
	' Fields:
	Field View:BufferView
	
	Field Address:UInt
	Field Count:UInt
End

Class InvalidViewMappingOperation Extends InvalidViewOperation
	' Constructor(s):
	Method New(View:BufferView, Offset:UInt, Count:UInt)
		Super.New(View, Offset, Count)
	End
	
	' Methods:
	Method ToString:String()
		Local Message:= "Failed to map a memory view at: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End

Class InvalidViewReadOperation Extends InvalidViewOperation ' InvalidBufferViewReadOperation
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Super.New(View, Address, Count)
	End
	
	' Methods:
	Method ToString:String()
		Local Message:= "Attempted to read from invalid local memory address: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End

Class InvalidViewWriteOperation Extends InvalidViewOperation ' InvalidBufferViewWriteOperation
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Super.New(View, Address, Count)
	End
	
	' Methods:
	Method ToString:String()
		Local Message:= "Attempted to perform an invalid write-operation on local address: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End

Class StreamTransferException Extends StreamError
	' Constructor(s):
	Method New(S:Stream=Null, TransferSize:UInt)
		Super.New(S)
		
		Self.TransferSize = TransferSize
	End
	
	' Methods:
	Method ToString:String()
		Return "Failed to perform stream transfer operation. {" + TransferSize + " bytes}"
	End
	
	' Fields:
	Field TransferSize:UInt
End

Class StreamUnavailableException Extends StreamError
	' Constructor(s):
	Method New(S:Stream=Null)
		Super.New(S)
	End
	
	Method ToString:String()
		Return "Unable to find valid stream instance(s)."
	End
End