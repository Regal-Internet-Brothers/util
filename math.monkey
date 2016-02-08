Strict

Public

' Preprocessor related:
#UTIL_WRAP_BOTH_WAYS = True

' Imports:
Import monkey.math

Import bitfield
Import random

' Functions:
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

Function PrintColor:Void(S:Stream, Pixel:UInt, Encoding:String="ARGB")
	S.WriteLine(ColorToString(Pixel, Encoding))
	
	Return
End