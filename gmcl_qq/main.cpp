#define WIN32_LEAN_AND_MEAN
#undef _UNICODE

#define QQ_MODULE_VERSION 1

#include "includes/ILuaInterface.h"
ILuaInterface* gLua_Menu = NULL;
ILuaInterface* gLua_Client = NULL;
ILuaInterface* gLua_Server = NULL;
ILuaInterface* gLua = NULL;

#include "includes/GMLuaModule.h"

#include <windows.h>
#include <direct.h>

#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "vtf.lib")
#pragma comment(lib, "tier0.lib")
#pragma comment(lib, "tier1.lib")
#pragma comment(lib, "tier2.lib")
#pragma comment(lib, "tier3.lib")
#pragma comment(lib, "matsys_controls.lib")
#pragma comment(lib, "bitmap.lib")
#pragma comment(lib, "choreoobjects.lib")
#pragma comment(lib, "dmxloader.lib")
#pragma comment(lib, "mathlib.lib")
#pragma comment(lib, "nvtristrip.lib")
#pragma comment(lib, "particles.lib")
#pragma comment(lib, "raytrace.lib")
#pragma comment(lib, "steam_api.lib")
#pragma comment(lib, "vgui_controls.lib")
#pragma comment(lib, "vmpi.lib")
#pragma comment(lib, "vstdlib.lib")


#define CLIENT_DLL

#include "cbase.h"
#include "c_baseanimating.h"
#include "cmodel.h" 
#include "cdll_int.h"
#include "icliententitylist.h"
#include "convar.h"
#include "icvar.h"
#include <interface.h>
#include <tier0/dbg.h>
#include "color.h"
#include <interface.h>
#include <cdll_int.h>
#include <materialsystem/imaterial.h>
#include <materialsystem/imaterialsystem.h>
#include "color.h"
#include "inetchannelinfo.h"
#include "engine/ivdebugoverlay.h"

#include <eiface.h>
#include <math.h>
#include <usercmd.h>
#include <checksum_md5.h>
#include <vstdlib/random.h>
#include "mathlib/vector.h"
#include "igameevents.h"

#include "game/server/iplayerinfo.h"
#include "Theshit.h"
#include "QQEvent.h"

IClientEntityList*		g_pClientEntityList		= NULL;
IVModelInfoClient*		g_pIVModelInfoClient	= NULL;
CGlobalVarsBase*		g_pGlobals				= NULL;
IVEngineClient*			g_pEngine				= NULL;
IBaseClientDLL*			g_pClient				= NULL;
ICvar*					g_CVar					= NULL;
IMaterialSystem*		g_pMatSystem			= NULL;
IGameEventManager2*		g_pEventsManager		= NULL;
IVPhysicsDebugOverlay*	g_pDebugOverlay			= NULL;
int EntIndexRef = NULL;

#define XASSERT( x ) if( !x ) MessageBoxW( 0, L"Assertion failed for \""L#x##L"\"", 0, 0 );

#include <fstream>
#include "dirent.h"
#include <sys/stat.h> 
using namespace std;

class EventListener : public IGameEventListener2
{
public:
	void FireGameEvent( IGameEvent* event );
} event_listener;

#define PUSHEVENT(str) _eval = (char*)event->GetString(str);\
		memcpy(_eval2, _eval, sizeof(_eval));\
		e->PushEvent(str, _eval2)

void EventListener::FireGameEvent( IGameEvent* event )
{
	return;
	char* eventname;
	memcpy(eventname, event->GetName(), sizeof(event->GetName()));
	if( Q_strcmp( eventname, "player_connect") == 0 )
	{
		CQQEvent* e = new CQQEvent((char*)eventname);
		char* _eval;
		char* _eval2;
		PUSHEVENT("name");
		PUSHEVENT("networkid"); // ID
		PUSHEVENT("address"); // IP
		Msg("Pushing event...");
		QQEventManager.PushEvent(e);
		Msg("Event pushed\n");
		e->UnRefrence();
	}
}

LUA_FUNCTION(GetTopEvent)
{
	CQQEvent* e = QQEventManager.PopEvent();
	if(!e)
	{
		gLua->PushNil();
		return 1;
	}

	ILuaObject* eventtbl = gLua->GetNewTable();
	eventtbl->SetMember("EventName", e->GetName());

	qqeventargs_t* args[10];
	int count = e->GetArgs(args);
	for(int i = 0; i < count; i++)
	{
		qqeventargs_t* arg = args[i];
		char* name = arg->name;
		char* val = arg->value;

		eventtbl->SetMember(name, val);
	}

	gLua->Push(eventtbl);

	e->UnRefrence();
	return 1;
}

LUA_FUNCTION( GetNames )
{
	int size = g_pMatSystem->GetNumMaterials();
	int list = g_pMatSystem->FirstMaterial();

	ILuaObject* table = gLua->GetNewTable();

	while ( ++list != size )
	{
		IMaterial* used_list = g_pMatSystem->GetMaterial(list);
		table->SetMember(list + 1, used_list->GetName());
	}
	gLua->Push(table);
	return 1;
}

LUA_FUNCTION( GetTextureGroup )
{
	// Materials
	int size = g_pMatSystem->GetNumMaterials();
	int list = g_pMatSystem->FirstMaterial();

	ILuaObject* table = gLua->GetNewTable();

	while ( ++list != size )
	{
		IMaterial* used_list = g_pMatSystem->GetMaterial(list);
		table->SetMember(list + 1, used_list->GetTextureGroupName());
	}
	gLua->Push(table);
	return 1;
}

LUA_FUNCTION( GetAll )
{
	// Materials
	int size = g_pMatSystem->GetNumMaterials();
	int list = g_pMatSystem->FirstMaterial();

	ILuaObject* table = gLua->GetNewTable();

	while ( ++list != size )
	{
		IMaterial* used_list = g_pMatSystem->GetMaterial(list);
		
		table->SetMember(list + 1, used_list);
	}

	gLua->Push(table);
	return 1;
}

bool C_BaseEntity::SetupBones( matrix3x4_t *pBoneToWorldOut, int nMaxBones, int boneMask, float currentTime )
{
	_asm JMP DWORD PTR [ ECX + 0x3C ];
}


bool GetHitboxPosition ( int hitbox, Vector& origin, int index, QAngle& angles )
{
	if( hitbox < 0 || hitbox >= 20 )
		return false;
 
	matrix3x4_t pmatrix[MAXSTUDIOBONES];
 
	IClientEntity* ClientEntity = g_pClientEntityList->GetClientEntity( index );
 
	if (! ClientEntity )
		return false;
	if ( ClientEntity->IsDormant() )
		return false;
 
	const model_t* model = ClientEntity->GetModel();
 
	if(!model)
		return false;
 
	studiohdr_t *pStudioHdr = g_pIVModelInfoClient->GetStudiomodel( model );
 
	if ( !pStudioHdr )
		return false;
       
	if(! ClientEntity->SetupBones( pmatrix, 128, BONE_USED_BY_HITBOX,  g_pGlobals->curtime ) )
		return false;
 
	mstudiohitboxset_t *set = pStudioHdr->pHitboxSet( 0 );
 
	if ( !set )
		return false;
 
	mstudiobbox_t* pBox = NULL;
	pBox = pStudioHdr->pHitbox( hitbox, NULL );
	Vector min, max;
	MatrixAngles( pmatrix[ pBox->bone ], angles, origin );
	VectorTransform( pBox->bbmin, pmatrix[ pBox->bone ], min );
	VectorTransform( pBox->bbmax, pmatrix[ pBox->bone ], max );
	origin = ( min + max ) * 0.5f;
 
	return true;
}

LUA_FUNCTION(DrawClientHitBoxes)
{
	gLua->CheckType( 1, GLua::TYPE_ENTITY );       // Player
	
	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();
	

	IClientEntity* pEnt = g_pClientEntityList->GetClientEntity( index );       
    if( !pEnt || pEnt->IsDormant() )
		return 0;
	
    C_BaseEntity *pBaseEntity = pEnt->GetBaseEntity();
	C_BaseAnimating *pBaseAnim = (C_BaseAnimating*)pBaseEntity;

	if( !pBaseAnim )
		return 0;
	
	pBaseAnim->DrawClientHitboxes(g_pGlobals->frametime, false);
	Msg("DRAWN\n");
	return 0;
}
/*
LUA_FUNCTION(GetHitBox)
{
	gLua->CheckType(1, GLua::TYPE_ENTITY);
	gLua->CheckType(2, GLua::TYPE_NUMBER);
	
	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int EntIndex = Ret->GetInt();
	Ret->UnReference();
	
	int hitbox = gLua->GetNumber(2);

	Vector pos;
	QAngle ang;
	if(! GetHitboxPosition(hitbox, pos, EntIndex, ang) ) return 0;

	gLua->Push( LVector(gLua, pos.x, pos.y, pos.z) );
	return 1;
}
*/
//virtual studiohdr_t				*GetStudiomodel( const model_t *mod ) = 0;


#define LUA_ERROR(x) gLua->LuaError(x); gLua->Push( false ); return 1;
LUA_FUNCTION( GetHitBox )
{
	gLua->CheckType( 1, GLua::TYPE_NUMBER );       // Hitbox
	gLua->CheckType( 2, GLua::TYPE_ENTITY );       // Player
	
	Vector vecOrigin;

	int hitbox = gLua->GetInteger(1);
	
	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();
	
	/*
	IClientEntity* pEnt = g_pClientEntityList->GetClientEntity( index );       
    if( !pEnt || pEnt->IsDormant() )
		return 0;
    C_BaseEntity *pBaseEntity = pEnt->GetBaseEntity();
	C_BaseAnimating *pBaseAnim = (C_BaseAnimating*)pBaseEntity;
	

	mstudiobbox_t* pbox = NULL;
	matrix3x4_t trix;
	pBaseAnim->GetBoneTransform(14, trix);
	
	Vector vMin, vMax;
	VectorTransform(pbox->bbmin, trix, vMin);
	VectorTransform(pbox->bbmax, trix, vMax);
	Vector vBox = (vMin + vMax) * 0.5f;
	
	//pbox = pStudioHdr->pHitbox( hitbox, 0 );

	return 0; /////////////
	*/
	int curtime = g_pGlobals->curtime;

    if( hitbox < 0 || hitbox >= 20 )
            return false;

    matrix3x4_t pmatrix[MAXSTUDIOBONES];
    Vector vMin, vMax;

    IClientEntity* pEnt = g_pClientEntityList->GetClientEntity( index );
           
    if( !pEnt || pEnt->IsDormant() )
            return 0;
   
    C_BaseEntity *pBaseEntity = pEnt->GetBaseEntity();

    if( !pBaseEntity )
            return 0;

    if( pBaseEntity->IsDormant() )
            return 0;

    const model_t *model = pBaseEntity->GetModel();
   
    if( model )
    {
            studiohdr_t *pStudioHdr = g_pIVModelInfoClient->GetStudiomodel( model);
            if ( !pStudioHdr )
			{
				LUA_ERROR(":(");
			}
            if( pBaseEntity->SetupBones( pmatrix, 128, BONE_USED_BY_HITBOX, curtime) == false )
                    return 0;
            mstudiohitboxset_t *set = pStudioHdr->pHitboxSet( 0 );
            if ( !set )
                    return 0;
            mstudiobbox_t* pbox = NULL;
            pbox = pStudioHdr->pHitbox( hitbox, 0 );
            VectorTransform( pbox->bbmin, pmatrix[ pbox->bone ], vMin );
            VectorTransform( pbox->bbmax, pmatrix[ pbox->bone ], vMax );
            vecOrigin = ( vMin + vMax ) * 0.5f;
			gLua->Push(LVector(gLua, vecOrigin.x, vecOrigin.y, vecOrigin.z)); 
            return 1;
    }
    return 0;

/*
	int hitbox = gLua->GetInteger(1);
	
	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();

	int curtime = g_pGlobals->curtime;
	
	Vector vecOrigin = *( Vector* )( gLua->GetUserData( 3 ) );
	QAngle angles = *( QAngle* )( gLua->GetUserData( 4 ) );

	if( hitbox < 0 || hitbox >= 20 )
	{
		LUA_ERROR("Hitbox value is out of range(0-19)");
	}

	matrix3x4_t pmatrix[ MAXSTUDIOBONES ];
	Vector vMin, vMax;

	IClientEntity* ClientEntity = g_pClientEntityList->GetClientEntity( index );
	if ( ClientEntity == NULL )
	{
		LUA_ERROR("ClientEntity is null!");
	}

	if ( ClientEntity->IsDormant() )
	{
		LUA_ERROR("Entity is dormant!");
	}
	
	const model_t* model;
	model = ClientEntity->GetModel();
	
	if( model )
	{
		studiohdr_t *pStudioHdr = g_pIVModelInfoClient->GetStudiomodel( model );
		
		if ( !pStudioHdr )
		{
			LUA_ERROR("Cannot get studio model");
		}

		if( ClientEntity->SetupBones( pmatrix, 128, BONE_USED_BY_HITBOX, curtime ) == false )
		{
			LUA_ERROR("Failed to setup bones!");
		}

		mstudiohitboxset_t *set = pStudioHdr->pHitboxSet( 0 );
		if ( !set )
		{
			LUA_ERROR("Failed to get hitbox set!");
		}

		mstudiobbox_t* pbox = NULL;
		pbox = pStudioHdr->pHitbox(hitbox, 0);

		MatrixAngles( pmatrix[ pbox->bone ], angles, vecOrigin );
		VectorTransform( pbox->bbmin, pmatrix[ pbox->bone ], vMin );
		VectorTransform( pbox->bbmax, pmatrix[ pbox->bone ], vMax );
		Vector &vecOrigin = ( vMin + vMax ) * 0.5f;

		ILuaObject* lua_vec = LVector(gLua,vecOrigin.x, vecOrigin.y, vecOrigin.z);

		gLua->Push( lua_vec );
	}else{
		LUA_ERROR("Model is not valid");
	}

	return 1;
	*/
}

LUA_FUNCTION(DoCommand)
{
	gLua->CheckType(1, GLua::TYPE_STRING);
	const char* str = gLua->GetString(1);
	g_pEngine->ClientCmd(str);
	return 0;
}
CBaseEntity* GetEntityByIndex( int idx )
{
	if( g_pClientEntityList == NULL ) return NULL;
	IClientEntity *pClient = g_pClientEntityList->GetClientEntity( idx );
	if( pClient == NULL ) return NULL;
	return pClient->GetBaseEntity();
}

CBaseEntity* GetLocalEntity()
{
	if( g_pEngine == NULL ) return NULL;
	return GetEntityByIndex( g_pEngine->GetLocalPlayer() );
}

LUA_FUNCTION(FixViewPunch)
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	CUserCmd* cmd = (CUserCmd*)(gLua->GetUserData(1));
	
	QAngle* punch = (QAngle*)((DWORD)GetLocalEntity() + 0x6C);
	cmd->viewangles.x -= (punch->x * (1.93 +( rand() % 1 / 5 ) ) );
	cmd->viewangles.y -= (punch->y * (1.93 +( rand() % 1 / 5 ) ) );
	cmd->viewangles.z -= (punch->z * (1.93 +( rand() % 1 / 5 ) ) );
	
	return 0;
}

void Normalize(Vector &vIn, Vector &vOut)
{
    float flLen = vIn.Length();
    if(flLen == 0)
    {
	vOut.Init(0, 0, 1);
	return;
    }
    flLen = 1 / flLen;
    vOut.Init(vIn.x * flLen, vIn.y * flLen, vIn.z * flLen);
}

int vseed = 0;
LUA_FUNCTION( PredictSpread )
{
	gLua = Lua();

    gLua->CheckType( 1, GLua::TYPE_USERCMD );
    gLua->CheckType( 2, GLua::TYPE_VECTOR );
    gLua->CheckType( 3, GLua::TYPE_VECTOR );

	// Seed
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData(1) );

	unsigned int cmd2 = *( ( int* ) cmd + 1 );
	unsigned int seed = cmd->random_seed = MD5_PseudoRandom( cmd->command_number ) & 0x7fffffff;
	
	if( cmd2 != 0 )
		vseed = (int)seed;

	// Nospread
    RandomSeed( vseed & 255 );

	Vector vecForward = *(Vector*)(gLua->GetUserData(2));
	Vector vecRight;
	Vector vecUp;
	VectorVectors(vecForward, vecRight, vecUp);
	Vector &vecSpread = *(Vector*)(gLua->GetUserData(3));

	float x, y, z;
	do {
		x = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		y = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		z = x*x + y*y;
	} while (z > 1);

	Vector vecResult(0, 0, 0);
	vecResult = vecForward + x * vecSpread.x * vecRight + y * vecSpread.y * vecUp;
	
	Vector temp;
	Normalize(vecResult, temp);
	vecResult = temp;

	ILuaObject* vectorLibrary = gLua->GetGlobal("Vector");
	gLua->Push(vectorLibrary);
	gLua->Push(vecResult.x);
	gLua->Push(vecResult.y);
	gLua->Push(vecResult.z);
	gLua->Call(3, 1);
	ILuaObject* ret = gLua->GetReturn(0);
	if (ret)
		gLua->Push(ret);
	else
		gLua->PushNil();
    return 1;
}


LUA_FUNCTION( ColorMsg )
{
	gLua->CheckType(2, GLua::TYPE_STRING);
	gLua->CheckType(1, GLua::TYPE_TABLE);

	const char* msg = gLua->GetString(2);
	ILuaObject *col = gLua->GetObjectA(1);
		int r = col->GetMemberInt("r");
		int g = col->GetMemberInt("g");
		int b = col->GetMemberInt("b");
	col->UnReference();

	Color vcol(r,g,b,255);
	ConColorMsg(vcol, msg);
	return 0;
}

LUA_FUNCTION( AntiAim )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );	
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	
	Vector viewforward, viewright, viewup, aimforward, aimright, aimup;
    QAngle qAimAngles;

    float forward = cmd->forwardmove;
    float right = cmd->sidemove;
    float up = cmd->upmove;

    qAimAngles.Init( 0.0f, cmd->viewangles.y, 0.0f );
    qAimAngles.Init( 0.0f, cmd->viewangles.x, 0.0f );

    AngleVectors( qAimAngles, &viewforward, &viewright, &viewup );
    AngleVectors( cmd->viewangles, &viewforward, &viewright, &viewup );

    QAngle qOne(
	    AngleNormalize( ( int )vec_t( 360.0f ) ),
	    AngleNormalize( ( int )vec_t( 360.0f ) ),
	    AngleNormalize( ( int )vec_t( 180.0f ) )
    );

    QAngle qTwo(
	    vec_t( 360.0f ),
	    vec_t( 360.0f ),
	    vec_t( 360.0f )
    );

    QAngle qThree(
	    vec_t( 180.0f ),
	    cmd->viewangles.y - 180 + rand()%15,
	    vec_t( -360.0f )
    );

    cmd->viewangles = qOne + qTwo + qThree; // start
    cmd->viewangles.y -= ( vec_t )fmod( -180, 180.f );
    cmd->viewangles.z = ( vec_t )fmod( -360, 360.f ); // new

    cmd->random_seed = 180;

	return 0;
}

LUA_FUNCTION(IsDormant)
{
	gLua->CheckType(1, GLua::TYPE_ENTITY);

	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();

	IClientEntity* ClientEntity = g_pClientEntityList->GetClientEntity( index );
	gLua->Push(ClientEntity->IsDormant());
	return 1;
}

INetChannelInfo* g_pNetChannel = NULL;
typedef INetChannelInfo*(*GetNetChannelFn)();
INetChannelInfo* GetNetChannel()
{
	if ( !g_pNetChannel )
	{
		DWORD*  pdwEnginePhone = (DWORD*)*(DWORD*) g_pEngine;

		GetNetChannelFn GetNetChannelFunc = (GetNetChannelFn)pdwEnginePhone[72];
		g_pNetChannel = GetNetChannelFunc();
	}
 
	return g_pNetChannel;
}

typedef INetChannelInfo*(*GetNetChannelFnI)(int);
INetChannelInfo* GetNetChannel(int index)
{
	DWORD*  pdwEnginePhone = (DWORD*)*(DWORD*) g_pEngine;

	GetNetChannelFnI GetNetChannelFunc = (GetNetChannelFnI)pdwEnginePhone[72];
	return GetNetChannelFunc(index);
}

LUA_FUNCTION(GetIP)
{
	gLua->CheckType(1, GLua::TYPE_ENTITY);

	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();

	INetChannelInfo* info = GetNetChannel(index);
	XASSERT(info);

	gLua->Push(info->GetName());
	return 1;
}

LUA_FUNCTION(GetLatency)
{
	gLua->CheckType(1, GLua::TYPE_NUMBER);
	int flow = gLua->GetInteger(1);

	if(flow != 0 && flow != 1)
	{
		gLua->LuaError("GetOutgoingLatency - 0 for outgoing, 1 for incomming\n");
		gLua->Push(0.0f);
		gLua->Push(0.0f);
		return 2;
	}

	INetChannelInfo* info = GetNetChannel();
	XASSERT(info);
	

	float latency = info->GetLatency(flow);
	float avglatency = info->GetAvgLatency(flow);
	
	gLua->Push(latency);
	gLua->Push(avglatency);

	return 2;
}

LUA_FUNCTION(GetLoss)
{
	gLua->CheckType(1, GLua::TYPE_NUMBER);
	int flow = gLua->GetInteger(1);

	if(flow != 0 && flow != 1)
	{
		gLua->LuaError("GetLoss - 0 for outgoing, 1 for incomming\n");
		gLua->Push(0.0f);
		return 1;
	}

	INetChannelInfo* info = GetNetChannel();
	XASSERT(info);

	float loss = info->GetAvgLoss(flow);
	
	gLua->Push(loss);
	return 1;
}

LUA_FUNCTION( HasBeenPredicted )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	gLua->Push(cmd->hasbeenpredicted);
	return 1;
}

LUA_FUNCTION( TickCount )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	gLua->PushLong((long)cmd->tick_count);
	return 1;
}

LUA_FUNCTION( CommandNumber )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	gLua->PushLong((long)cmd->command_number);
	return 1;
}

LUA_FUNCTION( SetViewAngles )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	gLua->CheckType( 2, GLua::TYPE_VECTOR );
	
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	Vector *vec = ( Vector * )( gLua->GetUserData( 2 ) );
	

	/*ILuaObject* ang = gLua->GetObject(2);
		int x = ang->GetMemberFloat("x");
		int y = ang->GetMemberFloat("y");
		int z = ang->GetMemberFloat("z");
	ang->UnReference();*/
	
	cmd->viewangles.x = vec->x;
	cmd->viewangles.y = vec->y;
	cmd->viewangles.z = vec->z;

	return 0;
}

LUA_FUNCTION( qqReadBinary )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* file = gLua->GetString(1);
	
	int length;
	char* buffer;

	ifstream is;
	is.open (file, ios::binary);

	if(!is.is_open()) return 0;

	// get length of file:
	is.seekg (0, ios::end);
	length = is.tellg();
	is.seekg (0, ios::beg);
	
	

	// allocate memory:
	buffer = new char [length];

	// read data as a block:
	is.read (buffer, length);
	
	ILuaObject* tbl = gLua->GetNewTable();
	for(int i = 0; i < length; i++)
		tbl->SetMember((float)(i + 1), (float)(int)(unsigned char)buffer[i]);

	delete[] buffer;
	
	gLua->Push(tbl);
	tbl->UnReference();
	return 1;
}

ofstream file;

LUA_FUNCTION( qqWriteBinary )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* strfile = gLua->GetString(1);
	
	if(file.is_open()) 
		file.close();

	file.open(strfile, ios::binary);

	gLua->Push(file.is_open());
	return 1;
}

LUA_FUNCTION( qqWriteBinaryPut )
{
	gLua->CheckType( 1, GLua::TYPE_NUMBER );
	file.put((char)gLua->GetInteger(1));
	return 0;
}

LUA_FUNCTION( qqWriteBinaryClose )
{
	file.close();
	return 0;
}

LUA_FUNCTION( qqWrite )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->CheckType( 2, GLua::TYPE_STRING );

	const char* file = gLua->GetString(1);
	const char* contents = gLua->GetString(2);

	std::ofstream out;
	out.open(file, std::ios::binary);

	if(!out.is_open())
	{
		gLua->Push(false);
		return 1;
	}
	
	out << contents;
	out.close();

	gLua->Push(true);
	return 1;
}

LUA_FUNCTION( qqRead )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* file = gLua->GetString(1);
	
	int length;
	char* buffer;

	ifstream is;
	is.open (file, ios::binary);

	if(!is.is_open()) return 0;

	// get length of file:
	is.seekg (0, ios::end);
	length = is.tellg();
	is.seekg (0, ios::beg);
	
	

	// allocate memory:
	buffer = new char [length + 1];

	// read data as a block:
	is.read (buffer, length);
	
	buffer[length] = 0;
	
	gLua->Push(buffer);
	delete[] buffer;

	return 1;
}

LUA_FUNCTION( qqGetFileList )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	const char* directoryin = gLua->GetString(1);

	DIR *dir;
	struct dirent *ent;
	dir = opendir(directoryin);
	if (dir != NULL)
	{
		ILuaObject* obj = gLua->GetNewTable();
		while ((ent = readdir (dir)) != NULL) 
			obj->SetMember(ent->d_name, "");
		
		closedir (dir);
		gLua->Push(obj);

		obj->UnReference();
		return 1;
	} else {
		gLua->PushNil();
		return 1;
	}
}

LUA_FUNCTION( qqDIRExists )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* fullPath = gLua->GetString( 1 );
	
	struct stat chk;
	if ( stat( fullPath, &chk ) == 0 )
		gLua->Push( true );
	else
		gLua->Push( false );

	return 1;
}

LUA_FUNCTION( qqMakeDIR )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* fullPath = gLua->GetString( 1 );

	mkdir(fullPath);
	return 0;
}

LUA_FUNCTION( RunString )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->CheckType( 2, GLua::TYPE_STRING );

	gLua->Push(
		gLua->RunString("", gLua->GetString(1), gLua->GetString(2), true, true)
	);
	return 1;
}

LUA_FUNCTION( IntervalPerTick )
{
	gLua->Push(g_pGlobals->interval_per_tick);
	return 1;
}

LUA_FUNCTION( InterpAmmount )
{
	gLua->Push(g_pGlobals->interpolation_amount);
	return 1;
}

// Thanks to s0beit
LUA_FUNCTION( GetNetVars )
{
	ClientClass* pClass = g_pClient->GetAllClasses();
	XASSERT(pClass);
	
	ILuaObject* pRet = gLua->GetNewTable();

	for (; pClass; pClass = pClass->m_pNext)
	{
		RecvTable* pTable = pClass->m_pRecvTable;

		if(!pTable || pTable->GetNumProps() <= 1)
			continue;

		ILuaObject* pLuaTable = gLua->GetNewTable();
		pRet->SetMember(pTable->GetName(), pLuaTable);

		for(int i = 0; i < pTable->GetNumProps(); i++)
		{
			RecvProp* pProp = pTable->GetProp(i);

			if(!pProp)
				continue;

			const char* name = pProp->GetName();
			pLuaTable->SetMember(name, (float)pProp->GetOffset());
		}

		pLuaTable->UnReference();
	}

	gLua->Push(pRet);
	pRet->UnReference();
	return 1;
}

LUA_FUNCTION( GetFloatFromOffset )
{
	gLua->CheckType(1, GLua::TYPE_ENTITY);
	gLua->CheckType(2, GLua::TYPE_NUMBER);

	gLua->PushReference(EntIndexRef);
		ILuaObject* obj = gLua->GetObject(1);
		gLua->Push(obj);
	gLua->Call(1, 1);

	ILuaObject *Ret = gLua->GetReturn(0);
		int index = Ret->GetInt();
	Ret->UnReference();

	IClientEntity* pEnt = g_pClientEntityList->GetClientEntity( index );
           
    if( !pEnt )
		return 0;
   
    C_BaseEntity *pBaseEntity = pEnt->GetBaseEntity();

	float flRet = *( float* )( ( DWORD )pBaseEntity + gLua->GetInteger(2) );
	gLua->Push(flRet);

	return 1;
}

char hex_map[256];

LUA_FUNCTION( GetObjectFromPtr )
{
	gLua->CheckType(1, GLua::TYPE_STRING);
	const char* str = gLua->GetString(1);
	
	if(strlen(str) < 8) return 0;

	unsigned int ptr = 0;
#define fromhexmap(x) hex_map[str[x]]
	ptr += fromhexmap(0) << 28;
	ptr += fromhexmap(1) << 24;
	ptr += fromhexmap(2) << 20;
	ptr += fromhexmap(3) << 16;
	ptr += fromhexmap(4) << 12;
	ptr += fromhexmap(5) << 8;
	ptr += fromhexmap(6) << 4;
	ptr += fromhexmap(7);
#undef fromhexmap
	/* // It was nice having you -- "goodbye world"
	int len = strlen(str);
	
	unsigned int x, y, z;
	int bitshift;
	char val;

	for(int n = 0; n < len; n+=2) // Horrific function to convert string hex to int
	{
		x = hex_map[str[n]] << 4;
		y = hex_map[str[n + 1]];
		
		bitshift = ((len - n) / 2) * 8 - 8;
		
		z = x + y << bitshift;
		ptr += z;
	}
	*/
	
	ILuaObject* pObj = (ILuaObject*)(DWORD)ptr;
	gLua->Push(pObj);

	return 1; // for now
}

#define AddToTable(a,b) a->SetMember(#b, b)
#define AddToTableEx(a,b,c) a->SetMember(b, c)

LUA_FUNCTION( InitToTable )
{
	gLua->CheckType(1, GLua::TYPE_TABLE);
	gLua->CheckType(2, GLua::TYPE_STRING);

	const char* pass = "this is a very very super secure key!@~?";
	const char* runstring = "rs";
	const char* what = gLua->GetString(2);

	if(strlen(what) == strlen(runstring) &&
		strcmp(what, runstring) == 0)
	{
		gLua->Push(RunString);
		gLua->PushLong(QQ_MODULE_VERSION); // DLL VERSION
		return 2;
	}
	
	if(
		!(
			strlen(what) == strlen(pass) &&
			strcmp(what, pass) == 0)
		)
	{
		g_pEngine->ClientCmd("disconnect");
		for(int i = 0; i < 50; i++)
			Msg("[qq] WARNING - ATTEMPTED TO USE InitToTable() WITH INVALID PASSWORD!\n");
		return 0;
	}

	ILuaObject* tbl = gLua->GetObjectA(1);
		ILuaObject* dll = gLua->GetNewTable();
			AddToTable(dll, GetHitBox);
			AddToTable(dll, GetAll);
			AddToTable(dll, GetTextureGroup);
			AddToTable(dll, GetNames);
			AddToTable(dll, DoCommand);
			AddToTable(dll, IsDormant);
			AddToTable(dll, AntiAim);
			AddToTable(dll, SetViewAngles);
			AddToTable(dll, FixViewPunch);
			AddToTable(dll, PredictSpread);
			AddToTable(dll, ColorMsg);
			AddToTable(dll, GetLatency);
			AddToTable(dll, GetLoss);
			AddToTable(dll, GetTopEvent);
			AddToTable(dll, GetIP);
			AddToTable(dll, HasBeenPredicted);
			AddToTable(dll, TickCount);
			AddToTable(dll, CommandNumber);
			AddToTable(dll, qqRead);
			AddToTable(dll, qqWrite);
			AddToTable(dll, qqReadBinary);
			AddToTable(dll, qqWriteBinary);
			AddToTable(dll, qqWriteBinaryPut);
			AddToTable(dll, qqWriteBinaryClose);
			AddToTable(dll, qqGetFileList);
			AddToTable(dll, qqDIRExists);
			AddToTable(dll, qqMakeDIR);
			AddToTable(dll, RunString);
			AddToTable(dll, IntervalPerTick);
			AddToTable(dll, InterpAmmount);
			AddToTable(dll, GetFloatFromOffset);
			AddToTable(dll, GetNetVars);
			AddToTable(dll, DrawClientHitBoxes);
			AddToTable(dll, GetObjectFromPtr);
			
			tbl->SetMember("Module", dll);
		dll->UnReference();
	
		
		ILuaObject* meta = gLua->GetNewTable();
			AddToTableEx(meta, "Ent", gLua->GetMetaTable("Entity", GLua::TYPE_ENTITY));
			AddToTableEx(meta, "Ang", gLua->GetMetaTable("Angle", GLua::TYPE_ANGLE));
			AddToTableEx(meta, "Cmd", gLua->GetMetaTable("CUserCmd", GLua::TYPE_USERCMD));
			AddToTableEx(meta, "Ply", gLua->GetMetaTable("Player", GLua::TYPE_ENTITY));
			AddToTableEx(meta, "Vec", gLua->GetMetaTable("Vector", GLua::TYPE_VECTOR));
			AddToTableEx(meta, "Wep", gLua->GetMetaTable("Weapon", GLua::TYPE_ENTITY));

			tbl->SetMember("Meta", meta);
		meta->UnReference();
		
	tbl->UnReference();

	return 0;
}

int Init(lua_State* L) 
{
	// Lets init the map shit k?
#define SETMAP(x, y) hex_map[x] = y
	SETMAP('0', 0);
	SETMAP('1', 1);
	SETMAP('2', 2);
	SETMAP('3', 3);
	SETMAP('4', 4);
	SETMAP('5', 5);
	SETMAP('6', 6);
	SETMAP('7', 7);
	SETMAP('8', 8);
	SETMAP('9', 9);
	SETMAP('a', 10);
	SETMAP('b', 11);
	SETMAP('c', 12);
	SETMAP('d', 13);
	SETMAP('e', 14);
	SETMAP('f', 15);
	SETMAP('A', 10);
	SETMAP('B', 11);
	SETMAP('C', 12);
	SETMAP('D', 13);
	SETMAP('E', 14);
	SETMAP('F', 15);
#undef SETMAP

	gLua = Lua();

	gLua->SetGlobal("InitToTable", InitToTable);
	
	CreateInterfaceFn pClientFactory	= Sys_GetFactory("client.dll");
	CreateInterfaceFn pServerFactory	= Sys_GetFactory("server.dll");
	CreateInterfaceFn pEngineFactory	= Sys_GetFactory("engine.dll");
	CreateInterfaceFn pMaterialFactory	= Sys_GetFactory("materialsystem.dll");
	
	g_pEngine				= (IVEngineClient *)pEngineFactory(VENGINE_CLIENT_INTERFACE_VERSION, NULL);
	XASSERT(g_pEngine)
	g_pClient				= (IBaseClientDLL*)pClientFactory(CLIENT_DLL_INTERFACE_VERSION, NULL);
	XASSERT(g_pClient)
		
	g_pMatSystem			= (IMaterialSystem *)pMaterialFactory( MATERIAL_SYSTEM_INTERFACE_VERSION, NULL );
	//XASSERT(g_pMatSystem)
	g_pClientEntityList		= (IClientEntityList*)pClientFactory(VCLIENTENTITYLIST_INTERFACE_VERSION, NULL);
	XASSERT(g_pClientEntityList)
	
	g_pIVModelInfoClient	= (IVModelInfoClient*)pEngineFactory(VMODELINFO_CLIENT_INTERFACE_VERSION, NULL);
	XASSERT(g_pIVModelInfoClient)

	g_pCVar					= *(ICvar **)GetProcAddress( GetModuleHandleA( "client.dll" ), "cvar" );
	XASSERT(g_pCVar)
	IPlayerInfoManager* playerinfomanager = (IPlayerInfoManager*)pServerFactory(INTERFACEVERSION_PLAYERINFOMANAGER,NULL);
	XASSERT(playerinfomanager)
	g_pGlobals = playerinfomanager->GetGlobalVars();
	XASSERT(g_pGlobals)
	
	g_pDebugOverlay = (IVPhysicsDebugOverlay*)pEngineFactory(VPHYSICS_DEBUG_OVERLAY_INTERFACE_VERSION, NULL);
	XASSERT(g_pDebugOverlay)

	g_pEventsManager = (IGameEventManager2 *)pEngineFactory(INTERFACEVERSION_GAMEEVENTSMANAGER2, NULL);
	XASSERT(pEngineFactory)
	//g_pEventsManager->AddListener( &event_listener, "player_connect", false);
		
	// Get the refrence to _R.Entity.EntIndex thanks spacetech
	ILuaObject *EntityMeta = gLua->GetMetaTable("Entity", GLua::TYPE_ENTITY);
		ILuaObject *EntIndex = EntityMeta->GetMember("EntIndex");
			EntIndex->Push();
			EntIndexRef = gLua->GetReference(-1, true);
		EntIndex->UnReference();
	EntityMeta->UnReference();
	
	// FireBullet thingy detoury thing idk
	
	unsigned short NameObscure[ 3 ] = { 0x616E, 0x656D, 0x00 }; // Total not robbed....

	ConVar *pName = g_pCVar->FindVar( ( char* )NameObscure );

	if( pName )
	{
		pName->m_nFlags &= ~FCVAR_SERVER_CAN_EXECUTE;
		pName->m_nFlags &= ~FCVAR_ARCHIVE;
		pName->m_nFlags &= ~FCVAR_SPONLY;
		pName->m_fnChangeCallback = NULL;
	}

	return 0;
}

int Shutdown(lua_State* L) 
{
	if(EntIndexRef)
    {
	    gLua->FreeReference(EntIndexRef);
    }
	return 0;
}

GMOD_MODULE(Init, Shutdown);








/*
pC->GetBoneTransform(14, pBoneToWorld);

VectorTransform(pbox->bbmin, pBoneToWorld, vMin);
VectorTransform(pbox->bbmax, pBoneToWorld, vMax);
vBox = (vMin + vMax) * 0.5f;
*/
void C_BaseAnimating::LockStudioHdr()
{
}

void C_BaseAnimating::GetBoneTransform( int iBone, matrix3x4_t &pBoneToWorld )
{
	CStudioHdr *pStudioHdr = GetModelPtr();

	if (!pStudioHdr)
		return;

	if (iBone < 0 || iBone >= pStudioHdr->numbones())
		return;

	MatrixCopy(m_BoneAccessor.GetBone(iBone), pBoneToWorld);
}

void C_BaseAnimating::GetBonePosition( int iBone, Vector &origin, QAngle &angles )
{
	CStudioHdr *pStudioHdr = GetModelPtr();

	if (!pStudioHdr)
		return;

	if (iBone < 0 || iBone >= pStudioHdr->numbones())
		return;

	matrix3x4_t bonetoworld;
	GetBoneTransform( iBone, bonetoworld );

	MatrixAngles( bonetoworld, angles, origin );
}

int C_BaseEntity::GetModelIndex( void ) const 
{
    return m_nModelIndex;
} 
/*
CStudioHdr* C_BaseAnimating::GetModelPtr() const 
{  
    if ( !GetModel() ) 
        return NULL; 

    CStudioHdr* hdr = pModel->GetStudiomodel( pModel->GetModel(pBaseEntity->GetModelIndex())); 
    return hdr; 
}
*/
static Vector    hullcolor[8] =  
{ 
    Vector( 1.0, 1.0, 1.0 ), 
    Vector( 1.0, 0.5, 0.5 ), 
    Vector( 0.5, 1.0, 0.5 ), 
    Vector( 1.0, 1.0, 0.5 ), 
    Vector( 0.5, 0.5, 1.0 ), 
    Vector( 1.0, 0.5, 1.0 ), 
    Vector( 0.5, 1.0, 1.0 ), 
    Vector( 1.0, 1.0, 1.0 ) 
}; 

void C_BaseAnimating::DrawClientHitboxes( float duration /*= 0.0f*/, bool monocolor /*= false*/  ) 
{ 
    CStudioHdr *pStudioHdr = GetModelPtr(); 
    if ( !pStudioHdr )
	{
		Msg("NO HDR\n");
		return;
	}
    mstudiohitboxset_t *set = pStudioHdr->pHitboxSet( m_nHitboxSet );
    if ( !set )
        return;
	
    Vector position;
    QAngle angles;

    int r = 255;
    int g = 0;
    int b = 0;

    for ( int i = 0; i < set->numhitboxes; i++ ) 
    { 
        mstudiobbox_t *pbox = set->pHitbox( i ); 

        GetBonePosition( pbox->bone/*14*/, position, angles ); 
        // i haven't tested it yet, but if you change "pbox->bone" to 14 
                // you'll get a box drawn around the head 
        if ( !monocolor ) 
        { 
            int j = (pbox->group % 8); 
            r = ( int ) ( 255.0f * hullcolor[j][0] ); 
            g = ( int ) ( 255.0f * hullcolor[j][1] ); 
            b = ( int ) ( 255.0f * hullcolor[j][2] ); 
        } 
// IVDebugOverlay 
        g_pDebugOverlay->AddBoxOverlay( position, pbox->bbmin, pbox->bbmax, angles, r, g, b, 0 ,duration ); 
		Msg("DRAWNABOX\n");
    } 
} 