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

Local cArquivo :=	""
Local cGrupos  := GetMV('NL_GRPIMP')
Local aGrupos  := UsrRetGrp(RETCODUSR())
Local lGrupo   := .F.
Local nI := 0

Private cNomeArq :=	""  
Private nPos     := 0
Private nLinhas  := 0	// Produtos lidos

For nI := 1 to Len(aGrupos)
	If aGrupos[nI] $ cGrupos
		lGrupo := .T.
		Exit
	Endif 
Next nI 

If !lGrupo
	Alert('Grupo do usuário sem permissão para executar essa rotina !')
	Return Nil 
Endif 

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
                                  
Local cString  := FT_FReadln()
Local nLinha   := 0
Local aCabec   := {}
Local aInfo    := {}
Local nProc    := 0	// Registros atualizados
Local nProcErr := 0	// Registros com erros
Local oModel   := FWLoadModel("MATA010") 
Local oSB1Mod  := oModel:GetModel("SB1MASTER")
Local nI := 0
Local lOK := .T.
Local cID := GetSXeNum('ZZ3', 'ZZ3_ID')
Local aDadosZZ3 := {}

cString := FT_FReadln()

aCabec := StrTokArr(cString,';')

FT_FSkip()	

oModel:SetOperation(3)

While !FT_FEOF()

	oModel:Activate()

	aDadosZZ3 := {}
	cString := FT_FReadln()
	aInfo := StrTokArr(cString,';')

	For nI :=1 to Len(aInfo)
		//Setando os campos
		If TamSx3(Alltrim(aCabec[nI]))[3] = 'D'
			oSB1Mod:SetValue(Alltrim(aCabec[nI]), Ctod(aInfo[nI])) 
		ElseIf TamSx3(Alltrim(aCabec[nI]))[3] = 'N'
			oSB1Mod:SetValue(Alltrim(aCabec[nI]), Val(aInfo[nI])) 
		Else 
			oSB1Mod:SetValue(Alltrim(aCabec[nI]), aInfo[nI]) 
		Endif 	
	Next nI 

	aAdd(aDadosZZ3, {aInfo[1]})
	
	//Se conseguir validar as informações
	If oModel:VldData()
		
		//Tenta realizar o Commit
		If oModel:CommitData()
			lOk := .T.
		
			For nI := 1 to Len(aDadosZZ3)
				ZZ3->(reclock('ZZ3',.T.))
				ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
				ZZ3->ZZ3_ID     := cID
				ZZ3->ZZ3_LINHA  := StrZero(nLinha += 1,6)
				ZZ3->ZZ3_DATA   := dDatabase
				ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
				ZZ3->ZZ3_TIPO   := '1'
				ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
				ZZ3->ZZ3_STATUS := '1'
				ZZ3->(MsUnlock())
			Next nI  
			ConfirmSX8()
			lOk := .T.

		//Se não deu certo, altera a variável para false
		Else
			cMessage := ''
			For nI := 1 to Len(aDadosZZ3)
				ZZ3->(reclock('ZZ3',.T.))
				ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
				ZZ3->ZZ3_ID     := cID
				ZZ3->ZZ3_LINHA  := StrZero(nLinha += 1,6)
				ZZ3->ZZ3_DATA   := dDatabase
				ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
				ZZ3->ZZ3_TIPO   := '1'
				ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
				ZZ3->ZZ3_ERRO   := 'Erro no commit do modelo de dados'
				ZZ3->ZZ3_STATUS := '2'
				ZZ3->(MsUnlock())
			Next nI 

			ConfirmSX8()
			lOk := .F.	
		EndIf
		
	//Se não conseguir validar as informações, altera a variável para false
	Else
		lOk := .F.
	EndIf
	
	//Se não deu certo a inclusão, mostra a mensagem de erro
	If ! lOk
		cMessage := ''
		//Busca o Erro do Modelo de Dados
		aErro := oModel:GetErrorMessage()
		
		//Monta o Texto que será mostrado na tela
		cMessage := 'Id do formulário de origem:' + cValToChar(aErro[01]) + CRLF
		cMessage += 'Id do campo de origem: '     + cValToChar(aErro[02]) + CRLF
		cMessage += 'Id do formulário de erro: '  + cValToChar(aErro[03]) + CRLF
		cMessage += 'Id do campo de erro: '       + cValToChar(aErro[04]) + CRLF
		cMessage += 'Id do erro: '                + cValToChar(aErro[05]) + CRLF + CRLF
		cMessage += 'Mensagem do erro: '          + CRLF
		cMessage += cValToChar(aErro[06])         + CRLF + CRLF
		cMessage += 'Mensagem da solução: '       + CRLF
		cMessage += cValToChar(aErro[07])         + CRLF

		For nI := 1 to Len(aDadosZZ3)
			ZZ3->(reclock('ZZ3',.T.))
			ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
			ZZ3->ZZ3_ID     := cID
			ZZ3->ZZ3_LINHA  := StrZero(nLinha += 1,6)
			ZZ3->ZZ3_DATA   := dDatabase
			ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
			ZZ3->ZZ3_TIPO   := '1'
			ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
			ZZ3->ZZ3_ERRO   := cMessage
			ZZ3->ZZ3_STATUS := '2'
			ZZ3->(MsUnlock())
		Next nI 

		ConfirmSX8()
		lRet := .F.	
		nProcErr += 1
	Else
		lRet := .T.
		ConOut("Produto incluido!")
	EndIf

	nProc += 1

	//Desativa o modelo de dados
	oModel:DeActivate()

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999') + CRLF +;
		'Registros com erros'+Space(2)+': ' + Transform(nProcErr,'@E 999,999'))

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
Local nLinha  := 0
Local aInfo   := {}
Local nProc   := 0	// Produtos atualizados
Local nProcErr := 0 // Registros com erros
Local oModel  := FWLoadModel("MATA010")
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
	nLinha += 1

	For nI := 1 to Len(aInfo)
		If TamSx3(Alltrim(aCabec[nI]))[3] = 'D'
			aAdd(aFields, {Alltrim(aCabec[nI]), Ctod(aInfo[nI]), Nil}) 
		ElseIf TamSx3(Alltrim(aCabec[nI]))[3] = 'N'
			aAdd(aFields, {Alltrim(aCabec[nI]), Val(aInfo[nI]), Nil}) 
		Else 
			aAdd(aFields, {Alltrim(aCabec[nI]), aInfo[nI], Nil}) 
		Endif 	

		If nI > 1 // Pula o código do produto
			If TamSx3(Alltrim(aCabec[nI]))[3] = 'D'
				aAdd(aDadosZZ3, {aInfo[1], Alltrim(aCabec[nI]), Dtoc(Posicione('SB1',1,xFilial('SB1')+aInfo[1], Alltrim(aCabec[nI]))), aInfo[nI]})
			ElseIf TamSx3(Alltrim(aCabec[nI]))[3] = 'N'
				aAdd(aDadosZZ3, {aInfo[1], Alltrim(aCabec[nI]), Str(Posicione('SB1',1,xFilial('SB1')+aInfo[1], Alltrim(aCabec[nI]))), aInfo[nI]})
			Else
				aAdd(aDadosZZ3, {aInfo[1], Alltrim(aCabec[nI]), Posicione('SB1',1,xFilial('SB1')+aInfo[1], Alltrim(aCabec[nI])), aInfo[nI]})
			Endif
		Endif
	Next nI

	//Se conseguir executar a operação automática
	If FWMVCRotAuto(oModel, "SB1", 4, {{"SB1MASTER", aFields}} ,,.T.)

		For nI := 1 to Len(aDadosZZ3)
			ZZ3->(reclock('ZZ3',.T.))
			ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
			ZZ3->ZZ3_ID     := cID
			ZZ3->ZZ3_LINHA  := StrZero(nLinha,6)
			ZZ3->ZZ3_DATA   := dDatabase
			ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
			ZZ3->ZZ3_TIPO   := '2'
			ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
			ZZ3->ZZ3_CAMPO  := aDadosZZ3[nI,2]
			ZZ3->ZZ3_TITULO := GetSx3Cache(aDadosZZ3[nI,2], 'X3_TITULO')
			ZZ3->ZZ3_ANT    := Alltrim(aDadosZZ3[nI,3])
			ZZ3->ZZ3_DEP    := Alltrim(aDadosZZ3[nI,4])
			ZZ3->ZZ3_STATUS := '1'
			ZZ3->(MsUnlock())
		Next nI  
		ConfirmSX8()
		lOk := .T.
	Else
		lOk := .F.
	EndIf
	
	//Se não deu certo a inclusão, mostra a mensagem de erro
	If ! lOk
		
		cMessage := ''
		//Busca o Erro do Modelo de Dados
		aErro := oModel:GetErrorMessage()
		
		//Monta o Texto que será mostrado na tela
		cMessage := 'Id do formulário de origem:' + cValToChar(aErro[01]) + CRLF
		cMessage += 'Id do campo de origem: '     + cValToChar(aErro[02]) + CRLF
		cMessage += 'Id do formulário de erro: '  + cValToChar(aErro[03]) + CRLF
		cMessage += 'Id do campo de erro: '       + cValToChar(aErro[04]) + CRLF
		cMessage += 'Id do erro: '                + cValToChar(aErro[05]) + CRLF + CRLF
		cMessage += 'Mensagem do erro: '          + CRLF
		cMessage += cValToChar(aErro[06])         + CRLF + CRLF
		cMessage += 'Mensagem da solução: '       + CRLF
		cMessage += cValToChar(aErro[07])         + CRLF

		For nI := 1 to Len(aDadosZZ3)
			ZZ3->(reclock('ZZ3',.T.))
			ZZ3->ZZ3_FILIAL := xFilial('ZZ3')
			ZZ3->ZZ3_ID     := cID
			ZZ3->ZZ3_LINHA  := StrZero(nLinha,6)
			ZZ3->ZZ3_DATA   := dDatabase
			ZZ3->ZZ3_USER   := Alltrim(USRRETNAME(RETCODUSR()))
			ZZ3->ZZ3_TIPO   := '2'
			ZZ3->ZZ3_CODPRO := aDadosZZ3[nI,1]
			ZZ3->ZZ3_ERRO   := cMessage
			ZZ3->ZZ3_STATUS := '2'
			ZZ3->(MsUnlock())
		Next nI 

		ConfirmSX8()
		lRet := .F.	

		nProcErr += 1

	Else
		lRet := .T.
		ConOut("Produto alterado")
	EndIf
	
	nProc += 1

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha))+' de '+Alltrim(Str(nLinhas)))

EndDo

//Desativa o modelo de dados
oModel:DeActivate()

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999') + CRLF +;
		'Registros com erros'+Space(2)+': ' + Transform(nProcErr,'@E 999,999'))

Return Nil

