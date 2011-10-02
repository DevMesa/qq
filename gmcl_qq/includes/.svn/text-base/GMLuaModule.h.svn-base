//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2008
//										 
//=============================================================================//

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "ILuaObject.h"
#include "ILuaShared.h"

#include "ILuaModuleManager.h"


#define GMOD_MODULE_ASSIGNSTATE() \
	if (i->IsServer() || i->IsDedicatedServer()){\
		gLua_Server = i;\
	}else if (i->IsClient()){\
		ILuaObject* MaxPlayers = i->GetGlobal("MaxPlayers");\
		if (MaxPlayers->isFunction()){\
			gLua_Client = i;\
		}else{\
			gLua_Menu = i;\
		}\
		MaxPlayers->UnReference();\
	}\

ILuaInterface *GMOD_MODULE_FUNCTION(lua_State* L)
{
	if (gLua_Server != NULL){
		if (L == gLua_Server->GetLuaState()){
			return gLua_Server;
		}
	}
	else if (gLua_Client != NULL){
		if (L == gLua_Client->GetLuaState()){
			return gLua_Client;
		}
	}
	else if (gLua_Menu != NULL){
		if (L == gLua_Menu->GetLuaState()){
			return gLua_Menu;
		}
	}
	return NULL; // If we get here, something is terribly wrong
}

// You should place this at the top of your module
#define GMOD_MODULE( _startfunction_, _closefunction_ ) \
	ILuaModuleManager* modulemanager = NULL;\
	int _startfunction_( lua_State* L );\
	int _closefunction_( lua_State* L );\
	extern "C" int __declspec(dllexport) gmod_open( ILuaInterface* i ) \
	{ \
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		modulemanager = i->GetModuleManager();\
		lua_State* L = (lua_State*)(i->GetLuaState());\
		GMOD_MODULE_ASSIGNSTATE()\
		return _startfunction_( L);\
	}\
	extern "C" int __declspec(dllexport) gmod_close( lua_State* L ) \
	{\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		__asm { nop }\
		_closefunction_( L );\
		return 0;\
	}\

#define LUA_FUNCTION( _function_ ) static int _function_( lua_State* L )