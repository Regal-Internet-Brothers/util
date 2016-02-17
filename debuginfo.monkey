Strict

Public

' Preprocessor related:
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

#DEBUG_THROW_ON_ERROR = True

' Friends:
#If UTIL_CONSOLE
	Friend console
#End

' Imports (Public):
' Nothing so far.

' Imports (Private):
Private

' Optional (Closed source):
#If UTIL_CONSOLE ' CONSOLE_IMPLEMENTED
	Import console
#End

Import monkey.lang

Public

' Global variable(s):
#If CONSOLE_IMPLEMENTED
	Global DebugConsole:Console = Null
#End

' Global variable(s) (Private):
Private

Const ErrorTemplate:String = "[ERROR] {Debug}: "
Const LogTemplate:String = "[INFO] {Debug}: "

Public

' Functions (Public):
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
				EmitError(Msg)
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
				EmitError(Msg)
			#End
		#End
	Endif
	
	Return
End

Function DebugPrint:Void(Str:String="", StopExecution:Bool=False)
	If (Not StopExecution And Str.Length = 0) Then
		Print("")
		
		Return
	Endif
	
	DebugError(Str, StopExecution)
	
	Return
End

' Functions (Private):
Private

Function EmitError:Void(Message:String)
	#If DEBUG_THROW_ON_ERROR
		Throw New DebugException(Message)
	#Else
		Error(Message)
	#End
	
	Return
End

Public

' Classes:
Class DebugException Extends Throwable
	' Constructor(s):
	Method New(Message:String)
		Self.Message = Message
	End
	
	' Methods:
	Method ToString:String() ' Property
		Return Message
	End
	
	' Fields (Protected):
	Protected
	
	Field Message:String
	
	Public
End