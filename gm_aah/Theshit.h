#pragma once

#ifndef DONTUNLOAD_H
#define DONTUNLOAD_H

/*

class ILuaShared
{
public:
    virtual void            blah();
    virtual void            Init(void * (*)(char  const*,int *),bool,void *);
    virtual void            LoadCache(void);
    virtual void            SaveCache(void);
    virtual void            Shutdown(void);
    virtual void            DumpStats(void);
    virtual void            CreateLuaInterface(ILuaCallback *,char);
    virtual void            CloseLuaInterface(ILuaInterface *);
    virtual ILuaInterface*    GetLuaInterface(char);
    virtual void            GetFile(char  const*,char  const*,bool,bool,bool *);
    virtual void            FileExists(char  const*,char  const*,bool,bool,bool *);
    virtual void            SetTranslateHook(ILuaCallback*);
    virtual void            MountContent(void);
    virtual void            MountAddons(void);
    virtual void            MountGamemodes(void);
    virtual void            MountLua(char  const*,bool);
    virtual void            MountLuaAdd(char  const*,char  const*);
    virtual void            UnMountLua(char  const*);
    virtual void            GetAddonList(void);
    virtual void            GetGamemodeList(void);
    virtual void            GetContentList(void);
    virtual void            GetCommaSeperatedContentList(void);
    virtual void            LZMACompress(char *,int);
    virtual void            GetInterfaceByState(lua_State *);
    virtual void            SetDepotMountable(char  const*,bool);
};



__const:0072D1C4                 dd offset __ZTI15CScriptEnforcer ; `typeinfo for'CScriptEnforcer
__const:0072D1C8                 dd offset __ZN15CScriptEnforcer4NameEv ; CScriptEnforcer::Name(void)
__const:0072D1CC                 dd offset __ZN15CBaseGameSystem4InitEv ; CBaseGameSystem::Init(void)
__const:0072D1D0                 dd offset __ZN15CBaseGameSystem8PostInitEv ; CBaseGameSystem::PostInit(void)
__const:0072D1D4                 dd offset __ZN15CBaseGameSystem8ShutdownEv ; CBaseGameSystem::Shutdown(void)
__const:0072D1D8                 dd offset __ZN15CBaseGameSystem18LevelInitPreEntityEv ; CBaseGameSystem::LevelInitPreEntity(void)
__const:0072D1DC                 dd offset __ZN15CBaseGameSystem19LevelInitPostEntityEv ; CBaseGameSystem::LevelInitPostEntity(void)
__const:0072D1E0                 dd offset __ZN15CBaseGameSystem36LevelShutdownPreClearSteamAPIContextEv ; CBaseGameSystem::LevelShutdownPreClearSteamAPIContext(void)
__const:0072D1E4                 dd offset __ZN15CBaseGameSystem22LevelShutdownPreEntityEv ; CBaseGameSystem::LevelShutdownPreEntity(void)
__const:0072D1E8                 dd offset __ZN15CBaseGameSystem23LevelShutdownPostEntityEv ; CBaseGameSystem::LevelShutdownPostEntity(void)
__const:0072D1EC                 dd offset __ZN15CBaseGameSystem6OnSaveEv ; CBaseGameSystem::OnSave(void)
__const:0072D1F0                 dd offset __ZN15CBaseGameSystem9OnRestoreEv ; CBaseGameSystem::OnRestore(void)
__const:0072D1F4                 dd offset __ZN15CBaseGameSystem19SafeRemoveIfDesiredEv ; CBaseGameSystem::SafeRemoveIfDesired(void)
__const:0072D1F8                 dd offset __ZN15CBaseGameSystem10IsPerFrameEv ; CBaseGameSystem::IsPerFrame(void)
__const:0072D1FC                 dd offset __ZN15CScriptEnforcerD1Ev ; CScriptEnforcer::~CScriptEnforcer()
__const:0072D200                 dd offset __ZN15CScriptEnforcerD0Ev ; CScriptEnforcer::~CScriptEnforcer()
__const:0072D204                 dd offset __ZN15CBaseGameSystem9PreRenderEv ; CBaseGameSystem::PreRender(void)
__const:0072D208                 dd offset __ZN15CBaseGameSystem6UpdateEf ; CBaseGameSystem::Update(float)
__const:0072D20C                 dd offset __ZN15CBaseGameSystem10PostRenderEv ; CBaseGameSystem::PostRender(void)
__const:0072D210                 dd offset __ZN15CScriptEnforcer8IsActiveEv ; CScriptEnforcer::IsActive(void)
__const:0072D214                 dd offset __ZN15CScriptEnforcer13ScriptAllowedEPKcPKhiPh ; CScriptEnforcer::ScriptAllowed(char  const*,uchar  const*,int,uchar *)


*/


class IScriptEnforcer
{
public:
	virtual void				Unknown001();					//0000
	virtual void				Unknown002();					//0004
	virtual void				Unknown003();					//0008
	virtual void				Unknown004();					//000C
	virtual void				Unknown005();					//0010
	virtual void				Unknown006();					//0014
	virtual void				Unknown007();					//0018
	virtual void				Unknown008();					//001C
	virtual void				Unknown009();					//0020
	virtual void				Unknown010();					//0024
	virtual void				Unknown011();					//0028
	virtual void				Unknown012();					//002C
	virtual void				Unknown013();					//0030
	virtual void				Unknown014();					//0034
	virtual void				Unknown015();					//0038
	virtual void				Unknown016();					//003C
	virtual void				Unknown017();					//0040
	virtual bool				IsActive( void );				//0044
	virtual bool				ScriptAllowed(
									char* strScript,
									unsigned char* data,
									int size,
									unsigned char* u1 );		//0048
};

struct ScriptEnforcer_VTable
{
	void ( __stdcall* Unknown001 )();							//0000
	void ( __stdcall* Unknown002 )();							//0004
	void ( __stdcall* Unknown003 )();							//0008
	void ( __stdcall* Unknown004 )();							//000C
	void ( __stdcall* Unknown005 )();							//0010
	void ( __stdcall* Unknown006 )();							//0014
	void ( __stdcall* Unknown007 )();							//0018
	void ( __stdcall* Unknown008 )();							//001C
	void ( __stdcall* Unknown009 )();							//0020
	void ( __stdcall* Unknown010 )();							//0024
	void ( __stdcall* Unknown011 )();							//0028
	void ( __stdcall* Unknown012 )();							//002C
	void ( __stdcall* Unknown013 )();							//0030
	void ( __stdcall* Unknown014 )();							//0034
	void ( __stdcall* Unknown015 )();							//0038
	void ( __stdcall* Unknown016 )();							//003C
	void ( __stdcall* Unknown017 )();							//0040
	bool ( __stdcall* IsActive )();								//0044
	bool ( __stdcall* ScriptAllowed )(char* strScript, unsigned char* data, int size, unsigned char* u1); //004C
};




BOOL DataCompare( BYTE* pData, BYTE* bMask, char * szMask )
{
	for( ; *szMask; ++szMask, ++pData, ++bMask )
		if( *szMask == 'x' && *pData != *bMask )
			return FALSE;
 
	return ( *szMask == NULL );
}

char hexvals[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
void ToHex(char* out, BYTE byte)
{
	char a = hexvals[((BYTE)byte >> 4) % 16];
	char b = hexvals[(BYTE)byte % 16];

	out[0] = a;
	out[1] = b;
}

void ToMD5(char* ret, BYTE* md5)
{
	for(int i = 0; i < 16; i++)
		ToHex((char*)(ret + (i * 2)), md5[i]);
	
	ret[32] = 0;
	return;
}

DWORD FindPattern( DWORD dwAddress, DWORD dwLen, BYTE *bMask, char * szMask )
{
	for( DWORD i = 0; i < dwLen; i++ )
		if( DataCompare( (BYTE*)( dwAddress + i ), bMask, szMask ) )
			return (DWORD)( dwAddress + i );
 
	return 0;
}

#define CALL_HOOK(gLua, name) \
	ILuaObject *hookT = gLua->GetGlobal("hook");\
		ILuaObject *hookM = hookT->GetMember("Call");\
			hookM->Push();\
			\
			gLua->Push(name);\
			gLua->PushNil();\
			\
			gLua_Menu->Call(2, 1);\
		hookM->UnReference();\
	hookT->UnReference();

#define CALL_HOOK_1(gLua, name, a) \
	ILuaObject *hookT = gLua->GetGlobal("hook");\
		ILuaObject *hookM = hookT->GetMember("Call");\
			hookM->Push();\
			\
			gLua->Push(name);\
			gLua->PushNil();\
			gLua->Push(a);\
			\
			gLua->Call(3, 1);\
		hookM->UnReference();\
	hookT->UnReference();

#define CALL_HOOK_2(gLua, name, a, b) \
	ILuaObject *hookT = gLua->GetGlobal("hook");\
		ILuaObject *hookM = hookT->GetMember("Call");\
			hookM->Push();\
			\
			gLua->Push(name);\
			gLua->PushNil();\
			gLua->Push(a);\
			gLua->Push(b);\
			\
			gLua->Call(4, 1);\
		hookM->UnReference();\
	hookT->UnReference();

#define CALL_HOOK_3(gLua, name, a, b, c) \
	ILuaObject *hookT = gLua->GetGlobal("hook");\
		ILuaObject *hookM = hookT->GetMember("Call");\
			hookM->Push();\
			\
			gLua->Push(name);\
			gLua->PushNil();\
			gLua->Push(a);\
			gLua->Push(b);\
			gLua->Push(c);\
			\
			gLua->Call(5, 1);\
		hookM->UnReference();\
	hookT->UnReference();

#endif