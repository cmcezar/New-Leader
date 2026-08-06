#INCLUDE "Protheus.ch"                                      
#INCLUDE "TbiConn.ch"   
#include "report.ch" 
#Include "Topconn.ch"
#INCLUDE "rwmake.ch"

STATIC lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTR02   บ Autor ณ MARCIO COSTA       บ Data ณ 22/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Producao com Impostos                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function RESTR02() 

Local oReport
			
oReport := ImpRel()

If oReport <> Nil
	oReport:PrintDialog()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTR02   บ Autor ณ MARCIO COSTA       บ Data ณ 21/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Estrura de Producao com Impostos                 ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpRel()

Local cPerg		:= "RESTR02   "
Local cTitulo 	:= "REPORT ESTRUTURA COSTS "	
Local cDesc1 	:= "Este Relat๓rio irแ imprimir Estrutura de Produtos com Impostos"
Local oRelat
Local aOrdem    := {}

ValidPerg(cPerg)
Pergunte(cPerg,.F.)

oReport := TReport():New("RESTR02",cTitulo,cPerg,{|oReport| fR42Print(oReport,cTitulo)},cDesc1)
oReport:DisableOrientation()
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

TReport():SetTitle( cTitulo ) 
			 	
oRelat := TRSection():New(oReport,cTitulo,{"SG1"},aOrdem,,,,,,,,,,,,.F. )  

TRCell():New(oRelat,"PRODUTO",,"PRODUTO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"DESCRICAO",,"DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"UNIDMED",,"U.M.",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"GRUPO",,"GRUPO",PesqPict("SB1","B1_GRUPO"),TamSX3("B1_GRUPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"TIPO",,"TIPO",PesqPict("SB1","B1_TIPO"),TamSX3("B1_TIPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"FANTASMA",,"FANTASMA",,8,/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"NECESSID",,"NECESSIDADE",,11,/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"PARENT",,"PARENT ITEM",PesqPict("SB1","B1_TIPO"),TamSX3("B1_TIPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,'NIVEL'		,,"NIVEL",/*Picture*/					,03			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,'QTDITEM'	,,"QUANTIDADE",PesqPict('SG1','G1_QUANT'),TamSX3("G1_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oRelat,'QUANT'		,,"QUANTIDADE",PesqPict('SG1','G1_QUANT'),TamSX3("G1_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oRelat,'QTDBASE'	,,"QTD.BASE",PesqPict('SB1','B1_QB'),TamSX3("B1_QB")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oRelat,"CUSTO",,"CUSTO"+CRLF+"UNITARIO",PesqPict("SB2","B2_CM1"),TamSX3("B2_CM1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"CUSTOT",,"CUSTO"+CRLF+"TOTAL",PesqPict("SB2","B2_VATU1"),TamSX3("B2_VATU1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"ALIQ_ICM",,"% MEDIO"+CRLF+"ICMS",PesqPict("SD2","D2_PICM"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ICMS",,"VALOR MEDIO"+CRLF+"ICMS",PesqPict("SD2","D2_VALICM"),TamSX3("D2_VALICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_IPI",,"% MEDIO"+CRLF+"IPI",PesqPict("SD2","D2_IPI"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"IPI",,"VALOR MEDIO"+CRLF+"IPI",PesqPict("SD2","D2_VALIPI"),TamSX3("D2_VALIPI")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_PIS",,"% MEDIO"+CRLF+"PIS",PesqPict("SD2","D2_ALQIMP6"),TamSX3("D2_ALQIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"PIS",,"VALOR MEDIO"+CRLF+"PIS",PesqPict("SD2","D2_VALIMP6"),TamSX3("D2_VALIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_COF",,"% MEDIO"+CRLF+"COFINS",PesqPict("SD2","D2_ALQIMP5"),TamSX3("D2_ALQIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"COF",,"VALOR MEDIO"+CRLF+"COFINS",PesqPict("SD2","D2_VALIMP5"),TamSX3("D2_VALIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"TOTALG",,"TOTAL CUSTO"+CRLF+"C/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")


oRelat:SetHeaderPage()
oRelat:SetHeaderBreak()
oRelat:SetReadOnly()
oRelat:SetTotalInLine(.F.)
	
Return oReport 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfR42Print  บ Autor ณ MARCIO COSTA       บ Data ณ 21/04/2026 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ IMPRESSAO DO RELATORIO                                     ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fR42Print(oReport,cTitulo)

Local oRelat  := oReport:Section(1)

Local cProduto 	:= ""
Local lDatRef   := !Empty(MV_PAR04)
Local nNivel   	:= 0
Local cAlias := "TRBX"
Local nCusto := 0

Local nIcm  := 0
Local nIpi  := 0
Local nPis  := 0
Local nCof  := 0
Local nTotI := 0

Private aMopc := {}
Private cOpcDft := ""
Private lNegEstr:=GETMV("MV_NEGESTR")

Private aArqTrab := {}

AAdd(aArqTrab, {"TIPO"	    	, "C"	,TamSX3("B1_TIPO")[1]	, 0	})
AAdd(aArqTrab, {"NECESSID"		, "C"	,TamSX3("B1_PRODSBP")[1], 0	})
AAdd(aArqTrab, {"PARENT"		, "C"	,TamSX3("B1_COD")[1]	, 0	})
AAdd(aArqTrab, {"PRODUTO"		, "C"	,TamSX3("B1_COD")[1]	, 0	})
AAdd(aArqTrab, {"DESCRICAO"		, "C"	,TamSX3("B1_DESC")[1]	, 0	})
AAdd(aArqTrab, {"LOCPAD"		, "C"	,TamSX3("B1_LOCPAD")[1]	, 0	})
AAdd(aArqTrab, {"UNIDMED"		, "C"	,TamSX3("B1_UM")[1]		, 0	})
AAdd(aArqTrab, {"FANTASMA"		, "C"	,TamSX3("B1_FANTASM")[1], 0	})
AAdd(aArqTrab, {"GRUPO"			, "C"	,TamSX3("B1_GRUPO")[1]	, 0	})
AAdd(aArqTrab, {"NIVEL"			, "N"	,3						, 0	})
AAdd(aArqTrab, {"QTDITEM"		, "N"	,TamSX3("G1_QUANT")[1]	, 4	})
AAdd(aArqTrab, {"QUANT"			, "N"	,TamSX3("G1_QUANT")[1]	, 4	})
AAdd(aArqTrab, {"QTDBASE"		, "N"	,TamSX3("B1_QB")[1]		, 4	})

If SELECT(cAlias) > 0
	(cAlias)->( dbCloseArea() )
EndIf 

//Cria a temporแria
oTempTable := FWTemporaryTable():New(cAlias)
//Define as colunas usadas
oTempTable:SetFields( aArqTrab )
 //Efetua a cria็ใo da tabela
oTempTable:Create()


dbSelectArea("SG1")
dbSetOrder(1)
If dbSeek(xFilial("SG1") + MV_PAR01)

	While !Eof() .And. SG1->G1_FILIAL + SG1->G1_COD == xFilial("SG1")+ MV_PAR01

		//Valida a data de validade da estrutura, se o pergunte 04 estiver preenchido.
		If lDatRef .And. (SG1->G1_INI > MV_PAR04 .Or. SG1->G1_FIM < MV_PAR04)
			SG1->(dbSkip())
			Loop
		EndIf

		cProduto := SG1->G1_COD
		nNivel   := 2
		
		dbSelectArea("SB1")
		aAreaSG1:=GetArea("SG1")
	
		dbSeek(xFilial("SB1") + cProduto)
		
		If !Empty(MV_PAR02)			
		
			cRevEst := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )

			If cRevEst < mv_par08																				
		
				Restarea(aAreaSG1)
		
				While cProduto == SG1->G1_COD
					SG1->(dbSkip())
					IncRegua()			
				End
				Loop			
			EndIf
		EndIf
	
		dbSelectArea("SB1")
		
		RecLock(cAlias,.T.)

			(cAlias)->PRODUTO   := cProduto
			(cAlias)->DESCRICAO := SB1->B1_DESC
			(cAlias)->TIPO		:= SB1->B1_TIPO
			(cAlias)->GRUPO		:= SB1->B1_GRUPO
			(cAlias)->UNIDMED	:= SB1->B1_UM
			(cAlias)->QTDBASE	:= If(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB"))
			(cAlias)->QTDITEM	:= If(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB"))
			(cAlias)->NIVEL		:= 1
			(cAlias)->NECESSID	:= SB1->B1_PRODSBP
			(cAlias)->LOCPAD	:= SB1->B1_LOCPAD
			(cAlias)->FANTASMA	:= SB1->B1_FANTASM
		
		MsUnLock()

		MR225Expl(cProduto,IF(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB")),nNivel,IF(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB")),If(Empty(MV_PAR02),Iif(lPCPREVATU, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),MV_PAR02),cAlias)
		
		dbSelectArea("SG1")
		dbSkip()
	EndDo
Else

	Aviso("Aten็ใo","Produto nใo possui estrutura cadastrada !")

Endif

dbSelectArea(cAlias)
dbGoTop()

oRelat:Init()

Do While !oReport:Cancel() .And. (cAlias)->(!Eof()) 

	oReport:IncMeter()
	
	oRelat:Cell("PRODUTO"):SetValue((cAlias)->PRODUTO)
	oRelat:Cell("DESCRICAO"):SetValue((cAlias)->DESCRICAO)
	oRelat:Cell("UNIDMED"):SetValue((cAlias)->UNIDMED)
	oRelat:Cell("GRUPO"):SetValue((cAlias)->GRUPO)
	oRelat:Cell("TIPO"):SetValue((cAlias)->TIPO)
	oRelat:Cell("FANTASMA"):SetValue(IIF((cAlias)->FANTASMA == "S", "Sim", "Nao"))

	oRelat:Cell("PARENT"):SetValue((cAlias)->PARENT)
	oRelat:Cell("NECESSID"):SetValue(IIf((cAlias)->NECESSID == "P", "Produzido","Comprado"))

	oRelat:Cell("NIVEL"):SetValue(StrZero((cAlias)->NIVEL,3))

	oRelat:Cell("QTDITEM"):SetValue((cAlias)->QTDITEM)
	//oRelat:Cell("QUANT"):SetValue((cAlias)->QUANT)
	//oRelat:Cell("QTDBASE"):SetValue((cAlias)->QTDBASE)

	nCusto := BuscaCus((cAlias)->PRODUTO)
    
	aImposto := {}
	If (cAlias)->NECESSID == "P"
		//aImposto := BuscaImpS((cAlias)->PRODUTO)  //Produto Produzido
		aImposto := {0,0,0,0}  //Produto Produzido
	else
		aImposto := BuscaImpE((cAlias)->PRODUTO)  //Produto Comprado
	Endif
	
	nIcm  := nCusto * (aImposto[1] / 100)
    nIpi  := nCusto * (aImposto[2] / 100)
    nPis  := nCusto * (aImposto[3] / 100)
    nCof  := nCusto * (aImposto[4] / 100)
    nTotI := nCusto + nIPI + nIcm + nPis + nCof

	oRelat:Cell("CUSTO"):SetValue(nCusto)
	oRelat:Cell("CUSTOT"):SetValue(Round(nCusto * (cAlias)->QTDITEM,4))

	oRelat:Cell("ALIQ_ICM"):SetValue(aImposto[1])
	oRelat:Cell("ICMS"):SetValue(nIcm)
	oRelat:Cell("ALIQ_IPI"):SetValue(aImposto[2])
	oRelat:Cell("IPI"):SetValue(nIpi)
	oRelat:Cell("ALIQ_PIS"):SetValue(aImposto[3])
	oRelat:Cell("PIS"):SetValue(nPis)
	oRelat:Cell("ALIQ_COF"):SetValue(aImposto[4])
	oRelat:Cell("COF"):SetValue(nCof)
	oRelat:Cell("TOTALG"):SetValue(nTotI)

	oRelat:PrintLine()

	dbSelectArea(cAlias)
	dbSkip()

EndDo

oRelat:Finish()	

(cAlias)->(dbCloseArea())

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณVALIDPERG ณ Autor ณ  Luiz Carlos Vieira	ณ Data ณ 03/07/97   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica as perguntas incluindo-as caso nao existam		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ                            					                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg(cPerg)

Local nLoop1
Local nLoop2
Local cLAlias := Alias()
Local aRegs   := {}

AADD(aRegs,{PADR(cPerg,10),"01","Produto                 ?",".",".","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"02","Revisao da Estrutura    ?",".",".","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"03","Imprime ate o Nivel     ?",".",".","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Data Referencia Custo   ?",".",".","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"05","Nro.Dias p/Base Impostos?",".",".","mv_ch5","N",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualizacao do SX1 com os parametros criadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX1")
dbSetorder(1)
For nLoop1 := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[nLoop1,2])
		RecLock("SX1",.T.)
		For nLoop2 := 1 to FCount()
			FieldPut(nLoop2,aRegs[nLoop1,nLoop2])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorna ambiente originalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cLAlias)

Return


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o   ณMR225Expl ณ Autor ณ Eveli Morasco         ณ Data ณ 08/09/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…oณ Faz a explosao de uma estrutura                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ MR225Expl(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpC4,ExpN3)       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo do produto a ser explodido                  ณฑฑ
ฑฑณ          ณ ExpN1 = Quantidade do pai a ser explodida                  ณฑฑ
ฑฑณ          ณ ExpN2 = Nivel a ser impresso                               ณฑฑ
ฑฑณ          ณ ExpC2 = Picture da quantidade                              ณฑฑ
ฑฑณ          ณ ExpC3 = Picture da perda                                   ณฑฑ
ฑฑณ          ณ ExpC4 = Opcionais do produto                               ณฑฑ
ฑฑณ          ณ ExpN3 = Quantidade do Produto Nivel Anterior               ณฑฑ
ฑฑณ          ณ As outras 6 variaveis sao utilizadas pela funcao Cabec     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Static Function MR225Expl(cProduto,nQuantPai,nNivel,nQtdBase,cRevisao,cAlias)

LOCAL nReg,nQuantItem := 0
LOCAL cAteNiv   := If(MV_PAR03=Space(3),"999",MV_PAR03) 
LOCAL cRevEst	:= ''
Local lDatRef  := !Empty(MV_PAR04)
Local lVlOpc      := .T.

dbSelectArea("SG1")

While !Eof() .And. SG1->G1_FILIAL + SG1->G1_COD == xFilial("SG1") + cProduto
	
	nReg := Recno()
	
	nQuantItem := xExplEstr(nQuantPai,Iif(lDatRef,MV_PAR04,Nil),,cRevisao,,,,,,,,lDatRef,lVlOpc)

	dbSelectArea("SG1")
	
	If nNivel <= Val(cAteNiv) // Verifica ate qual Nivel devera ser impresso
		If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))
			
			
			SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))  
			
			RecLock(cAlias,.T.)
				(cAlias)->PRODUTO    := SG1->G1_COMP
				(cAlias)->DESCRICAO  := SB1->B1_DESC
				(cAlias)->TIPO		 := SB1->B1_TIPO
				(cAlias)->GRUPO		 := SB1->B1_GRUPO
				(cAlias)->UNIDMED	 := SB1->B1_UM
				(cAlias)->PARENT     := SG1->G1_COD
				(cAlias)->NECESSID	 := SB1->B1_PRODSBP

				(cAlias)->QTDITEM	 := nQuantItem
				(cAlias)->QUANT		 := SG1->G1_QUANT
				(cAlias)->QTDBASE	 := If(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB"))
				(cAlias)->NIVEL		 := nNivel
				(cAlias)->LOCPAD	 := SB1->B1_LOCPAD
				(cAlias)->FANTASMA   := SB1->B1_FANTASM

			MsUnLock()				
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se existe sub-estrutura                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SG1")
			dbSeek(xFilial("SG1")+SG1->G1_COMP)
			
			cRevEst := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )
			
			If Found()
				MR225Expl(SG1->G1_COD,nQuantItem,nNivel+1,IF(RetFldProd(SB1->B1_COD,"B1_QB")==0,1,RetFldProd(SB1->B1_COD,"B1_QB")),If(!Empty(cRevEst),cRevEst,MV_PAR02),cAlias)
			EndIf
			dbGoto(nReg)
		EndIf
	EndIf
	dbSkip()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ExplEstr ณ Autor ณ Eveli Morasco         ณ Data ณ 20/08/92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula a quantidade usada de um componente da estrutura   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpN1 := ExplEstr(ExpN2,ExpD1,ExpC1,ExpC2)                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 = Quantidade utilizada pelo componente               ณฑฑ
ฑฑณ          ณ ExpD1 = Data para validacao do componente na estrutura     ณฑฑ
ฑฑณ          ณ ExpC1 = String contendo os opcionais utilizados            ณฑฑ
ฑฑณ          ณ ExpC2 = Revisao da estrutura utilizada                     ณฑฑ
ฑฑณ          ณ ExpN2 = Variavel com valor numerico que justifica o motivo ณฑฑ
ฑฑณ          ณ         pelo qual a quantidade esta zerada.                ณฑฑ
ฑฑณ          ณ         1 - Componente fora das datas inicio / fim         ณฑฑ
ฑฑณ          ณ         2 - Componente fora dos grupos de opcionais        ณฑฑ
ฑฑณ          ณ         3 - Componente fora das revisoes                   ณฑฑ
ฑฑณ          ณ ExpL1 = Indica se processa preestrutura                    ณฑฑ
ฑฑณ          ณ ExpL2 = Indica se processa o tipo de decimais da OP        ณฑฑ
ฑฑณ          ณ ExpC3 = Alias da tabela SG1                                ณฑฑ
ฑฑณ          ณ ExpC4 = Alias da tabela SB1                                ณฑฑ
ฑฑณ          ณ ExpL3 = Indica de foi chamado do MRP                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xExplEstr(nQuant,dDataStru,cOpcionais,cRevisao,nMotivo,lPreEstr,lTipoDec,cAliasSG1,cAliasSB1,lMRP,cProOpc,lVldData,lVlOpc,lProBlq)

LOCAL nQuantItem:=0,cUnidMod,nG1Quant:=0,nQBase:=0,nDecimal:=0,nBack:=0
LOCAL cAlias1:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
LOCAL lOk:=.T.
LOCAL nDecOrig:=Set(3,8)
LOCAL cCodigo
LOCAL cComponente
LOCAL cOpcArq
LOCAL dDataIni
LOCAL dDataFim
LOCAL nQtdCampo
LOCAL nQtdPerda
LOCAL cFixVar
LOCAL cTRT
LOCAL aVldEstr := {.T.,.T.,.T.} //na ordem, indica se valida datas, grupo de opc. e revisoes na estrutura
LOCAL aUsrVlEstr := {}
LOCAL aOpc := Nil
LOCAL nI        := 0
LOCAL nAltPer   := 0
LOCAL lAchouB1  := .F.
Local lTemQBP   := TemQBP()
Local lUsaMOpc	:= If(SuperGetMv('MV_REPGOPC',.F.,"N") == "S",.T.,.F.)
Local lProdMod  := .T.
Local lPCPREVATU	:= FindFunction('PCPREVATU')  
Local cRevAtu		:= ''

STATIC lUSRVLESTR
STATIC lMQTBASEST
STATIC lMQTDESTR
STATIC nDecSGG
STATIC nDecSG1

DEFAULT nMotivo	    := 0
DEFAULT lPreEstr	:= .F.
DEFAULT lTipoDec	:= .T.
DEFAULT cAliasSG1	:= "SG1"
DEFAULT cAliasSB1	:= "SB1"
DEFAULT lMRP		:= .F.
DEFAULT cProOpc     := ""
DEFAULT lVldData := .T.
DEFAULT lVlOpc   := .T.
DEFAULT lProBlq  := .T. // Considera se o Produto estแ bloqueado.

cCodigo    :=If(lPreEstr,SGG->GG_COD,(cAliasSG1)->G1_COD)
cComponente:=If(lPreEstr,SGG->GG_COMP,(cAliasSG1)->G1_COMP)
cOpcArq    :=If(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,(cAliasSG1)->G1_GROPC+(cAliasSG1)->G1_OPC)
cOpcArq    :=If(lUsaMOpc .And. !Empty(cProOpc) .And. !Empty(cOpcArq), cProOpc, cOpcArq)
nG1Quant   :=If(lPreEstr,SGG->GG_QUANT,(cAliasSG1)->G1_QUANT)
nQtdCampo  :=If(lPreEstr,SGG->GG_QUANT,(cAliasSG1)->G1_QUANT)
nQtdPerda  :=If(lPreEstr,SGG->GG_PERDA,(cAliasSG1)->G1_PERDA)
cFixVar    :=If(lPreEstr,SGG->GG_FIXVAR,(cAliasSG1)->G1_FIXVAR)
cTRT       :=If(lPreEstr,SGG->GG_TRT,(cAliasSG1)->G1_TRT)
lUSRVLESTR	 := IIF(lUSRVLESTR == Nil,ExistBlock('USRVLESTR'),lUSRVLESTR)
lMQTBASEST	 := IIF(lMQTBASEST == Nil,ExistBlock('MQTBASEST'),lMQTBASEST)
lMQTDESTR	 := IIF(lMQTDESTR  == Nil,ExistBlock('MQTDESTR'),lMQTDESTR)
nDecSGG	 := IIF(nDecSGG    == Nil,TamSX3("GG_QUANT")[2],nDecSGG)
nDecSG1	 := IIF(nDecSG1    == Nil,TamSX3("G1_QUANT")[2],nDecSG1)

If lMRP
	dDataIni   :=If(lPreEstr,SGG->GG_INI,Stod((cAliasSG1)->G1_INI))
	dDataFim   :=If(lPreEstr,SGG->GG_FIM,Stod((cAliasSG1)->G1_FIM))
Else
	dDataIni   :=If(lPreEstr,SGG->GG_INI,(cAliasSG1)->G1_INI)
	dDataFim   :=If(lPreEstr,SGG->GG_FIM,(cAliasSG1)->G1_FIM)
EndIf

If lPreEstr
	nDecimal:=nDecSGG
Else
	nDecimal:=nDecSG1
EndIf

//Verifica os opcionais cadastrados na Estrutura
cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

If (aOpc := Str2Array(cOpcionais,.F.)) != Nil
	cOpcArq := cProOpc
EndIf

//Verifica a Revisao Atual do Componente
cRevisao:= If((cRevisao == NIL),"",cRevisao)

//Verifica a data de validade
dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)

If lUSRVLESTR
	//Posiciona na SG1 para PE
	If lMRP
		dbSelectArea("SG1")
		MsSeek(xFilial("SG1")+cCodigo)
	EndIf

	aUsrVlEstr := ExecBlock("USRVLESTR",.F.,.F.,{cCodigo,cComponente,cTRT})

	For nI := 1 To 3
		If ValType(aUsrVlEstr[nI]) == "L"
			aVldEstr[nI] := aUsrVlEstr[nI]
		EndIf
	Next nI
EndIf

If lMRP
	lAchouB1 := .T.
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	lAchouB1 := MsSeek(xFilial("SB1")+cCodigo)
EndIf

If lAchouB1
	If Empty(cOpcionais) .And. !Empty(RetFldProd((cAliasSB1)->B1_COD,"B1_OPC",cAliasSB1))
		cOpcionais:=RetFldProd((cAliasSB1)->B1_COD,"B1_OPC",cAliasSB1)
	EndIf
	//Altera็ใo para considerar REV por filial 
	cRevAtu :=  IIF(lPCPREVATU , PCPREVATU((cAliasSB1)->B1_COD), (cAliasSB1)->B1_REVATU)
	If Empty(cRevisao) .And. !Empty(cRevAtu)
		cRevisao:= cRevAtu
	EndIf
	If aVldEstr[1] .And. !(dDataStru >= dDataIni .And. dDataStru <= dDataFim) .And. lVldData
		nMotivo:=1 // Componente fora das datas inicio / fim
		lOk:=.F.
	EndIf
	If aVldEstr[2] .And. lOk .And. !Empty(cOpcionais) .And. !Empty(cOpcArq) .And. !(cOpcArq $ cOpcionais) .And. lVlOpc
		nMotivo:=2  // Componente fora dos grupos de opcionais
		lOk:=.F.
	EndIf
	If aVldEstr[3] .And. lOk .And. !lPreEstr .And. !Empty(cRevisao) .And. ((cAliasSG1)->G1_REVINI > cRevisao .Or. (cAliasSG1)->G1_REVFIM < cRevisao)
		nMotivo:=3	// Componente fora das revisoes
		lOk:=.F.
	EndIf
EndIf

If !lMRP .And. cAlias1 <> ''
	dbSelectArea(cAlias1)
	dbSetOrder(nOrder)
	MsGoto(nRecno)
EndIf

If lOk
	cUnidMod := SuperGetMv("MV_UNIDMOD")

	SB1->(MsSeek(xFilial("SB1")+cCodigo))
	nQBase:=RetFldProd(cCodigo,If(lPreEstr.And.lTemQBP,"B1_QBP","B1_QB"))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ponto de Entrada p/ alterar qtde. base da estrutura    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMQTBASEST
		nAltPer:=ExecBlock('MQTBASEST', .F., .F., {nQBase})
		IF Valtype(nAltPer) == 'N'
			nQBase := nAltPer
		EndIf
	EndIf

	If !lMRP
		IF lProBlq
			SB1->(MsSeek(xFilial("SB1")+cComponente))
			IF ((RetFldProd(SB1->B1_COD,"B1_FANTASM") != 'S') .and. (SB1->B1_MSBLQL == '1'))
				nQuantItem := 0
				lOk := .F.
			EndIf

			IF SB1->B1_MSBLQL == '1'
				nQuantItem := 0
				lOk := .F.
			END IF

		EndIf
	EndIf

	If lOk
		lProdMod := IsProdMod(cComponente)

		If lProdMod
			cTpHr := SuperGetMv("MV_TPHR")
			If cTpHr == "N"
				nG1Quant := Int(nG1Quant)
				nG1Quant += ((nQtdCampo-nG1Quant)/60)*100
			EndIf
		EndIf

		If cFixVar $ " V"
			If lProdMod .And. cUnidMOD != "H"
				nQuantItem := ((nQuant / nG1Quant) / (100 - nQtdPerda)) * 100
			Else
				nQuantItem := ((nQuant * nG1Quant) / (100 - nQtdPerda)) * 100
			EndIf
			nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
		Else
			If lProdMod .And. cUnidMOD != "H"
				nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
			Else
				nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
			EndIf
		Endif

	EndIf
	nQuantItem:=Round(nQuantItem,nDecimal)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada p/ alterar qtde. do componente        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lMQTDESTR
	nAltPer:=ExecBlock('MQTDESTR', .F., .F., {nQuant,nQuantItem,lOk,nMotivo,cOpcArq,cOpcionais})
	If Valtype (nAltPer) == 'N'
		nQuantItem:= nAltPer
	EndIf
EndIf

//vai ser calculado no proprio MATA712
If !lMRP
	Do Case
		Case (SB1->B1_TIPODEC == "A" .And. lTipoDec)
			nBack := Round( nQuantItem,0 )
		Case (SB1->B1_TIPODEC == "I" .And. lTipoDec)
			nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
		Case (SB1->B1_TIPODEC == "T" .And. lTipoDec)
			nBack := Int( nQuantItem )
		OtherWise
			nBack := nQuantItem
	EndCase
Else
	nBack := nQuantItem
EndIf

Set(3,nDecOrig)

Return( nBack )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณTemQBP     ณAutor ณNorberto M de Melo       ณData  ณ 08/05/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Esta fun็ใo tem como objetivo validar a exist๊ncia da coluna ณฑฑ
ฑฑณ          ณ SB1->B1_QBP                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ.T. ou .F.                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGACUSA.PRX                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function TemQBP( )

Local lRet	:= .F.
Local aArea	:= GetArea()

dbSelectArea("SB1")
lRet := FieldPos( "B1_QBP" ) > 0

RestArea(aArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaImpE  บ Autor ณ MARCIO COSTA       บ Data ณ 05/05/2025 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Busca Impostos Entrada                                     ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaImpE(cProdAtu)

Local cQuery  := " "

Local dDataIni := dtos(MV_PAR04 - MV_PAR05)
Local dDataFim := dtos(MV_PAR04)

Local aRetImp := {}

If SELECT("TRBC") > 0
	("TRBC")->( dbCloseArea() )
EndIf 

cQuery := " SELECT B1_COD, "

cQuery += "     ISNULL((SELECT (SUM(D1_VALICM) / SUM(D1_BASEICM) ) * 100 "
cQuery += " 	        FROM " + RetSqlName("SD1")+" SD1A, " + RetSqlName("SF4")+" SF4A "
cQuery += "			    WHERE SD1A.D1_FILIAL = '" + xFilial("SD1") + "'" 
cQuery += "		    	AND SF4A.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "		    	AND SD1A.D1_COD = SB1.B1_COD
cQuery += "		    	AND SD1A.D1_TES = SF4A.F4_CODIGO
cQuery += "		    	AND SF4A.F4_ESTOQUE = 'S' 	
cQuery += "		    	AND SD1A.D1_TIPO = 'N'  
cQuery += "		    	AND SD1A.D1_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD1A.D1_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD1A.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4A.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD1A.D1_VALICM > 0
cQuery += "		    	),' ') AS PERC_ICM,

cQuery += "     ISNULL((SELECT (SUM(D1_VALIPI)/SUM(D1_BASEIPI))*100 "
cQuery += " 	        FROM " + RetSqlName("SD1")+" SD1B, " + RetSqlName("SF4")+" SF4B "
cQuery += "		    	WHERE SD1B.D1_FILIAL = '" + xFilial("SD1") + "'" 
cQuery += "			    AND SF4B.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD1B.D1_COD = SB1.B1_COD
cQuery += "			    AND SD1B.D1_TES = SF4B.F4_CODIGO
cQuery += "			    AND SF4B.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD1B.D1_TIPO = 'N'  
cQuery += "			    AND SD1B.D1_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD1B.D1_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD1B.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4B.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD1B.D1_VALIPI > 0
cQuery += "			    ),' ') AS PERC_IPI,

cQuery += "     ISNULL((SELECT (SUM(D1_VALIMP6)/SUM(D1_BASIMP6))*100 "
cQuery += " 	        FROM " + RetSqlName("SD1")+" SD1C, " + RetSqlName("SF4")+" SF4C "
cQuery += "		    	WHERE SD1C.D1_FILIAL = '" + xFilial("SD1") + "'" 
cQuery += "			    AND SF4C.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD1C.D1_COD = SB1.B1_COD
cQuery += "			    AND SD1C.D1_TES = SF4C.F4_CODIGO
cQuery += "			    AND SF4C.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD1C.D1_TIPO = 'N'  
cQuery += "			    AND SD1C.D1_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD1C.D1_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD1C.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4C.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD1C.D1_VALIMP6 > 0
cQuery += "			    ),' ') AS PERC_PIS,

cQuery += "     ISNULL((SELECT (SUM(D1_VALIMP5)/SUM(D1_BASIMP5))*100 "
cQuery += " 	        FROM " + RetSqlName("SD1")+" SD1D, " + RetSqlName("SF4")+" SF4D "
cQuery += "		    	WHERE SD1D.D1_FILIAL = '" + xFilial("SD1") + "'" 
cQuery += "			    AND SF4D.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD1D.D1_COD = SB1.B1_COD
cQuery += "			    AND SD1D.D1_TES = SF4D.F4_CODIGO
cQuery += "			    AND SF4D.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD1D.D1_TIPO = 'N'  
cQuery += "			    AND SD1D.D1_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD1D.D1_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD1D.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4D.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD1D.D1_VALIMP5 > 0
cQuery += "			    ),' ') AS PERC_COF

cQuery += " FROM " + RetSqlName("SB1")+" SB1 "
cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND SB1.B1_COD   = '" + cProdAtu + "' " 
cQuery += " AND SB1.D_E_L_E_T_ <> '*' 	

//MemoWrite("RESTR01.SQL", cQuery)

MPSysOpenQuery( cQuery, "TRBC" )

dbSelectArea("TRBC")
TRBC->(dbGoTop())   

iF !Eof()

	aRetImp := {TRBC->PERC_ICM,TRBC->PERC_IPI,TRBC->PERC_PIS,TRBC->PERC_COF}

	dbSelectArea("TRBC")
	dbCloseArea()
Else
	aRetImp := {0,0,0,0}
Endif

Return(aRetImp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaImpS  บ Autor ณ MARCIO COSTA       บ Data ณ 05/05/2025 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Busca Impostos Saida                                       ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaImpS(cProdAtu)

Local cQuery  := " "

Local dDataIni := dtos(MV_PAR04 - MV_PAR05)
Local dDataFim := dtos(MV_PAR04)

Local aRetImp := {}

If SELECT("TRBA") > 0
	("TRBA")->( dbCloseArea() )
EndIf 


cQuery := " SELECT B1_COD, "
cQuery += "     ISNULL((SELECT (SUM(D2_VALICM) / SUM(D2_BASEICM) ) * 100 "
cQuery += " 	        FROM " + RetSqlName("SD2")+" SD2A, " + RetSqlName("SF4")+" SF4A "
cQuery += "			    WHERE SD2A.D2_FILIAL = '" + xFilial("SD2") + "'" 
cQuery += "		    	AND SF4A.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "		    	AND SD2A.D2_COD = SB1.B1_COD
cQuery += "		    	AND SD2A.D2_TES = SF4A.F4_CODIGO
cQuery += "		    	AND SF4A.F4_ESTOQUE = 'S' 	
cQuery += "		    	AND SD2A.D2_TIPO NOT IN('B/D') "
cQuery += "		    	AND SD2A.D2_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD2A.D2_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD2A.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4A.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD2A.D2_VALICM > 0
cQuery += "		    	),' ') AS PERC_ICM,

cQuery += "     ISNULL((SELECT (SUM(D2_VALIPI)/SUM(D2_BASEIPI))*100 "
cQuery += " 	        FROM " + RetSqlName("SD2")+" SD2B, " + RetSqlName("SF4")+" SF4B "
cQuery += "		    	WHERE SD2B.D2_FILIAL = '" + xFilial("SD2") + "'" 
cQuery += "			    AND SF4B.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD2B.D2_COD = SB1.B1_COD
cQuery += "			    AND SD2B.D2_TES = SF4B.F4_CODIGO
cQuery += "			    AND SF4B.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD2B.D2_TIPO NOT IN('B/D') "
cQuery += "			    AND SD2B.D2_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD2B.D2_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD2B.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4B.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD2B.D2_VALIPI > 0
cQuery += "			    ),' ') AS PERC_IPI,

cQuery += "     ISNULL((SELECT (SUM(D2_VALIMP6)/SUM(D2_BASIMP6))*100 "
cQuery += " 	        FROM " + RetSqlName("SD2")+" SD2C, " + RetSqlName("SF4")+" SF4C "
cQuery += "		    	WHERE SD2C.D2_FILIAL = '" + xFilial("SD2") + "'" 
cQuery += "			    AND SF4C.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD2C.D2_COD = SB1.B1_COD
cQuery += "			    AND SD2C.D2_TES = SF4C.F4_CODIGO
cQuery += "			    AND SF4C.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD2C.D2_TIPO NOT IN('B/D') "
cQuery += "			    AND SD2C.D2_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD2C.D2_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD2C.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4C.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD2C.D2_VALIMP6 > 0
cQuery += "			    ),' ') AS PERC_PIS,

cQuery += "     ISNULL((SELECT (SUM(D2_VALIMP5)/SUM(D2_BASIMP5))*100 "
cQuery += " 	        FROM " + RetSqlName("SD2")+" SD2D, " + RetSqlName("SF4")+" SF4D "
cQuery += "		    	WHERE SD2D.D2_FILIAL = '" + xFilial("SD2") + "'" 
cQuery += "			    AND SF4D.F4_FILIAL = '" + xFilial("SF4") + "'" 
cQuery += "			    AND SD2D.D2_COD = SB1.B1_COD
cQuery += "			    AND SD2D.D2_TES = SF4D.F4_CODIGO
cQuery += "			    AND SF4D.F4_ESTOQUE = 'S' 	
cQuery += "			    AND SD2D.D2_TIPO NOT IN('B/D') "
cQuery += "			    AND SD2D.D2_EMISSAO >= '" + dDataIni + "'"
cQuery += "		    	AND SD2D.D2_EMISSAO <= '" + dDataFim + "'"
cQuery += "		    	AND SD2D.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SF4D.D_E_L_E_T_ <> '*'
cQuery += "		    	AND SD2D.D2_VALIMP5 > 0
cQuery += "			    ),' ') AS PERC_COF

cQuery += " FROM " + RetSqlName("SB1")+" SB1 "
cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND SB1.B1_COD   = '" + cProdAtu + "' " 
cQuery += " AND SB1.D_E_L_E_T_ <> '*' 	

MPSysOpenQuery( cQuery, "TRBA" )

dbSelectArea("TRBA")
TRBA->(dbGoTop())   

iF !Eof()

	aRetImp := {TRBA->PERC_ICM,TRBA->PERC_IPI,TRBA->PERC_PIS,TRBA->PERC_COF}

	dbSelectArea("TRBA")
	dbCloseArea()
Endif

Return(aRetImp)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaCus  บ Autor ณ MARCIO COSTA       บ Data ณ 05/05/2025 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Busca Custo			                                       ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaCus(cProdAtu)

Local nRet := 0
Local aCusto := {}

dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial("SB2") + cProdAtu)

	While !Eof() .And. SB2->B2_COD == cProdAtu

		If SB2->B2_LOCAL == '13' .Or. nRet > 0 //pe็as nao conformes
			dbSkip()
			Loop
		Endif
		
		aCusto := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR04+1,cFilAnt)

		If aCusto[08] > 0
			nRet := aCusto[08]
		Endif

		dbSelectArea("SB2")
		dbSkip()
	End
Endif

Return(nRet)
