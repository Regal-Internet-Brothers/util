Strict

Public

' Imports:
Import monkey.lang

' Global variable(s):
#If CONSOLE_IMPLEMENTED
	Global DebugConsole:Console = Null
#End

' Global variable(s) (Private):
Private

Const ErrorTemplate:String = "[ERROR] {Debug}: "
Const LogTemplate:String = "[INFO] {Debug}: "

Public

' Functions:
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
	If (Not StopExecution And Str.Length = 0) Then
		Print("")
		
		Return
	Endif
	
	DebugError(Str, StopExecution)
	
	Return
End