#INCLUDE "PROTHEUS.CH"
#include 'Ap5Mail.ch'

User Function NLEMAILPED(cTitulo,aErroCab,aErroItem,cMotivo)
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

Private cDescMot := cMotivo
   
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
oMessage:cTo 		:= GetMV("ZZ_EMAILP", , "")//'diaz.solution1@gmail.com'
oMessage:cSubject 	:= cTitulo

	cMensagem := fRetHtml(aErroCab)
	cMensagem += fRetItem(aErroItem)
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



Static Function fRetHtml(aErroCab)
Local cHTML := ''

		cHTML := "<html>"
		cHTML += "	<head>"	
		cHTML += "		<meta content='text/html; charset=ISO-8859-1' http-equiv='content-type'>"	
		cHTML += "		<title>AVISO !! - Pedido de Compra</title>"
		cHTML += "	</head>"
		cHTML += "	<body>"	
		cHTML += "		<font size='-1'><br></font><br>"
		cHTML += "		<table style='text-align: left; width: 964px; height: 26px; background-color: rgb(217, 230, 236); font-weight: bold;' border='0' cellpadding='0' cellspacing='0'>"		
		cHTML += "			<tbody>"			
		cHTML += "				<tr>"				
		cHTML += "					<td style='vertical-align: top; background-color: rgb(217, 230, 236);'>"
		cHTML += "						<span style='font-weight: bold;'><font size='4'>Num. Ped.: "+ aErroCab[1][1] +" | Tipo: "+aErroCab[1][2]+" | Cliente - Loja: "+aErroCab[1][3]+" - "+aErroCab[1][4]+"  </font></span>"
		cHTML += "					</td>"			
		cHTML += "				</tr>"		
		cHTML += "			</tbody>"	
		cHTML += "		</table>"	
		cHTML += "		<br>"
		cHTML += "		<table style='text-align: left; width: 400px; height: 10px;' border='0' cellpadding='0' cellspacing='0'>"			
		cHTML += "			<tbody>"							
		cHTML += "				<tr>"					
		cHTML += "					<td style='vertical-align: top; width: 200px;'><span style='font-weight: bold;'>Data:</span></td>"
		cHTML += "	            	<td style='vertical-align: top; width: 750px;'>"+ DToC(dDataBase) +"</td>"			
		cHTML += "				</tr>"	        
		cHTML += "			</tbody>"
		cHTML += "			<tbody>"							
		cHTML += "				<tr>"					
		cHTML += "					<td style='vertical-align: top; width: 800;'><span style='font-weight: bold;'>Motivo:</span></td>"
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
		cHTML += "				</tr>"	
	
Return(cHTML)

Static Function fRetItem(aErroItem)
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

Return(cRet)


Static Function fRetRodape()
Local cHTML := ''

		cHTML += "			</tbody>"			
		cHTML += "		</table>"		
		cHTML += "		<br>"
		cHTML += "	</body>"
		cHTML += "</html>"

Return(cHTML)
