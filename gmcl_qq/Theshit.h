#ifndef QQ_H
#define QQ_H
#include "includes/ILuaInterface.h"


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

#endif