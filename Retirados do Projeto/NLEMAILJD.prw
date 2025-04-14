#INCLUDE "PROTHEUS.CH"
#include 'Ap5Mail.ch'

User Function NLEMAILJD(lMot,aCont,nErro)
Local cUser 	:= ""
Local cPass 	:= ""
LOcal cSendSrv 	:= ""
Local cMsg 		:= ""
Local cMensagem	:= ""
Local nSendPort := 0
Local nTimeout 	:= 0
Local xRet
Local oServer
Local oMessage

Private cDescMot := ""
Private cTitulo	 := ""
Private aCab 	 := aCont

Default nErro	 := 0

//VERIFICA SE ESTÁ COM ERRO
IF nErro == 1

	cDescMot := "REGISTROS COM ERRO NA ALTERAÇÃO PARA PREVISÃO DE VENDAS"
	cTitulo  := "ERRO NA ALTERAÇÃO DA PREVISÃO DE VENDAS"

ELSE
	IF nErro == 2

		cDescMot := "REGISTROS COM ERRO NA INCLUSÃO PARA PREVISÃO DE VENDAS"
		cTitulo	 := "ERRO NA INCLUSÃO DE PREVISÃO DE VENDAS"

	ELSE

		//VERIFICA SE É ALTERAÇÃO OU INCLUSÃO
		IF lMot 

			cDescMot := "REGISTROS INCLÚIDOS PARA PREVISÃO DE VENDAS"
			cTitulo	 := "INCLUSÃO DE PREVISÃO DE VENDAS"

		ELSE

			cDescMot := "REGISTROS ALTERADOS PARA PREVISÃO DE VENDAS"
			cTitulo  := "ALTERAÇÃO DA PREVISÃO DE VENDAS"

		ENDIF

	endif

endif
   
cUser 		:= GetMV("MV_RELAUSR", , "") 		//define the e-mail account username
cPass 		:= GetMV("MV_RELAPSW", , "")		//define the e-mail account password
cSendSrv 	:= "smtp.gmail.com"					//GetMV("MV_RELSERV", , "") 		// define the send server
nTimeout 	:= 60 								// define the timout to 60 seconds
   
oServer := TMailManager():New()
   
oServer:SetUseSSL( .F. )
oServer:SetUseTLS( .F. )

nSendPort := 587 	//default port for SMTPS protocol with TLS
oServer:SetUseTLS( .T. )   

// once it will only send messages, the receiver server will be passed as ""
// and the receive port number won't be passed, once it is optional
xRet := oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
If xRet != 0
	cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( xRet )
  	conout( cMsg )
	//Alert(cMsg)
  	Return()
Endif
   
// the method set the timout for the SMTP server
xRet := oServer:SetSMTPTimeout( nTimeout )
If xRet != 0
	cMsg := "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout )
    conout( cMsg )
	//Alert( cMsg )
Endif
   
// estabilish the connection with the SMTP server
xRet := oServer:SMTPConnect()
If xRet <> 0
    cMsg := "Could not connect on SMTP server: " + oServer:GetErrorString( xRet )
    conout( cMsg )
	//Alert( cMsg )
    Return()
Endif
   
// authenticate on the SMTP server (if needed)
xRet := oServer:SmtpAuth( cUser, cPass )
If xRet <> 0
    cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
    conout( cMsg )
	//Alert(cMsg)
    oServer:SMTPDisconnect()
    Return()
Endif
   
oMessage := TMailMessage():New()
oMessage:Clear()
   
oMessage:cDate 		:= cValToChar( Date() )
oMessage:cFrom 		:= GetMV("MV_RELFROM", , "")
oMessage:cTo 		:= 'diaz.solution1@gmail.com;soliveira@newleader.com'//GetMV("ZZ_PEDJD", , "")
oMessage:cSubject 	:= cTitulo

	cMensagem := fRetHtml(aCab,lMot,nErro)

	//SEM REGISTROS
	//cMensagem += fRetItem(aErroItem)

	cMensagem += fRetRodape()

oMessage:cBody 		:= cMensagem
   
xRet := oMessage:Send( oServer )
If xRet <> 0
    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
    conout( cMsg )
	//Alert( cMsg )
Endif
   
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    cMsg := "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet )
    conout( cMsg )
	//Alert( cMsg )
Endif

Return()



Static Function fRetHtml(aCab,lMot,nErro)
Local cHTML := ''
Local nX    := 0
Local lErro := .F.
Local cProd	:= ""

	cHTML := "<html>"

	For nX := 1 to len(aCab)

		if empty(aCab[nX][1])

			cProd := "Não encontrado"

		else

			cProd := ALLTRIM(aCab[nX][1])

		endif

		cHTML += "	<head>"	
		cHTML += "		<meta content='text/html; charset=ISO-8859-1' http-equiv='content-type'>"	

		//VERIFICA SE ESTÁ COM ERRO
		IF nErro == 1

			cHTML += "		<title>AVISO!! PREVISÃO DE VENDAS (ALTERAÇÃO COM ERRO) - JOHN DEERE</title>"

			lErro := .T.

		ELSE
			IF nErro == 2

				cHTML += "		<title>AVISO!! PREVISÃO DE VENDAS (INCLUSÃO COM ERRO) - JOHN DEERE</title>"

				lErro := .T.

			ELSE

				//VERIFICA SE É ALTERAÇÃO OU INCLUSÃO
				IF lMot 

					cHTML += "		<title>AVISO!! PREVISÃO DE VENDAS (INCLUSÃO) - JOHN DEERE</title>"

				ELSE

					cHTML += "		<title>AVISO!! PREVISÃO DE VENDAS (ALTERAÇÃO) - JOHN DEERE</title>"

				ENDIF

			endif

		endif
		
		cHTML += "	</head>"
		cHTML += "	<body>"	
		cHTML += "		<font size='-1'><br></font><br>"
		cHTML += "		<table style='text-align: left; width: 964px; height: 26px; background-color: rgb(217, 230, 236); font-weight: bold;' border='0' cellpadding='0' cellspacing='0'>"		
		cHTML += "			<tbody>"			
		cHTML += "				<tr>"				
		cHTML += "					<td style='vertical-align: top; background-color: rgb(217, 230, 236);'>"
		cHTML += "						<span style='font-weight: bold;'><font size='4'>PRODUTO: "+ cProd +" | DATA: "+DTOC(aCab[nX][2])+" | QUANTIDADE: "+ALLTRIM(STR(aCab[nX][3]))+"  </font></span>"
		cHTML += "					</td>"			
		cHTML += "				</tr>"		
		/*cHTML += "			</tbody>"	
		cHTML += "		</table>"	
		cHTML += "		<br>"
		cHTML += "		<table style='text-align: left; width: 400px; height: 10px;' border='0' cellpadding='0' cellspacing='0'>"			
		cHTML += "			<tbody>"							
		cHTML += "				<tr>"					
		cHTML += "					<td style='vertical-align: top; width: 200px;'><span style='font-weight: bold;'>MOTIVO: </span></td>"

		if lErro

			cHTML += "	            	<td style='vertical-align: top; width: 750px;'>"+ aCab[nX][3] +"</td>"	

		else

			cHTML += "	            	<td style='vertical-align: top; width: 750px;'>SUCESSO</td>"

		endif

		cHTML += "				</tr>"	        
		cHTML += "			</tbody>"
		cHTML += "			<tbody>"							
		cHTML += "				<tr>"					
		cHTML += "					<td style='vertical-align: top; width: 800;'><span style='font-weight: bold;'>DESCRIÇÃO:</span></td>"
		cHTML += "	            	<td style='vertical-align: top; width: 1500;'>"+ cDescMot +"</td>"	
		cHTML += "				</tr>"	        
		cHTML += "			</tbody>"		
		cHTML += "		</table>"		
		cHTML += "		<br>"	    
		cHTML += "		<table style='text-align: left; width: 964px; height: 22px;' border='1' bordercolor='Black' cellpadding='0' cellspacing='0'>"
		cHTML += "			<tbody>"	        	
		cHTML += "				<tr>"
		cHTML += "					<td style='vertical-align: top; width: 100px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>PRODUTO</td>"
		cHTML += "	            	<td style='vertical-align: top; width: 200px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>ITEM</td>"
		cHTML += "	            	<td style='vertical-align: top; width: 080px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>ARMAZÉM</td>
		cHTML += "	            	<td style='vertical-align: top; width: 080px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>QUANTIDADE DIGIT.</td>"
		cHTML += "	            	<td style='vertical-align: top; width: 080px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>SALDO ATUAL</td>"
		cHTML += "	            	<td style='vertical-align: top; width: 080px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;'>SALDO FIM DO MÊS</td>"
		cHTML += "				</tr>"*/	

	Next nX
	
Return(cHTML)

/*Static Function fRetItem(aErroItem)
Local cRet := ''
Local nX   := 0

	For nX := 1 to len(aErroItem)

		cRet += "				<tr>"		
		cRet += "					<td style='vertical-align: top; width: 200px; text-align: center;'>"+ aErroItem[nX][1] +"</td>"
		cRet += "					<td style='vertical-align: top; width: 200px; text-align: center;'>"+ aErroItem[nX][2] +"</td>"
		cRet += "					<td style='vertical-align: top; width: 200px; text-align: center;'>"+ aErroItem[nX][6] +"</td>"
		cRet += "					<td style='vertical-align: top; width: 100px; text-align: center;'>"+ aErroItem[nX][5] +"</td>"
		cRet += "					<td style='vertical-align: top; width: 200px; text-align: center;'>"+ aErroItem[nX][4] +"</td>"
		cRet += "					<td style='vertical-align: top; width: 200px; text-align: center;'>"+ aErroItem[nX][3] +"</td>"
		cRet += "				</tr>" 	

	next nX

Return(cRet)*/


Static Function fRetRodape()
Local cHTML := ''

		cHTML += "			</tbody>"			
		cHTML += "		</table>"		
		cHTML += "		<br>"
		cHTML += "	</body>"
		cHTML += "</html>"

Return(cHTML)
