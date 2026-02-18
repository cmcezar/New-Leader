#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Directry.ch"

//----------------------------------------------\\
/*/{Protheus.doc} NLESTA02
// Rotina para importar e atualizar o cadastro de 
   produtos a partir de um arquivo txt.
@author Claudio Macedo
@since 05/02/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function NLESTA02()

Local cArquivo	:=	""

Private cNomeArq :=	""  
Private nPos     := 0
Private nLinhas  := 0	// Produtos lidos

Pergunte('NLESTA02',.T.,'Atualizar tabela de produtos')

nPos :=	Aviso('Atualizar Produtos','Esta rotina tem como objetivo importar ou alterar '+CRLF+'o cadastro de produtos a partir de um arquivo txt.',{'Atualizar','Sair'}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( 'Arquivo |*.txt|' , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)

		If MsgYesNo(IIF(mv_par01 = 1,'Confirma a inclusão dos produtos ?','Confirma a alteração dos produtos ?'))
			FT_FUse()       // Fecha se houver arquivo aberto/em uso.
			FT_FUse(cArquivo) 
			FT_FGoTop()

			nLinhas := FT_FLastRec() - 1
			FT_FGoTop()

			If mv_par01 = 1
				Processa( {|| IncluiProd() }, 'Processando arquivo ' + cNomeArq, 'Incluindo produtos ...', .F.)
			Else 
				Processa( {|| AlteraProd() }, 'Processando arquivo ' + cNomeArq, 'Alterando produtos ...', .F.)
			Endif 
		Endif 

	Endif
Endif

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} IncluiProd
// Inclui produtos a partir de um arquivo texto
@author Claudio Macedo
@since 05/02/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function IncluiProd()
                                  
Local cString := FT_FReadln()
Local nLinha  := 1
Local aCabec  := {}
Local aInfo   := {}
Local nProc   := 0	// Produtos atualizados
Local oModel  := FWLoadModel("MATA010") 
Local oSB1Mod := oModel:GetModel("SB1MASTER")
//Local oSB5Mod := oModel:GetModel("SB5DETAIL")
Local nI := 0
Local lOK := .T.

cString := FT_FReadln()

aCabec := StrTokArr(cString,';')

FT_FSkip()	

oModel:SetOperation(3)

While !FT_FEOF()

	oModel:Activate()

	cString := FT_FReadln()

	aInfo := StrTokArr(cString,';')

	For nI :=1 to Len(aInfo)
		//Setando os campos
		oSB1Mod:SetValue(aCabec[nI], aInfo[nI]) 
//		oSB1Mod:SetValue("B1_DESC"   , cDesc     )
//		oSB1Mod:SetValue("B1_TIPO"   , cTipo     ) 
//		oSB1Mod:SetValue("B1_UM"     , cUM       ) 
//		oSB1Mod:SetValue("B1_LOCPAD" , cLocPad   ) 

	Next nI 

	//If oSB5Mod != Nil
		//oSB5Mod:SetValue("B5_CEME"   , cCEME     )
	//EndIf
	
	//Se conseguir validar as informações
	If oModel:VldData()
		
		//Tenta realizar o Commit
		If oModel:CommitData()
			lOk := .T.
			
		//Se não deu certo, altera a variável para false
		Else
			lOk := .F.
		EndIf
		
	//Se não conseguir validar as informações, altera a variável para false
	Else
		lOk := .F.
	EndIf
	
	//Se não deu certo a inclusão, mostra a mensagem de erro
	If ! lOk
		//Busca o Erro do Modelo de Dados
		aErro := oModel:GetErrorMessage()
		
		//Monta o Texto que será mostrado na tela
		cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
		cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
		cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
		cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
		cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
		cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
		cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
		cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
		cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
		
		//Mostra mensagem de erro
		lRet := .F.
		ConOut("Erro: " + cMessage)
	Else
		lRet := .T.
		ConOut("Produto incluido!")
	EndIf

	nProc += 1

	//Desativa o modelo de dados
	oModel:DeActivate()

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999'))

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} AlteraProd
// Altera os pprodutos a partir de um arquivo texto
@author Claudio Macedo
@since 06/02/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function AlteraProd()
                                  
Local cString := FT_FReadln()
Local nLinha  := 1
Local aInfo   := {}
Local nProc   := 0	// Produtos atualizados
Local oModel  := FWLoadModel("MATA010")
//Local oSB1Mod := oModel:GetModel("SB1MASTER")
Local aCabec  := {}
Local aFields := {}
Local aDadosZZ3 := {}
Local nI := 0
Local lOK := .T.
Local cID := GetSXeNum('ZZ3', 'ZZ3_ID')

cString := FT_FReadln()

/* ------------------ I M P O R T A N T E ------------------ */
/* A primeira coluna do arquivo deve ser o código do produto */

aCabec := StrTokArr(cString,';')

FT_FSkip()	

While !FT_FEOF()

	aFields   := {}
	aDadosZZ3 := {}
	cString   := FT_FReadln()
	aInfo     := StrTokArr(cString,';')

	For nI := 1 to Len(aInfo)
		aAdd(aFields,   {aCabec[nI], aInfo[nI], Nil})
		If nI > 1 // Pula o código do produto
			aAdd(aDadosZZ3, {aInfo[1], aCabec[nI], Posicione('SB1',1,xFilial('SB1')+aInfo[1],aCabec[nI]), aInfo[nI]})
		Endif
	Next nI
	
	//cMusica := oSB1Mod:GetValue('B1_COD') 

	//Se conseguir executar a operação automática
	If FWMVCRotAuto(oModel, "SB1", 4, {{"SB1MASTER", aFields}} ,,.T.)

		For nI := 1 to Len(aDadosZZ3)
			ZZ3->(reclock('ZZ3',.T.))
			ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
			ZZ3->ZZ3_ID     := cID
			ZZ3->ZZ3_DATA   := dDatabase
			ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
			ZZ3->ZZ3_TIPO   := Alltrim(Str(mv_par01))
			ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
			ZZ3->ZZ3_CAMPO  := GetSx3Cache(aDadosZZ3[nI,2], 'X3_TITULO')
			ZZ3->ZZ3_ANT    := aDadosZZ3[nI,3]
			ZZ3->ZZ3_DEP    := aDadosZZ3[nI,4]
			ZZ3->(MsUnlock())
		Next nI  
		ConfirmSX8()
		lOk := .T.
	Else
		RollBackSX8()
		lOk := .F.
	EndIf
	
	//Se não deu certo a inclusão, mostra a mensagem de erro
	If ! lOk
		//Busca o Erro do Modelo de Dados
		aErro := oModel:GetErrorMessage()
		
		//Monta o Texto que será mostrado na tela
		cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
		cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
		cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
		cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
		cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
		cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
		cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
		cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
		cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
		
		//Mostra mensagem de erro
		lRet := .F.
		ConOut("Erro: " + cMessage)
		
	Else
		lRet := .T.
		ConOut("Produto excluido")
	EndIf
	
	nProc += 1

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

//Desativa o modelo de dados
oModel:DeActivate()

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999'))

Return Nil

