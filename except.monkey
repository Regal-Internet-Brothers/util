Strict

Public

' Imports (Private):
Private

Import regal.typetool

Import brl.stream
Import brl.databuffer

Public

' Classes:

' This is used to catch (And throw) an unspecific allocation exception.
Class AllocationException Extends Throwable
	' Constructor(s):
	Method New(RequestedSize:UInt)
		Self.RequestedSize = RequestedSize
	End
	
	' Methods:
	Method ToString:String()
		Return "An error occurred while allocating a dynamic are of memory. {" + RequestedSize + " bytes}"
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