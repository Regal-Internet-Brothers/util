Strict

Public

' Preprocessor related:
#If TARGET = "glfw" And (Not GLFW_VERSION Or GLFW_VERSION = 1) ' Or TARGET = "sexy"
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