Strict

Public

' Imports:
Import typetool

Import external

' Constant variable(s) (Public):
' Nothing so far.

' Constant variable(s) (Private):
Private

#If Not UTIL_CPUCOUNT_IMPLEMENTED
	Const DEFAULT_CPUCOUNT:Int = 2
#End

Public

' Global variable(s) (Public):
' Nothing so far.

' Global variable(s) (Private):
Private

#If Not UTIL_CLIPBOARD_NATIVE
	Global Clipboard:String
#End

Public

' Functions:
#If Not UTIL_CPUCOUNT_IMPLEMENTED
	' Functions:
	Function CPUCount:Int()
		Return DEFAULT_CPUCOUNT
	End
#End

' For documentation on clipboard functionality, please visit the 'external' module.
#If Not UTIL_CLIPBOARD_INPUT_AVAILABLE
	Function GetClipboard:String()
		Return Clipboard
	End
#End

#If Not UTIL_CLIPBOARD_OUTPUT_AVAILABLE
	Function SetClipboard:Bool(Input:String)
		Clipboard = Input
		
		' Return the default response.
		Return False
	End
#End

#If Not UTIL_CLIPBOARD_CLEAR_AVAILABLE
	Function ClearClipboard:Bool()
		' In the event we couldn't find a native implementation,
		' just assign the clipboard to a blank 'String'.
		SetClipboard("")
		
		' Return the default response.
		Return True
	End
#End