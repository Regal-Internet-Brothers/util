Strict

Public

' Preprocessor related:
#Rem
#If TARGET = "glfw" Or TARGET = "sexy"
	#GLFW_TARGET = True
#End
#End

#If CONFIG = "debug"
	#DEBUG_PRINT = True
#Else
	#DEBUG_PRINT = False
#End

#DEBUG_PRINT_QUOTES = False

' Imports (Public):
Import byteorder
Import imagedimensions
Import retrostrings
Import stringutil
Import vector

#If CONSOLE_IMPLEMENTED
	Import console
#End

Import sizeof
Import time

#If Not BRL_GAMETARGET_IMPLEMENTED
	Import mojoemulator
#End

Import publicdatastream

' Imports (Private):
Private

' Official:

' BRL:
Import brl.databuffer
Import brl.stream
Import brl.filepath

' Unofficial:

' ImmutableOctet:
Import autostream

Public

' Constant variable(s):

' Used mainly for external code where '-9999...' isn't ever going to be valid.
' You should stick to 'Null' in most cases; try not to use this.
Const NOVAR:Int = -999999

Const ErrorTemplate:String = "[ERROR] {Debug}: " ' + Space
Const LogTemplate:String = "[Info] {Debug}: " ' + Space

' Global variable(s) (Public):
#If CONSOLE_IMPLEMENTED
	Global DebugConsole:Console = Null
#End

' Global variable(s) (Private):
Private

' Nothing so far.

Public

' Functions:
Function FLAG:Int(ID:Int)
	Return Pow(2, ID)
End

' This command is little-endian only:
Function AsByte:Int(I:Int)
	Return ((I Shl 24) Shr 24)
End

' This command treats data as 8-bit (Turns something like $F7, into $FFFFFFF7)
' This is only applied on little-endian systems,
' please use this command for hex values (Monkey converts hex on compile-time).
Function PaddedHex:Int(I:Int)
	If (Not BigEndian()) Then
		Return AsByte(I)
	Endif
	
	Return I
End

Function Transfer:Bool(InputStream:Stream, OutputStream:Stream, DataSize:Int)
	' Check for errors:
	If (DataSize = 0) Then Return False
	If (InputStream = Null Or InputStream.Eof()) Then Return False
	If (OutputStream = Null) Then Return False
	
	' Local variable(s):
	#If FLAG_TEMP_BUFFERS
		Local Data:DataBuffer = New DataBuffer(DataSize)
		Local DataLength:= DataSize ' Data.Length()
		
		' Read from the input-stream, then write to the output-stream:
		InputStream.Read(Data, 0, DataLength)
		OutputStream.Write(Data, 0, DataLength)
		
		Data.Discard()
	#Else
		'Local Data:Int[DataSize]
		
		For Local I:Int = 1 To DataSize ' Data.Length()
			OutputStream.WriteByte(InputStream.ReadByte())
		Next
	#End
	
	' Return the default response.
	Return True
End

Function Sq:Float(Input:Float)
	Return Pow(Input, 2.0) ' Input * Input
End

Function Sq:Int(Input:Int)
	Return Pow(Input, 2)
End

Function WrapAngle:Float(A:Float)
	While (A < 0.0)
		A += 360.0
	Wend
	
	While (A > 360.0)
		A -= 360.0
	Wend
	
	Return A
End

Function WrapColor:Float(C:Float)
	#Rem
	While (C < 0.0)
		C += 255.0
	Wend
	
	While (C > 255.0)
		C -= 255.0
	Wend
	#End
	
	Return C Mod 256.0
End

#If CONSOLE_IMPLEMENTED
	Function DebugBind:Bool(C:Console)
		If (C = Null) Then Return False
		
		DebugConsole = C
		
		' Return the default response.
		Return True
	End
#End

Function DebugError:Void(Msg:String, StopExecution:Bool=True)
	#If DEBUG_PRINT
		' Local variable(s):
		Local TempMsg:String
		
		If (StopExecution) Then
			TempMsg = ErrorTemplate
		Else
			TempMsg = LogTemplate
		Endif
		
		#If DEBUG_PRINT_QUOTES			
			Msg = Tempmsg + Quote + Msg + Quote
		#Else
			Msg = TempMsg + Msg
		#End
		
		#If CONSOLE_IMPLEMENTED
			If (DebugConsole <> Null) Then
				DebugConsole.WriteLine(Msg, True)
			Else
		#End
		
		Print(Msg)
		
		#If CONSOLE_IMPLEMENTED
			Endif
		#End
	#Else
		' This may change later:
		If (StopExecution) Then
			Msg = ErrorTemplate + Msg
		Endif
	#End

	If (StopExecution) Then
		#If CONFIG = "debug"
			#If DEBUG_PRINT
				DebugStop()
			#Else
				Error(Msg)
			#End
		#Else
			#If DEBUG_PRINT
				Local FinalStr:String = (ErrorTemplate + Quote + "Attempt to stop execution failed. (Reason: Release-mode)" + Quote)
				
				#If CONSOLE_IMPLEMENTED
					If (DebugConsole <> Null) Then
						DebugConsole.WriteLine(FinalStr, True)
					Else
				#End
				
				Print(FinalStr)
				
				#If CONSOLE_IMPLEMENTED
					Endif
				#End
			#Else
				Error(Msg)
			#End
		#End
	Endif
	
	#If CONFIG = "debug"
		' Nothing so far.
	#Else
		' Nothing so far.
	#End

	Return
End

Function DebugPrint:Void(Str:String, StopExecution:Bool=False)
	DebugError(Str, StopExecution)

	Return
End

' Classes:
Class GenericUtilities<T>
	' Global variable(s):
	Global NIL:T
	
	' Functions:
	Function IndexOfList:T(L:List<T>, Index:Int=0)
		' Local variable(s):
		Local Response:T
		Local Data:list.Node<T> = L.FirstNode()
				
		For Local I:= 0 Until Index
			Data = Data.NextNode()
			
			' Not my favorite method, but it works:
			If (Data = Null) Then
				Return Response
			Endif
		Next
		
		Response = Data.Value()
		
		' Return the value of the assessed node.
		Return Response
	End
	
	Function CopyArray:T[](Source:T[], Destination:T[]=[], SourceOffset:Int=0, DestinationOffset:Int=0)
		If (Destination.Length() = 0) Then
			Destination = New T[Source.Length()]
		Endif
		
		Local MinLength:Int = Min(Source.Length(), Destination.Length())
		
		For Local Index:Int = 0 Until MinLength
			' Local variable(s):
			Local DestinationIndex:= Index+DestinationOffset
			Local SourceIndex:= Index+SourceOffset
			
			' Check if we can perform the current operation:
			If (DestinationIndex >= Destination.Length() Or SourceIndex >= Source.Length()) Then
				Exit
			Endif
			
			Destination[DestinationIndex] = Source[SourceIndex]
		Next
		
		Return Destination
	End
	
	Function CloneArray:T[](Source:T[], Destination:T[]=[])
		Return CopyArray(Source, Destination)
	End
	
	Function Read:T(S:Stream)
		Return Read(S, NIL)
	End
		
	Function Read:T[](S:Stream, DataArray:T[], Size:Int=-1)
		If (Size = -1) Then Size = S.ReadInt()
		
		If (Size > 0) Then
			If (DataArray.Length() = 0) Then
				DataArray = New T[Size]
			Endif
		Endif
		
		' Local variable(s):
		Local DLength:Int = Min(DataArray.Length, Size)
		
		For Local Index:= 0 Until DLength
			DataArray[Index] = Read(S, NIL)
		Next
		
		Return DataArray
	End
	
	Function Write:Void(S:Stream, DataArray:T[], WriteLength:Bool=True)
		' Local variable(s):
		Local DLength:= DataArray.Length()
		
		If (WriteLength) Then S.WriteInt(DLength)
		
		For Local Index:= 0 Until DLength
			Write(S, DataArray[Index])
		Next
		
		Return
	End
	
	Function Read:Int(S:Stream, Indentifier:Int, Size:Int=4)
		' Local variable(s):
		Local Data:Int = 0
		
		If (Size > 1) Then
			If (Size < 4) Then
				Data = S.ReadShort()
			Else
				If (Size > 4) Then
					S.ReadInt()
				Endif
				
				Data = S.ReadInt()
			Endif
		Else
			Data = S.ReadByte()
		Endif
		
		Return Data
	End
	
	Function Write:Void(S:Stream, Data:Int, Size:Int=4)
		Size = IntSize(Size)
		
		If (Size > 1) Then
			If (Size < 4) Then
				S.WriteShort(Data)
			Else
				If (Size > 4) Then
					S.WriteInt(0)
				Endif
				
				S.WriteInt(Data)
			Endif
		Else
			S.WriteByte(Data)
		Endif
		
		Return
	End
	
	#Rem
	Function Read:Bool(S:Stream, Identifier:Bool)
		Return Read(S, Int(Identifier), 1)
	End
	
	Function Write:Void(S:Stream, B:Bool)
		Write(S, Int(B), 1)
		
		Return
	End
	#End
	
	Function Read:Float(S:Stream, Identifier:Float)		
		Return S.ReadFloat()
	End
	
	Function Write:Void(S:Stream, Data:Float)
		S.WriteFloat(Data)
		
		Return
	End
	
	Function Read:String(S:Stream, Data:String, Encoding:String="utf8", Size:Int=-1)
		If (Size = -1) Then Size = S.ReadInt()
		
		Data = S.ReadString(Size, Encoding)
		
		' Return the newly read string.
		Return Data
	End
	
	Function Write:Void(S:Stream, Data:String, Encoding:String="utf8", WriteSize:Bool=True)
		If (WriteSize) Then S.WriteInt(Data.Length())
		S.WriteString(Data, Encoding)
		
		Return
	End
End