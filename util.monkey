Strict

Public

' Preprocessor related:
#Rem
#If TARGET = "glfw" Or TARGET = "sexy"
	#GLFW_TARGET = True
#End
#End

#UTIL_IMPLEMENTED = True
#UTIL_WRAP_BOTH_WAYS = True
#UTIL_PREPROCESSOR_FIXES = False ' True
#UTIL_DELEGATE_TYPETOOL = False
#UTIL_TYPECODE_STRINGS_USE_SHORTHAND = False

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

#If Not UTIL_PREPROCESSOR_FIXES
	' These are the actual default settings for these variables:
	#UTIL_READ_LINES_QUICKLY = True
	
	#If HOST = "winnt"
		#UTIL_WRITELINE_ENDTYPE = "CRLF" ' "LF"
	#Else
		#UTIL_WRITELINE_ENDTYPE = "LF"
	#End
#Else
	' The default values of these are purposely separate from the main settings:
	#If READ_LINE_QUICKLY
		#UTIL_READ_LINES_QUICKLY = READ_LINE_QUICKLY
	#Else
		#UTIL_READ_LINES_QUICKLY = True
	#End
	
	#If WRITE_LINE_ENDTYPE
		#UTIL_WRITELINE_ENDTYPE = WRITE_LINE_ENDTYPE
	#Else
		#If HOST = "winnt"
			#UTIL_WRITELINE_ENDTYPE = "CRLF"
		#Else
			#UTIL_WRITELINE_ENDTYPE = "LF"
		#End
	#End
#End

' Imports (Public):
Import external
Import fallbacks

' Open Source Modules:
Import autostream
Import byteorder
Import imagedimensions
Import retrostrings
Import stringutil
Import boxutil
Import vector
Import sizeof
Import time

#If Not BRL_GAMETARGET_IMPLEMENTED
	Import mojoemulator
#End

' Closed Source Modules (Completely optional):
Import console

' Imports (Private):
Private

' Unofficial:
Import ioelement

' Official:

' BRL:
Import brl.databuffer
Import brl.stream
Import brl.filepath

' Mojo:
#If BRL_GAMETARGET_IMPLEMENTED And Not MILLISECS_IMPLEMENTED
	Import mojo.app
#End

Public

' Imports (Other):
#If Not UTIL_DELEGATE_TYPETOOL
	Private
#End

Import typetool

#If Not UTIL_DELEGATE_TYPETOOL
	Public
#End

' Implementation checks:
#If IOELEMENT_IMPLEMENTED
	#UTIL_SUPPORT_IOELEMENTS = True
#End

' Aliases:
Alias TypeCode = Int ' Byte

' Constant variable(s):

' Type codes (Mainly used for generic classes):
Const TYPE_OBJECT:TypeCode			= 0
Const TYPE_INT:TypeCode				= 1
Const TYPE_BOOL:TypeCode			= 2
Const TYPE_FLOAT:TypeCode			= 3
Const TYPE_STRING:TypeCode			= 4

' Type strings (Mainly used by 'TypeToString'):
Const TYPE_UNKNOWN_STR:String			= "Unknown"
Const TYPE_OBJECT_STR:String			= "Object"

#If Not UTIL_TYPECODE_STRINGS_USE_SHORTHAND
	Const TYPE_INT_STR:String			= "Int"
	Const TYPE_BOOL_STR:String			= "Bool"
	Const TYPE_FLOAT_STR:String			= "Float"
	Const TYPE_STRING_STR:String		= "String"
#Else
	Const TYPE_INT_STR:String			= "%"
	Const TYPE_BOOL_STR:String			= "?"
	Const TYPE_FLOAT_STR:String			= "#"
	Const TYPE_STRING_STR:String		= "$"
#End

' Comparison response-codes:
Const COMPARE_UNKNOWN:Int = 0
Const COMPARE_RIGHT:Int = 1
Const COMPARE_LEFT:Int = -1

' Ascii codes:
Const ASCII_CARRIAGE_RETURN:Byte = 13
Const ASCII_LINE_FEED:Byte = 10

' Used mainly for external code where '-9999...' isn't ever going to be valid.
' You should stick to 'Null' in most cases; try not to use this.
Const NOVAR:= -999999

' This acts as a general "automatic-value".
' Basically, you can check against this for things like manually defined array-lengths.
Const UTIL_AUTO:Long = -1

' This is for situations where the length of something can be optional.
Const AUTOMATIC_LENGTH:Long = -1

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

' Functions (Public):

' This command treats data as 8-bit (Turns something like $F7, into $FFFFFFF7)
' This is only applied on little-endian systems,
' please use this command for hex values (Monkey converts hex on compile-time).
Function PaddedHex:UInt(I:UInt)
	If (Not BigEndian()) Then
		Return AsByte(I)
	Endif
	
	Return I
End

Function Transfer:Bool(InputStream:Stream, OutputStream:Stream, DataSize:ULong)
	' Check for errors:
	#If Not MONKEYLANG_EXTENSION_TYPE_UNISGNED_INT
		If (DataSize <= 0) Then Return False
	#End
	
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
		'Local Data:Byte[DataSize]
		
		For Local I:= 1 To DataSize ' Data.Length()
			OutputStream.WriteByte(InputStream.ReadByte())
		Next
	#End
	
	' Return the default response.
	Return True
End

Function Sq:Double(Input:Double)
	Return Input * Input ' Pow(Input, 2.0)
End

Function Sq:Long(Input:Long)
	Return Input * Input ' Pow(Input, 2)
End

#If Not MONKEYLANG_EXPLICIT_BOXES
	Function Sq:Long(IO:IntObject)
		Return Sq(IO.ToInt())
	End
	
	Function Sq:Double(FO:FloatObject)
		Return Sq(FO.ToFloat())
	End
#End

' Ideally, the 'Denom' argument should be positive:
Function SMod:Long(Input:Long, Denom:Long)
	Return GenericUtilities<Long>.SMod(Input, Denom)
End

Function SMod:Double(Input:Double, Denom:Double)
	Return GenericUtilities<Double>.SMod(Input, Denom)
End

#If Not MONKEYLANG_EXPLICIT_BOXES
	Function SMod:Long(IO:IntObject, Denom:IntObject)
		Return SMod(IO.ToInt(), Denom.ToInt())
	End
	
	Function SMod:Double(FO:FloatObject, Denom:FloatObject)
		Return SMod(FO.ToFloat(), Denom.ToFloat())
	End
#End

Function WrapAngle:Double(A:Double)
	#If UTIL_WRAP_BOTH_WAYS
		Return SMod(A, 360.0)
	#Else
		Return A Mod 360.0
	#End
End

Function WrapColor:Double(C:Double)
	#Rem
	While (C < 0.0)
		C += 255.0
	Wend
	
	While (C > 255.0)
		C -= 255.0
	Wend
	#End
	
	#If UTIL_WRAP_BOTH_WAYS
		Return SMod(C, 256.0)
	#Else
		Return (C Mod 256.0)
	#End
End

' Bitwise manipulation commands:
Function FLAG:ULong(BitNumber:ULong)
	Return Pow(2, BitNumber)
End

' This command is little-endian only:
Function AsByte:UInt(I:UInt)
	Return ((I Shl 24) Shr 24)
End

Function ToggleBit:Int(BitField:Int, BitNumber:Int, Value:Bool)
	Return ToggleBitMask(BitField, Pow(2, BitNumber), Value)
End

Function ToggleBitMask:Int(BitField:Int, Mask:Int, Value:Bool)
	If (Value) Then
		Return ActivateBitMask(BitField, Mask)
	Endif
	
	Return DeactivateBitMask(BitField, Mask)
End

Function ToggleBit:Int(BitField:Int, BitNumber:Int)
	Return ToggleBitMask(BitField, Pow(2, BitNumber))
End

Function ToggleBitMask:Int(BitField:Int, Mask:Int)
	If ((BitField & Mask) > 0) Then
		Return ToggleBitMask(BitField, Mask, False)
	Endif
	
	Return ToggleBitMask(BitField, Mask, True)
End

Function BitActivated:Bool(BitField:Int, BitNumber:Int)
	Return BitMaskActivated(BitField, Pow(2, BitNumber))
End

Function BitDeactivated:Bool(BitField:Int, BitNumber:Int)
	Return Not BitActivated(BitField, BitNumber)
End

Function BitMaskActivated:Bool(BitField:Int, Mask:Int)
	Return ((BitField & Mask) > 0)
End

Function BitMaskDeactivated:Bool(BitField:Int, Mask:Int)
	Return Not BitMaskActivated(BitField, Mask)
End

Function ActivateBit:Int(BitField:Int, BitNumber:Int)
	Return ActivateBitMask(BitField, Pow(2, BitNumber))
End

Function DeactivateBit:Int(BitField:Int, BitNumber:Int)
	Return DeactivateBitMask(BitField, Pow(2, BitNumber))
End

Function ActivateBitMask:Int(BitField:Int, Mask:Int)
	Return (BitField | Mask)
End

Function DeactivateBitMask:Int(BitField:Int, Mask:Int)
	Return (BitField & ~Mask) ' (BitField ~ Mask)
End

' Comparison commands:

' To normal Monkey users, these do the same thing:
Function CompareInts:Int(X:Int, Y:Int)
	Return X-Y
End

Function CompareLongs:Long(X:Long, Y:Long)
	Return X-Y
End

Function CompareShorts:Short(X:Short, Y:Short)
	Return X-Y
End

Function CompateSBytes:SByte(X:SByte, Y:SByte)
	Return X-Y
End

' This just for the sake of keeping names consistent:
Function CompareBytes:Byte(X:Byte, Y:Byte)
	Return X-Y
End

' The standard return type for non-integral comparison is currently 'Int':
Function CompareFloats:Int(X:Float, Y:Float)
	If (X < Y) Then
		Return COMPARE_LEFT
	Endif
	
	Return Int(X > Y)
End

Function CompareDoubles:Int(X:Double, Y:Double)
	If (X < Y) Then
		Return COMPARE_LEFT
	Endif
	
	Return Int(X > Y)
End

Function CompareStrings:Int(X:String, Y:String)
	Return X.Compare(Y)
End

' Comparison wrappers:
Function Compare:Int(X:Int, Y:Int)
	Return CompareInts(X, Y)
End

Function Compare:Int(X:Float, Y:Float)
	Return CompareFloats(X, Y)
End

Function Compare:Int(X:String, Y:String)
	Return CompareStrings(X, Y)
End

' Extension-based wrappers:
#If MONKEYLANG_EXTENSION_TYPE_LONG
	Function Compare:Long(X:Long, Y:Long)
		Return CompareLongs(X, Y)
	End
#End

#If MONKEYLANG_EXTENSION_TYPE_SHORT
	Function Compare:Short(X:Short, Y:Short)
		Return CompareShorts(X, Y)
	End
#End

#If MONKEYLANG_EXTENSION_TYPE_SBYTE
	Function Compare:SByte(X:SByte, Y:SByte)
		Return CompareSBytes(X, Y)
	End
#End

#If MONKEYLANG_EXTENSION_TYPE_BYTE
	Function Compare:Byte(X:Byte, Y:Byte)
		Return CompareBytes(X, Y)
	End
#End

#If MONKEYLANG_EXTENSION_TYPE_DOUBLE
	Function Compare:Int(X:Double, Y:Double)
		Return CompareDoubles(X, Y)
	End
#End

' This command is a helper function for the inverse position of a byte inside of an integer.
Function ProcessColorLocation:UInt(Point:Byte)
	#If Not MONKEYLANG_EXTENSION_TYPE_BYTE
		' Check for errors:
		If (Point < 0) Then
			Return 0
		Endif
	#End
	
	Return (SizeOf_Integer_InBits-(SizeOf_Octet_InBits*(Point+1))) ' ((SizeOf_Integer_InBits-SizeOf_Octet_InBits)-(SizeOf_Octet_InBits*Point))
End

' NOTE: This command will produce incorrect color values without all characters present in the encode-string.
Function ColorToString:String(Pixel:UInt, Encoding:String="ARGB")
	' Ensure the encoding is always described as uppercase.
	Encoding = Encoding.ToUpper()
	
	' Return the encoded color-string:
	Return ("R: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("R"))) & $000000FF) +
			", G: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("G"))) & $000000FF) +
			", B: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("B"))) & $000000FF) +
			", A: " + ((Pixel Shr ProcessColorLocation(Encoding.Find("A"))) & $000000FF))
End

Function PrintColor:Void(Pixel:UInt, Encoding:String="ARGB")
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

' This command sets the randomization seed to the current up-time of the system (In milliseconds).
Function SetSeedToUptime:Void()
	Seed = Millisecs()
	
	Return
End

' These commands are basic wrappers for the 'Rnd' command, which allow the user to generate
' a one-off random number (Without changing the seed after execution).
Function RandomNumber:Double()
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd()
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End

Function RandomNumber:Double(Range:Double)
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd(Range)
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End

Function RandomNumber:Double(Low:Double, High:Double)
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd(Low, High)
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End

' This command writes a standard line to a 'Stream'.
' This supports both 'LF', and 'CRLF' line endings currently, and this can be configured with 'UTIL_WRITELINE_ENDTYPE'.
' Though character encoding is supported with this, only ASCII is supported by 'ReadLine'.
Function WriteLine:Bool(S:Stream, Line:String, CharacterEncoding:String="ascii")
	' Check for errors:
	If (S = Null) Then
		Return False
	Endif
	
	S.WriteString(Line, CharacterEncoding)
	
	#If UTIL_WRITELINE_ENDTYPE = "CRLF"
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
	Local Padding:ULong = 0 ' * SizeOf_Char
	
	Local Str:String
	
	#If Not UTIL_READ_LINES_QUICKLY
		Local Size:ULong = 0
	#End
	
	While (Not S.Eof())
		Local Char:= S.ReadByte()
		
		If (Char <> ASCII_LINE_FEED) Then
			If (Char <> ASCII_CARRIAGE_RETURN) Then
				#If UTIL_READ_LINES_QUICKLY
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
	
	#If Not UTIL_READ_LINES_QUICKLY
		S.Seek(Position)
		
		Str = S.ReadString(Size, "ascii")
		
		S.Seek(S.Position()+Padding)
	#End
	
	' Return the string we read from the stream.
	Return Str
End

Function ResizeBuffer:DataBuffer(Buffer:DataBuffer, Size:Long=AUTOMATIC_LENGTH, CopyData:Bool=True, DiscardOldBuffer:Bool=False, OnlyWhenDifferentSizes:Bool=False)
	Local BufferAvailable:Bool = (Buffer <> Null)
	
	If (BufferAvailable And OnlyWhenDifferentSizes) Then
		If (Size <> AUTOMATIC_LENGTH And Buffer.Length() = Size) Then
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
		
		' Generate the final message:
		Msg = TempMsg +
		
		#If DEBUG_PRINT_QUOTES
			Quote + Msg + Quote
		#Else
			Msg
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
	
	Return
End

Function DebugPrint:Void(Str:String="", StopExecution:Bool=False)
	If (Not StopExecution And Str.Length() = 0) Then
		Print("")
		
		Return
	Endif
	
	DebugError(Str, StopExecution)
	
	Return
End

' This command is useful for dealing with arrays:
Function OutOfBounds:Bool(Position:ULong, Length:ULong)
	Return (Position >= Length)
End

' The following functions are designed to be used with generic classes:
Function TypeIsObject:Bool(O:Object)
	Return True
End

Function TypeIsObject:Bool(IO:IntObject)
	Return False
End

Function TypeIsObject:Bool(BO:BoolObject)
	Return False
End

Function TypeIsObject:Bool(FO:FloatObject)
	Return False
End

Function TypeIsObject:Bool(SO:StringObject)
	Return False
End

Function TypeIsObject:Bool(I:Int)
	Return False
End

Function TypeIsObject:Bool(B:Bool)
	Return False
End

Function TypeIsObject:Bool(F:Float)
	Return False
End

Function TypeIsObject:Bool(S:String)
	Return False
End

Function TypeOf:TypeCode(O:Object)
	Return TYPE_OBJECT
End

' Normally, I'd have these surrounded by a preprocessor check for an extension, but this is purposeful.
Function TypeOf:TypeCode(IO:IntObject)
	Return TYPE_INT
End

Function TypeOf:TypeCode(BO:BoolObject)
	Return TYPE_BOOL
End

Function TypeOf:TypeCode(FO:FloatObject)
	Return TYPE_FLOAT
End

Function TypeOf:TypeCode(SO:StringObject)
	Return TYPE_STRING
End

Function TypeOf:TypeCode(I:Int)
	Return TYPE_INT
End

Function TypeOf:TypeCode(B:Bool)
	Return TYPE_BOOL
End

Function TypeOf:TypeCode(F:Float)
	Return TYPE_FLOAT
End

Function TypeOf:TypeCode(S:String)
	Return TYPE_STRING
End

Function TypeAsString:String(O:Object)
	Return TypeAsString(TYPE_OBJECT) ' TypeToString(TypeOf(O))
End

Function TypeAsString:String(IO:IntObject)
	Return TypeAsString(TYPE_INT) ' TypeToString(TypeOf(IO))
End

Function TypeAsString:String(BO:BoolObject)
	Return TypeAsString(TYPE_BOOL) ' TypeToString(TypeOf(BO))
End

Function TypeAsString:String(FO:FloatObject)
	Return TypeAsString(TYPE_FLOAT) ' TypeToString(TypeOf(FO))
End

Function TypeAsString:String(SO:StringObject)
	Return TypeAsString(TYPE_STRING) ' TypeToString(TypeOf(SO))
End

Function TypeAsString:String(I:Int)
	Return TypeToString(TYPE_INT) ' TypeToString(TypeOf(I))
End

Function TypeAsString:String(B:Bool)
	Return TypeToString(TYPE_BOOL) ' TypeToString(TypeOf(B))
End

Function TypeAsString:String(F:Float)
	Return TypeToString(TYPE_FLOAT) ' TypeToString(TypeOf(F))
End

Function TypeAsString:String(S:String)
	Return TypeToString(TYPE_STRING) ' TypeToString(TypeOf(S))
End

Function TypeToString:String(Code:TypeCode)
	' Check if the input-code is known:
	Select Code
		Case TYPE_OBJECT
			Return TYPE_OBJECT_STR
		Case TYPE_INT
			Return TYPE_INT_STR
		Case TYPE_BOOL
			Return TYPE_BOOL_STR
		Case TYPE_FLOAT
			Return TYPE_FLOAT_STR
		Case TYPE_STRING
			Return TYPE_STRING_STR
	End Select
	
	' If nothing else, return the "unknown type" 'String'.
	Return TYPE_UNKNOWN_STR
End

' Other:

' This command acts as a wrapper for the standard 'SetClipboard' command.
' This will not store the current state of the clipboard in any kind of collection.
Function PushClipboard:Bool(Input:String)
	Return SetClipboard(Input)
End

' This command will retrieve the data from the internal clipboard, then clear it after:
Function PopClipboard:String()
	' Local variable(s):
	
	' Get the current state of the clipboard.
	Local Clipboard:= GetClipboard()
	
	' Clear the clipboard.
	ClearClipboard()
	
	' Return the data we retrieved.
	Return Clipboard
End

' Functions (Private):
Private

' The following commands were created to solve auto-conversion conflicts with the standard "box" classes:
Function Sgn:Long(I:Long)
	Return math.Sgn(I)
End

Function Sgn:Double(F:Double)
	Return math.Sgn(F)
End

#If Not MONKEYLANG_EXPLICIT_BOXES
	Function Sgn:Long(IO:IntObject)
		Return Sgn(IO.ToInt())
		'Return math.Sgn(IO.ToInt())
	End
	
	Function Sgn:Double(FO:FloatObject)
		Return Sgn(FO.ToFloat())
		'Return math.Sgn(FO.ToFloat())
	End
#End

Public

' Classes:
Class GenericUtilities<T>
	' Constant variable(s):
	
	' Comparison response codes (Positive numbers are for error-reporting):
	Const COMPARE_RESPONSE_IDENTICAL:Int			= -1
	Const COMPARE_RESPONSE_WRONG_LENGTH:Int			= -2
	
	' Other:
	Const AUTO:= UTIL_AUTO
	
	' Global variable(s):
	
	' For internal and extern use. That being said, please do not modify this value.
	Global NIL:T
	
	' Functions:
	
	' This command gives the user the type-code of 'T'.
	Function Type:TypeCode()
		' Return the type code of 'NIL'.
		Return TypeOf(NIL)
	End
	
	' This command specifies if 'T' is an object.
	Function IsObject:Bool()
		Return TypeIsObject(NIL)
	End
	
	' This command wraps the standard 'BoolToString' conversion command.
	Function AsString:String(Input:Bool)
		Return BoolToString(Input)
	End
	
	' This command reads a string from a standard 'Stream' object.
	Function AsString:String(S:Stream, Length:Long=AUTO, Encoding:String="utf8")
		If (Length = AUTO) Then
			Length = S.Length()
		Endif
		
		Return S.ReadString(Length, Encoding)
	End
	
	' By default, this command will add the 'Offset' argument to the processed version of the 'Length' argument.
	' To disable this, set 'ApplyOffsetToLength' to 'False'.
	Function AsString:String(Input:T[], Offset:ULong=0, Length:Long=AUTO, AddSpaces:Bool=True, ApplyOffsetToLength:Bool=True)
		' Local variable(s):
		Local Output:String = LeftBracket
		
		' If no length was specified, use the array's length:
		If (Length = AUTO) Then
			Length = Input.Length()
		Endif
		
		Local VirtualLength:ULong
		
		If (ApplyOffsetToLength) Then
			VirtualLength = Length+Offset
		Else
			VirtualLength = Length
		Endif
		
		For Local Index:= Offset Until VirtualLength
			Output += String(Input[Index])
			
			If (Index+1 < VirtualLength) Then
				If (AddSpaces) Then
					Output += (Comma + Space) ' ", "
				Else
					Output += Comma
				Endif
			Endif
		Next
		
		Return Output + RightBracket
	End
	
	Function CopyStringToArray:T[](Input:String, Output:T[], Offset:ULong=0, Length:Long=AUTO)
		If (Length = AUTO) Then
			Length = Min(Input.Length(), Output.Length())
		Endif
		
		For Local I:= Offset Until Length
			Output[I] = Input[I]
		Next
		
		' Just for the sake of convenience, return the 'Output' array.
		Return Output
	End
	
	Function IndexOfList:T(L:List<T>, Index:ULong=0)
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
	
	Function SMod:T(Input:T, Denom:T)
		Return (Input Mod (Denom*Sgn(Input)))
	End
	
	Function PrintArray:Void(Input:T[])
		Print(AsString(Input))
		
		Return
	End
	
	Function OutputArray:Void(Input:T[])
		PrintArray(Input)
		
		Return
	End
	
	Function OutputArray:Void(Input:T[], S:Stream, WriteLength:Bool=False)
		Write(S, Input, WriteLength)
		
		Return
	End
	
	Method ReadArray:Void(Input:T[], S:Stream, Size:Long=AUTO)
		Read(S, Input, Size)
		
		Return
	End
	
	#Rem
		NOTES:
			* In the event of an error, an empty array will be produced.
			
			* The 'CopyArray' command's 'FitSource' argument should only be enabled with the
			knowledge that the original destination may have been discarded.
			
			Your code must reflect this by disregarding the original array,
			and simply assigning the old array to the retrun value.
			
			EXAMPLE:
				' Local variable(s):
				Local A:T[10], A2:T[3]
				
				' This will likely produce a new 'T' array, based on the area-delta.
				A2 = CopyArray(A, A2, True)
	#End
	
	Function CopyArray:T[](Source:T[], Destination:T[], FitSource:Bool)
		Return CopyArray(Source, Destination, 0, 0, AUTO, AUTO, FitSource)
	End
	
	Function CopyArray:T[](Source:T[], Destination:T[], Source_Offset:ULong=0, Destination_Offset:ULong=0, Source_Length:Long=AUTO, Destination_Length:Long=AUTO, FitSource:Bool=False)
		If (Source_Length = AUTO) Then
			Source_Length = Source.Length()
		Endif
		
		If (Destination_Length = AUTO) Then
			Destination_Length = Destination.Length()
		Endif
		
		' Local variable(s):
		
		' These two are used as caches for the real lengths of the arrays:
		Local Destination_RealLength:= Destination.Length()
		Local Source_RealLength:= Source.Length()
		
		' Calculate the source and destination areas:
		Local Source_Area:Long = (Source_Length-Source_Offset)
		
		' Make sure we have a source to work with:
		If (Source_Area <= 0) Then
			' The source-area is too small for use, return an empty array.
			Return []
		Endif
		
		Local Destination_Area:Long = (Destination_Length-Destination_Offset)
		
		' If we're not going to fit the source, check if the destination-area is big enough:
		If (Not FitSource) Then
			If (Destination_Area <= 0) Then
				' The destination-area is too small for use, return an empty array.
				Return []
			Endif
		Endif
		
		Local Operation_Area:Long
		
		If (FitSource And Destination_Area < Source_Area) Then
			Local AreaDelta:Long = (Source_Area-Destination_Area)
			Local NewArea:Long = (Destination_RealLength+AreaDelta)
			
			If (NewArea > Destination_RealLength) Then
				Destination = Destination.Resize(NewArea)
			Else
				Destination = Destination.Resize(Destination_Length+AreaDelta)
			Endif
			
			Destination_Area = Source_Area
			Operation_Area = Destination_Area
		Else
			Operation_Area = Min(Source_Area, Destination_Area)
		Endif
		
		' Copy the contents of the source-array into the destination-array:
		For Local Index:= 0 Until Operation_Area
			Destination[Index+Destination_Offset] = Source[Index+Source_Offset]
		Next
		
		' Return the destination-array.
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
	
	Function Read:T[](S:Stream, DataArray:T[], Size:Long=AUTO)
		If (Size = AUTO) Then
			Size = S.ReadInt() ' S.ReadLong()
		Endif
		
		If (Size > 0) Then
			If (DataArray.Length() = 0) Then
				DataArray = New T[Size]
			Endif
		Endif
		
		' Local variable(s):
		Local DLength:= Min(DataArray.Length(), Size)
		
		For Local Index:= 0 Until DLength
			DataArray[Index] = Read(S, NIL)
		Next
		
		Return DataArray
	End
	
	Function Write:Void(S:Stream, DataArray:T[], WriteLength:Bool=True)
		' Local variable(s):
		Local DLength:= DataArray.Length()
		
		If (WriteLength) Then
			S.WriteInt(DLength) ' S.WriteLong(DLength)
		Endif
		
		For Local Index:= 0 Until DLength
			Write(S, DataArray[Index])
		Next
		
		Return
	End
	
	Function Read:Long(S:Stream, Identifier:Long, Size:Byte=4)
			If (Size > 1) Then
				If (Size < 4) Then
					Return S.ReadShort()
				Else
					' Good enough for now:
					If (Size > 4) Then
						S.ReadInt()
					Endif
					
					Return S.ReadInt()
					'Return S.ReadLong()
				Endif
		#If MONKEYLANG_EXTENSION_TYPE_BYTE
			Else
		#Else
			Elseif (Size > 0) Then
		#End
				Return S.ReadByte()
			Endif
		
		' Return the default response.
		Return 0
	End
	
	Function Write:Void(S:Stream, Data:Long, Size:Byte=4)
		Size = Byte(IntSize(Size)) ' ApplyByteBounds(IntSize(Size))
		
			If (Size > 1) Then
				If (Size < 4) Then
					S.WriteShort(Data)
				Else
					If (Size > 4) Then
						S.WriteInt(0)
					Endif
					
					S.WriteInt(Data)
					'S.WriteLong(Data)
				Endif
		#If MONKEYLANG_EXTENSION_TYPE_BYTE
			Else
		#Else
			Elseif (Size > 0) Then
		#End
				S.WriteByte(Data)
			Endif
		
		Return
	End
	
	#Rem
	Function Read:Bool(S:Stream, Identifier:Bool)
		Return Read(S, Long(Identifier), 1)
	End
	
	Function Write:Void(S:Stream, B:Bool)
		Write(S, Long(B), 1)
		
		Return
	End
	#End
	
	'Function Read:Double(S:Stream, Identifier:Double)
	Function Read:Float(S:Stream, Identifier:Float)
		Return S.ReadFloat() ' S.ReadDouble()
	End
	
	'Function Write:Void(S:Stream, Data:Double)
	Function Write:Void(S:Stream, Data:Float)
		S.WriteFloat(Data) ' S.WriteDouble(Data)
		
		Return
	End
	
	Function Read:String(S:Stream, Data:String, Encoding:String="utf8", Size:Long=AUTO)
		' Check if the size was manually specified:
		If (Size = AUTO) Then
			' Read the string's length from the input-stream.
			Size = S.ReadInt() ' S.ReadLong()
		Endif
		
		' Read the desired string from the input-stream, then return it.
		Return S.ReadString(Size, Encoding)
	End
	
	Function Write:Void(S:Stream, Data:String, Encoding:String="utf8", WriteSize:Bool=True)
		' Check if we're writing the size of the input-string.
		If (WriteSize) Then
			' Write the length of the input-string to the output-stream.
			S.WriteInt(Data.Length()) ' S.WriteLong(Data.Length())
		Endif
		
		' Write the input-string to the output-stream.
		S.WriteString(Data, Encoding)
		
		Return
	End
	
	#If UTIL_SUPPORT_IOELEMENTS
		Function Read:Void(S:Stream, Data:InputChildElement)
			Data.Load(S)
			
			Return
		End
		
		Function Write:Void(S:Stream, Data:OutputChildElement)
			Data.Save(S)
		End
	#End
	
	' The following commands were created to solve auto-conversion conflicts with the standard "box" classes:
	#If Not MONKEYLANG_EXPLICIT_BOXES
		Function Read:Long(S:Stream, Identifier:IntObject, Size:Byte=4)
			Return Read(S, Identifier.ToInt(), Size)
		End
		
		Function Write:Void(S:Stream, Data:IntObject, Size:Byte=4)
			Write(S, Data.ToInt(), Size)
			
			Return
		End
		
		'Function Read:Double(S:Stream, Identifier:FloatObject)
		Function Read:Float(S:Stream, Identifier:FloatObject)
			Return Read(S, Identifier.ToFloat())
		End
		
		Function Write:Void(S:Stream, Data:FloatObject)
			Write(S, Data.ToFloat())
			
			Return
		End
	#End
	
	' Constructor(s):
	
	' DO NOT CREATE NEW INSTANCES OF THIS CLASS.
	Method New()
		DebugError("This class should not be used in this was.")
	End
End