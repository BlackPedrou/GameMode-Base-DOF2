/*
Creditos: Pedro_Eduardo
Conta Forum: http://forum.sa-mp.com/member.php?u=288140
*/
//======================================[ INCLUDES ]====================================||
#include 	a_samp
#include 	DOF2
#include	zcmd

#define 	DarMoney(%0,%1) ResetPlayerMoney(%0) && GivePlayerMoney(%0,%1)
//======================================[ DIALOGOS ]====================================||
#define 	DIALOG_REGISTRO      	0
#define 	DIALOG_LOGIN         	1

#define 	DIALOG_NICK				2
#define		DIALOG_SENHA			3
#define		DIALOG_SKIN				4
#define 	DIALOG_SCORE			5
#define 	DIALOG_DINHEIRO			6
//======================================[ INICIO ]======================================||
main(){}

enum pInfo
{
	pAdmin,
	pSkin,
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	pInterior,
	pScore,
	pDinheiro
}

new Dados[MAX_PLAYERS][pInfo];
new Conta[256];

//=====================================[ CALLBACKS ]====================================||
public OnGameModeInit()
{
  SetGameModeText("Modo livre");
  UsePlayerPedAnims();																
	return  1;
}

public OnGameModeExit()
{
	DOF2_Exit();
	return 1;
}

public OnPlayerConnect(playerid)
{
	//=================================[ LOGIN/REGISTRO ]===============================||
	format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
	if(!DOF2_FileExists(Conta))
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "REGISTRO", "Registrar!", "Registrar", "Sair");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN", "Logar", "Conectar", "Sair");
	}
	//==================================================================================||
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	//=================================[ SALVANDO CONTAS ]==============================||
	format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
	DOF2_SetInt(Conta, "Admin", Dados[playerid][pAdmin]);
	DOF2_SetInt(Conta, "Skin", Dados[playerid][pSkin]);
	DOF2_SetInt(Conta, "Dinheiro", GetPlayerMoney(playerid));
	DOF2_SetInt(Conta, "Score", GetPlayerScore(playerid));
	
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, Float:X, Float:Y, Float:Z);
	DOF2_SetFloat(Conta, "PosX", X);
	DOF2_SetFloat(Conta, "PosY", Y);
	DOF2_SetFloat(Conta, "PosZ", Z);
	DOF2_SetInt(Conta, "Interior", GetPlayerInterior(playerid));
	
	DOF2_SaveFile();
	//==================================================================================||
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//=================================[ DIALOG_REGISTRO ]==============================||
	if(dialogid == DIALOG_REGISTRO)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
	            ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Registro", "Digite Sua Senha Para Se Registrar!", "Registrar", "Sair");
	            return 1;
			}
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
			DOF2_CreateFile(Conta);
			DOF2_SetString(Conta, "Senha", inputtext);
			DOF2_SaveFile();
			
			CriarConta(playerid);
			CarregarConta(playerid);
			return 1;
		}
		else
		{
			Kick(playerid);
			return 1;
		}
	}
	//=================================[ DIALOGO   LOGIN ]==============================||
	if(dialogid == DIALOG_LOGIN)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
	            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "REGISTRO", "Registrar no servidor", "Entrar", "Sair");
	            return 1;
			}
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
			if(strcmp(inputtext, DOF2_GetString(Conta, "Senha"), true))
			{
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "LOGIN", "Entrar no servidor","Entrar", "Sair");
                SendClientMessage(playerid, -1, "Senha incorreta!");
				return 1;
			}
			else //se conseguir logar
			{
				CarregarConta(playerid);
				return 1;
			}
		}
		else
		{
			Kick(playerid);
			return 1;
		}
	}
	//=================================[ DIALOGO    NICK ]==============================||
	if(dialogid == DIALOG_NICK)
	{
		if(response)
		{
			if(!strlen(inputtext))
			{
				ShowPlayerDialog(playerid, DIALOG_NICK, DIALOG_STYLE_INPUT, "Mudar Nick", "para mudar de nick, digite-a abaixo.", "Mudar", "Voltar");
			}
			new String01[54], king[60],kingold[60];
			format(kingold, sizeof(kingold), "Contas/%s.ini",Nome(playerid));
			format(String01, sizeof(String01), "O Jogado %s, mudou seu nick para %s", Nome(playerid),inputtext);
			SendClientMessageToAll( -1, String01);
			format(king, sizeof(king), "Contas/%s.ini", inputtext);
			DOF2_RenameFile(kingold, king);
			SetPlayerName(playerid, inputtext);
		}
		else
		{
			return 0;
		}
		return 1;
	}
	//=================================[ DIALOGO   SENHA ]==============================||
	if(dialogid == DIALOG_SENHA)
	{
		if(response)
		{
			if(!strlen(inputtext))
			{
				ShowPlayerDialog(playerid, DIALOG_SENHA, DIALOG_STYLE_INPUT, "Mudar Senha", "para mudar de senha, digite-a abaixo.", "Mudar", "Voltar");
			}
			new String01[128];
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
			DOF2_SetString(Conta, "Senha", inputtext);
			DOF2_SaveFile();
			format(String01, sizeof(String01), "{12FF05}Sua nova senha é {25E01B}'%s' tire um print para n esquecer apertando [f8]", inputtext);
			SendClientMessage(playerid, -1, String01);
		}
		else
		{
			return 0;
		}
		return 1;
	}
	//=================================[ DIALOGO    SKIN ]==============================||
	if(dialogid == DIALOG_SKIN)
	{
		if(response)
		{
			if(!strlen(inputtext))
			{
				ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT, "Mudar Skin", "para mudar de skin, digite-a abaixo.", "Mudar", "Voltar");
			}
			new String01[128];
			format(String01, sizeof(String01), "Você colocou a Skin Número %i", strval(inputtext));
			SendClientMessage(playerid, -1, String01);
			
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));		
			Dados[playerid][pSkin] = strval(inputtext);	
			DOF2_SetInt(Conta, "Skin", Dados[playerid][pSkin]);
			DOF2_SaveFile();
			SetPlayerSkin(playerid,strval(inputtext));
		}
		else
		{
			return 0;
		}
		return 1;
	}
	//=================================[ DIALOGO    SCORE ]==============================||
	if(dialogid == DIALOG_SCORE)
	{
		if(response)
		{
			if(!strlen(inputtext))
			{
				ShowPlayerDialog(playerid, DIALOG_SCORE, DIALOG_STYLE_INPUT, "Mudar Score", "para mudar de score, digite-a abaixo.", "Mudar", "Voltar");
			}
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
			new String01[128];
			format(String01, sizeof(String01), "Você colocou %i de Score", strval(inputtext));
			SendClientMessage(playerid, -1, String01);
			DOF2_SetString(Conta, "Score", inputtext);
			DOF2_SaveFile();
			SetPlayerScore(playerid,strval(inputtext));
		}
		else
		{
			return 0;
		}
		return 1;
	}
	//=================================[ DIALOGO    DINHEIRO ]==============================||
	if(dialogid == DIALOG_DINHEIRO)
	{
		if(response)
		{
			if(!strlen(inputtext))
			{
				ShowPlayerDialog(playerid, DIALOG_DINHEIRO, DIALOG_STYLE_INPUT, "Mudar Dinheiro", "para mudar de dinheiro, digite-a abaixo.", "Mudar", "Voltar");
			}
			format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
			new String01[128];
			format(String01, sizeof(String01), "Você colocou %iR$ na sua conta", strval(inputtext));
			SendClientMessage(playerid, -1, String01);
			DOF2_SetString(Conta, "Dinheiro", inputtext);
			DOF2_SaveFile();
			DarMoney(playerid,strval(inputtext));
		}
		else
		{
			return 0;
		}
		return 1;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerSkin(playerid, Dados[playerid][pSkin]);
	return 1;
}

CriarConta(playerid)
{
	format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
	
	DOF2_SetInt(Conta, "Admin", 0);
	DOF2_SetInt(Conta, "Skin", 98);
	DOF2_SetInt(Conta, "Dinheiro", 500);
	DOF2_SetInt(Conta, "Score", 0);
	DOF2_SetInt(Conta, "PosX", 2000);
	DOF2_SetInt(Conta, "PosY", 2000);
	DOF2_SetInt(Conta, "PosZ", 13);
	DOF2_SetInt(Conta, "Interior", 0);	
	DOF2_SaveFile();
}

CarregarConta(playerid)
{
	format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
	
	Dados[playerid][pAdmin] = DOF2_GetInt(Conta, "Admin");
	Dados[playerid][pSkin] = DOF2_GetInt(Conta, "Skin");
	Dados[playerid][pDinheiro] = DOF2_GetInt(Conta, "Dinheiro");
	Dados[playerid][pScore] = DOF2_GetInt(Conta, "Score");
	Dados[playerid][pPosX] = DOF2_GetInt(Conta, "PosX");
	Dados[playerid][pPosY] = DOF2_GetInt(Conta, "PosY");
	Dados[playerid][pPosZ] = DOF2_GetInt(Conta, "PosZ");
	Dados[playerid][pInterior] = DOF2_GetInt(Conta, "Interior");
	
	SetPlayerScore(playerid, Dados[playerid][pScore]);
	DarMoney(playerid, Dados[playerid][pDinheiro]);
	SetPlayerInterior(playerid, Dados[playerid][pInterior]);
	SetSpawnInfo(playerid, 1, Dados[playerid][pSkin], Dados[playerid][pPosX], Dados[playerid][pPosY], Dados[playerid][pPosZ], 269.15, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
}

//=====================================================================================||

Nome(playerid)
{
	new pNome[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pNome, 24);
	return pNome;
}

//=============================[Comandos]==============================================||

CMD:mudarsenha(playerid)
{
	return ShowPlayerDialog(playerid, DIALOG_SENHA, DIALOG_STYLE_INPUT, "Mudar Senha", "para mudar de senha, digite-a abaixo.", "Mudar", "Voltar");
}

CMD:mudarnick(playerid)
{
	return ShowPlayerDialog(playerid, DIALOG_NICK, DIALOG_STYLE_INPUT, "Mudar Nick", "para mudar de nick, digite-a abaixo.", "Mudar", "Voltar");
}

CMD:skin(playerid)
{
	return ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT, "Mudar Skin", "para mudar de skin, digite-a abaixo.", "Mudar", "Voltar");
}

CMD:score(playerid)
{
	return ShowPlayerDialog(playerid, DIALOG_SCORE, DIALOG_STYLE_INPUT, "Mudar Score", "para mudar de Score, digite-a abaixo.", "Mudar", "Voltar");
}

CMD:dinheiro(playerid)
{
	return ShowPlayerDialog(playerid, DIALOG_DINHEIRO, DIALOG_STYLE_INPUT, "Mudar dinheiro", "para dar dinheiro pra vc, digite-a abaixo.", "Mudar", "Voltar");
}

CMD:rg(playerid)
{
	format(Conta, sizeof(Conta), "Contas/%s.ini", Nome(playerid));
	new King[200];
	new mnome[200],mdinheiro[200],mscore[200],mskin[200],madmin[200];
	format(mnome, sizeof(mnome),"Meu Nome: %s\n\n",Nome(playerid));
	format(mdinheiro, sizeof(mdinheiro),"Dinheiro: %d\n\n",GetPlayerMoney(playerid));
	format(mscore, sizeof(mscore),"Score: %d\n\n",GetPlayerScore(playerid));
	format(mskin, sizeof(mskin),"Skin: %d\n\n",Dados[playerid][pSkin]);
	format(madmin, sizeof(madmin),"Admin : %d\n\n",Dados[playerid][pAdmin]);
	
	strcat(King, mnome);
	strcat(King, mdinheiro);
	strcat(King, mscore);
	strcat(King, mskin);
	strcat(King, madmin);
	return ShowPlayerDialog(playerid, 3125,DIALOG_STYLE_MSGBOX,"seu RG",King,"ok","");
}

CMD:viraradmin(playerid)
{
	Dados[playerid][pAdmin] = 1;
	DOF2_SetInt(Conta, "Admin", Dados[playerid][pAdmin]);
	DOF2_SaveFile();
	return 1;
}

CMD:adm(playerid)
{
	if(Dados[playerid][pAdmin] == 0) return SendClientMessage(playerid, -1, "Você não é admin");
	SendClientMessage(playerid, -1, "Confimado! Você é ilu.. ");
	return SendClientMessage(playerid, -1, " Admin* ");
}
