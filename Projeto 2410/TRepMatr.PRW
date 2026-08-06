//Bibliotecas
#Include "Totvs.ch"
#Define STR_PULA	Chr(13)+Chr(10)


/*/{Protheus.doc} User Function zRelator
Relatório Centro de Estrutura Simples Customizado - Padrão = MATR225
@author TIAGO DIAS
@since 14/07/2022
@version 1.0
@type function
/*/
//Highway1939! - roberto.c.lima@newleader.com
User Function tRepMatr()
	Local aArea     
	Local oReport
	Local aPergs 	as array   
    local aPar	 	as array	    
					
	Private aRetorno 	as array
	Private cCodComp
	Private cTipoComp
	Private cDescComp
	Private cUniComp
	Private nQtdComp
	Private cCodProd
	Private cDescProd
	Private cTipoProd
	Private cUniProd
	Private nQtdEstrut
	Private cUltForn	//D1_FORNECE
	Private nQtdUnit	//D1_VUNIT
	Private nUltCusto	//D1_QUANT/D1_CUSTO
	Private nTotStd	
	Private nTotCusto
	//Private cDescComp
	Private nValImp
	Private nValSem
	Private cNomeFor
	Private cCodForn
	Private dDtVal
	Private dDatFim

	aArea	:= FWGetArea()
	aPergs	:= {}
	aRetorno:= {}

	aPar	:= 	{;
			Space( TamSx3( "G1_COD" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "G1_COD" )[ 01 ] ),;
			Space( TamSx3( "B1_TIPO" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "B1_TIPO" )[ 01 ] ),;
			Space( TamSx3( "B1_GRUPO" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "B1_GRUPO" )[ 01 ] ),;
			CtoD( "01" + "/" + StrZero( Month( dDatabase ), 2 ) + "/" + Str( Year( dDatabase ) ) ),;
			Replicate( "Z" , TamSx3( "G1_FIM" )[ 01 ] ),;
			}

	//Adicionando os parametros do ParamBox
	Aadd(aPergs, {1, "Produto De"	, aPar[ 01 ], "", "", "SB1", ""		, 061, .F. })//B1_COD
	Aadd(aPergs, {1, "Produto Até"	, aPar[ 02 ], "", "", "SB1", ".T."		, 061, .F. })//B1_COD

	Aadd(aPergs, {1, "Tipo De"		, aPar[ 03 ], "", "", "", ""		, 061, .F. })//B1_TIPO
	Aadd(aPergs, {1, "Tipo Até"		, aPar[ 04 ], "", "", "", ".T."		, 061, .F. })//B1_TIPO
		
	Aadd(aPergs, {1, "Grupo De"		, aPar[ 05 ], "", "", "", ""		, 061, .F. })//B1_GRUPO
	Aadd(aPergs, {1, "Grupo Até"	, aPar[ 06 ], "", "", "", ".T."		, 061, .F. })//B1_GRUPO

	//Aadd(aPergs, {1, "Início Validade"	, aPar[ 07 ], "", "", "", ".T."	, 061, .F. })//G1_INI E G1_FIM
	//Aadd(aPergs, {1, "Fim Validade Até"		, aPar[ 08 ], "", "", "", ".T."	, 061, .F. })//G1_INI E G1_FIM
	
	//Se a pergunta for confirma, cria as definicoes do relatorio
	If ParamBox(aPergs, "Informe os parametros", @aRetorno)
		oReport := U_fReportDef(aRetorno)
		oReport:PrintDialog()
	EndIf
	
	FWRestArea(aArea)
Return

/*/{Protheus.doc} U_fReportDef
Definicoes do relatorio zRelator
@author TIAGO DIAS
@since 14/07/2022
@version 1.0
@type function
/*/

User Function fReportDef(aRetorno)

	Local oReport
	Local oSection
	Local oQuebra 
	Local nDevice	:= 4 //apenas excel

	oSection	:= Nil
	oQuebra		:= Nil
	
	//Criacao do componente de impressao
	oReport := TReport():New( "tRepMatr",;
		"Relatório de Produto X Componente",;
		,;
		{|oReport| U_fRepPrint(oReport, aRetorno),};
		)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	
	//Orientacao do Relatorio - paisagem
	oReport:SetLandscape()

	//oReport:SetPortrait() //Retrato
	oReport:SetDevice(nDevice)	//Excel
	
	//Criando a secao de dados
	oSection := TRSection():New(oReport,"Produto X Componente",{"SB1","SG1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	

	oSection:SetTotalInLine(.F.)
	
	//Colunas do relatorio
	TRCell():New(oSection,"COD"			,/*Tabela*/	,"Código Produto"			 ,PesqPict("SB1","B1_COD")		,TamSx3("B1_COD")[1]		,/*lPixel*/,{|| Alltrim(cCodProd)	})		// CODIGO DO PRODUTO
	TRCell():New(oSection,"DESC"		,/*Tabela*/ ,"Descrição Produto"		 ,PesqPict("SB1","B1_DESC")		,TamSx3("B1_DESC")[1]		,/*lPixel*/,{|| Alltrim(cDescProd)	})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"TIPO"		,/*Tabela*/	,"Tipo Produto"		 		 ,PesqPict("SB1","B1_TIPO")		,TamSx3("B1_TIPO")[1]		,/*lPixel*/,{|| Alltrim(cTipoProd)	})		// TIPO DO PRODUTO
	TRCell():New(oSection,"UM"			,/*Tabela*/	,"Unidade Produto"			 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniProd)  	})		// UNIDADE DO PRODUTO
	TRCell():New(oSection,"COD"			,/*Tabela*/ ,"Código Componente"		 ,PesqPict("SG1","G1_COMP")		,TamSx3("G1_COMP")[1]		,/*lPixel*/,{|| Alltrim(cCodComp)	})		// CODIGO DO PRODUTO
	TRCell():New(oSection,"TIPO"		,/*Tabela*/	,"Tipo Componente"	 	 	 ,PesqPict("SB1","B1_TIPO")		,TamSx3("B1_TIPO")[1]		,/*lPixel*/,{|| Alltrim(cTipoComp)	})		// TIPO DO PRODUTO
	TRCell():New(oSection,"DESC"		,/*Tabela*/	,"Descriçao Componente"		 ,PesqPict("SB1","B1_DESC")		,TamSx3("B1_DESC")[1]		,/*lPixel*/,{|| Alltrim(cDescComp)	})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"FORN"		,/*Tabela*/	,"Código Fornecedor"		 ,PesqPict("SA2","A2_COD")		,TamSx3("A2_COD")[1]		,/*lPixel*/,{|| Alltrim(cCodForn)	})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"DESFORN"		,/*Tabela*/	,"Descriçao Fornecedor"		 ,PesqPict("SA1","A2_NOME")		,TamSx3("A2_NOME")[1]		,/*lPixel*/,{|| Alltrim(cNomeFor)	})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"DESFORN"		,/*Tabela*/	,"Valor sem Imposto"		 ,PesqPict("SD1","D1_CUSTO")	,TamSx3("D1_CUSTO")[1]		,/*lPixel*/,{|| nValSem				})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"DESFORN"		,/*Tabela*/	,"Valor com Imposto"		 ,PesqPict("SD1","D1_CUSTO")	,TamSx3("D1_CUSTO")[1]		,/*lPixel*/,{|| nValImp				})		// DESCRIÇÃO DO PRODUTO
	TRCell():New(oSection,"QUANT"		,/*Tabela*/	,"Quantidade Componente"	 ,PesqPict("SG1","G1_QUANT")	,TamSx3("G1_QUANT")[1]		,/*lPixel*/,{|| nQtdComp			})		// QUANTIDADE
	TRCell():New(oSection,"UM"			,/*Tabela*/	,"Unidade Componente"		 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniComp)	})		// UNIDADE DO PRODUTO
	TRCell():New(oSection,"INIVAL"		,/*Tabela*/	,"Início Validade"		 	 ,PesqPict("SG1","G1_INI")		,TamSx3("G1_INI")[1]		,/*lPixel*/,{|| dDtVal				})		// UNIDADE DO PRODUTO
	TRCell():New(oSection,"FILVAL"		,/*Tabela*/	,"Fim Validade"		 		 ,PesqPict("SG1","G1_FIM")		,TamSx3("G1_FIM")[1]		,/*lPixel*/,{|| dDatFim				})		// UNIDADE DO PRODUTO

	//TRCell():New(oSection,"QP"			,/*Tabela*/	,"Quantidade Estrutura"		 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniComp)	})		// UNIDADE DO PRODUTO
	//TRCell():New(oSection,"ULTFORN"		,/*Tabela*/	,"Ultimo Fornecedor"		 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniComp)	})		// UNIDADE DO PRODUTO
	//TRCell():New(oSection,"ULTPRC"		,/*Tabela*/	,"Último Preço Liq."		 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniComp)	})		// UNIDADE DO PRODUTO
	//TRCell():New(oSection,"ULTPRC"		,/*Tabela*/	,"Último Preço Liq."		 ,PesqPict("SB1","B1_UM")		,TamSx3("B1_UM")[1]			,/*lPixel*/,{|| Alltrim(cUniComp)	})		// UNIDADE DO PRODUTO

	//Quebras do relatorio
	//oQuebra := TRBreak():New(oSection, oSection:Cell("B1_COD"), {||"Quebra por PRODUTO"}, .F.)
	
	//Totalizadores
	//TRFunction():New(oSection:Cell("C7_EMISSAO"), , "COUNT", oQuebra, , "@!", , .F.)
	
Return oReport

/*/{Protheus.doc} U_fRepPrint
Impressao do relatorio zRelator
@author TIAGO DIAS
@since 14/07/2022
@version 1.0
@type function
/*/

User Function fRepPrint(oReport, aRetorno)
	//PARÂMETRO
	Local cProdDe 	:= aRetorno[1]
	Local cProdAte 	:= aRetorno[2]
	Local cTipoDe 	:= aRetorno[3]
	Local cTipoAte 	:= aRetorno[4]
	Local cGrupoDe 	:= aRetorno[5]
	Local cGrupoAte := aRetorno[6]
	//Local dDataRef 	:= aRetorno[7]
	//Local dDataRefA := DTOS(aRetorno[8])

	//QUERY
	Local cQuery 	:= ""
	Local cQueryD1 	:= ""
	Local nTotal	:= 0
	Local nAtual	:= 0
	Local nSD1 		:= 0

	//Pegando as secoes do relatorio
	oSecao := oReport:Section(1)

	//QUERY RETORNA TODOS OS ITENS DA SB1 QUE CONTEM SG1
	cQuery := "SELECT "											+ STR_PULA
		cQuery += "B1_COD,"										+ STR_PULA
		cQuery += "B1_DESC,"									+ STR_PULA
		cQuery += "B1_TIPO,"									+ STR_PULA
		cQuery += "B1_UM,"										+ STR_PULA
		cQuery += "G1_COMP,"									+ STR_PULA
		cQuery += "G1_INI,"										+ STR_PULA
		cQuery += "G1_FIM,"										+ STR_PULA
		cQuery += "G1_QUANT"									+ STR_PULA
	cQuery += "FROM SB1010 SB1 (NOLOCK)"						+ STR_PULA
		cQuery += "INNER JOIN SG1010 SG1 ON (SG1.G1_COD = SB1.B1_COD)"	+ STR_PULA
	cQuery += "WHERE SB1.D_E_L_E_T_ =''"						+ STR_PULA
	cQuery += "AND SG1.D_E_L_E_T_ =''"							+ STR_PULA

	//FILTROS
	//PRODUTO
	cQuery  += " AND B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' "+ STR_PULA
	//TIPO
	cQuery  += " AND B1_TIPO BETWEEN '"+cTipoDe+"' AND '"+cTipoAte+"' "+ STR_PULA
	//GRUPO
	cQuery  += " AND B1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"' "+ STR_PULA
	
	//DATA REFERENCIA
	//if ! empty(dDataRef)
		//cQuery  += " AND G1_INI >= '"+DTOS(dDataRef)+"' "					+ STR_PULA
	//endif
	//cQuery  += " AND G1_FIM <= '"+dDataRefA+"' "				+ STR_PULA

	cQuery += "ORDER BY B1_COD"									+ STR_PULA
	
	//Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_REP")//AKK28830 -> 584 / nao trazer componente tipo GG
	DbSelectArea("QRY_REP")
	Count to nTotal
	oReport:SetMeter(nTotal)

	//Posiciona para pegar informações de componente
	SB1->(dbSetOrder(1))
	SB1->(DbGotop())
	
	//Enquanto houver dados
	oSecao:Init()
	QRY_REP->(DbGoTop())
	While ! QRY_REP->(Eof()) //.and. nAtual < 1000

		cCodProd  	:= QRY_REP->B1_COD
		cDescProd 	:= QRY_REP->B1_DESC
		cCodComp  	:= QRY_REP->G1_COMP
		cTipoProd 	:= QRY_REP->B1_TIPO
		cUniProd	:= QRY_REP->B1_UM
		nQtdComp	:= QRY_REP->G1_QUANT
		dDtVal		:= DTOS(QRY_REP->G1_INI)
		dDatFim		:= DTOS(QRY_REP->G1_FIM)

		//QUERY PARA RETORNAR ULTIMO REGISTRO DA SD1 DO COMPONENTE (COMPRA DO PRODUTO)
		cQueryD1 := " SELECT "											+ STR_PULA
			//cQueryD1 += "D1_FORNECE,"									+ STR_PULA
			//cQueryD1 += "D1_QUANT,"									+ STR_PULA
			//cQueryD1 += "D1_VUNIT,"									+ STR_PULA
			//cQueryD1 += "D1_CUSTO"									+ STR_PULA
			cQueryD1 += "* "											+ STR_PULA
		cQueryD1 += " FROM SD1010 SD1 (NOLOCK)"							+ STR_PULA
			cQueryD1 += "WHERE SD1.D_E_L_E_T_ =''"						+ STR_PULA
			cQueryD1 += "AND SD1.D1_COD='"+cCodComp+"'"					+ STR_PULA
			cQueryD1 += "ORDER BY D1_DTDIGIT DESC"						+ STR_PULA

		PlsQuery(cQueryD1, "QRY_SD1")
		DbSelectArea("QRY_SD1")
		Count to nSD1

		QRY_SD1->(DbGoTop())
		While ! QRY_SD1->(Eof())

			nValImp  := QRY_SD1->D1_VUNIT

			nValSem  := (QRY_SD1->D1_CUSTO/QRY_SD1->D1_QUANT)

			cCodForn := ALLTRIM(QRY_SD1->D1_FORNECE)

			IF SB1->(dbSeek(xFilial("SB1") + QRY_SD1->D1_COD))

				cDescComp 	:= ALLTRIM(SB1->B1_DESC)
				cTipoComp 	:= ALLTRIM(SB1->B1_TIPO)
				cUniComp 	:= ALLTRIM(SB1->B1_UM)

			ENDIF

			//POSICIONA NA SD1
			//A2_FILIAL + A2_COD + A2_LOJA
			IF SA2->(dbSeek(xFilial("SA2") + QRY_SD1->D1_FORNECE + QRY_SD1->D1_LOJA))

				cNomeFor := ALLTRIM(SA2->A2_NOME)
				
			ENDIF

			EXIT

		EndDo

		QRY_SD1->(DbCloseArea())

		//Incrementando a regua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSecao:PrintLine()

		QRY_REP->(DbSkip())

	EndDo

	oSecao:Finish()
	QRY_REP->(DbCloseArea())
	
	//FWRestArea(aArea)

Return

/*SELECT 
B1_COD,
B1_DESC,
B1_TIPO,
B1_UM,
G1_COMP,
G1_INI,
G1_FIM,
G1_QUANT
FROM SB1010 SB1 (NOLOCK)
INNER JOIN SG1010 SG1 ON (SG1.G1_COD = SB1.B1_COD)
WHERE SB1.D_E_L_E_T_ =''
AND SG1.D_E_L_E_T_ =''
 AND B1_COD BETWEEN '               ' AND 'ZZZZZZZZZZZZZZZ' 
 AND B1_TIPO BETWEEN '  ' AND 'ZZ' 
 AND B1_GRUPO BETWEEN '    ' AND 'ZZZZ' 
 AND G1_INI >= '20230901' 
ORDER BY B1_COD
