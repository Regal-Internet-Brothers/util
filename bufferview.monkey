Strict

Public

#Rem
	TODO:
		* Replace uses of 'Int' and 'Float' with 'Long' and 'Double'.
			('LongArrayView', 'DoubleArrayView', etc)
#End

' Preprocessor related:
#REGAL_UTIL_BUFFERVIEW = True

#REGAL_UTIL_BUFFERVIEW_BYTE_OPTIMIZATIONS = True

'#If CONFIG = "debug"
	'#REGAL_UTIL_BUFFERVIEW_SAFE = True
'#End

' Imports (Public):
Import brl.databuffer

' Imports (Private):
Private

Import memory

Import regal.sizeof
Import regal.typetool

Import monkey.math

Public

' Interfaces:
Interface BufferView
	' Constant variable(s):
	Const MAX_VIEW_ELEMENTS:= 0 ' -1
	
	' Methods:
	' Nothing so far.
	
	' Properties:
	Method Data:DataBuffer() Property
	Method Offset:UInt() Property ' Int
End

' Classes:
Class ArrayView<ValueType> Implements BufferView Abstract
	' Constant variable(s) (Public):
	Const MAX_VIEW_ELEMENTS:= BufferView.MAX_VIEW_ELEMENTS
	
	' Global variable(s) (Protected):
	Protected
	
	Global NIL:ValueType
	
	Public
	
	' Constructor(s) (Public):
	
	#Rem
		NOTES:
			* The 'ElementCount' argument(s) is/are bound by the amount of memory given to the view.
				This means the segment of a buffer that you intend to map must be at least the
				length you specify, scaled according to the requested size for each element.
				
				An invalid size will result in an exception.
	#End
	
	Method New(ElementSize:UInt, ElementCount:UInt, __Direct:Bool=False)
		Self.ElementSize = ElementSize
		
		InitializeCustomBuffer(ElementSize, ElementCount, __Direct)
	End
	
	Method New(ElementSize:UInt, Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Self.Offset = OffsetInBytes
		Self.ElementSize = ElementSize
		Self.Data = Data
		
		Self.Size = GetSize(Data, ElementSize, ElementCount)
	End
	
	' The 'ExtraOffset' argument is used to offset from the 'View' object's offset.
	Method New(ElementSize:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Self.ElementSize = ElementSize
		
		Self.Offset = (View.Offset + ExtraOffset)
		
		Self.Data = View.Data
		
		Self.Size = GetSize(Self.Data, ElementSize, ElementCount)
	End
	
	' Constructor(s) (Private):
	Private
	
	Method GetSize:UInt(Data:DataBuffer, ElementSize:UInt, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		If (ElementCount = MAX_VIEW_ELEMENTS) Then
			Return Data.Length
		Endif
		
		Local IntendedSize:= (ElementCount * ElementSize) ' CountInBytes(ElementCount)
		
		' Make sure the intended size is correct.
		If (IntendedSize < ElementSize Or IntendedSize > Data.Length) Then
			' The intended size is either too large, or too small.
			Throw New InvalidViewMappingOperation(Self, Offset, IntendedSize)
		Endif
		
		Return IntendedSize
	End
	
	' NOTE: It is considered unsafe to call this constructor before assigning a value to the 'ElementSize' property.
	Method InitializeCustomBuffer:Void(ElementSize:UInt, ElementCount:UInt, __Direct:Bool=False) Final
		If (ElementSize = 0 Or ElementCount = 0) Then
			Throw New BulkAllocationException<BufferView>(Self, 0) ' IntendedSize
		Endif
		
		Local IntendedSize:= (ElementCount * ElementSize)
		
		Self.Data = New DataBuffer(IntendedSize, __Direct) ' CountInBytes(ElementCount)
		
		Self.Offset = 0
		Self.Size = Self.Data.Length
	End
	
	Public
	
	' Methods (Public):
	
	' If overridden, these methods must respect the 'Offset' property:
	Method Get:ValueType(Index:UInt)
		Return GetRaw(Offset + IndexToAddress(Index))
	End
	
	Method Set:Void(Index:UInt, Value:ValueType)
		SetRaw(Offset + IndexToAddress(Index), Value)
		
		Return
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method GetArray:Bool(Index:UInt, Output:ValueType[], Count:UInt, OutputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will be used to store our current write-location in 'Output'.
		Local OutputPosition:= OutputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Copy the value located at 'Address' into the output.
			Output[OutputPosition] = GetRaw_Unsafe(Address)
			
			' Move to the next target-location for the output-data.
			OutputPosition += 1
			
			' Move forward by one entry.
			Address += ElementSize
		Wend
		
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
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method SetArray:Bool(Index:UInt, Input:ValueType[], Count:UInt, InputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will store our current position in the 'Input' array.
		Local InputPosition:= InputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
		' The amount 'Address' will move by on each iteration.
		Local Stride:= ElementSize
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Write a value at the current address using an entry from the input-data.
			SetRaw_Unsafe(Address, Input[InputPosition])
			
			' Move to the next entry in the input-data.
			InputPosition += 1
			
			' Move forward by one entry.
			Address += Stride
		Wend
		
		' Return the default response.
		Return True
	End
	
	Method SetArray:Bool(Index:UInt, Input:ValueType[])
		Return SetArray(Index, Input, Input.Length)
	End
	
	' TODO: Optimize this overload to bypass index conversion.
	Method SetArray:Bool(Input:ValueType[])
		Return SetArray(0, Input)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method Clear:Bool(Index:UInt, Count:UInt)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > ViewBounds) Then
			Return False
		Endif
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
		' The amount 'Address' will move by on each iteration.
		Local Stride:= ElementSize
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Clear an entry at our current location in the buffer.
			ClearRaw(Address)
			
			' Move forward by one entry.
			Address += Stride
		Wend
		
		' Return the default response.
		Return True
	End
	
	' TODO: Optimize this overload to bypass either index conversion or standard assignment.
	Method Clear:Bool()
		Return Clear(0, Length)
	End
	
	Method Add:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) + Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	Method Subtract:ValueType(Index:UInt, Value:ValueType)
		Return Add(Index, -Value)
	End
	
	' This supplies the raw size of 'Count' elements in bytes.
	Method CountInBytes:UInt(Count:Int)
		Return IndexToAddress(Count) ' (Count * ElementSize)
	End
	
	' This converts an index to a raw address for use with the internal buffer.
	Method IndexToAddress:UInt(Index:UInt)
		#If REGAL_UTIL_BUFFERVIEW_BYTE_OPTIMIZATIONS
			If (ElementSize = 1) Then
				Return Index
			Endif
		#End
		
		Return (Index * ElementSize)
	End
	
	' This converts a raw address to an index.
	Method AddressToIndex:UInt(Address:UInt)
		#If REGAL_UTIL_BUFFERVIEW_BYTE_OPTIMIZATIONS
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
	' Implementations should not bother with out-of-bounds checks.
	Method GetRaw_Unsafe:ValueType(RawAddress:UInt) Abstract
	Method SetRaw_Unsafe:Void(RawAddress:UInt, Value:ValueType) Abstract
	
	' Implemented:
	Method SetRaw:Void(Address:UInt, Value:ValueType) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > ViewBounds) Then
			Throw New InvalidViewWriteOperation(Self, Address, ElementSize)
		Endif
		
		SetRaw_Unsafe(Address, Value)
		
		Return
	End
	
	Method GetRaw:ValueType(Address:UInt) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > ViewBounds) Then
			Throw New InvalidViewReadOperation(Self, Address, ElementSize)
		Endif
		
		Return GetRaw_Unsafe(Address)
	End
	
	Method ClearRaw:Void(Address:UInt)
		SetRaw(Address, NIL)
		
		Return
	End
	
	Public
	
	' Properties (Public):
	
	' This provides the number of elements in this view.
	Method Length:UInt() Property
		#If REGAL_UTIL_BUFFERVIEW_BYTE_OPTIMIZATIONS
			If (ElementSize = 1) Then
				Return Size
			Endif
		#End
		
		Return (Size / ElementSize)
	End
	
	' This describes the address of the absolute furthest into the internal buffer this view reaches.
	' This is mainly useful for raw bounds checks that already account for offsets.
	' For a good example of this, view the 'GetArray' command's implementation(s).
	Method ViewBounds:UInt() Property
		Return (Size + Offset)
	End
	
	' This returns the raw size of the internal buffer area (In bytes), without adjusting for offsets.
	' This is useful when the literal size (In bytes) of this view is required.
	Method Size:UInt() Property ' Int
		Return Self._Size ' UInt(Data.Length)
	End
	
	' This specifies the size of an element.
	Method ElementSize:UInt() Property
		Return Self._ElementSize
	End
	
	' This provides access to the internal buffer-offset.
	' Note: This is already accounted for when calculating 'Size'.
	Method Offset:UInt() Property ' Int
		Return Self._Offset
	End
	
	Method Offset:Void(Value:UInt) Property
		Self._Offset = Value
		
		#If REGAL_UTIL_BUFFERVIEW_SAFE
			' Nothing so far.
		#End
		
		Return
	End
	
	' This provides access to the internal buffer.
	Method Data:DataBuffer() Property ' Final
		Return Self._Data
	End
	
	' Properties (Protected):
	Protected
	
	Method Size:Void(Value:UInt) Property
		Self._Size = Value
		
		Return
	End
	
	Method Data:Void(Value:DataBuffer) Property
		Self._Data = Value
		
		Return
	End
	
	Method ElementSize:Void(Value:UInt) Property
		Self._ElementSize = Value
		
		Return
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	Field _ElementSize:UInt ' Int
	Field _Offset:UInt ' Int
	Field _Size:UInt ' Int
	Field _Data:DataBuffer
	
	Public
End

' This is an intermediate class which defines mathematical routines for both integral and floating-point types.
Class MathArrayView<ValueType> Extends ArrayView<ValueType> Abstract
	' Constructor(s):
	Method New(ElementSize:UInt, ElementCount:UInt, __Direct:Bool=False)
		Super.New(ElementSize, ElementCount, __Direct)
	End
	
	Method New(ElementSize:UInt, Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(ElementSize, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(ElementSize:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(ElementSize, View, ElementCount, ExtraOffset)
	End
	
	' Methods:
	
	' This increments the value located at 'Index' by one.
	Method Increment:ValueType(Index:UInt)
		Return Add(Index, ValueType(1))
	End
	
	' This decrements the value located at 'Index' by one.
	Method Decrement:ValueType(Index:UInt)
		Return Subtract(Index, ValueType(1))
	End
	
	' This multiplies the value located at 'Index' using the value specified.
	' The result is written into memory, then returned.
	Method Multiply:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) * Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This divides the value located at 'Index' using the value specified.
	' The result is written into memory, then returned.
	Method Divide:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) / Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This squares the value located at 'Index'.
	' The result is both returned by the method, and
	' written into memory at the specified location.
	Method Sq:ValueType(Index:UInt) ' Square
		Local Value:= Get(Index)
		Local Result:= (Value * Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This calculates the square-root of the value located at 'Index'.
	' The result is both returned by this method, and
	' written into memory at the specified location.
	Method Sqrt:ValueType(Index:UInt) ' SquareRoot
		Local Result:= Sqrt(Get(Index))
		
		Set(Index, Result)
		
		Return Result
	End
End

Class IntArrayView Extends MathArrayView<Int> ' ArrayView<Long> ' Int ' LongArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf_Integer ' 4
	
	' Constructor(s) (Public):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(Type_Size:UInt, ElementCount:UInt, __Direct:Bool=False)
		Super.New(Type_Size, ElementCount, __Direct)
	End
	
	Method New(Type_Size:UInt, Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	Public
	
	' Methods (Public):
	Method GetUnsigned:Int(Index:UInt)
		Return (Get(Index) & $FFFFFFFF)
	End
	
	Method SetUnsigned:Void(Index:UInt, Value:Int)
		Set(Index, (Value & $FFFFFFFF))
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Int(Address:UInt) ' Final
		Return Data.PeekInt(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) ' Final
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
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(Type_Size:UInt, ElementCount:UInt, __Direct:Bool=False)
		Super.New(Type_Size, ElementCount, __Direct)
	End
	
	Method New(Type_Size:UInt, Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	Public
	
	' Methods (Public):
	Method GetUnsigned:Int(Index:UInt) ' Short
		Return (Get(Index) & $FFFF)
	End
	
	Method SetUnsigned:Void(Index:UInt, Value:Int) ' Short
		Set(Index, (Value & $FFFF))
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Int(Address:UInt) ' Final ' Short
		Return Data.PeekShort(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) ' Final ' Short
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
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Methods (Public):
	#If REGAL_UTIL_BUFFERVIEW_BYTE_OPTIMIZATIONS
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
	
	Method GetUnsigned:Int(Address:UInt) ' Byte
		Return (Get(Address) & $FF)
	End
	
	Method SetUnsigned:Void(Index:UInt, Value:Int) ' Byte
		Set(Index, (Value & $FF))
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Int(Address:UInt) ' Final ' Byte
		Return Data.PeekByte(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) ' Final ' Byte
		Data.PokeByte(Address, Value)
		
		Return
	End
	
	Public
End

Class FloatArrayView Extends MathArrayView<Float> ' DoubleArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf_Float ' 4 ' 8
	
	' Constructor(s):
	Method New(Count:UInt, __Direct:Bool=False)
		Super.New(Type_Size, Count, __Direct)
	End
	
	Method New(Data:DataBuffer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Float(Address:UInt) ' Final ' Double
		Return Data.PeekFloat(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Float) ' Final ' Double
		Data.PokeFloat(Address, Value)
		
		Return
	End
	
	Public
End