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

If !Pergunte(cPerg, .T.)
    Return Nil
Endif

nPos :=	Aviso('Importação de Previsão e Pedido de Venda','Esta rotina tem como objetivo importar'+CRLF+' previsões e pedidos de venda.',{'Importar','Sair'}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( 'Previsão e Pedido de Venda |*.txt|' , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)
		cPath	 :=	Substring(cArquivo,0,RAT('\',cArquivo))
		cNomeArq :=	Substring(cArquivo,RAT('\',cArquivo)+1,Len(cArquivo))
	
		FT_FUse()       // Fecha se houver arquivo aberto/em uso.
		FT_FUse(cArquivo) 
		FT_FGoTop()

		nLinhas := FT_FLastRec() - 1
		FT_FGoTop()
		FT_FSkip()
		//oArq := Arquivo():New(cPath,cNomeArq)
		//oArq:Open()
		//oArq:Use()
		
		//nLinhas := nLinArq()
		//oArq:GoTop()
		
		ProcRegua(nLinhas)
	
		Processa( {|| ImportaTxt() }, 'Processando arquivo ' + cNomeArq, 'Importando previsão e pedido de venda ...', .F.)
		Processa( {|| GeraSC4() }, 'Previsão de Venda', 'Incluindo as previsões de venda ...', .F.)
				
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
	ZZ5->ZZ5_LOJA    := mv_par02
	ZZ5->(MsUnlock())
	ConfirmSX8()
Endif 

While !FT_FEOF() 

	//cString := FT_FReadln()
	aString := StrTokArr(FT_FReadln(),';')

	ZZ6->(reclock('ZZ6',.T.))
	ZZ6->ZZ6_FILIAL := xFilial('ZZ6')
	ZZ6->ZZ6_ID		:= cID
	ZZ6->ZZ6_ITEM	:= cItem
	ZZ6->ZZ6_TIPO   := IIF(aString[1] = 'Forecast', '1', '2')
	ZZ6->ZZ6_DATA	:= Ctod(aString[2])
	ZZ6->ZZ6_PLANTA	:= aString[3]
	ZZ6->ZZ6_ORDCOM	:= aString[4]
	ZZ6->ZZ6_ITCOM	:= aString[5]
	ZZ6->ZZ6_PNCLI	:= aString[6]
	ZZ6->ZZ6_QTDENT	:= Val(aString[7])
	ZZ6->ZZ6_QTDANT	:= Val(aString[8])
	ZZ6->ZZ6_PRCUNI	:= Val(aString[9])
	ZZ6->ZZ6_PNNWL	:= Posicione('SA7',3,xFilial('SA7') + mv_par01 + mv_par02 + aString[6], 'A7_PRODUTO') // Amarração Produto x Cliente

	cItem := Soma1(cItem)
	ZZ6->(MsUnlock())

	FT_FSkip()

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo '+Alltrim(cNomeArq)+' importado.')

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

Local aDados := {}
Local aLog   := {}
Local cErro  := ''
Local cAliasZZ6 := GetNextAlias()
Local nI := 0

Private lMsErroAuto    := .F.    /* Variável de controle interno da rotina automatica que informa se houve erro durante o processamento */

Private lMsHelpAuto	   := .T.    /* Variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à 
                                    partir da rotina automática */

Private lAutoErrNoFile := .T.    /* Força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar
                                    direto no arquivo temporário */
 
BeginSQL Alias cAliasZZ6

	COLUMN ZZ6_DATA AS DATE

	SELECT ZZ6_DATA, ZZ6_PLANTA, ZZ6_ORDCOM, ZZ6_ITCOM, ZZ6_PNCLI, ZZ6_QTDENT, ZZ6_PRCUNI, ZZ6_PNNWL, ROUND(ZZ6_QTDENT*ZZ6_PRCUNI,2) AS ZZ6_VALOR
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

	aadd(aDados,{'C4_PRODUTO', (cAliasZZ6)->ZZ6_PNNWL , Nil})  
	aadd(aDados,{'C4_DOC'    , cNomeArq               , Nil})  
	aadd(aDados,{'C4_QUANT'  , (cAliasZZ6)->ZZ6_QTDENT, Nil})
	aadd(aDados,{'C4_VALOR'  , (cAliasZZ6)->ZZ6_VALOR , Nil})
	aadd(aDados,{'C4_DATA'   , (cAliasZZ6)->ZZ6_DATA  , Nil}) 
	aadd(aDados,{'C4_LOCAL'  , Posicione('SB1',1,xFilial('SB1')+(cAliasZZ6)->ZZ6_PNNWL,'B1_LOCPAD'),Nil})

	MATA700(aDados,3)
		
	If lMsErroAuto
		aLog := GetAutoGRLog() 	/* Função que retorna as informações de erro ocorridos durante o processo da rotina automática */			                                 				
		For nI := 1 to Len(aLog)
			cErro =+ aLog[nI] + CRLF
		Next
		Alert(cErro)
	EndIf

	(cAliasZZ6)->(DbSkip())

Enddo 

(cAliasZZ6)->(DbCloseArea())

Return Nil 
