Strict

Public

' Imports:
Import meta

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
	
	' This command reads a string from the entire contents of 'S'.
	Function AsString:String(S:Stream, Encoding:String="utf8")
		Return S.ReadString(Encoding)
	End

	' This command reads a string from a standard 'Stream' object.
	Function AsString:String(S:Stream, Length:Long, Encoding:String="utf8") ' Int
		Return S.ReadString(Length, Encoding)
	End
	
	' By default, this command will add the 'Offset' argument to a processed version of the 'Length' argument.
	' To disable this, set the 'ApplyOffsetToLength' argument to 'False'.
	Function AsString:String(Input:T[], Offset:ULong=0, Length:Long, AddSpaces:Bool=True, ApplyOffsetToLength:Bool=True)
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
		
		If (VirtualLength > 0) Then
			Local Output:String = LeftBracket
			Local FinalIndex:= (VirtualLength - 1)

			For Local Index:= Offset Until FinalIndex
				Output += String(Input[Index])

				If (AddSpaces) Then
					Output += ", " ' + Comma + Space
				Else
					Output += "," ' + Comma
				Endif
			Next

			Return Output + Input[FinalIndex] + "]" ' + RightBracket
		Endif

		Return ""
	End

	Function AsString:String(Input:T[], Offset:ULong=0, AddSpaces:Bool=True, ApplyOffsetToLength:Bool=True)
		Return AsString(Input, Offset, Input.Length, AddSpaces, ApplyOffsetToLength)
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
	
	Function CopyStack:Void(In:Stack<T>, Out:Stack<T>)
		For Local I:= 0 Until In.Length
			Out.Push(In.Get(I))
		Next
		
		Return
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
	
	' Constructor(s) (Private):
	Private
	
	' DO NOT CREATE NEW INSTANCES OF THIS CLASS.
	Method New()
		DebugError("This class should not be used in this was.")
	End
	
	Public
End