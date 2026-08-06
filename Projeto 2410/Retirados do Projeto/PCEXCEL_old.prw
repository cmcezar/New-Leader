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
	Local lInclui       := .T.
	Local cLog 			:= ""
	Local cUserName 	:= LogUserName()
	Local cTime 		:= Time()
	Local cData 		:= DATE()
	Local cNome 		:= UsrFullName(__cUserID )
    Local nCount 		:= 0
	Local nVez          := 0
	Local nOpc          := 0
	Local oFile
	
	Private lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.
	Private oDlgEstr
	
	Public cC7Num       := ""

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
		while (oFile:hasLine())
			nCount ++
			if nCount == 1 .Or.  nCount == 3
				cCab  := Separa(oFile:GetLine(),";",.t.)
			Else
				nVez++
				cCSV    := oFile:GetLine()
				
				///Se a linha estiver vazia, fim dos Registros.
				if cCSV == ";;;;;;;;;;;;;;"
					Exit
				Endif

				///Passa as informações para o Vetor
				aVetor  := Separa(cCSV,";",.t.)
				
				///Primeira vez Cabeçalho, as demais são itens
				if nVez == 1
					U_VerCab(aVetor)
				Else
					lRet := U_VerItem(aVetor,nVez-1)
				Endif

				///A Primeira execução, puxa a maior numeração e soma 1
				///Após o ExecAuto puxa a numeração do pedido de vendas
				if lInclui
					cC7Num := SOMA1(GetcC7Num())
				Endif

				///Prepara informações
				U_PrepInf(aVetor,cC7Num,nVez)	

				///Executa somente após a inserção do produto no aArray
				if nVez > 1
					lMsErroAuto := .F.	

					///A primeira exetução inclui, as demais Altera
					if lInclui
						nOpc := 3
					Else
						nOpc := 4
					Endif

					///Somente executa se os itens passarem na verificação
					if lRet

						FWMsgRun(, {|| MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,{aArray},nOpc) }, "Processando", "Executando inclusão do item n° "+ AllTrim(cItm) +"...")

						If lMsErroAuto
							MostraErro()
							lRet := .F.
							
							cLog   += OemToAnsi("==    ERRO    == | ")
							cLog   += OemToAnsi("== ITEM N° "+AllTrim(cItm)+": ERRO NA INCLUSÃO DO PEDIDO DE COMPRAS") + CHR(13) + CHR(10)
							nVez--
						Else
							cLog   += OemToAnsi("==      OK      == | ")
							cLog   += OemToAnsi("== PEDIDO DE COMPRAS N°:"+AllTrim(cC7Num)+" ITEM:"+AllTrim(cItm)+" INCLUIDO COM SUCESSO") + CHR(13) + CHR(10)
							lInclui:= .F.
						EndIf
					Else
						cLog   += OemToAnsi("==    ERRO    == | ")
						cLog   += OemToAnsi("== ITEM N° "+AllTrim(cItm)+": DADOS INSUFICIENTES") + CHR(13) + CHR(10)
						nVez--
					Endif
				Endif
			Endif
		End	

		cLog += CHR(13)+CHR(10) + "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
		cLog += "FINAL DE LOG DE PEDIDO DE COMPRAS"+CHR(13)+CHR(10)
		cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
		cLog += " Usuario  =>  : " + cUserName 	+  CHR(13)+CHR(10)
		cLog += " Nome    =>  : " + cNome 	    +  CHR(13)+CHR(10)
		cLog += OemToAnsi(" Horario  =>  : ")   + Time() 	   + CHR(13)+CHR(10)
		cLog += OemToAnsi(" Data     =>  : ")   + DTOC(DATE()) + CHR(13)+CHR(10)
		cLog += "------------------------------------------------------------------------------------------------------------------------------------------"+CHR(13)+CHR(10)
		
		U_zMsgLog(cLog,"Log Pedidos de Compras",2,.F.)
		oFile:Close()
	endif
Return

User Function PrepInf(aInfo,cNum,nVez)

///------- Local ----------------------
	
	Local dEmiss        := Date()

	Local cProd         := ""
	Local cTes          := ""
	Local cCodTab       := ""
	Local nQtd          := 0
	Local nPreco        := 0
	Local nMoeda        := 0
	Local nTxMoeda      := 0
	Local cCC           := ""
	Local cTpFrete      := ""
	Local nDespesa      := 0
	Local nSeguro       := 0
	Local cAliq         := ""
	Local dDTEntrega    := ""
	Local cObs          := ""

///------ Public ------------------

	Public cFornc      
	Public cLoja       
	Public cCond       
	Public cContato    
	Public cFilEnt      
	Public cItm 
	Public nVal
 
	Public aCab        
	Public aArray      

///------- Default --------------

	Default cFornc      := ""
	Default cLoja       := ""
	Default cCond       := ""
	Default cContato    := ""
	Default cFilEnt     := ""  
	Default cItm        := ""   
	Default nValFrete   := 0

	Default nVez        := 0
	Default aCab        := {}
	Default aArray      := {}

///------- Atribuindo Valores ------------
	
	if nVez == 1
		dEmiss        :=      Date()
		cFornc        :=      aVetor[1]
		cLoja         :=      aVetor[2]
		cCond         :=      aVetor[3]
		cContato      :=      aVetor[4]
		cFilEnt       :=     xFilial("SC7")
		cTpFrete      :=      aVetor[5]
		nDespesa      :=  Val(aVetor[6])
		nSeguro       :=  Val(aVetor[7])
		nValFrete     :=  Val(aVetor[8])
	Else
		cProd         :=      aVetor[1]
		cTes          :=      aVetor[2]
		cCodTab       :=      aVetor[3]
		nQtd          :=  Val(aVetor[4] )
		nPreco        :=  Val(aVetor[5] )
		nMoeda        :=  Val(aVetor[6] )
		nTxMoeda      :=  Val(aVetor[7] )
		cCC           :=      aVetor[8]
		cAliq         := Val (aVetor[9] )
		dDTEntrega    := CToD(aVetor[10])
		cObs          :=      aVetor[11]
	Endif

///------- Infos ---------------------	
	
	if nVez == 1
		aAdd(aCab     ,{ "C7_EMISSAO"  , dEmiss                , NIL })
		aAdd(aCab     ,{ "C7_FORNECE"  , cFornc                , NIL })
		aAdd(aCab     ,{ "C7_LOJA"     , cLoja                 , NIL })
		aAdd(aCab     ,{ "C7_COND"     , cCond                 , NIL })
		aAdd(aCab     ,{ "C7_CONTATO"  , cContato              , NIL })
		aAdd(aCab     ,{ "C7_FILENT"   , cFilEnt               , NIL })
		aAdd(aCab     ,{ "C7_TPFRETE"  , cTpFrete              , NIL })	
		aAdd(aCab     ,{ "C7_DESPESA"  , nDespesa              , NIL })	
		aAdd(aCab     ,{ "C7_SEGURO"   , nSeguro               , NIL })	
		aAdd(aCab     ,{ "C7_FRETE"    , nValFrete             , NIL })	
	Else

		if nVez == 3
			aAdd(aCab ,{ "C7_NUM"      , cNum                  , NIL })
		Endif

		aArray := {}
		cItm   := StrZero((nVez-1),4,0)
		aAdd(aArray   ,{ "C7_TIPO"     , 1                     , NIL })
		aAdd(aArray   ,{ "C7_ITEM"     , cItm                  , NIL })
		aAdd(aArray   ,{ "C7_PRODUTO"  , cProd                 , NIL })
		aAdd(aArray   ,{ "C7_TES"      , cTes                  , NIL })
		aAdd(aArray   ,{ "C7_CODTAB"   , cCodTab               , NIL })
		aAdd(aArray   ,{ "C7_QUANT"    , nQtd                  , NIL })
		aAdd(aArray   ,{ "C7_PRECO"    , nPreco                , NIL })
		aAdd(aArray   ,{ "C7_MOEDA"    , nMoeda                , NIL })
		aAdd(aArray   ,{ "C7_TXMOEDA"  , nTxMoeda              , NIL })
		aAdd(aArray   ,{ "C7_CC"       , cCC                   , NIL })	
		aAdd(aArray   ,{ "C7_IPI"      , cAliq                 , NIL })	
		aAdd(aArray   ,{ "C7_DATPRF"   , dDTEntrega            , NIL })	
		aAdd(aArray   ,{ "C7_OBSM"     , cObs                  , NIL })	
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
User Function VerCab(aItens)

	Local cQuery := ""
	Local cMsg   := ""
	Local lLoja  := .F.

	///Verifica Fornecedor
	if !Empty(AllTrim(aVetor[1]))

		///Verifica se existe fornecedor
		SA2->(DBSetOrder(1))
		if SA2->(!DbSeek(xFilial("SA2")+aVetor[1]))
			cMsg := "   - Fornecedor invalido." + CRLF
		Endif
	Else
		cMsg := "   - Fornecedor em branco." + CRLF
	Endif



	///Verifica Loja
	if !Empty(AllTrim(aVetor[2]))

		///Se tiver aberto, fecha  tabela
		if Select("TRB1") > 0
			TRB1->(dbclosearea())
		Endif

		cQuery := " SELECT A2_COD, A2_NOME, A2_LOJA "
		cQuery += " FROM "+RetSQLName("SA2")
		cQuery += " WHERE A2_COD ='"+ aVetor[1] +"' "
		cQuery += " AND D_E_L_E_T_=''"
		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias "TRB1"

		///Verifica se a Loja é igual as lojas cadastradas do cliente
		While TRB1->(!EOF())
			
			///Se loja for diferente da cadastrada, passa para a proxima linha
			if TRB1->A2_LOJA <> aVetor[2]
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
	if !Empty(AllTrim(aVetor[3]))
		
		///Verifica se existe Condição de Pagamento
		SE4->(DBSetOrder(1))
		if SE4->(!DbSeek(xFilial("SE4")+aVetor[3]))
			cMsg += "   - Condição de Pagamento invalida." + CRLF
		Endif
	Else
		cMsg += "   - Condição de Pagamento em branco." + CRLF
	Endif
	


	///Se tiver erro, mostra erro
	if !Empty(AllTrim(cMsg))
		MsgAlert("Erro no Cabeçalho:" + CRLF + CRLF + cMsg,"Atenção")
		U_PCEXCEL()
	Endif
Return




///Verifica lista de itens
User Function VerItem(aItens,nItem)
	Local cMsg    := ""
	Local lRet    := .T.
	Local cQuery  := ""
	Local lCodTab := .F.

	///Verifica Produto
	if !Empty(AllTrim(aVetor[1]))
		
		///Verifica se existe o produto 
		SB1->(DBSetOrder(1))
		if SB1->(!DbSeek(xFilial("SB1") + aVetor[1]))
			cMsg := "   - Produto invalido." + CRLF
		Endif
	Else
		cMsg := "   - Produto em branco." + CRLF
	Endif


	
	///Verifica Tes
	if !Empty(AllTrim(aVetor[2]))

		///Verifica se existe Tes
		SF4->(DBSetOrder(1))
		if SF4->(!DbSeek(xFilial("SF4") + aVetor[2]))
			cMsg += "   - Tes invalida." + CRLF
		Endif
	Endif



	///Valida CodTab
	if !Empty(AllTrim(aVetor[3]))

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
			if TRB1->AIA_CODTAB <> aVetor[3]
				TRB1->(DbSkip())
			
			///Se encontrar CodTab, sai da verificação
			Else
				lCodTab := .T.
				Exit
			Endif
		EndDo

		///Se não encontrar o CodTab
		if !lCodTab
			aVetor[3]:= ""
		Endif
	Endif


	
	///Valida Quantidade
	if Empty(AllTrim(aVetor[4]))
		cMsg += "   - Quantidade em branco." + CRLF
	Endif



	///Valida Preço
	if Empty(AllTrim(aVetor[5])) 
		cMsg += "   - Preço em branco." + CRLF
	Endif



	///Valida Moeda
	if Empty(AllTrim(aVetor[6])) 
		cMsg += "   - Moeda em branco." + CRLF
	Endif



	///Valida Taxa Moeda
	if Empty(AllTrim(aVetor[7])) 
		aVetor[7] := "0"
	Endif



	///Valida CC
	if Empty(AllTrim(aVetor[8])) 
		cMsg += "   - CC em branco." + CRLF
	Endif



	///Valida Data Entrega
	if Empty(AllTrim(aVetor[10]))
		cMsg += "   - Data Entrega em branco."
	Endif


	///Se tiver erro, mostra erro
	if !Empty(AllTrim(cMsg))
		lRet := .F.
	Endif

Return lRet
