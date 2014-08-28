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

#If CONFIG = "release"
	#DEBUG_PRINT_ON_ERROR = True
#Else
	#DEBUG_PRINT_ON_ERROR = False
#End

#DEBUG_PRINT_QUOTES = False

#READ_LINE_QUICKLY = True

#If HOST = "winnt"
	#WRITE_LINE_ENDTYPE = "CRLF"
#Else
	#WRITE_LINE_ENDTYPE = "LF"
#End

' Imports (Public):
Import autostream

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

' Imports (Private):
Private

' Official:

' BRL:
Import brl.databuffer
Import brl.stream
Import brl.filepath

Public

' Constant variable(s):

' Ascii codes:
Const ASCII_CARRIAGE_RETURN:Int = 13
Const ASCII_LINE_FEED:Int = 10

' Used mainly for external code where '-9999...' isn't ever going to be valid.
' You should stick to 'Null' in most cases; try not to use this.
Const NOVAR:Int = -999999

' This is for situations where the length of something can be optional.
Const AUTOMATIC_LENGTH:Int = -1

Const ErrorTemplate:String = "[ERROR] {Debug}: " ' + Space
Const LogTemplate:String = "[Info] {Debug}: " ' + Space

' Global variable(s) (Public):
#If CONSOLE_IMPLEMENTED
	Global DebugConsole:Console = Null
#End

' A global stack logging randomization seeds.
' This is commonly accessed by the 'PushSeed' and 'PopSeed' functions.
Global SeedStack:Stack<Int> = Null

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

' This command is a helper function for 
Function ProcessColorLocation:Int(Point:Int)
	' Check for errors:
	If (Point < 0) Then
		Return 0
	Endif
	
	Return (SizeOf_Integer_InBits-(SizeOf_Octet_InBits*(Point+1))) ' ((SizeOf_Integer_InBits-SizeOf_Octet_InBits)-(SizeOf_Octet_InBits*Point))
End

' NOTE: This command will produce incorrect color values without all characters present in the encode-string.
Function ColorToString:String(Pixel:Int, Encoding:String="ARGB")
	' Ensure the encoding is always described as uppercase.
	Encoding = Encoding.ToUpper()
	
	' Return the encoded color-string.
	Return ("R: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("R"))) & $000000FF) +
			", G: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("G"))) & $000000FF) +
			", B: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("B"))) & $000000FF) +
			", A: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("A"))) & $000000FF))
End

Function PrintColor:Void(Pixel:Int, Encoding:String="ARGB")
	Print(ColorToString(Pixel, Encoding))
	
	Return
End

' This is just a wrapper for the main implementation:
Function PushSeed:Bool()
	Return PushSeed(Seed)
End

' The return value of this function specifies if the seed-stack already existed.
Function PushSeed:Bool(Seed:Int)
	' Local variable(s):
	Local Response:Bool = (SeedStack <> Null)
	
	If (Not Response) Then
		SeedStack = New IntStack()
	Endif
	
	SeedStack.Push(Seed)
	
	' Return the calculated response.
	Return Response
End

' This command retrieves a seed from the seed-stack,
' if no seed exists, the current randomization seed is returned.
Function PopSeed:Int()
	If (SeedStack <> Null) Then
		If (Not SeedStack.IsEmpty()) Then
			Return SeedStack.Pop()
		Endif
	Endif
	
	' Return the default response.
	Return Seed
End

' This command writes a standard line to a 'Stream'.
' This supports both 'LF', and 'CRLF' line endings currently, and this can be configured with 'WRITE_LINE_ENDTYPE'.
' Though character encoding is supported with this, only ASCII is supported by 'ReadLine'.
Function WriteLine:Bool(S:Stream, Line:String, CharacterEncoding:String="ascii")
	' Check for errors:
	If (S = Null) Then
		Return False
	Endif
	
	S.WriteString(Line, CharacterEncoding)
	
	#If WRITE_LINE_ENDTYPE = "CRLF"
		S.WriteByte(ASCII_CARRIAGE_RETURN)
	#End
	
	S.WriteByte(ASCII_LINE_FEED)
	
	' Return the default response.
	Return True
End

' This command reads a standard line from a 'Stream'. (This supports both 'LF', and 'CRLF' line endings currently)
' In addition, only 'ASCII' is currently supported.
Function ReadLine:String(S:Stream)
	' Local variable(s):
	Local Position:= S.Position()
	Local Padding:Int = 0 ' * SizeOf_Char
	Local Str:String
	
	#If Not READ_LINE_QUICKLY
		Local Size:Int = 0
	#End
	
	While (Not S.Eof())
		Local Char:= S.ReadByte()
		
		If (Char <> ASCII_LINE_FEED) Then
			If (Char <> ASCII_CARRIAGE_RETURN) Then
				#If READ_LINE_QUICKLY
					Str += String.FromChar(Char)
				#Else
					Size += 1
				#End
			Else
				Padding = 2*SizeOf_Char
			Endif
		Else
			#Rem
				If (Padding = 0) Then
					Padding = 1
				Endif
			#End
			
			Padding = Max(Padding, 1*SizeOf_Char)
			
			Exit
		Endif
	Wend
	
	#If Not READ_LINE_QUICKLY
		S.Seek(Position)
		
		Str = S.ReadString(Size, "ascii")
		
		S.Seek(S.Position()+Padding)
	#End
	
	' Return the string we read from the stream.
	Return Str
End

Function ResizeBuffer:DataBuffer(Buffer:DataBuffer, Size:Int=AUTOMATIC_LENGTH, CopyData:Bool=True, DiscardOldBuffer:Bool=False, OnlyWhenDifferentSizes:Bool=False)
	Local BufferAvailable:Bool = (Buffer <> Null)
	
	If (BufferAvailable And OnlyWhenDifferentSizes) Then
		If (Size <> AUTO And Buffer.Length() = Size) Then
			Return Buffer
		Endif
	Endif
	
	If (Size = AUTOMATIC_LENGTH) Then
		Size = Buffer.Length()
	Endif
	
	' Allocate a new data-buffer.
	Local B:= New DataBuffer(Size)
	
	' Copy the buffer's bytes over to 'B'.
	If (BufferAvailable) Then
		If (CopyData) Then
			' Copy the contents of 'Buffer' to the newly generated buffer-object.
			Buffer.CopyBytes(0, B, 0, Buffer.Length())
		Endif
		
		If (DiscardOldBuffer) Then
			' Discard the old buffer.
			Buffer.Discard()
		Endif
	Endif
	
	' Return the newly generated buffer.
	Return B
End

#If CONSOLE_IMPLEMENTED
	Function DebugBind:Bool(C:Console)
		If (C = Null) Then Return False
		
		DebugConsole = C
		
		' Return the default response.
		Return True
	End
#End

Function DebugError:Void(E:Throwable, StopExecution:Bool=True)
	#If CONFIG = "debug"
		DebugStop()
	#Else
		DebugPrint("Unknown exception has been thrown; continuing anyway.")
	#End
	
	Return
End

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
			#If DEBUG_PRINT_ON_ERROR
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
	' Constant variable(s):
	
	' Comparison response codes (Positive numbers are for error-reporting):
	Const COMPARE_RESPONSE_IDENTICAL:Int			= -1
	Const COMPARE_RESPONSE_WRONG_LENGTH:Int			= -2
	
	' Other:
	Const AUTO:Int = -1
	
	' Global variable(s):
	
	' For internal and extern use. That being said, please do not modify this value.
	Global NIL:T
	
	' Functions:
	Function AsString:String(Input:Bool)
		Return BoolToString(Input)
	End
	
	Function AsString:String(S:Stream, Length:Int=AUTO, Encoding:String="utf8")
		If (Length = AUTO) Then
			Length = S.Length()
		Endif
		
		Return S.ReadString(Length, Encoding)
	End
	
	Function AsString:String(Input:T[], Offset:Int=0, Length:Int=AUTO, AddSpaces:Bool=True)
		' Local variable(s):
		Local Output:String = LeftBracket
		
		' If no length was specified, use the array's length.
		If (Length = AUTO) Then
			Length = Input.Length()
		Endif
		
		Local VirtualLength:= Length+Offset
		
		For Local Index:Int = Offset Until VirtualLength
			Output += Input[Index]
			
			If (Index+1 < VirtualLength) Then
				Output += Comma
				
				If (AddSpaces) Then
					Output += Space
				Endif
			Endif
		Next
		
		Return Output + RightBracket
	End
	
	Function CopyStringToArray:T[](S:String, Input:T[], Offset:Int=0, Length:Int=AUTO)
		If (Length = AUTO) Then
			Length = Min(S.Length(), Input.Length())
		Endif
		
		For Local I:Int = Offset Until Length
			Input[I] = S[I]
		Next
		
		' Just for the sake of convenience, return the 'Input' array.
		Return Input
	End
	
	Function IndexOfList:T(L:List<T>, Index:Int=0)
		' Local variable(s):
		Local Data:list.Node<T> = L.FirstNode()
				
		For Local I:= 0 Until Index
			Data = Data.NextNode()
			
			' Not my favorite method, but it works:
			If (Data = Null) Then
				Return NIL
			Endif
		Next
		
		' Return the value of the assessed node.
		Return Data.Value()
	End
	
	Function Zero:T[](Input:T[])
		Return Nil(Input)
	End
	
	Function Nil:T[](Input:T[])
		For Local Index:= 0 Until Input.Length()
			Input[Index] = NIL
		Next
		
		Return Input
	End
	
	Function PrintArray:Void(Input:T[])
		Print(AsString(Input))
		
		Return
	End
	
	Function CopyArray:T[](Source:T[], Destination:T[])
		For Local Index:Int = 0 Until Min(Source.Length(), Destination.Length())
			Destination[Index] = Source[Index]
		Next
		
		Return Destination
	End
	
	Function CopyArray:T[](Source:T[])
		Return CloneArray(Source)
	End
	
	Function CloneArray:T[](Source:T[])
		Return CopyArray(Source, New T[Source.Length()])
	End
	
	' This command returns a positive number upon an error,
	' otherwise a 'response code' will be given (See the "Contant variable(s)" section for details).
	Function Compare:Int(A1:T[], A2:T[], CheckLength:Bool=True)
		' Local variable(s):
		Local A1_Length:= A1.Length
		Local A2_Length:= A2.Length
		
		' Check for errors:
		If (CheckLength) Then
			' Make sure they're both the same length.
			If (A1_Length <> A2_Length) Then
				Return COMPARE_RESPONSE_WRONG_LENGTH
			Endif
		Endif
		
		For Local I:= 0 Until Min(A1_Length, A2_Length)
			If (A1[I] <> A2[I]) Then
				' Not the best of escape methods, but it works.
				Return I
			Endif
		Next
		
		' Return the default response.
		Return COMPARE_RESPONSE_IDENTICAL
	End
	
	' This function returns positive if both arrays are identical.
	Function SimpleCompare:Bool(A1:T[], A2:T[], CheckLength:Bool=True)
		Return (Compare(A1, A2, CheckLength) = COMPARE_RESPONSE_IDENTICAL)
	End
	
	Function Read:T(S:Stream)
		Return Read(S, NIL)
	End
		
	Function Read:T[](S:Stream, DataArray:T[], Size:Int=AUTO)
		If (Size = AUTO) Then Size = S.ReadInt()
		
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
	
	Function Read:String(S:Stream, Data:String, Encoding:String="utf8", Size:Int=AUTO)
		If (Size = AUTO) Then Size = S.ReadInt()
		
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