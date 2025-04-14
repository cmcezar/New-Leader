#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"
#Include "Rwmake.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)


/*/{Protheus.doc} PCEXCEL
Gera ou Atualiza o Pedido de Compras
@type function
@author Rodrigo Salomão
@since 05/12/2023
@version 1.0
/*/
User Function PCEXCEL()
	
	Local aParamBox := {}
	Local aParamRet := {}
	Local lRet      := .T.  
	
	aAdd(aParambox,{6,"Local do Arquivo",GetTempPatch() + Space(150),"","","",85,.T.,"Todos os arquivos (*.*) |*.*",GetTempPath()})

	While .T.
		lRet := .T.
		if Parambox(aParambox,"Parametros",@aParamRet,,,,,,,,,.T.)
			
			///Se tiver vazio
			if Empty(AllTrim(MV_PAR01))
				MsgAlert("O caminho do arquivo está em branco, favor digitar o caminho do arquivo.","Atenção")
				lRet := .F.
			Else

				///Se não encontrar o arquivo
				If !File(MV_PAR01)
					MsgAlert("Arquivo não encontrado no caminho informado, favor verificar o caminho digitado.","Atenção")
					lRet:= .F.
				Else
					LerExcel(MV_PAR01)
					Exit
				Endif
			Endif
		Else
			MsgAlert("Parametros não encontrados.","Atenção")
			Exit
		Endif
	EndDo
Return()

Static Function LerExcel(cFileName)

///------------ Log --------------------------------------
	
Local lRet          := .T.
Local cLog 			:= ""
Local cUserName 	:= LogUserName()
Local cTime 		:= Time()
Local cData 		:= DATE()
Local cNome 		:= UsrFullName(__cUserID )
Local aLog			:= {}
Local cMens			:= ''
Local nI			:= 0
Local aLinhas       := {}
Local oFile

Private lMsErroAuto    := .F.    /* Variável de controle interno da rotina automatica que informa se houve erro durante o processamento */
Private lMsHelpAuto	   := .T.    /* Variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à 
								partir da rotina automática */

Private lAutoErrNoFile := .T.    /* Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar
								direto no arquivo temporário */   

Private oDlgEstr

Public cC7Num := ""
Public cFornec := ''
Public cLoja  := ''
Public aCab   := {}
Public aArray := {}     
Public aVetor := {} 

///------------ Inicio -----------------------------------

ProcRegua(RecCount())	

cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
cLog += "INICIO DE LOG DE PEDIDO DE COMPRAS"+CHR(13)+CHR(10)
cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
cLog += " Usuario  =>  : " + cUserName 	+  CHR(13)+CHR(10)
cLog += " Nome    =>  : " + cNome 	    +  CHR(13)+CHR(10)
cLog += OemToAnsi(" Horario  =>  : ")   + cTime 	   + CHR(13)+CHR(10)
cLog += OemToAnsi(" Data     =>  : ")   + DTOC(cData)  +CHR(13)+CHR(10)
cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)+CHR(13)+CHR(10)

oFile := FWFileReader():New(cFileName)

if (oFile:Open())

	aLinhas := oFile:getAllLines()

	For nI :=1 to Len(aLinhas)
		aLinha := Separa(aLinhas[nI],";",.T.)
		aAdd(aVetor, aLinha)
	Next nI
	oFile:Close()
Endif 

For nI := 1 to Len(aVetor)

	If nI = 1 .Or. nI = 3
		Loop
	Endif 

	If nI = 2
		cFornec := aVetor[nI,1]
		cLoja   := aVetor[nI,2]
		lRet := U_VerCab(aVetor[nI])
	Else
		lRet := U_VerItem(aVetor[nI], nI, cFornec, cLoja)
	Endif

Next nI

oFile:Close()

If lRet

	cC7Num := SOMA1(GetcC7Num())

	nI := 0

	For nI := 1 to Len(aVetor)

		If nI = 1 .Or. nI = 3
			Loop
		Endif 

		U_PrepInf(aVetor[nI], cC7Num, nI)	

	Next nI 

	FWMsgRun(, {|| MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aArray,3) }, "Processando", "Executando inclusão do pedido n° "+ AllTrim(cC7Num) +"...")

	If lMsErroAuto

		aLog := GetAutoGRLog() 	/* Função que retorna as informações de erro ocorridos durante o processo da rotina automática */			                                 						

		For nI := 1 To Len(aLog)
			cMens += StrTran(aLog[nI], '< --', ' ** ' ) + CRLF			
		Next nI	

		MsgInfo(cMens, 'Erro')

		cLog   += OemToAnsi("==    ERRO    == | ")
		cLog   += OemToAnsi("== ERRO NA INCLUSÃO DO PEDIDO DE COMPRAS (EXECAUTO)") + CHR(13) + CHR(10)

	Else
		cLog   += OemToAnsi("==      OK      == | ")
		cLog   += OemToAnsi("== PEDIDO DE COMPRAS N°: "+AllTrim(cC7Num)+" INCLUIDO COM SUCESSO") + CHR(13) + CHR(10)
	EndIf
Else
	cLog   += OemToAnsi("==    ERRO    == | ")
	cLog   += OemToAnsi("== DADOS INSUFICIENTES") + CHR(13) + CHR(10)

Endif

cLog += CHR(13)+CHR(10) + "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
cLog += "FINAL DE LOG DE PEDIDO DE COMPRAS"+CHR(13)+CHR(10)
cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
cLog += " Usuario  =>  : " + cUserName 	+  CHR(13)+CHR(10)
cLog += " Nome    =>  : " + cNome 	    +  CHR(13)+CHR(10)
cLog += OemToAnsi(" Horario  =>  : ")   + Time() 	   + CHR(13)+CHR(10)
cLog += OemToAnsi(" Data     =>  : ")   + DTOC(DATE()) + CHR(13)+CHR(10)
cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)

U_zMsgLog(cLog,"Log Pedidos de Compras",2,.F.)

Return

User Function PrepInf(aInfo,cNum,nLinha)

Local aItem := {}

if nLinha == 2		
	aAdd(aCab     ,{ "C7_NUM"      , cNum            , NIL })
	aAdd(aCab     ,{ "C7_EMISSAO"  , Date()          , NIL })
	aAdd(aCab     ,{ "C7_FORNECE"  , aVetor[nLinha,1]       , NIL })
	aAdd(aCab     ,{ "C7_LOJA"     , aVetor[nLinha,2]       , NIL })
	aAdd(aCab     ,{ "C7_COND"     , aVetor[nLinha,3]       , NIL })
	aAdd(aCab     ,{ "C7_CONTATO"  , aVetor[nLinha,4]       , NIL })
	aAdd(aCab     ,{ "C7_FILENT"   , xFilial("SC7")  , NIL })
	aAdd(aCab     ,{ "C7_TPFRETE"  , aVetor[nLinha,5]       , NIL })	
	aAdd(aCab     ,{ "C7_DESPESA"  , Val(aVetor[nLinha,6])  , NIL })	
	aAdd(aCab     ,{ "C7_SEGURO"   , Val(aVetor[nLinha,7])  , NIL })	
	aAdd(aCab     ,{ "C7_FRETE"    , Val(aVetor[nLinha,8])  , NIL })	
Else
	aAdd(aItem   ,{ "C7_TIPO"     , 1                                   , NIL })
	aAdd(aItem   ,{ "C7_ITEM"     , StrZero((nLinha-1),4,0)             , NIL })
	aAdd(aItem   ,{ "C7_PRODUTO"  , aVetor[nLinha,1]                    , NIL })
	aAdd(aItem   ,{ "C7_TES"      , aVetor[nLinha,2]                    , NIL })
	aAdd(aItem   ,{ "C7_CODTAB"   , aVetor[nLinha,3]                    , NIL })
	aAdd(aItem   ,{ "C7_QUANT"    , Val(aVetor[nLinha,4])				 , NIL })
	aAdd(aItem   ,{ "C7_PRECO"    , Val(aVetor[nLinha,5])       		 , NIL })
	aAdd(aItem   ,{ "C7_TOTAL"    , Val(aVetor[nLinha,4])*Val(aVetor[nLinha,5]), NIL })
	aAdd(aItem   ,{ "C7_MOEDA"    , Val(aVetor[nLinha,6])               , NIL })
	aAdd(aItem   ,{ "C7_TXMOEDA"  , Val(aVetor[nLinha,7])               , NIL })
	aAdd(aItem   ,{ "C7_CC"       , aVetor[nLinha,8]                    , NIL })	
	aAdd(aItem   ,{ "C7_IPI"      , Val (aVetor[nLinha,9])              , NIL })	
	aAdd(aItem   ,{ "C7_DATPRF"   , CToD(aVetor[nLinha,10])             , NIL })	
	aAdd(aItem   ,{ "C7_OBSM"     , aVetor[nLinha,11]                   , NIL })	

	aAdd(aArray, aItem)
Endif	

Return

///Gera o proximo numero do Pedido de compras
Static Function GetcC7Num()
	
	Local cQuery := ""
	Local cC7Num := "" 
	
///----------------------- Procura o maior numero da SC7 -------------------------///
	
	if Select('TRB') > 0 //VERIFICA SE A TABELA AINDA ESTA ABERTA
		TRB->(dbclosearea())
	Endif

	cQuery :=" SELECT MAX(C7_NUM) AS C7_NUM "
	cQuery +=" FROM " + RetSQLTab('SC7')
	cQuery +=" WHERE D_E_L_E_T_ ='' "
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "TRB"
	
	cC7Num := (TRB->C7_NUM)

Return cC7Num

/*/{Protheus.doc} zMsgLog
Função que mostra uma mensagem de Log com a opção de salvar em txt
@type function
@author Atilio
@since 14/04/2017
@version 1.0
@param cMsg, character, Mensagem de Log
@param cTitulo, character, Título da Janela
@param nTipo, numérico, Tipo da Janela (1 = Ok; 2 = Confirmar e Cancelar)
@param lEdit, lógico, Define se o Log pode ser editado pelo usuário
@return lRetMens, Define se a janela foi confirmada
@example
    u_zMsgLog("Daniel Teste 123", "Título", 1, .T.)
    u_zMsgLog("Daniel Teste 123", "Título", 2, .F.)
/*/
 
User Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
    Local lRetMens := .F.
    Local oDlgMens
    Local oBtnOk, cTxtConf := ""
    Local oBtnCnc, cTxtCancel := ""
    Local oBtnSlv
    Local oFntTxt := TFont():New("Tahoma",,-012,,.F.,,,,,.F.,.F.)
    Local oMsg   
    Default cMsg    := "..."
    Default cTitulo := "zMsgLog"
    Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
    Default lEdit   := .F.
     
    //Definindo os textos dos botões
    If(nTipo == 1)
        cTxtConf:='&Ok'
    Else
        cTxtConf:='&Confirmar'
        cTxtCancel:='C&ancelar'
    EndIf
 
    //Criando a janela centralizada com os botões
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 294, 169 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
        If !lEdit                                              
            oMsg:lReadOnly := .T.                               
        EndIf
         
        //Se for Tipo 1, cria somente o botão OK
        If (nTipo==1)
            @ 177, 246 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
         
        //Senão, cria os botões OK e Cancelar
        ElseIf(nTipo==2)
            @ 177, 246 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            @ 187, 246 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
        EndIf
         
        //Botão de Salvar em Txt
        @ 177, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens
 
/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/
 
Static Function fSalvArq(cMsg, cTitulo)
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
     
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return

///Verifica Dados do Cabeçalho
User Function VerCab(aLinha)

	Local cQuery := ""
	Local cMsg   := ""
	Local lLoja  := .F.
	Local lRet   := .T.

	///Verifica Fornecedor
	if !Empty(AllTrim(aLinha[1]))

		///Verifica se existe fornecedor
		SA2->(DBSetOrder(1))
		if SA2->(!DbSeek(xFilial("SA2")+aLinha[1]))
			cMsg := "   - Fornecedor invalido." + CRLF
		Endif
	Else
		cMsg := "   - Fornecedor em branco." + CRLF
	Endif

	///Verifica Loja
	if !Empty(AllTrim(aLinha[2]))

		///Se tiver aberto, fecha  tabela
		if Select("TRB1") > 0
			TRB1->(dbclosearea())
		Endif

		cQuery := " SELECT A2_COD, A2_NOME, A2_LOJA "
		cQuery += " FROM "+RetSQLName("SA2")
		cQuery += " WHERE A2_COD ='"+ aLinha[1] +"' "
		cQuery += " AND D_E_L_E_T_=''"
		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias "TRB1"

		///Verifica se a Loja é igual as lojas cadastradas do cliente
		While TRB1->(!EOF())
			
			///Se loja for diferente da cadastrada, passa para a proxima linha
			if TRB1->A2_LOJA <> aLinha[2]
				TRB1->(DbSkip())
			
			///Se encontrar loja, sai da verificação
			Else
				lLoja := .T.
				Exit
			Endif
		EndDo

		///Se não encontrar a Loja
		if !lLoja
			cMsg += "   - Loja não cadastrada neste cliente." + CRLF
		Endif
	Else
		cMsg += "   - Loja em branco." + CRLF
	Endif

	///Verifica condição de pagamento
	if !Empty(AllTrim(aLinha[3]))
		
		///Verifica se existe Condição de Pagamento
		SE4->(DBSetOrder(1))
		if SE4->(!DbSeek(xFilial("SE4")+aLinha[3]))
			cMsg += "   - Condição de Pagamento invalida." + CRLF
		Endif
	Else
		cMsg += "   - Condição de Pagamento em branco." + CRLF
	Endif
	
	///Se tiver erro, mostra erro
	if !Empty(AllTrim(cMsg))
		MsgAlert("Erro no Cabeçalho:" + CRLF + CRLF + cMsg,"Atenção")
		lRet := .F.
		//U_PCEXCEL()
	Endif
Return lRet


///Verifica lista de itens
User Function VerItem(aItens,nItem,cFornc,cLoja)
	Local cMsg    := ""
	Local lRet    := .T.
	Local cQuery  := ""
	Local lCodTab := .F.

	///Verifica Produto
	if !Empty(AllTrim(aVetor[nItem,1]))
		
		///Verifica se existe o produto 
		SB1->(DBSetOrder(1))
		if SB1->(!DbSeek(xFilial("SB1") + aVetor[nItem,1]))
			cMsg := "   - Produto invalido." + CRLF
		Endif
	Else
		cMsg := "   - Produto em branco." + CRLF
	Endif
	
	///Verifica Tes
	if !Empty(AllTrim(aVetor[nItem,2]))

		///Verifica se existe Tes
		SF4->(DBSetOrder(1))
		if SF4->(!DbSeek(xFilial("SF4") + aVetor[nItem,2]))
			cMsg += "   - Tes invalida." + CRLF
		Endif
	Endif

	///Valida CodTab
	if !Empty(AllTrim(aVetor[nItem,3]))

		///Se tiver aberto, fecha  tabela
		if Select("TRB1") > 0
			TRB1->(dbclosearea())
		Endif

		cQuery := " SELECT AIA_CODFOR, AIA_LOJFOR, AIA_CODTAB "
		cQuery += " FROM "+RetSQLName("AIA")
		cQuery += " WHERE AIA_CODFOR ='"+ cFornc +"' "
		cQuery += " AND AIA_LOJFOR ='"+ cLoja +"' "
		cQuery += " AND D_E_L_E_T_=''"
		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias "TRB1"

		///Verifica se o CodTab é igual aos CodTabs cadastrados do cliente
		While TRB1->(!EOF())
			
			///Se CodTab for diferente do cadastrada, passa para a proxima linha
			if TRB1->AIA_CODTAB <> aVetor[nItem,3]
				TRB1->(DbSkip())
			
			///Se encontrar CodTab, sai da verificação
			Else
				lCodTab := .T.
				Exit
			Endif
		EndDo

		///Se não encontrar o CodTab
		if !lCodTab
			aVetor[nItem,3]:= ""
		Endif
	Endif
	
	///Valida Quantidade
	if Empty(AllTrim(aVetor[nItem,4]))
		cMsg += "   - Quantidade em branco." + CRLF
	Endif

	///Valida Preço
	if Empty(AllTrim(aVetor[nItem,5])) 
		cMsg += "   - Preço em branco." + CRLF
	Endif

	///Valida Moeda
	if Empty(AllTrim(aVetor[nItem,6])) 
		cMsg += "   - Moeda em branco." + CRLF
	Endif

	///Valida Taxa Moeda
	if Empty(AllTrim(aVetor[nItem,7])) 
		aVetor[nItem,7] := "0"
	Endif

	///Valida CC
	if Empty(AllTrim(aVetor[nItem,8])) 
		cMsg += "   - CC em branco." + CRLF
	Endif

	///Valida Data Entrega
	if Empty(AllTrim(aVetor[nItem,10]))
		cMsg += "   - Data Entrega em branco."
	Endif

	///Se tiver erro, mostra erro
	if !Empty(AllTrim(cMsg))
		lRet := .F.
	Endif

Return lRet
