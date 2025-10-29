#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpPlan
Ponto de entrada para interpretar e tratar importa��o de saldos em 
estoque com lote e endere�o.
Gera SBF.

@author Jo�o Gustavo Orsi
@since 26/10/2015
@version P11 / P12
/*/
//-------------------------------------------------------------------
User Function ImpPlan()

	Local aRegs 	:= {}
	Local nOpcao 	:= ParamIxb
	
	If nOpcao == 1
		aRegs := ImpSaldo(aRegs)
	Else
		Break
	EndIf

Return aRegs

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpSaldo
Permite selecionar o arquivo com os saldos a serem importados.

@author Jo�o Gustavo Orsi
@since 26/10/2015
@version P11 / P12
/*/
//-------------------------------------------------------------------
Static Function ImpSaldo(aRegs)

	Local aParambox	:= {}
	Local aRet		:= {}
	
	FT_FUse() && Fecha se houver arquivo aberto/em uso.
	aAdd(aParamBox,{6,'Buscar arquivo: ', Space(80), '', '', '',80,.T.,'Todos os arquivos (*.CSV) |*.CSV|',"D:/",GETF_LOCALFLOPPY+GETF_LOCALHARD,.F.})	
	If !ParamBox(aParamBox, 'Arquivo de Saldos', aRet)
		Return
	ElseIf !Empty(MV_PAR01)
		Processa({|| RunProc(AllTrim(MV_PAR01),aRegs)},'Processando','Importando arquivo de saldo em estoque. Aguarde...',.F.)
	Else
		MsgAlert("Nenhum arquivo selecionado. Selecione um arquivo.","ImpSaldo")
	Endif

Return aRegs

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc
L� o arquivo, monta e retorna o array com os saldos a serem importados.

@author Jo�o Gustavo Orsi
@since 26/10/2015
@version P11 / P12
/*/
//-------------------------------------------------------------------
Static Function RunProc(cFile,aRegs)

	Local nLinhas	:= 0
	Local cValor	:= ""
	Local aItem	:= {}
	Local aAux	:= {}
	
	FT_FUse(cFile) 
	FT_FGoTop()
	FT_FSkip()
	nLinhas := FT_FLastRec() - 1
//	nLinhas := FT_FLastRec()
	While !FT_FEOF()
		cValor := FT_FReadln()
		aItem := StrTokArr2(cValor,";",.T.)
		aAdd(aAux,{;
			aItem[1] + Space(TAMSX3("B1_COD")[1] - Len(aItem[1]))	,;	//COLUNA 01 - Codigo do produto
			aItem[2]															,;	//COLUNA 02 - Almoxarifado
			aItem[3]															 ;	//COLUNA 05 - Localizacao
		})
		aAdd(aRegs,aAux)
		aAux := {}
		FT_FSkip()	
	EndDo
	FT_FUse() // Fecha o arquivo aberto/em uso.
	If MsgYesNo("Ser�o processados " + cValToChar(nLinhas) + " registros. Continuar processamento?","ImpSaldo")
		Return aRegs
	Else
		MsgAlert("Processamento cancelado pelo usu�rio.","CANCELADO")
		Break
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc
L� o arquivo, monta e retorna o array com os saldos a serem importados.

@author Jo�o Gustavo Orsi
@since 29/12/2016
@version P11 / P12
/*/
//-------------------------------------------------------------------
Static Function PergModelo()

	Local aParambox 	:= {}
	Local aRet     	:= {}
	
	FT_FUse() && Fecha se houver arquivo aberto/em uso.
	// Cria��o de parambox
	aAdd(aParamBox,{6,"Diret�rio destino: "	, Space(80),   "", "", "",    80,.T.,"Todos os arquivos (*.CSV) |*.CSV|",,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY,.F.}) //MV_PAR01
	If !ParamBox(aParamBox, "Par�metros", aRet)
		Return
	ElseIf !Empty(MV_PAR01)
		Processa({|| GeraModelo(AllTrim(MV_PAR01))},"Processando","Gerando arquivo de modelo. Aguarde...",.F.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraModelo
L� o arquivo, monta e retorna o array com os saldos a serem importados.

@author Jo�o Gustavo Orsi
@since 29/12/2016
@version P11 / P12
/*/
//-------------------------------------------------------------------
Static Function GeraModelo(cArqMod)

	fWrite(nHdl,"GRUPO;DESCRI��O GRUPO;SALDO INICIAL;COMPRAS(A);MOVIM. INTERNAS(B);REQ. PROD.(C);TRANSF.(D);PRODU��O(E);VENDAS(F);TRANSF. PROD.(G);DEV. VENDAS(H);DEV. COMPRAS(I);ENT. TERC.(J);SAIDA TERC.(K);SALDO ATUAL" + Chr(13) + Chr(10))
	fClose(nHdl)
	oExcelApp := MsExcel():New() // Executa o excel
	oExcelApp:WorkBooks:Open(cArqResult) // Abre a planilha 
	oExcelApp:SetVisible(.T.) 
	
Return
