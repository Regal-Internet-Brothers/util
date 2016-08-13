Strict

Public

' Imports (Public):
Import bitfield
Import compare

' Imports (Private):
Private

Import brl.stream
Import brl.databuffer

Import except

Public

' This command treats data as 8-bit (Turns something like $F7, into $FFFFFFF7)
' This is only applied on little-endian systems,
' please use this command for hex values (Monkey converts hex on compile-time).
Function PaddedHex:UInt(I:UInt)
	If (Not BigEndian()) Then
		Return AsByte(I)
	Endif
	
	Return I
End

' This command is little-endian only:
Function AsByte:UInt(I:UInt)
	Return ((I Shl 24) Shr 24)
End

' This command is useful when dealing with arrays.
Function OutOfBounds:Bool(Position:UInt, Length:UInt)
	Return (Position >= Length)
End

' This performs a transfer operation from 'InputStream' to
' 'OutputStream', using a block of memory of size 'DataSize'.
Function Transfer:Void(InputStream:Stream, OutputStream:Stream, DataSize:UInt)
	' Check for errors:
	#If Not MONKEYLANG_EXTENSION_TYPE_UNISGNED_INT
		If (DataSize <= 0) Then
			Throw New StreamTransferException(Null, DataSize)
		Endif
	#End
	
	If (InputStream = Null Or OutputStream = Null) Then
		Throw New StreamUnavailableException()
	End
	
	' Local variable(s):
	#If UTIL_TEMP_BUFFERS
		Local Data:DataBuffer = New DataBuffer(DataSize)
		
		If (Data = Null) Then ' Data.Length <> DataSize
			Throw New BulkAllocationException<DataBuffer>(Data, DataSize)
		Endif
		
		Local DataLength:= DataSize ' Data.Length
		
		' Read from the input-stream, then write to the output-stream:
		InputStream.ReadAll(Data, 0, DataLength)
		OutputStream.WriteAll(Data, 0, DataLength)
		
		Data.Discard()
	#Else
		'Local Data:Int[DataSize]
		'Local Data:Byte[DataSize]
		
		' This is terrible, but it's our only option without temporary buffers.
		For Local I:= 1 To DataSize ' Data.Length
			OutputStream.WriteByte(InputStream.ReadByte())
		Next
	#End
	
	Return
End

Function ResizeBuffer:DataBuffer(Buffer:DataBuffer, Size:Long=AUTOMATIC_LENGTH, CopyData:Bool=True, DiscardOldBuffer:Bool=False, OnlyWhenDifferentSizes:Bool=False)
	Local BufferAvailable:Bool = (Buffer <> Null)
	
	If (BufferAvailable And OnlyWhenDifferentSizes) Then
		If (Size <> AUTOMATIC_LENGTH And Buffer.Length = Size) Then
			Return Buffer
		Endif
	Endif
	
	If (Size = AUTOMATIC_LENGTH) Then
		Size = Buffer.Length
	Endif
	
	' Allocate a new data-buffer.
	Local B:= New DataBuffer(Size)
	
	' Copy the buffer's bytes over to 'B'.
	If (BufferAvailable) Then
		If (CopyData) Then
			' Copy the contents of 'Buffer' to the newly generated buffer-object.
			Buffer.CopyBytes(0, B, 0, Buffer.Length)
		Endif
		
		If (DiscardOldBuffer) Then
			' Discard the old buffer.
			Buffer.Discard()
		Endif
	Endif
	
	' Return the newly generated buffer.
	Return B
End

Function SetBuffer:Void(Output:DataBuffer, Value:Byte, Count:UInt, Offset:UInt=0)
	For Local I:= Offset Until (Count + Offset)
		Output.PokeByte(I, Value)
	Next
	
	Return
End

Function SetBuffer:Void(Output:DataBuffer, Value:Byte, Offset:UInt=0)
	SetBuffer(Output, Value, Output.Length - Offset, Offset)
	
	Return
End

Function SetBuffer:Void(Output:DataBuffer, Bytes:Byte[], Bytes_Length:UInt, Bytes_Offset:UInt=0, Offset:UInt=0)
	For Local I:= 0 Until Bytes_Length
		Output.PokeByte((I + Offset), Bytes[I + Bytes_Offset])
	Next
	
	Return
End

Function SetBuffer:Void(Output:DataBuffer, Bytes:Byte[], Offset:UInt=0)
	SetBuffer(Output, Bytes, Bytes.Length, 0, Offset)
	
	Return
End