Strict

Public

' Preprocessor related:
#If TARGET = "glfw" ' Or TARGET = "sexy"
	' This check is done without an associated import for a good reason,
	' this module assumes such fixes will be described by an outside module.
	' The primary module ('util') will be used for this under normal conditions.
	#If UTIL_PREPROCESSOR_FIXES
		#CPUCOUNT_IMPLEMENTED = UTIL_CPUCOUNT_IMPLEMENTED
	#End
	
	' Native clipboard-functionality is not available
	' from earlier versions of GLFW, you must use GLFW3:
	#If GLFW_VERSION = 3
		#UTIL_CLIPBOARD_NATIVE = True
		
		#UTIL_CLIPBOARD_INPUT_AVAILABLE = True
		#UTIL_CLIPBOARD_OUTPUT_AVAILABLE = True
		#UTIL_CLIPBOARD_CLEAR_AVAILABLE = True
	#Elseif GLFW_VERSION = 2
		#UTIL_CPUCOUNT_IMPLEMENTED = True
	#End
#End

#If UTIL_CLIPBOARD_INPUT_AVAILABLE And Not UTIL_CLIPBOARD_OUTPUT_AVAILABLE Or UTIL_CLIPBOARD_OUTPUT_AVAILABLE And Not UTIL_CLIPBOARD_INPUT_AVAILABLE
	' This should only be defined if input or output is supported without the other.
	' For a preprocessor variable describing both as implemented, see 'UTIL_CLIPBOARD_FULLSUPPORT'.
	#UTIL_CLIPBOARD_MINIMAL = True
#End

#If UTIL_CLIPBOARD_INPUT_AVAILABLE And UTIL_CLIPBOARD_OUTPUT_AVAILABLE
	' This should only be defined if full clipboard support is available.
	#UTIL_CLIPBOARD_FULLSUPPORT = True
#End

' Imports (Monkey):
' Nothing so far.

' Imports (Native):
#If UTIL_CLIPBOARD_NATIVE ' TARGET = "glfw"
	Import "native/util.${TARGET}.${LANG}"
#End

' External bindings:
Extern

' Functions:

#Rem
	The 'CPUCount' command is only available on the GLFW2 target.
	As of GLFW3, GLFW does not supply this functionality.
#End

#If UTIL_CPUCOUNT_IMPLEMENTED
	#If TARGET = "glfw"
		Function CPUCount:Int()="glfwGetNumberOfProcessors"
	#Else
		#Error "Internal Error: Unable to find a valid implementation of 'CPUCount'"
	#End
#End

#Rem
	Clipboard functionality is not supported on most targets.
	
	When available, this will allow you to read, write,
	or even clear the operating system's clipboard.
	
	On targets with partial support for clipboard functionality,
	some features are largely undefined, and may not be the best option.
	
	In general, keep your clipboard functionality as optional as possible.
	
	In the event something is not implemented on a specific target,
	functionality will be 'simulated' with a global variable.
	
	Fall-back functionality is completely dependent on the local 'fallbacks' module,
	and is "undefined", but generally stable behavior.
	
	Clipboard functionality is still somewhat experimental,
	but it should work for you without any issues.
#End

#If UTIL_CLIPBOARD_INPUT_AVAILABLE
	#If LANG = "cpp"
		Function GetClipboard:String()="external_util::getClipboard"
	#Else
		Function GetClipboard:String()="external_util.getClipboard"
	#End
#End

#If UTIL_CLIPBOARD_OUTPUT_AVAILABLE
	#If LANG = "cpp"
		Function SetClipboard:Bool(Input:String)="external_util::setClipboard"
	#Else
		Function SetClipboard:Bool(Input:String)= "external_util.setClipboard"
	#End
#End

#If UTIL_CLIPBOARD_CLEAR_AVAILABLE
	#If LANG = "cpp"
		Function ClearClipboard:Bool()="external_util::clearClipboard"
	#Else
		Function ClearClipboard:Bool()="external_util.clearClipboard"
	#End
#End

Public