#ifndef QQ_H
#define QQ_H
#include "includes/ILuaInterface.h"

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