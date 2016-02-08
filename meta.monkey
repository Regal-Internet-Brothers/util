Strict

Public

' Imports:
Import bitfield

' Aliases:
Alias TypeCode = Int ' Byte

' Constant variable(s):

' This acts as a general "automatic-value".
' This is only provided for legacy compatibility; do not
' use this value in code that was not built around it.
Const UTIL_AUTO:Long = -1

' This is for situations where the length of something can be optional.
' This currently mirrors 'UTIL_AUTO' and its behavior.
' Please use better overloading practices if possible.
Const AUTOMATIC_LENGTH:= UTIL_AUTO

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

' Functions:

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