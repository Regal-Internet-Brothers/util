Strict

Public

#Rem
	NOTES:
		* The system-info-based fall-backs for 'CPUCount' have
		not been tested on any other platform than Windows.
		
		If you are unable to compile using
		these fall-backs, please notify me.
		
		If you for some reason need to disable these fall-backs,
		please define the 'UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK'
		preprocessor variable as 'False'.
		
		Windows, as well as most POSIX compatible systems
		should be supported (Even if some modification is required).
		
		Ideally, Linux and Mac OS X should work (As well as Windows).
#End

' Imports (Public) (Monkey):
Import typetool

Import external

' Imports (Private) (Monkey):
Private

#If Not UTIL_CPUCOUNT_IMPLEMENTED And (TARGET = "glfw" And GLFW_VERSION > 2) Or TARGET = "stdcpp" Or LANG = "cs"
	#If HOST = "winnt" And LANG <> "cs"
		Import brl.process
	
		#If BRL_PROCESS_IMPLEMENTED
			#UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK = True
		#End
	#Elseif LANG = "cs" Or (HOST = "macos" And HOST = "linux" Or HOST = "unix" Or HOST = "bsd") ' And LANG = "cpp"
		#UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK = True
		#UTIL_CPUCOUNT_EXTERNAL_FALLBACK = True
	#End
#End

Public

' Imports (Native):

' Just some future-proofing:
#If UTIL_CPUCOUNT_EXTERNAL_FALLBACK And UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK
	Import "native/util_fallback.${LANG}"
#End

' External bindings:
Extern

#If UTIL_CPUCOUNT_EXTERNAL_FALLBACK And UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK
	#If LANG = "cpp"
		Function CPUCount:Int()="external_util::processorsAvailable"
	#Else
		Function CPUCount:Int()="external_util.processorsAvailable"
	#End
#End

Public

' Constant variable(s) (Public):
' Nothing so far.

' Constant variable(s) (Private):
Private

#If Not UTIL_CPUCOUNT_IMPLEMENTED Or UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK
	#If TARGET = "flash" Or TARGET = "html5"
		Const DEFAULT_CPUCOUNT:Int = 1
	#Else
		Const DEFAULT_CPUCOUNT:Int = 2
	#End
#End

Public

' Global variable(s) (Public):
' Nothing so far.

' Global variable(s) (Private):
Private

#If Not UTIL_CLIPBOARD_NATIVE
	Global Clipboard:String
#End

#If UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK
	Global SystemInfo_CPUCount:Int = 0
#End

Public

' Functions:
#If UTIL_CPUCOUNT_SYSTEMINFO_FALLBACK
	#If Not UTIL_CPUCOUNT_EXTERNAL_FALLBACK
		Function CPUCount:Int()
			#If HOST = "winnt"
				' Set the implementation flag so the user knows we're not using a fall-back.
				#UTIL_CPUCOUNT_IMPLEMENTED = True
				
				If (SystemInfo_CPUCount = 0) Then
					Local Count:= Int(GetEnv("NUMBER_OF_PROCESSORS"))
					
					If (Count > 0) Then
						SystemInfo_CPUCount = Count
					Else
						SystemInfo_CPUCount = DEFAULT_CPUCOUNT
					Endif
				Endif
				
				Return SystemInfo_CPUCount
			#Else
				'#Error "Internal error: Unable to find suitable version of 'CPUCount'."
				
				Return DEFAULT_CPUCOUNT
			#End
		End
	#End
#Elseif Not UTIL_CPUCOUNT_IMPLEMENTED
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