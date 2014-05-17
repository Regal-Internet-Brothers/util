Strict

Public

' Preprocessor related:
#If TARGET = "glfw" Or TARGET = "sexy"
	#CPUCOUNT_IMPLEMENTED = True
#End

' Imports (Monkey):
' Nothing so far.

' Imports (Native):
' Nothing so far.

' External bindings:
Extern

#If CPUCOUNT_IMPLEMENTED
	Function CPUCount:Int()="glfwGetNumberOfProcessors"
#End

Public