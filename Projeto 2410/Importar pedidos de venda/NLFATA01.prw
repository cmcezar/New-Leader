#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'rwmake.ch'
#INCLUDE 'Directry.ch'

//----------------------------------------------\\
/*/{Protheus.doc} NLFATA01
// Rotina para importar pedido de venda em formato texto.
@author Claudio Macedo
@since 20/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function NLFATA01()

Local cArquivo := ''
Local cPath	   := ''
Local cPerg	   :=  PADR('NLFATA01', 10)

Private cNomeArq :=	''  
Private nPos     := 0
Private nLinhas  := 0
Private cCliente := ''
Private cLoja    := ''
Private lPrevisao := .F.
Private lPedido   := .F.

If !Pergunte(cPerg, .T.)
    Return Nil
Endif

nPos :=	Aviso('Importação de Previsão e Pedido de Venda','Esta rotina tem como objetivo importar'+CRLF+' previsões e pedidos de venda.',{'Importar','Sair'}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( 'Arquivos csv |*.csv|' , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)
		cPath	 :=	Substring(cArquivo,0,RAT('\',cArquivo))
		cNomeArq :=	Substring(cArquivo,RAT('\',cArquivo)+1,Len(cArquivo))
	
		FT_FUse()       // Fecha se houver arquivo aberto/em uso.
		FT_FUse(cArquivo) 
		FT_FGoTop()

		nLinhas := FT_FLastRec() - 1
		FT_FGoTop()
		FT_FSkip()
		
		ProcRegua(nLinhas)
	
		Processa( {|| ImportaTxt() }, 'Processando arquivo ' + cNomeArq, 'Importando previsão e pedido de venda ...', .F.)

		If lPrevisao // Gera previsão de venda
			Processa( {|| ExcluiSC4() } , 'Previsão de Venda', 'Excluindo as previsões de venda ...', .F.)
			Processa( {|| GeraSC4() }   , 'Previsão de Venda', 'Incluindo as previsões de venda ...', .F.)
		Endif 

		If lPedido	 // Gera pedido de venda
			Processa( {|| ExcluiSC5() } , 'Pedido de Venda', 'Excluindo os pedidos de venda ...', .F.)
			Processa( {|| GeraSC5() }   , 'Pedido de Venda', 'Incluindo os pedidos de venda ...', .F.)
		Endif 		

	Endif
Endif

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} ImportaTxt
// Importa arquivo texto
@author Claudio Macedo
@since 20/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function ImportaTxt()
                                  
Local aString := {}
Local cItem   := '0001'
Local nLinha  := 1
Local cID	  := GetSXeNum('ZZ5','ZZ5_ID')

If !FT_FEOF()
	ZZ5->(reclock('ZZ5',.T.))
	ZZ5->ZZ5_FILIAL  := xFilial('ZZ5')
	ZZ5->ZZ5_ID		 := cID
	ZZ5->ZZ5_NOMARQ  := cNomeArq
	ZZ5->ZZ5_DATA	 := dDatabase
	ZZ5->ZZ5_CLIENT  := mv_par01
	ZZ5->(MsUnlock())
	ConfirmSX8()
Endif 

While !FT_FEOF() 

	//cString := FT_FReadln()
	aString := StrTokArr(FT_FReadln(),';')

	cCliente := ''
	cLoja    := ''

	SA1->(DbSetOrder(14))
	If SA1->(DbSeek(xFilial('SA1') + Alltrim(aString[3])))
		cCliente := SA1->A1_COD
		cLoja    := SA1->A1_LOJA
	Endif 

	ZZ6->(reclock('ZZ6',.T.))
	ZZ6->ZZ6_FILIAL := xFilial('ZZ6')
	ZZ6->ZZ6_ID		:= cID
	ZZ6->ZZ6_ITEM	:= cItem
	ZZ6->ZZ6_DATA	:= Ctod(aString[2])
	ZZ6->ZZ6_PLANTA	:= aString[3]
	ZZ6->ZZ6_ORDCOM	:= aString[4]
	ZZ6->ZZ6_ITCOM	:= aString[5]
	ZZ6->ZZ6_PNCLI	:= aString[6]
	ZZ6->ZZ6_QTDENT	:= Val(aString[7])
	ZZ6->ZZ6_QTDANT	:= Val(aString[8])
	ZZ6->ZZ6_PRCUNI	:= Val(aString[9])
	ZZ6->ZZ6_PNNWL	:= Posicione('SA7',3,xFilial('SA7') + cCliente + cLoja + aString[6], 'A7_PRODUTO') // Amarração Produto x Cliente

	If aString[1] = 'Forecast'
		ZZ6->ZZ6_TIPO := '1'
		lPrevisao     := .T.
	Else 
		ZZ6->ZZ6_TIPO := '2'
		lPedido       := .T.
	Endif 

	cItem := Soma1(cItem)
	ZZ6->(MsUnlock())

	FT_FSkip()

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo '+Alltrim(cNomeArq)+' importado.')

Return Nil

//-------------------------------------------------\\
/*/{Protheus.doc} ExcluiSC4
// Excluir as previsões de venda
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ExcluiSC4()

/* Excluindo as previsões de venda */
SC4->(DbSetOrder(4)) 
SC4->(DbSeek(xFilial('SC4') + mv_par01))

While !SC4->(Eof()) .And. SC4->C4_FILIAL = xFilial('SC4') .And. SC4->C4_XCLIENT = mv_par01

	SC4->(reclock('SC4',.F.))
	SC4->(DbDelete())
	SC4->(MsUnlock())

	SC4->(DbSkip())
EndDo

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} GeraSC4
// Incluindo as previsões de venda
@author Claudio Macedo
@since 21/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function GeraSC4()

Local aDados   := {}
Local aLog     := {}
Local cErro    := ''
Local cAliasZZ6 := GetNextAlias()
Local nI := 0

Private lMsErroAuto    := .F.    /* Variável de controle interno da rotina automatica que informa se houve erro durante o processamento */

Private lMsHelpAuto	   := .T.    /* Variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à 
                                    partir da rotina automática */

Private lAutoErrNoFile := .T.    /* Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar
                                    direto no arquivo temporário */
 
BeginSQL Alias cAliasZZ6

	COLUMN ZZ6_DATA AS DATE

	SELECT ZZ6_ID, ZZ6_DATA, ZZ6_PLANTA, ZZ6_ORDCOM, ZZ6_ITCOM, ZZ6_PNCLI, ZZ6_QTDENT, ZZ6_PRCUNI, ZZ6_PNNWL, ROUND(ZZ6_QTDENT*ZZ6_PRCUNI,2) AS ZZ6_VALOR
	FROM %Table:ZZ5% ZZ5 INNER JOIN %Table:ZZ6% ZZ6 ON
			ZZ6_FILIAL = %xFilial:ZZ6%
		AND ZZ6_ID     = ZZ5_ID
		AND ZZ6_TIPO   = '1'
		AND ZZ6.%notdel%
	WHERE ZZ5_FILIAL = %xFilial:ZZ5%
		AND ZZ5_NOMARQ = %Exp:cNomeArq%
		AND ZZ5.%notdel%
EndSQL

(cAliasZZ6)->(DbGoTop())

While !(cAliasZZ6)->(EOF())

	cCliente := ''
	cLoja    := ''

	SA1->(DbSetOrder(14))
	If SA1->(DbSeek(xFilial('SA1') + (cAliasZZ6)->ZZ6_PLANTA))
		cCliente := SA1->A1_COD
		cLoja    := SA1->A1_LOJA
	Endif 

	aadd(aDados,{'C4_XTIPINC', '2' , Nil})  
	aadd(aDados,{'C4_PRODUTO', (cAliasZZ6)->ZZ6_PNNWL , Nil})  
	aadd(aDados,{'C4_DOC'    , (cAliasZZ6)->ZZ6_ID    , Nil})  
	aadd(aDados,{'C4_QUANT'  , (cAliasZZ6)->ZZ6_QTDENT, Nil})
	aadd(aDados,{'C4_VALOR'  , (cAliasZZ6)->ZZ6_VALOR , Nil})
	aadd(aDados,{'C4_DATA'   , (cAliasZZ6)->ZZ6_DATA  , Nil}) 
	aadd(aDados,{'C4_LOCAL'  , Posicione('SB1',1,xFilial('SB1')+(cAliasZZ6)->ZZ6_PNNWL,'B1_LOCPAD'),Nil})
	aadd(aDados,{'C4_XCLIENT', cCliente , Nil}) 
	aadd(aDados,{'C4_XLOJA'  , cLoja    , Nil}) 
	aadd(aDados,{'C4_XDTIMP' , dDatabase, Nil}) 

	MATA700(aDados,3)
		
	If lMsErroAuto
		cErro := ''
		aLog := GetAutoGRLog() 	/* Função que retorna as informações de erro ocorridos durante o processo da rotina automática */			                                 				
		For nI := 1 to Len(aLog)
			cErro += aLog[nI] + CRLF
		Next
		Alert(cErro)
	EndIf

	(cAliasZZ6)->(DbSkip())

Enddo 

(cAliasZZ6)->(DbCloseArea())

Return Nil 

//-------------------------------------------------\\
/*/{Protheus.doc} ExcluiSC5
// Excluir as previsões de venda
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ExcluiSC5()

Local cAliasSC5 := GetNextAlias()

BeginSQL Alias cAliasSC5

	SELECT C5_NUM
	FROM %Table:SC5% SC5
	WHERE C5_FILIAL = %xFilial:SC5%
		AND C5_CLIENT = %Exp:mv_par01%
		AND C5_NUM NOT IN (SELECT C9_PEDIDO FROM %Table:SC9% SC9 WHERE SC9.%notdel%)
		AND C5_XTIPINC = '2'
		AND SC5.%notdel%
EndSQL

(cAliasSC5)->(DbGoTop())

/* Excluindo os pedidos de venda */
While !(cAliasSC5)->(Eof()) 
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial('SC5') + (cAliasSC5)->C5_NUM))
		SC5->(reclock('SC5',.F.))
		SC5->(DbDelete())
		SC5->(MsUnlock())
	Endif 

	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial('SC6') + (cAliasSC5)->C5_NUM))

	While !SC6->(EOF()) .And. SC6->C6_FILIAL = xFilial('SC6') .And. SC6->C6_NUM = (cAliasSC5)->C5_NUM
		SC6->(reclock('SC6',.F.))
		SC6->(DbDelete())
		SC6->(MsUnlock())
		SC6->(DbSkip())
	Enddo 

	(cAliasSC5)->(DbSkip())
EndDo

(cAliasSC5)->(DbCloseArea())

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} GeraSC5
// Incluindo os pedidos de venda
@author Claudio Macedo
@since 21/04/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function GeraSC5()

Local aLog     := {}
Local aCabec   := {}
Local aItem    := {}
Local aItens   := {}
Local cErro    := ''
Local nRegs    := 0
Local cAliasREG := GetNextAlias()
Local cAliasZZ6 := GetNextAlias()
Local nI := 0


Private lMsErroAuto    := .F.    /* Variável de controle interno da rotina automatica que informa se houve erro durante o processamento */

Private lMsHelpAuto	   := .T.    /* Variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à 
                                    partir da rotina automática */

Private lAutoErrNoFile := .T.    /* Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar
                                    direto no arquivo temporário */

BeginSQL Alias cAliasREG
		
	SELECT Count(*) AS Registros
	FROM %Table:ZZ5% ZZ5 INNER JOIN %Table:ZZ6% ZZ6 ON
			ZZ6_FILIAL = %xFilial:ZZ6%
		AND ZZ6_ID     = ZZ5_ID
		AND ZZ6_TIPO   = '2'
		AND ZZ6.%notdel%
	WHERE ZZ5_FILIAL = %xFilial:ZZ5%
		AND ZZ5_NOMARQ = %Exp:cNomeArq%
		AND ZZ5.%notdel%
				
EndSQL

(cAliasREG)->(dbGoTop())

nRegs := (cAliasREG)->Registros

ProcRegua(nRegs)

(cAliasREG)->(DbCloseArea())

BeginSQL Alias cAliasZZ6

	COLUMN ZZ6_DATA AS DATE

	SELECT ZZ6_ID, ZZ6_DATA, ZZ6_PLANTA, ZZ6_ORDCOM, ZZ6_ITCOM, ZZ6_PNCLI, ZZ6_QTDENT, ZZ6_PRCUNI, ZZ6_PNNWL
	FROM %Table:ZZ5% ZZ5 INNER JOIN %Table:ZZ6% ZZ6 ON
			ZZ6_FILIAL = %xFilial:ZZ6%
		AND ZZ6_ID     = ZZ5_ID
		AND ZZ6_TIPO   = '2'
		AND ZZ6.%notdel%
	WHERE ZZ5_FILIAL = %xFilial:ZZ5%
		AND ZZ5_NOMARQ = %Exp:cNomeArq%
		AND ZZ5.%notdel%
EndSQL

(cAliasZZ6)->(DbGoTop())


While !(cAliasZZ6)->(EOF())

	cCliente := ''
	cLoja    := ''

	SA1->(DbSetOrder(14))
	If SA1->(DbSeek(xFilial('SA1') + (cAliasZZ6)->ZZ6_PLANTA))
		cCliente := SA1->A1_COD
		cLoja    := SA1->A1_LOJA
	Endif 

	cTES := Posicione('SA7',1,xFilial('SA7') + cCliente + cLoja + (cAliasZZ6)->ZZ6_PNNWL, 'A7_XTESPV') // Amarração Produto x Cliente

	AAdd(aCabec, {"C5_FILIAL" , xFilial("SC5"), Nil})
	AAdd(aCabec, {"C5_TIPO"   , "N"		, Nil})
	AAdd(aCabec, {"C5_CLIENTE", cCliente, Nil})
	AAdd(aCabec, {"C5_LOJACLI", cLoja	, Nil})
	AAdd(aCabec, {"C5_TPFRETE", "F"	    , Nil})
	AAdd(aCabec, {"C5_XTIPINC", "2"	    , Nil})
	AAdd(aCabec, {"C5_XORDCOM", (cAliasZZ6)->ZZ6_ORDCOM, Nil})
	AAdd(aCabec, {"C5_XITCOM" , (cAliasZZ6)->ZZ6_ITCOM , Nil})
	AAdd(aCabec, {"C5_XIDEDI" , (cAliasZZ6)->ZZ6_ID , Nil})

	aItem  := {}
	aItens := {}
			
	AAdd(aItem, {"C6_FILIAL" , xFilial("SC6") , Nil})
	AAdd(aItem, {"C6_ITEM"   , '01', Nil})
	AAdd(aItem, {"C6_PRODUTO", (cAliasZZ6)->ZZ6_PNNWL , Nil})
	AAdd(aItem, {"C6_QTDVEN" , (cAliasZZ6)->ZZ6_QTDENT, Nil})
	AAdd(aItem, {"C6_NUMPCOM", (cAliasZZ6)->ZZ6_ORDCOM, Nil})
	AAdd(aItem, {"C6_ITEMPC" , (cAliasZZ6)->ZZ6_ITCOM , Nil})
	AAdd(aItem, {"C6_TES"    , cTES, Nil})
	AAdd(aItem, {"C6_ENTREG" , (cAliasZZ6)->ZZ6_DATA  , Nil})      
	AAdd(aItens, aItem)

	IncProc("Incluindo pedido de venda ...")

	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
					
	If lMsErroAuto
		cErro := ''
		aLog := GetAutoGRLog() 	/* Função que retorna as informações de erro ocorridos durante o processo da rotina automática */			                                 				
		For nI := 1 to Len(aLog)
			cErro += aLog[nI] + CRLF
		Next
		Alert(cErro)
	Endif

	(cAliasZZ6)->(DbSkip())

Enddo 

(cAliasZZ6)->(DbCloseArea())

Return Nil 

/*
===============================================================================================================================
Programa--------: DelPedRel
Autor-----------: desney.silva
Data da Criacao-: 09/09/2016
===============================================================================================================================
Descrição-------: Funcao para excluir automaticamente o pedido relacionado ref.Operacao Triangular.
===============================================================================================================================
Parâmetros------: 
_cFil - Filial do Pedido a ser excluido
_cNumPed - Numero do Pedido a ser excluido
===============================================================================================================================
Retorno---------: 
===============================================================================================================================
Data da Modificação---: 
Autor ----------------:
Modificação ----------:
===============================================================================================================================
*/
Static Function DelPedRel(_cFil,_cNumPed)

	local cArea := GetArea()

	local aCabec 	:= {}
	local aItens 	:= {}
	local nRecnoC5 	:= SC5->(Recno())
	local nRecnoC6	:= SC6->(Recno())

	local lRetDel	:= .T.

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(_cFil+_cNumPed))

		aAdd(aCabec,{"C5_NUM"   	,SC5->C5_NUM	,Nil })
		aAdd(aCabec,{"C5_TIPO"		,SC5->C5_TIPO	,Nil })
		aAdd(aCabec,{"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil })
		aAdd(aCabec,{"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil })
		aAdd(aCabec,{"C5_LOJAENT"	,SC5->C5_LOJAENT	,Nil })
		aAdd(aCabec,{"C5_CONDPAG"	,SC5->C5_CONDPAG	,Nil })

		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(_cFil+_cNumPed))
			While SC6->(!Eof()) .and. SC6->C6_FILIAL+SC6->C6_NUM == _cFil+_cNumPed

				aAdd(aItens,{"C6_ITEM"		,SC6->C6_ITEM	,Nil })
				aAdd(aItens,{"C6_PRODUTO"	,SC6->C6_PRODUTO,Nil })
				aAdd(aItens,{"C6_QTDVEN"	,SC6->C6_QTDVEN	,Nil })
				aAdd(aItens,{"C6_PRCVEN"	,SC6->C6_PRCVEN	,Nil })
				aAdd(aItens,{"C6_PRUNIT"	,SC6->C6_PRUNIT	,Nil })
				aAdd(aItens,{"C6_VALOR"		,SC6->C6_VALOR	,Nil })
				aAdd(aItens,{"C6_TES"		,SC6->C6_TES	,Nil })

				SC6->(dbSkip())
			Enddo
		Endif

		lMsErroAuto	:= .F.
		MATA410(aCabec,aItens,5)
		If !lMsErroAuto
			MsgInfo("Pedido Relacionado Operação Triangular " + _cNumPed + ' excluído com sucesso!',"MT410TOK()")
		Else
			MsgStop("Erro ao excluir Pedido Relacionado Operação Triangular " + _cNumPed + '. Informe ao Depto.TI.',"MT410TOK()")
			Mostraerro()
			lRetDel := .F.
		Endif
	Else
		MsgStop("Pedido relacionado: " + _cNumPed + 'não localizado. Informe ao Depto.TI')
		lRetDel := .F.
	Endif

	SC6->(dbGoTo(nRecnoC6))
	SC5->(dbGoTo(nRecnoC5))

	RestArea(cArea)

Return lRetDel
