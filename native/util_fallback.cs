
// Classes:
class external_util
{
	// Constant variable(s):
	public const int CPUCOUNT_DEFAULT = 2; // 1;
	
	// Global variable(s) (Public):
	// Nothing so far.
	
	// Global variable(s) (Private):
	private static int processorsAvailable_cache = 0;
	
	// Functions:
	public static int processorsAvailable()
	{
		if (processorsAvailable_cache == 0)
		{
			// Local variable(s):
			int count = Environment.ProcessorCount;
			
			processorsAvailable_cache = (count > 0) ? count : CPUCOUNT_DEFAULT;
		}
		
		return processorsAvailable_cache;
	}
}
