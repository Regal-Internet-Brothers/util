Strict

Public

' Imports:
Import external

' Functions:
#If Not CPUCOUNT_IMPLEMENTED
	' Constant variable(s):
	Const DEFAULT_CPUCOUNT:Int = 2
	
	' Functions:
	Function CPUCount:Int()
		Return DEFAULT_CPUCOUNT
	End
#End