Strict

Public

' Preprocessor related:

' 'util' configuration:
#UTIL_IMPLEMENTED = True
#UTIL_TEMP_BUFFERS = True
#UTIL_WRAP_BOTH_WAYS = True

'#UTIL_CONSOLE = True

'#UTIL_DELEGATE_TYPETOOL = False
'#UTIL_TYPECODE_STRINGS_USE_SHORTHAND = False
'#UTIL_PREPROCESSOR_FIXES = False ' True

' Other:
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

' Imports (Public):
Import external
Import fallbacks

' Default imports:
Import regal.autostream
Import regal.byteorder
Import regal.imagedimensions
Import regal.retrostrings
Import regal.stringutil
Import regal.boxutil
Import regal.vector
Import regal.sizeof
Import regal.time

#If Not BRL_GAMETARGET_IMPLEMENTED
	Import regal.mojoemulator
#End

' Optional (Closed source):
#If UTIL_CONSOLE ' CONSOLE_IMPLEMENTED
	Import console
#End

' Imports (Private):
Private

' Unofficial:
Import regal.ioelement

' Official:

' BRL:
Import brl.databuffer
Import brl.stream
Import brl.filepath

' Mojo:
#If BRL_GAMETARGET_IMPLEMENTED And Not MILLISECS_IMPLEMENTED
	Import mojo.app
#End

Public

' Imports (Other):
#If Not UTIL_DELEGATE_TYPETOOL
	Private
#End

Import regal.typetool

#If Not UTIL_DELEGATE_TYPETOOL
	Public
#End

' Implementation checks:
#If IOELEMENT_IMPLEMENTED
	#UTIL_SUPPORT_IOELEMENTS = True
#End