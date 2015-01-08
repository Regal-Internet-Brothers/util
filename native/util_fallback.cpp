
/*
	ATTENTION: The functionality provided in this file is largely untested.
	
	This file uses specific POSIX and vendor-defined functionality
	in order to get the number of processors/threads available on a system.
	
	Specific measures are made to make sure POSIX functionality is supported,
	however, I can't support everybody. If you're having problems compiling,
	please define/uncomment 'UTIL_FORCE_POSIX' (Or add your system to the check).
*/

// Preprocessor related:
//#define UTIL_FORCE_POSIX

// Includes:
#if defined(UTIL_FORCE_POSIX) || defined (__unix__)
	|| (defined (__APPLE__) && defined (__MACH__))
	|| defined(__linux__) || defined(__gnu_linux__)
	|| defined(__OpenBSD__) || defined(__FreeBSD__)
	
	#define UTIL_POSIX_AVAILABLE
	
	// If you're unable to compile with this defined, comment this line out.
	#define UTIL_USE_NEWPOSIX
#endif

#ifdef UTIL_POSIX_AVAILABLE
	#include <unistd.h>
	
	#if !defined(UTIL_USE_NEWPOSIX) // defined(__linux__)
		#include <linux/sysctl.h>
	#endif
#endif

// Namespaces:
namespace external_util
{
	// Global variable(s):
	
	// Do not modify this variable.
	static int processorsAvailable_cache = 0;
	static int DEFAULT_CPUCOUNT = 2; // 1;
	
	// Functions:
	int processorsAvailable()
	{
		if (processorsAvailable_cache == 0)
		{
			#if UTIL_POSIX_AVAILABLE
				#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_4) || defined(UTIL_USE_NEWPOSIX)
					// Local variable(s):
					
					// Not the best of methods, but it works...
					int count = (int)sysconf(_SC_NPROCESSORS_ONLN);
					
					processorsAvailable_cache = (count > 0) ? count : DEFAULT_CPUCOUNT;
				#else
					/*
						This setup is not likely to have long-term compatibility.
						However, it will probably support a larger number of legacy systems.
						
						This compatbility oriented backend is based off of a
						post made by StackOverflow user "paxos1977".
						(http://stackoverflow.com/a/150971)
					*/
					
					// Local variable(s):
					size_t variableSize = sizeof(processorsAvailable_cache);
					
					int MIB[4];
					
					MIB[0] = CTL_HW;
					MIB[1] = HW_AVAILCPU;
					
					sysctl(MIB, 2, &processorsAvailable_cache, &variableSize, NULL, 0);
					
					if (processorsAvailable_cache < 1)
					{
						MIB[1] = HW_NCPU;
						
						sysctl(MIB, 2, &processorsAvailable_cache, &variableSize, NULL, 0);
						
						if (processorsAvailable_cache < 1)
							processorsAvailable_cache = DEFAULT_CPUCOUNT;
					}
				#endif
			#endif
		}
		
		return processorsAvailable_cache;
	}
}
