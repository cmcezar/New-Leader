#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*
Autor: Tiago Dias
Data: 02/07/2023
Descri��o: importa��o autom�tica de pedidos de venda john Deere e Previs�o de Venda de acordo com o filtro no ParamBox
*/
User Function NLPEDJF()
Local aPergs   	:= {}
Local nTipo    	:= ""
Local aPar 		:= {Space(4)}
Local aRetorno	:= {}

Private cTipo	:= ""
	
	//Adiciona array com perguntas - Tipo: Previs�o ou Firme (Pedidos)
	aAdd(aPergs, {2, "Tipo ", nTipo		, {"1=Pedido de Venda","2=Previs�o de Venda"}, 100, ".T.", .F.})
	aAdd(aPergs, {1, "Ano"  , aPar[ 01 ], "", ".T.", "", ".T.", 80,  .F.})

	//Executa rotina de op��o
	If ParamBox(aPergs, "Informe os par�metros (Pedido de Venda ou Previs�o de Venda)", @aRetorno)

		// 1 = Pedido e 2 = Previs�o
		if aRetorno[1] == "2"

			//Executa fun��o para importar previs�o
			MsAguarde({|| U_ImportPrev("Previs�o",aRetorno)}, "Aguarde...", "Processando Registros...")
		else

			//Executa rotina para importar Pedidos
			MsAguarde({|| U_ImportPed("Firme",aRetorno)}, "Aguarde...", "Processando Registros...")

		endif

	EndIf

Return

//-------------------------------------------------------------------------//
//PREVIS�O DE VENDAS
//-------------------------------------------------------------------------//
/*
Autor: Tiago Dias
Data: 02/07/2023
Descri��o: realiza a importa��o de Previs�o de venda
*/
User Function ImportPrev(cTipo,aRetorno)
Local cData   := DTOS(Date())
Local cArq    := "pedven.csv"
Local cDir    := "C:\IMPORTADORPED\"  
Local cLinha  := ""
Local lTerc   := .T.
Local _contl  := 0
Local nX 	:= 0

Default cTipo 	:= "x"
Default aRetorno := {}


Private aDados  := {}

Private aJan 		:= {}
Private aFev 		:= {}
Private aMar 		:= {}
Private aAbr 		:= {}
Private aMai 		:= {}
Private aJun 		:= {}
Private aJul		:= {}
Private aAgo 		:= {}
Private aSet 		:= {}
Private aOut		:= {}
Private aNov 		:= {}
Private aDez 		:= {}

Private cAno 	  	:= aRetorno[2]
Private aErro 		:= {}
Private lSel  		:= .F.
Private dDtEntrega	:= ""
Private cCodProd	:= ""
Private aPed      	:= {}
Private aExcel		:= {}
Private nAtual		:= 0
Private aPrevisao	:= {}
Private aMata700	:= {}
Private dData		:= ""
Private cTabel		:= ""
Private nPreco		:= 0
Private aAlt		:= {}
Private aInc		:= {}
Private cObs    	:= ""
Private cDoc    	:= ""
Private lMsErroAuto := .F.
Private cLocal 		:= ""
Private aIncErro	:= {}
Private aAltErro 	:= {}
Private cErro		:= ""
Private nTotal		:= 0
Private cCodCli		:= ""
Private nSemAlt		:= 0

	//MSGINFO("TESTE")

	//Busca o caminho do arquivo
	If !File(cDir+cArq)

		MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao da PREVISAO sera abortada!","ATENCAO")

		Return

	Else 
		MSGALERT("O arquivo " +cDir+cArq + " foi encontrado. A importacao da PREVISAO sera executada!","ATENCAO")
			
	EndIf

	nHdl := fOpen(cDir+cArq,0)

	//Valida o arquivo
	If nHdl == -1

		If !Empty(cDir+cArq)

			MsgAlert("O arquivo de nome "+cDir+cArq+" nao pode ser aberto! Verifique os parametros.","Atencao!")

		Endif

		Return

	Endif

	//Valida o arquivo
	If !File(cDir+cArq)

		MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impped] - ATENCAO")

		Return
		
	EndIf

	aDados  	:= {}
	aJan 		:= {}
	aFev 		:= {}
	aMar 		:= {}
	aAbr 		:= {}
	aMai 		:= {}
	aJun 		:= {}
	aJul		:= {}
	aAgo 		:= {}
	aSet 		:= {}
	aOut		:= {}
	aNov 		:= {}
	aDez 		:= {}
	nX 			:= 0
	cAno 	  	:= aRetorno[2]

	//L� e adiciona em Array todos os registro do arquivo
	FT_FUSE(cDir+cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
	
		IncProc("Lendo arquivo texto...")

		lTerc := .F.

		cLinha := FT_FREADLN()

		_contl	:= _contl + 1

		If  _contl > 3

			AADD(aDados,Separa(cLinha,";",.T.))

		EndIf
	
		FT_FSKIP()

	EndDo

	//L� array com todos os registros e separa de acordo com m�s e ano
	For nX := 1 to len(aDados)

		dEmba	:= aDados[nX][3]

		//Valida Ano / M�s / Tipo (Previsto ou Firme)
		if ((VAL(substr(dEmba,9,2)) == VAL(substr(cAno,3,2))) .AND. (VAL(substr(dEmba,4,2)) >= VAL(substr(cData,5,2))) .AND. (ALLTRIM(aDados[nX][1]) == cTipo)) .OR. (VAL(substr(cAno,3,2)) > VAL(substr(cData,3,2)) .AND. VAL(substr(dEmba,9,2)) == VAL(substr(cAno,3,2)))
			Do Case
				Case substr(dEmba,4,2) = "01"
					aAdd(aJan,{aDados[nX]})
				Case substr(dEmba,4,2) = "02"
					aAdd(aFev,{aDados[nX]})
				Case substr(dEmba,4,2) = "03"
					aAdd(aMar,{aDados[nX]})
				Case substr(dEmba,4,2) = "04"
					aAdd(aAbr,{aDados[nX]})
				Case substr(dEmba,4,2) = "05"
					aAdd(aMai,{aDados[nX]})
				Case substr(dEmba,4,2) = "06"
					aAdd(aJun,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "07"
					aAdd(aJul,{aDados[nX]})
				Case substr(dEmba,4,2) = "08"
					aAdd(aAgo,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "09"
					aAdd(aSet,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "10"
					aAdd(aOut,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "11"
					aAdd(aNov,{aDados[nX]})
				Case substr(dEmba,4,2) = "12"
					aAdd(aDez,{aDados[nX]})
			EndCase

		endif

	Next nX
	
	aPrevisao := {}

	//Verifica se tem conte�do nos Arrays
	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTO - JANEIRO

	nQuant := 0
	if len(aJan) > 0
	
		For nX := 1 to len(aJan)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJan[nX][1][7])

					nQuant += VAL(aJan[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"01",ALLTRIM(aJan[nX][1][4])})

					cProd 	:= ALLTRIM(aJan[nX][1][7])
					nQuant	:= VAL(aJan[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJan[nX][1][7])
				nQuant	:= VAL(aJan[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJan)

				aAdd(aPrevisao,{cProd,nQuant,"01",ALLTRIM(aJan[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - FEVERIRO
	nQuant := 0
	if len(aFev) > 0

		For nX := 1 to len(aFev)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aFev[nX][1][7])

					nQuant += VAL(aFev[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"02",ALLTRIM(aFev[nX][1][4])})

					cProd 	:= ALLTRIM(aFev[nX][1][7])
					nQuant	:= VAL(aFev[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aFev[nX][1][7])
				nQuant	:= VAL(aFev[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aFev)

				aAdd(aPrevisao,{cProd,nQuant,"02",ALLTRIM(aFev[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - MAR�O
	nQuant := 0
	if len(aMar) > 0

		For nX := 1 to len(aMar)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aMar[nX][1][7])

					nQuant += VAL(aMar[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"03",ALLTRIM(aMar[nX][1][4])})

					cProd 	:= ALLTRIM(aMar[nX][1][7])
					nQuant	:= VAL(aMar[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aMar[nX][1][7])
				nQuant	:= VAL(aMar[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aMar)

				aAdd(aPrevisao,{cProd,nQuant,"03",ALLTRIM(aMar[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - ABRIL
	nQuant := 0
	if len(aAbr) > 0

		For nX := 1 to len(aAbr)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aAbr[nX][1][7])

					nQuant += VAL(aAbr[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"04",ALLTRIM(aAbr[nX][1][4])})

					cProd 	:= ALLTRIM(aAbr[nX][1][7])
					nQuant	:= VAL(aAbr[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aAbr[nX][1][7])
				nQuant	:= VAL(aAbr[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aAbr)

				aAdd(aPrevisao,{cProd,nQuant,"04",ALLTRIM(aAbr[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - MAIO
	nQuant := 0
	if len(aMai) > 0

		For nX := 1 to len(aMai)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aMai[nX][1][7])

					nQuant += VAL(aMai[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"05",ALLTRIM(aMai[nX][1][4])})

					cProd 	:= ALLTRIM(aMai[nX][1][7])
					nQuant	:= VAL(aMai[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aMai[nX][1][7])
				nQuant	:= VAL(aMai[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aMai)

				aAdd(aPrevisao,{cProd,nQuant,"05",ALLTRIM(aMai[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - JUNHO
	nQuant := 0
	if len(aJun) > 0

		For nX := 1 to len(aJun)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJun[nX][1][7])

					nQuant += VAL(aJun[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"06",ALLTRIM(aJun[nX][1][4])})

					cProd 	:= ALLTRIM(aJun[nX][1][7])
					nQuant	:= VAL(aJun[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJun[nX][1][7])
				nQuant	:= VAL(aJun[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJun)

				aAdd(aPrevisao,{cProd,nQuant,"06",ALLTRIM(aJun[nX][1][4])})

			endif

		Next nX
		
	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - JULHO
	nQuant := 0
	if len(aJul) > 0

		For nX := 1 to len(aJul)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJul[nX][1][7])

					nQuant += VAL(aJul[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"07",ALLTRIM(aJul[nX][1][4])})

					cProd 	:= ALLTRIM(aJul[nX][1][7])
					nQuant	:= VAL(aJul[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJul[nX][1][7])
				nQuant	:= VAL(aJul[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJul)

				aAdd(aPrevisao,{cProd,nQuant,"07",ALLTRIM(aJul[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTO - AGOSTO
	nQuant := 0
	if len(aAgo) > 0

		For nX := 1 to len(aAgo)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aAgo[nX][1][7])

					nQuant += VAL(aAgo[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"08",ALLTRIM(aAgo[nX][1][4])})

					cProd 	:= ALLTRIM(aAgo[nX][1][7])
					nQuant	:= VAL(aAgo[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aAgo[nX][1][7])
				nQuant	:= VAL(aAgo[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aAgo)

				aAdd(aPrevisao,{cProd,nQuant,"08",ALLTRIM(aAgo[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - SETEMBRO
	nQuant := 0
	if len(aSet) > 0
	
		For nX := 1 to len(aSet)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aSet[nX][1][7])

					nQuant += VAL(aSet[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"09",ALLTRIM(aSet[nX][1][4])})

					cProd 	:= ALLTRIM(aSet[nX][1][7])
					nQuant	:= VAL(aSet[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aSet[nX][1][7])
				nQuant	:= VAL(aSet[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aSet)

				aAdd(aPrevisao,{cProd,nQuant,"09",ALLTRIM(aSet[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - OUTUBRO
	nQuant := 0
	if len(aOut) > 0

		For nX := 1 to len(aOut)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aOut[nX][1][7])

					nQuant += VAL(aOut[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"10",ALLTRIM(aOut[nX][1][4])})

					cProd 	:= ALLTRIM(aOut[nX][1][7])
					nQuant	:= VAL(aOut[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aOut[nX][1][7])
				nQuant	:= VAL(aOut[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aOut)

				aAdd(aPrevisao,{cProd,nQuant,"10",ALLTRIM(aOut[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - NOVEMBRO
	nQuant := 0
	if len(aNov) > 0

		For nX := 1 to len(aNov)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aNov[nX][1][7])

					nQuant += VAL(aNov[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"11",ALLTRIM(aNov[nX][1][4])})

					cProd 	:= ALLTRIM(aNov[nX][1][7])
					nQuant	:= VAL(aNov[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aNov[nX][1][7])
				nQuant	:= VAL(aNov[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aNov)

				aAdd(aPrevisao,{cProd,nQuant,"11",ALLTRIM(aNov[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - DEZEMBRO
	nQuant := 0
	if len(aDez) > 0

		For nX := 1 to len(aDez)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aDez[nX][1][7])

					nQuant += VAL(aDez[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"12",ALLTRIM(aDez[nX][1][4])})

					cProd 	:= ALLTRIM(aDez[nX][1][7])
					nQuant	:= VAL(aDez[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aDez[nX][1][7])
				nQuant	:= VAL(aDez[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aDez)

				aAdd(aPrevisao,{cProd,nQuant,"12",ALLTRIM(aDez[nX][1][4])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//POSICIONA NA TABELA SC4 PARA FILTRAR E ALTERAR O REGISTRO CASO TENHA DIFEREN�A NA QUANTIDADE
	DbSelectArea( 'SC4' )
	SC4->( DbSetorder(1) ) 
	//SC4->( DbGoTop() )

	aAlt 		:= {}
	aAltErro 	:= {}
	aInc 		:= {}
	aIncErro 	:= {}

	nAtual		:= 0

	nSemAlt		:= 0

	//-------------------------------------------------------------------------//
	//REALIZA A EXECU��O DO MATA700 DE ACORDO COM O ARRAY DAS SOMAS DOS PRODUTOS
	if len(aPrevisao) > 0

		For nX := 1 to len(aPrevisao)

			nAtual++
			MsProcTxt("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(len(aPrevisao)) + "...")
			
			//Cliente Padr�o
			If alltrim(aPrevisao[Nx][4]) = "John Deere Brazil"

				cCodCli	:= "00000101"
							
			Else

				cCodCli	:= "00000102"			
				
			EndIf

			//Retorna c�dido de Documento - "PPV"+lMES+lANO
			cDoc 	 := "PPV"+aPrevisao[nX][3]+cAno
			
			//Retorna C�digo do Produto
			cCodProd := Posicione("SA7",3,xFilial("SA7")+cCodCli+aPrevisao[nX][1],"A7_PRODUTO")

			//Retorna c�digo de armaz�m do produto
			cLocal   := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_LOCPAD")

			//Se for branco, considera 01
			if empty(cLocal)

				cLocal := "01"

			endif

			//Retorna c�digo de cliente
			cTabel	 := Posicione("SA1",1,xFilial("SA1")+cCodCli,"A1_TABELA")

			//Retorna pre�o do produto
			nPreco   := Posicione("DA1",1,xFilial("DA1")+cTabel+cCodProd,"DA1_PRCVEN")

			//Define data de acordo com Ano digitado, m�s adicionado em cada Array e dia 01 sempre padr�o
			dData    := cAno+aPrevisao[nX][3]+"01"

			//REALIZA FILTRO PARA VERIFICAR SE A QUANTIDADE TOTAL DE CADA PRODUTO DENTRO M�S MUDOU
			//C4_FILIAL + C4_PRODUTO + DTOS(C4_DATA)
			IF SC4->(dbSeek(xFilial("SC4")+cCodProd+dData))

				//SE A QUANTIDADE FOR DIFERENTE, GRAVA A ATUAL
				IF SC4->C4_QUANT <> aPrevisao[nX][2] //.or. SC4->C4_VALOR <> (nPreco*aPrevisao[nX][2]) - VERIFICAR

					//SE FOR ALTERADO
					cObs := "ALTERA��O REALIZADA: "+DTOS(dDataBase)
					
					//ALTERA��O SER� FEITA POR EXECAUTO E N�O POR RECLOCK
					/*IF Reclock("SC4",.F.)

						SC4->C4_QUANT := aPrevisao[nX][2] 
						SC4->C4_VALOR := nPreco*aPrevisao[nX][2] 

						SC4->(MsUnlock())

					ENDIF*/

					//REALIZA ALTERA��O AUTOM�TICA
					aMata700 := {}

					aadd(aMata700,{"C4_PRODUTO"  ,cCodProd       			,Nil})  //Campo B1_COD
					aadd(aMata700,{"C4_LOCAL"    ,cLocal                	,Nil})
					aadd(aMata700,{"C4_DOC"      ,cDoc      				,Nil})  //Campo B1_DESC
					aadd(aMata700,{"C4_QUANT"    ,aPrevisao[nX][2]          ,Nil})
					aadd(aMata700,{"C4_VALOR"    ,nPreco*aPrevisao[nX][2]   ,Nil})
					aadd(aMata700,{"C4_DATA"     ,StoD(dData)               ,Nil})  //Pode ser utilizado da seguinte forma [ Date() +10 ] para somar a data atual at� chegar a desejada.
					aadd(aMata700,{"C4_OBS"      ,cObs            			,Nil})

					//REALIZA INCLUS�O AUTOM�TICA
					MATA700(aMata700,4)

					//RETORNA ERRO EM TELA COM MOTIVO
					If !lMsErroAuto

						//ALIMENTA ARRAY PARA ENVIO DE E-MAIL -> ALTERA��O
						aAdd(aAlt,{cCodProd,StoD(dData),aPrevisao[nX][2]})

						ConOut("Altera��o realizada com sucesso! MATA700")

						//confirmSX8()

					Else

						//MostraErro()
						//aErro := GetAutoGRLog()
						cErro := "Nao foi possivel realizar altera��o"
						Conout( cErro )

						//Verifica se o c�digo do produto est� em branco
						if empty(cCodProd)

							cErro := "Produto n�o encontrado!"

						endif

						aAdd(aAltErro,{cCodProd,StoD(dData),aPrevisao[nX][2],cErro})

						//rollBackSX8()

					EndIf
				
				ELSE

					nSemAlt++

				ENDIF

			ELSE

				//SE FOR ALTERADO
				cObs := "INCLUS�O REALIZADA: "+DTOS(dDataBase)

				aMata700 := {}

				aadd(aMata700,{"C4_PRODUTO"  ,cCodProd       			,Nil})  //Campo B1_COD
				aadd(aMata700,{"C4_LOCAL"    ,cLocal               		,Nil})
				aadd(aMata700,{"C4_DOC"      ,cDoc      				,Nil})  //Campo B1_DESC
				aadd(aMata700,{"C4_QUANT"    ,aPrevisao[nX][2]          ,Nil})
				aadd(aMata700,{"C4_VALOR"    ,nPreco*aPrevisao[nX][2]   ,Nil})
				aadd(aMata700,{"C4_DATA"     ,StoD(dData)               ,Nil})  //Pode ser utilizado da seguinte forma [ Date() +10 ] para somar a data atual at� chegar a desejada.
				aadd(aMata700,{"C4_OBS"      ,cObs            			,Nil})

				//REALIZA INCLUS�O AUTOM�TICA
				MATA700(aMata700,3)

				//RETORNA ERRO EM TELA COM MOTIVO
				If !lMsErroAuto

					//ALIMENTA ARRAY PARA ENVIO DE E-MAIL -> INCLUS�O
					aAdd(aInc,{cCodProd,StoD(dData),aPrevisao[nX][2]})

					ConOut("Inclus�o realizada com sucesso! MATA700")

					//confirmSX8()

				Else

					//MostraErro()
					//aErro := GetAutoGRLog()
					cErro := "Nao foi possivel realizar inclusao"
					Conout( cErro )

					//Verifica se o c�digo do produto est� em branco
					if empty(cCodProd)

						cErro := "Produto n�o encontrado!"

					endif

					aAdd(aIncErro,{cCodProd,StoD(dData),aPrevisao[nX][2],cErro})

					//rollBackSX8()

				EndIf
			
			ENDIF

		Next nX

	else
		MSGINFO( "Sem registro para importa��o" )
	endif

	IF nSemAlt > 0

		//MENSAGEM EM TELA DA QUANTIDADE QUE NAO SOFREU ALTERA��O
		MSGALERT("Quantidade: "+ALLTRIM(cValToChar(nSemAlt)),"ATENCAO - PREVIS�O (sem altera��o) !")

	ENDIF	

	IF LEN(aAlt) > 0

		//MENSAGEM EM TELA DA QUANTIDADE QUE SOFREU ALTERA��O
		MSGALERT("Quantidade: "+ALLTRIM(cValToChar(len(aAlt))),"ATENCAO - PREVIS�O (com altera��o) !")

	ENDIF

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> ALTERA��O
	/*if len(aAlt) > 0

		//U_NLEMAILJD(.F.,aAlt)

		MSGALERT("Lista de Previs�o alterada enviada por E-mail","ATENCAO (altera��o) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> INCLUS�O
	if len(aInc) > 0

		//U_NLEMAILJD(.T.,aInc)

		MSGALERT("Lista de Previs�o inclu�da enviada por E-mail","ATENCAO (inlcus�o) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> ALTERA��O ERRO
	if len(aAltErro) > 0

		//U_NLEMAILJD(.F.,aAltErro,1)

		MSGALERT("Lista de Previs�o alterada com erro enviada por E-mail","ATENCAO (altera��o com erro) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> INCLUS�O ERRO
	if len(aIncErro) > 0

		//U_NLEMAILJD(.T.,aIncErro,2)

		MSGALERT("Lista de Previs�o inclus�o com erro enviada por E-mail","ATENCAO (inclus�o com erro) !")

	endif*/

Return

//-------------------------------------------------------------------------//
//PEDIDO DE VENDAS
//-------------------------------------------------------------------------//
/*
Autor: Tiago Dias
Data: 04/07/2023
Descri��o: realiza a importa��o de Pedido de venda
*/
User Function ImportPed(cTipo,aRetorno)
Local cData   := DTOS(Date())
Local cArq    := "pedven.csv"
Local cDir    := "C:\IMPORTADORPED\"  
Local cLinha  := ""
Local lTerc   := .T.
Local _contl  := 0
Local aDados  := {}

Local aJan 		:= {}
Local aFev 		:= {}
Local aMar 		:= {}
Local aAbr 		:= {}
Local aMai 		:= {}
Local aJun 		:= {}
Local aJul		:= {}
Local aAgo 		:= {}
Local aSet 		:= {}
Local aOut		:= {}
Local aNov 		:= {}
Local aDez 		:= {}
Local nX 		:= 0
Local nC6			:= 0
Local nQr			:= 0

Private cAno 	  	:= aRetorno[2]
Private aErro 		:= {}
Private lSel  		:= .F.
Private dDtEntrega	:= ""
Private cCodProd	:= ""
Private aPed      	:= {}
Private aExcel		:= {}
Private nAtual		:= 0
Private aPrevisao	:= {}
Private dData		:= ""
Private cTabel		:= ""
Private nPreco		:= 0
Private aAlt		:= {}
Private aInc		:= {}
Private cObs    	:= ""
Private cDoc    	:= ""
Private lMsErroAuto := .F.
Private cLocal 		:= ""
Private aIncErro	:= {}
Private aAltErro 	:= {}
Private cErro		:= ""
Private nTotal		:= 0
Private aCabec		:= {}
Private aLinha		:= {}
Private aItem		:= {}
Private cNumPed		:= ""
Private cCondPag	:= ""
Private cCodCli 	:= ""
Private cQuery		:= ""
Private _cNum		:= ""
Private _cItem		:= ""
Private _cProd		:= ""
Private aMesItens 	:= {}
Private aSc6 		:= {}
Private lAltPed		:= .F.
Private nItensInc 	:= 0
Private nItensAlt 	:= 0
Private nItem		:= 0

	//Busca o caminho do arquivo
	If !File(cDir+cArq)

		MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao da PREVISAO sera abortada!","ATENCAO")

		Return

	Else 
		MSGALERT("O arquivo " +cDir+cArq + " foi encontrado. A importacao da PREVISAO sera executada!","ATENCAO")
			
	EndIf

	nHdl := fOpen(cDir+cArq,0)

	//Valida o arquivo
	If nHdl == -1

		If !Empty(cDir+cArq)

			MsgAlert("O arquivo de nome "+cDir+cArq+" nao pode ser aberto! Verifique os parametros.","Atencao!")

		Endif

		Return

	Endif

	//Valida o arquivo
	If !File(cDir+cArq)

		MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impped] - ATENCAO")

		Return
		
	EndIf

	//L� e adiciona em Array todos os registro do arquivo
	FT_FUSE(cDir+cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
	
		IncProc("Lendo arquivo texto...")

		lTerc := .F.

		cLinha := FT_FREADLN()

		_contl	:= _contl + 1

		If  _contl > 3 .and. ALLTRIM(substr(cLinha,1,AT(";",cLinha)-1)) == cTipo

			AADD(aDados,Separa(cLinha,";",.T.))

		EndIf
	
		FT_FSKIP()

	EndDo

	//L� array com todos os registros e separa de acordo com m�s e ano
	For nX := 1 to len(aDados)

		dEmba	:= aDados[nX][3]

		//Valida Ano / M�s / Tipo (Previsto ou Firme)
		if ((VAL(substr(dEmba,9,2)) == VAL(substr(cAno,3,2))) .AND. (VAL(substr(dEmba,4,2)) >= VAL(substr(cData,5,2)))) .OR. (VAL(substr(cAno,3,2)) > VAL(substr(cData,3,2)) .AND. VAL(substr(dEmba,9,2)) == VAL(substr(cAno,3,2))) //.AND. (ALLTRIM(aDados[nX][1]) == cTipo)
			
			Do Case
				Case substr(dEmba,4,2) = "01"
					aAdd(aJan,{aDados[nX]})
				Case substr(dEmba,4,2) = "02"
					aAdd(aFev,{aDados[nX]})
				Case substr(dEmba,4,2) = "03"
					aAdd(aMar,{aDados[nX]})
				Case substr(dEmba,4,2) = "04"
					aAdd(aAbr,{aDados[nX]})
				Case substr(dEmba,4,2) = "05"
					aAdd(aMai,{aDados[nX]})
				Case substr(dEmba,4,2) = "06"
					aAdd(aJun,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "07"
					aAdd(aJul,{aDados[nX]})
				Case substr(dEmba,4,2) = "08"
					aAdd(aAgo,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "09"
					aAdd(aSet,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "10"
					aAdd(aOut,{aDados[nX]}) 
				Case substr(dEmba,4,2) = "11"
					aAdd(aNov,{aDados[nX]})
				Case substr(dEmba,4,2) = "12"
					aAdd(aDez,{aDados[nX]})
			EndCase

		endif

	Next nX

//Verifica se tem conte�do nos Arrays
//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTO - JANEIRO
	if len(aJan) > 0
	
		For nX := 1 to len(aJan)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJan[nX][1][7])

					nQuant += VAL(aJan[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"01",ALLTRIM(aJan[nX][1][4]),ALLTRIM(aJan[nX][1][5]),ALLTRIM(aJan[nX][1][6]),VAL(aJan[nX][1][23])})

					cProd 	:= ALLTRIM(aJan[nX][1][7])
					nQuant	:= VAL(aJan[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJan[nX][1][7])
				nQuant	:= VAL(aJan[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJan)

				aAdd(aPrevisao,{cProd,nQuant,"01",ALLTRIM(aJan[nX][1][4]),ALLTRIM(aJan[nX][1][5]),ALLTRIM(aJan[nX][1][6]),VAL(aJan[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - FEVERIRO
	if len(aFev) > 0

		For nX := 1 to len(aFev)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aFev[nX][1][7])

					nQuant += VAL(aFev[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"02",ALLTRIM(aFev[nX][1][4]),ALLTRIM(aFev[nX][1][5]),ALLTRIM(aFev[nX][1][6]),VAL(aFev[nX][1][23])})

					cProd 	:= ALLTRIM(aFev[nX][1][7])
					nQuant	:= VAL(aFev[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aFev[nX][1][7])
				nQuant	:= VAL(aFev[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aFev)

				aAdd(aPrevisao,{cProd,nQuant,"02",ALLTRIM(aFev[nX][1][4]),ALLTRIM(aFev[nX][1][5]),ALLTRIM(aFev[nX][1][6]),VAL(aFev[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - MAR�O
	if len(aMar) > 0

		For nX := 1 to len(aMar)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aMar[nX][1][7])

					nQuant += VAL(aMar[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"03",ALLTRIM(aMar[nX][1][4]),ALLTRIM(aMar[nX][1][5]),ALLTRIM(aMar[nX][1][6]),VAL(aMar[nX][1][23])})

					cProd 	:= ALLTRIM(aMar[nX][1][7])
					nQuant	:= VAL(aMar[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aMar[nX][1][7])
				nQuant	:= VAL(aMar[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aMar)

				aAdd(aPrevisao,{cProd,nQuant,"03",ALLTRIM(aMar[nX][1][4]),ALLTRIM(aMar[nX][1][5]),ALLTRIM(aMar[nX][1][6]),VAL(aMar[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - ABRIL
	if len(aAbr) > 0

		For nX := 1 to len(aAbr)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aAbr[nX][1][7])

					nQuant += VAL(aAbr[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"04",ALLTRIM(aAbr[nX][1][4]),ALLTRIM(aAbr[nX][1][5]),ALLTRIM(aAbr[nX][1][6]),VAL(aAbr[nX][1][23])})

					cProd 	:= ALLTRIM(aAbr[nX][1][7])
					nQuant	:= VAL(aAbr[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aAbr[nX][1][7])
				nQuant	:= VAL(aAbr[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aAbr)

				aAdd(aPrevisao,{cProd,nQuant,"04",ALLTRIM(aAbr[nX][1][4]),ALLTRIM(aAbr[nX][1][5]),ALLTRIM(aAbr[nX][1][6]),VAL(aAbr[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - MAIO
	if len(aMai) > 0

		For nX := 1 to len(aMai)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aMai[nX][1][7])

					nQuant += VAL(aMai[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"05",ALLTRIM(aMai[nX][1][4]),ALLTRIM(aMai[nX][1][5]),ALLTRIM(aMai[nX][1][6]),VAL(aMai[nX][1][23])})

					cProd 	:= ALLTRIM(aMai[nX][1][7])
					nQuant	:= VAL(aMai[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aMai[nX][1][7])
				nQuant	:= VAL(aMai[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aMai)

				aAdd(aPrevisao,{cProd,nQuant,"05",ALLTRIM(aMai[nX][1][4]),ALLTRIM(aMai[nX][1][5]),ALLTRIM(aMai[nX][1][6]),VAL(aMai[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - JUNHO
	if len(aJun) > 0

		For nX := 1 to len(aJun)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJun[nX][1][7])

					nQuant += VAL(aJun[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"06",ALLTRIM(aJun[nX][1][4]),ALLTRIM(aJun[nX][1][5]),ALLTRIM(aJun[nX][1][6]),VAL(aJun[nX][1][23])})

					cProd 	:= ALLTRIM(aJun[nX][1][7])
					nQuant	:= VAL(aJun[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJun[nX][1][7])
				nQuant	:= VAL(aJun[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJun)

				aAdd(aPrevisao,{cProd,nQuant,"06",ALLTRIM(aJun[nX][1][4]),ALLTRIM(aJun[nX][1][5]),ALLTRIM(aJun[nX][1][6]),VAL(aJun[nX][1][23])})

			endif

		Next nX
		
	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - JULHO
	if len(aJul) > 0

		For nX := 1 to len(aJul)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aJul[nX][1][7])

					nQuant += VAL(aJul[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"07",ALLTRIM(aJul[nX][1][4]),ALLTRIM(aJul[nX][1][5]),ALLTRIM(aJul[nX][1][6]),VAL(aJul[nX][1][23])})

					cProd 	:= ALLTRIM(aJul[nX][1][7])
					nQuant	:= VAL(aJul[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aJul[nX][1][7])
				nQuant	:= VAL(aJul[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aJul)

				aAdd(aPrevisao,{cProd,nQuant,"07",ALLTRIM(aJul[nX][1][4]),ALLTRIM(aJul[nX][1][5]),ALLTRIM(aJul[nX][1][6]),VAL(aJul[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTO - AGOSTO
	if len(aAgo) > 0

		For nX := 1 to len(aAgo)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aAgo[nX][1][7])

					nQuant += VAL(aAgo[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"08",ALLTRIM(aAgo[nX][1][4]),ALLTRIM(aAgo[nX][1][5]),ALLTRIM(aAgo[nX][1][6]),VAL(aAgo[nX][1][23])})

					cProd 	:= ALLTRIM(aAgo[nX][1][7])
					nQuant	:= VAL(aAgo[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aAgo[nX][1][7])
				nQuant	:= VAL(aAgo[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aAgo)

				aAdd(aPrevisao,{cProd,nQuant,"08",ALLTRIM(aAgo[nX][1][4]),ALLTRIM(aAgo[nX][1][5]),ALLTRIM(aAgo[nX][1][6]),VAL(aAgo[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - SETEMBRO
	if len(aSet) > 0
	
		For nX := 1 to len(aSet)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aSet[nX][1][7])

					nQuant += VAL(aSet[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"09",ALLTRIM(aSet[nX][1][4]),ALLTRIM(aSet[nX][1][5]),ALLTRIM(aSet[nX][1][6]),VAL(aSet[nX][1][23])})

					cProd 	:= ALLTRIM(aSet[nX][1][7])
					nQuant	:= VAL(aSet[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aSet[nX][1][7])
				nQuant	:= VAL(aSet[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aSet)

				aAdd(aPrevisao,{cProd,nQuant,"09",ALLTRIM(aSet[nX][1][4]),ALLTRIM(aSet[nX][1][5]),ALLTRIM(aSet[nX][1][6]),VAL(aSet[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - OUTUBRO
	if len(aOut) > 0

		For nX := 1 to len(aOut)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aOut[nX][1][7])

					nQuant += VAL(aOut[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"10",ALLTRIM(aOut[nX][1][4]),ALLTRIM(aOut[nX][1][5]),ALLTRIM(aOut[nX][1][6]),VAL(aOut[nX][1][23])})

					cProd 	:= ALLTRIM(aOut[nX][1][7])
					nQuant	:= VAL(aOut[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aOut[nX][1][7])
				nQuant	:= VAL(aOut[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aOut)

				aAdd(aPrevisao,{cProd,nQuant,"10",ALLTRIM(aOut[nX][1][4]),ALLTRIM(aOut[nX][1][5]),ALLTRIM(aOut[nX][1][6]),VAL(aOut[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - NOVEMBRO
	if len(aNov) > 0

		For nX := 1 to len(aNov)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aNov[nX][1][7])

					nQuant += VAL(aNov[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"11",ALLTRIM(aNov[nX][1][4]),ALLTRIM(aNov[nX][1][5]),ALLTRIM(aNov[nX][1][6]),VAL(aNov[nX][1][23])})

					cProd 	:= ALLTRIM(aNov[nX][1][7])
					nQuant	:= VAL(aNov[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aNov[nX][1][7])
				nQuant	:= VAL(aNov[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aNov)

				aAdd(aPrevisao,{cProd,nQuant,"11",ALLTRIM(aNov[nX][1][4]),ALLTRIM(aNov[nX][1][5]),ALLTRIM(aNov[nX][1][6]),VAL(aNov[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//AGLUTINA PRODUTOS - DEZEMBRO
	if len(aDez) > 0

		For nX := 1 to len(aDez)

			//Verifica se est� na primeira linha
			if nX > 1
				
				//Verifica se o c�digo do produto � igual e soma a quantidade
				if cProd == ALLTRIM(aDez[nX][1][7])

					nQuant += VAL(aDez[nX][1][9])
				
				else

					//Add no array para a cria��o dos pedidos aglutinados
					aAdd(aPrevisao,{cProd,nQuant,"12",ALLTRIM(aDez[nX][1][4]),ALLTRIM(aDez[nX][1][5]),ALLTRIM(aDez[nX][1][6]),VAL(aDez[nX][1][23])})

					cProd 	:= ALLTRIM(aDez[nX][1][7])
					nQuant	:= VAL(aDez[nX][1][9])

				endif

			else

				cProd	:= ALLTRIM(aDez[nX][1][7])
				nQuant	:= VAL(aDez[nX][1][9])

			endif

			//Verifica se � o ultima item
			if nX == len(aDez)

				aAdd(aPrevisao,{cProd,nQuant,"12",ALLTRIM(aDez[nX][1][4]),ALLTRIM(aDez[nX][1][5]),ALLTRIM(aDez[nX][1][6]),VAL(aDez[nX][1][23])})

			endif

		Next nX

	endif

	//-------------------------------------------------------------------------//
	//POSICIONA NAS TABELAS SC5 E SC6 PARA FILTRAR E ALTERAR O REGISTRO CASO TENHA DIFEREN�A NA QUANTIDADE
	DbSelectArea( 'SC5' )
	SC5->( DbSetorder(1) ) 
	//SC5->( DbGoTop() )

	DbSelectArea( 'SC6' )
	SC6->( DbSetorder(1) ) 
	//SC6->( DbGoTop() )

	//-------------------------------------------------------------------------//
	//REALIZA A EXECU��O DO MATA410 DE ACORDO COM O ARRAY DAS SOMAS DOS PRODUTOS
	nItensInc := 0
	nItensAlt := 0

	For nX := 1 to len(aPrevisao)

		nAtual++
        MsProcTxt("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(len(aPrevisao)) + "...")

		aMesItens := {}

		//Verifica o M�s para criar os itens
		Do Case
			Case aPrevisao[nX][3] = "01"
				aMesItens	:= aClone(aJan)			
			Case aPrevisao[nX][3] = "02"
				aMesItens	:= aClone(aFev)
			Case aPrevisao[nX][3] = "03"
				aMesItens	:= aClone(aMar)
			Case aPrevisao[nX][3] = "04"
				aMesItens	:= aClone(aAbr)
			Case aPrevisao[nX][3] = "05"
				aMesItens	:= aClone(aMai)
			Case aPrevisao[nX][3] = "06"
				aMesItens	:= aClone(aJun)
			Case aPrevisao[nX][3] = "07"
				aMesItens	:= aClone(aJul)
			Case aPrevisao[nX][3] = "08"
				aMesItens	:= aClone(aAgo)
			Case aPrevisao[nX][3] = "09"
				aMesItens	:= aClone(aSet)
			Case aPrevisao[nX][3] = "10"
				aMesItens	:= aClone(aOut)
			Case aPrevisao[nX][3] = "11"
				aMesItens	:= aClone(aNov)
			Case aPrevisao[nX][3] = "12"
				aMesItens	:= aClone(aDez)
		EndCase

		//Cliente Padr�o
		If alltrim(aPrevisao[Nx][4]) = "John Deere Brazil"

			cCodCli	:= "00000101"
						
		Else

			cCodCli	:= "00000102"			
			
		EndIf

		//Retorna C�digo do Produto
		cCodProd := Posicione("SA7",3,xFilial("SA7")+cCodCli+aPrevisao[nX][1],"A7_PRODUTO")

		//Condi��o de pagamento
		cCondPag	:= Posicione("SA1",1,xFilial("SA1")+cCodCli,"A1_COND")

		//Data de entrega / embalagem
		dData    := cAno+aPrevisao[nX][3]+"01"

		//Retorna c�digo de cliente
		cTabel	 := Posicione("SA1",1,xFilial("SA1")+cCodCli,"A1_TABELA")

		//Retorna pre�o do produto
		nPreco   := Posicione("DA1",1,xFilial("DA1")+cTabel+cCodProd,"DA1_PRCVEN")

		//Tipo de Opera��o - Sempre 01
		cOper	 := "01"

		//Tipo OP - sempre F (Firme)
		cTipoOp	 := "F"

		_cNum	:= ""
		_cItem	:= ""
		_cProd  := ""

		aSc6	:= {}

		//Realiza query para encontrar registo da SC6 usando quantidade e datas
		cQuery := " SELECT * FROM " + RETSQLNAME("SC6") + "  SC6 "							+	CRLF
		cQuery += " INNER JOIN " + RETSQLNAME("SC5") + " SC5 ON SC5.C5_NUM = SC6.C6_NUM"	+	CRLF	
		cQuery += " WHERE SC6.D_E_L_E_T_ = '' "												+	CRLF
		cQuery += "	AND SC6.C6_ITEMPC = '"+ALLTRIM(aPrevisao[nX][6])+"'"					+	CRLF
		cQuery += "	AND SC6.C6_PRODUTO = '"+cCodProd+"'"									+	CRLF
		cQuery += "	AND SUBSTRING(SC6.C6_ENTREG,5,2) = '"+aPrevisao[nX][3]+"'"				+	CRLF
		//cQuery += "	AND SC6.C6_DATAEMB = '"+dData+"'"									+	CRLF //VERIFICAR
		//cQuery += "	AND SC6.C6_QTDVEN = "+aPrevisao[nX][2]+""							+	CRLF //PODE MUDAR
		cQuery += "	AND SC6.C6_OPER = '"+cOper+"'"											+	CRLF
		cQuery += "	AND SC6.C6_NUMPCOM = '"+ALLTRIM(aPrevisao[nX][5])+"'"					+	CRLF
		cQuery += "	AND SC6.C6_XPROD = '"+ALLTRIM(aPrevisao[nX][1])+"'"						+	CRLF
		cQuery += "	AND SC6.C6_TPOP = '"+cTipoOp+"'"										+	CRLF
		//cQuery += "	AND SC6.C6_ITEM = '01'"												+	CRLF
		cQuery += "	ORDER BY SC6.C6_ENTREG"													+	CRLF

		PLSQuery(cQuery, 'QUERYC6')
		DbSelectArea('QUERYC6')
		QUERYC6->(DbGoTop())

		While ! QUERYC6->(EoF())

			_cNum	:= QUERYC6->C5_NUM
			_cItem	:= QUERYC6->C6_ITEM
			_cProd  := QUERYC6->C6_PRODUTO
			_nQtd 	:= QUERYC6->C6_QTDVEN

			aAdd(aSc6,{_cNum,_cItem,_cProd,_nQtd})

			QUERYC6->(DbSkip()) 

		ENDDO

		QUERYC6->(dbCloseArea())
		
		/*DbSelectArea( 'SC5' )
		SC5->( DbSetorder(1) ) 

		DbSelectArea( 'SC6' )
		SC6->( DbSetorder(1) )*/ 
		
		if !empty(_cNum)

			lAltPed := .F.

			//C5_FILIAL + C5_NUM                  
			IF SC5->(dbSeek(xFilial("SC5")+_cNum)) //.or. !empty(_cNum)

				//ADICIONA CABE�ALHO
				aCabec 	:= {}
				//cNumPed	:= _cNum

				aadd(aCabec,{"C5_NUM"   		,SC5->C5_NUM							,Nil })
				aadd(aCabec,{"C5_TIPO" 			,"N"									,Nil })
				aadd(aCabec,{"C5_CLIENTE"		,substr(cCodCli,1,6)					,Nil })
				aadd(aCabec,{"C5_LOJACLI"		,substr(cCodCli,7,2)					,Nil })
				aadd(aCabec,{"C5_LOJAENT"		,substr(cCodCli,7,2)					,Nil })
				aadd(aCabec,{"C5_CONDPAG"		,cCondPag								,Nil })
				//aadd(aCabec,{"C5_MENNOTA"		,ALLTRIM(aPrevisao[nX][5])	+" "+  ALLTRIM(aPrevisao[nX][6]),Nil })

				//ADICIONA ITEM
				aLinha :={}
				aItem  := {}

				//Cria array com itens, sempre produtos iguais
				For nC6 := 1 to len(aMesItens)

					//s� faz no produto posicionado
					if ALLTRIM(aMesItens[nItem][1][7]) == aPrevisao[nX][1]

						nItem++

						//Verifica itens retornados da query
						For nQr := 1 to len(aSc6)

							aLinha :={}

							//s� faz no produto posicionado
							if ALLTRIM(aSc6[nQr][3]) == aPrevisao[nX][1]

								//C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
								if SC6->(dbSeek(xFilial("SC6")+aSc6[nQr][1]+aSc6[nQr][2]+aSc6[nQr][3])) 

									//Verifica se existe diferen�a
									IF SC6->C6_QTDVEN <> VAL(aMesItens[nItem][1][9]) .OR. SC6->C6_ENTREG <> CTOD(aMesItens[nItem][1][3])//.or. SC6->C6_VALOR <> (nPreco*aPrevisao[nX][2]) - VERIFICAR

										aadd(aLinha,{"LINPOS"			,"C6_ITEM"                              ,StrZero(nQr,2)})
										aadd(aLinha,{"AUTDELETA"		,"N"									, Nil})
										aadd(aLinha,{"C6_NUM"			,SC5->C5_NUM							, Nil})
										aadd(aLinha,{"C6_ITEM"			,_cItem									, Nil})
										aadd(aLinha,{"C6_ITEMPC"		,ALLTRIM(aPrevisao[nX][6])				, Nil})
										aadd(aLinha,{"C6_PRODUTO"		,cCodProd								, Nil})
										aadd(aLinha,{"C6_ENTREG"		,CTOD(aMesItens[nItem][1][3])			, Nil})	
										//aadd(aLinha,{"C6_DATAEMB"		,STOD(dData)							, Nil})
										aadd(aLinha,{"C6_QTDVEN"		,VAL(aMesItens[nItem][1][9])			, Nil})
										aadd(aLinha,{"C6_PRCVEN"		,nPreco									, Nil})
										aadd(aLinha,{"C6_VALOR"			,nPreco*VAL(aMesItens[nItem][1][9])		, Nil})
										aadd(aLinha,{"C6_OPER"			,cOper									, Nil})
										aadd(aLinha,{"C6_PRUNIT"		,nPreco									, Nil})
										aadd(aLinha,{"C6_NUMPCOM"		,ALLTRIM(aPrevisao[nX][5])				, Nil})
										aadd(aLinha,{"C6_XVLRLIQ"		,VAL(aMesItens[nItem][1][23])			, Nil})	
										aadd(aLinha,{"C6_XPROD"		    ,ALLTRIM(aPrevisao[nX][1])     			, Nil})
										aadd(aLinha,{"C6_TPOP"		    ,cTipoOp		      					, Nil})

										aadd(aItem,aLinha)

										lAltPed := .T.
									
									ELSE

										nItensInc++

									endif
							
								endif

							endif

						Next nQr
					
					ELSE

						LOOP
					
					endif
				
				Next nC6

				//Executa a altera��o do pedido
				IF lAltPed .and. len(aItem) > 0

					MSEXECAUTO({|x,y,z| MATA410(x,y,z)},aCabec,aItem,4,.F.)

					//RETORNA ERRO EM TELA COM MOTIVO
					If !lMsErroAuto

						//ALIMENTA ARRAY PARA ENVIO DE E-MAIL -> INCLUS�O
						//aAdd(aAlt,{cCodProd,StoD(dData),aPrevisao[nX][2]})//VERIFICAR

						nItensAlt++

						ConOut("Altera��o realizada com sucesso! MATA410")

						//confirmSX8()

					Else

						MostraErro()
						//aErro := GetAutoGRLog()
						cErro := "Nao foi possivel realizar altera��o"
						Conout( cErro )

						//Verifica se o c�digo do produto est� em branco
						if empty(cCodProd)

							cErro := "Produto n�o encontrado!"

						endif

						//aAdd(aAltErro,{cCodProd,StoD(dData),aPrevisao[nX][2],cErro})//VERIFICAR

						//rollBackSX8()

					EndIf
				
				ENDIF

			endif

		ELSE

			//ADICIONA CABE�ALHO
			aCabec 	:= {}
			cNumPed	:= GETSX8NUM('SC5','C5_NUM')	

			aadd(aCabec,{"C5_NUM"   		,cNumPed								,Nil })
			aadd(aCabec,{"C5_ZPEDJ"   		,"Sim"									,Nil })
			aadd(aCabec,{"C5_TIPO" 			,"N"									,Nil })
			aadd(aCabec,{"C5_CLIENTE"		,substr(cCodCli,1,6)					,Nil })
			aadd(aCabec,{"C5_LOJACLI"		,substr(cCodCli,7,2)					,Nil })
			aadd(aCabec,{"C5_LOJAENT"		,substr(cCodCli,7,2)					,Nil })
			aadd(aCabec,{"C5_CONDPAG"		,cCondPag								,Nil })
			aadd(aCabec,{"C5_MENNOTA"		,ALLTRIM(aPrevisao[nX][5])	+" "+  ALLTRIM(aPrevisao[nX][6]),Nil })


			//ADICIONA ITEM
			aLinha := {}
			aItem  := {}

			For nC6 := 1 to len(aMesItens)

				aLinha := {}

				//s� faz no produto posicionado
				if ALLTRIM(aMesItens[nC6][1][7]) == aPrevisao[nX][1]

					aadd(aLinha,{"C6_NUM"			,cNumPed								, Nil})
					aadd(aLinha,{"C6_ITEMPC"		,ALLTRIM(aPrevisao[nX][6])				, Nil})
					aadd(aLinha,{"C6_PRODUTO"		,cCodProd								, Nil})
					aadd(aLinha,{"C6_ENTREG"		,CTOD(aMesItens[nC6][1][3])				, Nil})	
					//aadd(aLinha,{"C6_DATAEMB"		,STOD(dData)							, Nil})
					aadd(aLinha,{"C6_QTDVEN"		,VAL(aMesItens[nC6][1][9])				, Nil})
					aadd(aLinha,{"C6_PRCVEN"		,nPreco									, Nil})
					aadd(aLinha,{"C6_VALOR"			,nPreco*VAL(aMesItens[nC6][1][9])		, Nil})
					aadd(aLinha,{"C6_OPER"			,cOper									, Nil})
					aadd(aLinha,{"C6_PRUNIT"		,nPreco									, Nil})
					aadd(aLinha,{"C6_NUMPCOM"		,ALLTRIM(aPrevisao[nX][5])				, Nil})
					aadd(aLinha,{"C6_XVLRLIQ"		,VAL(aMesItens[nC6][1][23])				, Nil})	
					aadd(aLinha,{"C6_XPROD"		    ,ALLTRIM(aPrevisao[nX][1])     			, Nil})
					aadd(aLinha,{"C6_TPOP"		    ,cTipoOp		      					, Nil})

					aadd(aItem,aLinha)

				ENDIF
			
			Next nC6

			if len(aItem) > 0

				//Executa a inclus�o do pedido
				MSEXECAUTO({|x,y,z| MATA410(x,y,z)},aCabec,aItem,3)

			ENDIF

			//RETORNA ERRO EM TELA COM MOTIVO
			If !lMsErroAuto

				//ALIMENTA ARRAY PARA ENVIO DE E-MAIL -> INCLUS�O
				//aAdd(aInc,{cCodProd,StoD(dData),aPrevisao[nX][2]})

				ConOut("Inclus�o realizada com sucesso! MATA410")

				//confirmSX8()

			Else

				MostraErro()
				//aErro := GetAutoGRLog()
				cErro := "Nao foi possivel realizar inclusao"
				Conout( cErro )

				//Verifica se o c�digo do produto est� em branco
				if empty(cCodProd)

					cErro := "Produto n�o encontrado!"

				endif

				//aAdd(aIncErro,{cCodProd,StoD(dData),aPrevisao[nX][2],cErro})

				//rollBackSX8()

			EndIf

		ENDIF

	Next nX

	IF nItensAlt > 0
		//MENSAGEM EM TELA DA QUANTIDADE QUE SOFREU ALTERA��O
		MSGALERT("Quantidade: "+ALLTRIM(cValToChar(nItensAlt)),"ATENCAO - PEDIDOS (com altera��o) !")
	endif

	if nItensInc > 0
		//MENSAGEM EM TELA DA QUANTIDADE QUE SOFREU ALTERA��O
		MSGALERT("Quantidade: "+ALLTRIM(cValToChar(nItensInc)),"ATENCAO - PEDIDOS (sem altera��o) !")
	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> ALTERA��O//VERIFICAR
	/*if len(aAlt) > 0

		U_NLEMAILJD(.F.,aAlt)

		MSGALERT("Lista de Previs�o alterada enviada por E-mail","ATENCAO (altera��o) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> INCLUS�O
	if len(aInc) > 0

		U_NLEMAILJD(.T.,aInc)

		MSGALERT("Lista de Previs�o inclu�da enviada por E-mail","ATENCAO (inlcus�o) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> ALTERA��O ERRO
	if len(aAltErro) > 0

		U_NLEMAILJD(.F.,aAltErro,1)

		MSGALERT("Lista de Previs�o alterada com erro enviada por E-mail","ATENCAO (altera��o com erro) !")

	endif

	//CHAMA ROTINA DE ENVIO DE E-MAIL AUTOM�TICO -> INCLUS�O ERRO
	if len(aIncErro) > 0

		U_NLEMAILJD(.T.,aIncErro,2)

		MSGALERT("Lista de Previs�o inclus�o com erro enviada por E-mail","ATENCAO (inclus�o com erro) !")

	endif*/

Return
