Strict

Public

' Imports:
Import regal.typetool

' Constant variable(s):

' Comparison response-codes:
Const COMPARE_UNKNOWN:Int = 0
Const COMPARE_RIGHT:Int = 1
Const COMPARE_LEFT:Int = -1

' Functions:

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