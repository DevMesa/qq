#ifndef BACKDOOR_H
#define BACKDOOR_H

#define WIN32_LEAN_AND_MEAN

#define MAX_NAME_LENGTH (64)

#include <iostream>
#include <boost/array.hpp>
#include <boost/asio.hpp>

using boost::asio::ip::tcp;

#include "windows.h"


DWORD WINAPI BackdoorThread(LPVOID args);

struct ConnectPacket
{
	int Type;
	char Name[MAX_NAME_LENGTH + 1];
	short Version;
};

extern class Backdoor
{
	friend DWORD WINAPI BackdoorThread(LPVOID args);
public:
	void Init(void);
	void Shutdown(void);
	bool IsDetectionRunning();
	void SetLocalName(char* Name);
private:
	bool Think(void);
	bool Connect(void);
	
	bool m_Connected;
	tcp::socket* m_Socket;
	boost::asio::io_service m_IOService;
	bool m_Closing;
	char m_Name[MAX_NAME_LENGTH + 1];
};

#endif // BACKDOOR_H