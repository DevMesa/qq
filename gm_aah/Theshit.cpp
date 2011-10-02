
//#include "windows.h"
// Prevents shit from being unloaded...
// Causes a crash you see.

/*
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved)
{
	HMODULE hand = GetCurrentModule();
  switch(ul_reason_for_call)
  {
  case DLL_PROCESS_ATTACH:
    LockLibraryIntoProcessMem(hModule, &hand);
    break;
  case DLL_PROCESS_DETACH:
    break;
  }
    return TRUE;
}

*/
