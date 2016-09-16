Strict

Public

' Preprocessor related:
#REGAL_UTIL_BUFFERS_BYTE_OPTIMIZATIONS = True

'#If CONFIG = "debug"
	'#REGAL_UTIL_BUFFERS_SAFE = True
'#End

' Imports (Public):
Import brl.databuffer

' Imports (Private):
Private

Import memory

Import regal.sizeof
Import regal.typetool

Public

' Interfaces:
Interface BufferView
	' Methods:
	' Nothing so far.
	
	' Properties:
	Method Data:DataBuffer() Property
	Method Offset:UInt() Property ' Int
End

' Classes:
Class ArrayView<ValueType> Implements BufferView Abstract
	' Global variable(s):
	Global NIL:ValueType
	
	' Constructor(s):
	Method New(ElementSize:UInt, Count:UInt, __Direct:Bool=False)
		Self.ElementSize = ElementSize
		Self.Data = New DataBuffer(CountInBytes(Count), __Direct)
	End
	
	Method New(ElementSize:UInt, Data:DataBuffer, OffsetInBytes:UInt=0)
		Self.Offset = OffsetInBytes
		Self.ElementSize = ElementSize
		Self.Data = Data
	End
	
	' The 'ExtraOffset' argument is used to offset from the 'View' object's offset.
	Method New(ElementSize:UInt, View:BufferView, ExtraOffset:UInt=0)
		Self.ElementSize = ElementSize
		Self.Offset = (View.Offset + ExtraOffset)
		Self.Data = View.Data
	End
	
	' Methods (Public):
	
	' If overridden, these methods must respect the 'Offset' property:
	Method Get:ValueType(Index:UInt)
		Return GetRaw(Offset + IndexToAddress(Index))
	End
	
	Method Set:Void(Index:UInt, Value:ValueType)
		SetRaw(Offset + IndexToAddress(Index), Value)
		
		Return
	End
	
	Method GetArray:Bool(Index:UInt, Output:ValueType[], Count:UInt, OutputOffset:UInt=0)
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		If (Bounds > Size) Then
			Return False
		Endif
		
		'PeekInts : Void ( address:Int, ints:Int[], offset:Int, count:Int )
		
		Local OutputPosition:= OutputOffset
		
		For Local Address:= OffsetIndexToAddress(Index) Until ByteBounds Step ElementSize
			Output[OutputPosition] = GetRaw(Address)
			
			OutputPosition += 1
		Next
		
		' Return the default response.
		Return True
	End
	
	Method GetArray:ValueType[](Index:UInt, Count:UInt, _ArrOff:UInt=0)
		Local Output:= New ValueType[_ArrOff + Count]
		
		If (Not GetArray(Index, Output, Count, _ArrOff)) Then
			Return []
		Endif
		
		Return Output
	End
	
	' This supplies the raw size of 'Count' elements in bytes.
	Method CountInBytes:UInt(Count:Int)
		Return IndexToAddress(Count) ' (Count * ElementSize)
	End
	
	' This converts an index to a raw address for use with the internal buffer.
	Method IndexToAddress:UInt(Index:UInt)
		#If REGAL_UTIL_BUFFERS_BYTE_OPTIMIZATIONS
			If (ElementSize = 1) Then
				Return Index
			Endif
		#End
		
		Return (Index * ElementSize)
	End
	
	' This converts a raw address to an index.
	Method AddressToIndex:UInt(Address:UInt)
		#If REGAL_UTIL_BUFFERS_BYTE_OPTIMIZATIONS
			If (ElementSize = 1) Then
				Return Address
			Endif
		#End
		
		Return (Address / ElementSize)
	End
	
	#Rem
		The result of this method is a non-convertible raw address.
		By definition, this address may not be used with commands like
		'AddressToIndex', as the value would be skewed.
		
		To fix this address for such commands, subtract a stored result gathered
		from the 'Offset' property at the time this method was called.
		
		Because the value of 'Offset' can be changed, you must always ensure that
		the offset you apply to restore the appropriate value corresponds with the
		original value associated with this object's 'Offset' property.
		
		This type of address manipulation is not recommended,
		and should be avoided wherever possible.
	#End
	
	Method OffsetIndexToAddress:UInt(Index:UInt) Final
		Return (IndexToAddress(Index) + Offset)
	End
	
	' This method is an extension, which should only be used when converting
	' a value from a real address to a convertible address.
	' This command is not recommended, and is subject to deletion.
	Method __OffsetAddressToIndex:UInt(_Address:UInt) Final
		Return AddressToIndex(_Address - Offset)
	End
	
	' Methods (Protected):
	Protected
	
	' Abstract:
	
	' These two methods operate on raw addresses.
	' This means the input should not be an index,
	' nor should it be a non-offset address.
	' The i
	Method GetRaw:ValueType(Address:UInt) Abstract
	Method SetRaw:Void(Address:UInt, Value:ValueType) Abstract
	
	Public
	
	' Properties (Public):
	
	' This provides the number of elements in this view.
	Method Length:UInt() Property
		#If REGAL_UTIL_BUFFERS_BYTE_OPTIMIZATIONS
			If (ElementSize = 1) Then
				Return Size
			Endif
		#End
		
		Return (Size / ElementSize)
	End
	
	' This provides the raw size of the internal buffer (In bytes).
	Method Size:UInt() Property
		Return UInt(Data.Length)
	End
	
	' This specifies the size of an element.
	Method ElementSize:UInt() Property
		Return Self._ElementSize
	End
	
	' This provides access to the internal buffer offset.
	Method Offset:UInt() Property ' Int
		Return Self._Offset
	End
	
	Method Offset:Void(Value:UInt) Property
		Self._Offset = Value
		
		#If REGAL_UTIL_BUFFERS_SAFE
			' Nothing so far.
		#End
		
		Return
	End
	
	' This provides access to the internal buffer.
	Method Data:DataBuffer() Property ' Final
		Return Self._Data
	End
	
	Method Data:Void(Value:DataBuffer) Property
		Self._Data = Value
		
		Return
	End
	
	' Properties (Protected):
	Protected
	
	Method ElementSize:Void(Value:UInt) Property
		Self._ElementSize = Value
		
		Return
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	Field _ElementSize:UInt ' Int
	Field _Offset:UInt ' Int
	Field _Data:DataBuffer
	
	Public
End

Class IntArrayView Extends ArrayView<Int> ' ArrayView<Long> ' Int ' LongArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf_Integer ' 4
	
	' Constructor(s) (Public):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected

	'#Rem
	Method New(Type_Size:UInt, Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Type_Size:UInt, Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	'#End
	
	Public
	
	' Methods (Protected):
	Protected
	
	Method GetRaw:Int(Address:UInt) ' Final
		Return Data.PeekInt(Address)
	End
	
	Method SetRaw:Void(Address:UInt, Value:Int) ' Final
		Data.PokeInt(Address, Value)
		
		Return
	End
	
	Public
End

Class ShortArrayView Extends IntArrayView ' ArrayView<Int> ' Short
	' Constant variable(s):
	Const Type_Size:= SizeOf_Short
	
	' Constructor(s) (Public):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected

	'#Rem
	Method New(Type_Size:UInt, Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Type_Size:UInt, Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	'#End
	
	Public
	
	' Methods (Protected):
	Protected
	
	Method GetRaw:Int(Address:UInt) ' Final ' Short
		Return Data.PeekShort(Address)
	End
	
	Method SetRaw:Void(Address:UInt, Value:Int) ' Final ' Short
		Data.PokeShort(Address, Value)
		
		Return
	End
	
	Public
End

Class ByteArrayView Extends ShortArrayView ' ArrayView<Int> ' Byte
	' Constant variable(s):
	Const Type_Size:= SizeOf_Byte
	
	' Constructor(s):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	
	' Methods (Public):
	#If REGAL_UTIL_BUFFERS_BYTE_OPTIMIZATIONS
		' These two methods follow the integrity rules of 'Offset':
		Method Get:Int(Address:UInt) ' Byte
			Return GetRaw(Offset + Address)
		End
		
		Method Set:Void(Address:UInt, Value:Int) ' Byte
			SetRaw(Offset + Address, Value)
			
			Return
		End
		
		#Rem
			Method IndexToAddress:UInt(Address:UInt) ' Index:UInt
				Return Address
			End
			
			Method AddressToIndex:UInt(Address:UInt)
				Return Address
			End
		#End
	#End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw:Int(Address:UInt) ' Final ' Byte
		Return Data.PeekByte(Address)
	End
	
	Method SetRaw:Void(Address:UInt, Value:Int) ' Final ' Byte
		Data.PokeByte(Address, Value)
		
		Return
	End
	
	Public
End

Class FloatArrayView Extends ArrayView<Float> ' DoubleArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf_Float ' 4 ' 8
	
	' Constructor(s):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0)
		Super.New(Type_Size, Data, OffsetInBytes)
	End
	
	Method New(View:BufferView, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ExtraOffset)
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw:Float(Address:UInt) ' Final ' Double
		Return Data.PeekFloat(Address)
	End
	
	Method SetRaw:Void(Address:UInt, Value:Float) ' Final ' Double
		Data.PokeFloat(Address, Value)
		
		Return
	End
	
	Public
End