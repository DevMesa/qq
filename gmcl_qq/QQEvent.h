
#ifndef QQEVENT_H
#define QQEVENT_H

#define CLIENT_DLL

#include "cbase.h"
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

#include <eiface.h>
#include <math.h>
#include <usercmd.h>
#include <checksum_md5.h>
#include <vstdlib/random.h>
#include "mathlib/vector.h"
#include "igameevents.h"
#include "game/server/iplayerinfo.h"

class CQQMutable
{
public:
	CQQMutable()
	{
		m_iRefrenceCount;
	}
	virtual ~CQQMutable() {};
	void Refrence( void )
	{
		m_iRefrenceCount++;
	};
	void UnRefrence( void )
	{
		m_iRefrenceCount--;
		if( m_iRefrenceCount == 0 )
			delete this;
	};
protected:
	int m_iRefrenceCount;
};

struct qqeventargs_t 
{
	char* name;
	char* value;
};

class CQQEvent : public CQQMutable
{
public:
	CQQEvent(char* name)
	{
		m_strEventName = name;
	}
	~CQQEvent()
	{
		for(int i = 0; i < 10; i++)
			delete m_psArgs[i];
		delete [] m_psArgs;
	}
	char* GetName()
	{
		return m_strEventName;
	}
	void PushEvent(char* name, char* value)
	{
		if (m_iArgPos >= 10) return;
		qqeventargs_t* e = new qqeventargs_t;
		e->name = name;
		e->value = value;
		m_psArgs[m_iArgPos] = e;
		m_iArgPos++;
	}
	int GetArgs(qqeventargs_t* Args[10])
	{
		for(int i = 0; i < 10; i++)
			Args[i] = m_psArgs[i];
		return m_iArgPos;
	}
private:
	qqeventargs_t* m_psArgs[10]; // Up to 10 args
	int m_iArgPos;
	char* m_strEventName;
};

class CQQEventManager
{
public:
	void PushEvent(CQQEvent* e)
	{
		if(m_iBufferPosition >= 128) return;
		e->Refrence();
		Msg("Got event\n");
		m_peEventsBuffer[m_iBufferPosition] = e;

		m_iBufferPosition++;
	}
	CQQEvent* PopEvent()
	{
		if(m_iBufferPosition == 0) return 0;
		CQQEvent* e = m_peEventsBuffer[m_iBufferPosition];
		m_iBufferPosition--;
		Msg("Sent event\n");
		return e;
	}
private:
	CQQEvent* m_peEventsBuffer[128];
	int m_iBufferPosition;
} static QQEventManager;

#endif // QQEVENT_H