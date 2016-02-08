Strict

Public

' Imports:
Import external
Import fallbacks

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