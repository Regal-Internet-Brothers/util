
// External C++ / GLFW functionality for the 'util' module:

// Namespace(s):
namespace external_util
{
	// Functions:
	bool setClipboard(String input)
	{
		// Set the system's clipboard-string.
		glfwSetClipboardString(BBGlfwGame::GlfwGame()->GetGLFWwindow(), input.ToUtf8()); // input.ToCString<char>();
		
		// Return the default response.
		return true;
	}
	
	String getClipboard()
	{
		// Grab the current state of the clipboard.
		const char* nativeString = glfwGetClipboardString(BBGlfwGame::GlfwGame()->GetGLFWwindow());
		
		// Convert the native clipboard-data into a Monkey 'String'.
		return String(nativeString, strlen(nativeString));
	}
	
	bool clearClipboard()
	{
		// Attempt to clear the clipboard (For some reason, I can't just supply 'NULL').
		glfwSetClipboardString(BBGlfwGame::GlfwGame()->GetGLFWwindow(), "");
		
		// Return the default response.
		return true;
	}
}
