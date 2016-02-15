Strict

Public

' Imports (Public):
Import monkey.random

' Imports (Private):
Private

Import regal.time
Import regal.typetool

Public

' Global variable(s):

' A global stack logging randomization seeds.
' This is commonly accessed by the 'PushSeed' and 'PopSeed' functions.
Global SeedStack:Stack<Int> = Null

' Functions:

' This is just a wrapper for the main implementation:
Function PushSeed:Bool()
	Return PushSeed(Seed)
End

' The return value of this function specifies if the seed-stack already existed.
Function PushSeed:Bool(Seed:Int)
	' Local variable(s):
	Local Response:Bool = (SeedStack <> Null)
	
	If (Not Response) Then
		SeedStack = New IntStack()
	Endif
	
	SeedStack.Push(Seed)
	
	' Return the calculated response.
	Return Response
End

' This command retrieves a seed from the seed-stack,
' if no seed exists, the current randomization seed is returned.
Function PopSeed:Int()
	If (SeedStack <> Null) Then
		If (Not SeedStack.IsEmpty()) Then
			Return SeedStack.Pop()
		Endif
	Endif
	
	' Return the default response.
	Return Seed
End

' This command sets the randomization seed to the
' current up-time of the system (In milliseconds).
' This is only done if a valid implementation could be found.
' In the event 'Millisecs' could not be resolved, this will do fail silently.
Function SetSeedToUptime:Void()
	#If MILLISECS_IMPLEMENTED
		Seed = Millisecs()
	#End
	
	Return
End

' These commands are basic wrappers for the 'Rnd' command, which allow the user to generate
' a one-off random number (Without changing the seed after execution).
Function RandomNumber:Double()
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd()
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End

Function RandomNumber:Double(Range:Double)
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd(Range)
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End

Function RandomNumber:Double(Low:Double, High:Double)
	' Push the current seed onto the seed-stack.
	PushSeed()
	
	' Set the seed to the up-time of the system (In milliseconds).
	SetSeedToUptime()
	
	' Local variable(s):
	
	' Randomize a number for the user.
	Local Number:= Rnd(Low, High)
	
	' Pop the last saved seed off of the seed-stack.
	PopSeed()
	
	' Return the randomized number.
	Return Number
End