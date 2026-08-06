#INCLUDE "Protheus.ch"                                      
#INCLUDE "TbiConn.ch"   
#include "report.ch" 
#Include "Topconn.ch"
#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR01   บ Autor ณ MARCIO COSTA       บ Data ณ 22/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio MARGEM E NOTAS                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function RFATR01() 

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
ฑฑบPrograma  ณRFATR01   บ Autor ณ MARCIO COSTA       บ Data ณ 21/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Notas de Saida com Impostos e Margens            ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpRel()

Local cPerg		:= "RFATR01   "
Local cTitulo 	:= "REPORT SALES AND MARGIN ANALYSIS"	
Local cDesc1 	:= "Este Relat๓rio irแ imprimir Notas de Saida com Impostos e Margens"	
Local oRelat
Local aOrdem    := {"Documento","Produto"}

ValidPerg(cPerg)
Pergunte(cPerg,.F.)

oReport := TReport():New("RFATR01",cTitulo,cPerg,{|oReport| fR42Print(oReport,cTitulo)},cDesc1)
oReport:DisableOrientation()
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

TReport():SetTitle( cTitulo ) 
			 	
oRelat := TRSection():New(oReport,cTitulo,{"SD2"},aOrdem,,,,,,,,,,,,.F. )  

TRCell():New(oRelat,"NOTA",,"DOCUMENTO",PesqPict("SD2","D2_DOC"),TamSX3("D2_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"SERIE",,"SERIE",PesqPict("SD2","D2_SERIE"),TamSX3("D2_SERIE")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"EMISSAO",,"EMISSAO",PesqPict("SD2","D2_EMISSAO"),TamSX3("D2_EMISSAO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"CLIENTE",,"CLIENTE",PesqPict("SD2","D2_CLIENTE"),TamSX3("D2_CLIENTE")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"LOJA",,"LOJA",PesqPict("SD2","D2_LOJA"),TamSX3("D2_LOJA")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"RAZAO",,"RAZAO SOCIAL",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"PRODUTO",,"PRODUTO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"DESCRICAO",,"DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"UNIDMED",,"U.M.",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"TIPO",,"TIPO",PesqPict("SB1","B1_TIPO"),TamSX3("B1_TIPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")

TRCell():New(oRelat,"TES",,"TES",PesqPict("SD2","D2_TES"),TamSX3("D2_TES")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"CFOP",,"CFOP",PesqPict("SD2","D2_CF"),TamSX3("D2_CF")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")

TRCell():New(oRelat,"QUANTIDADE",,"QUANTIDADE",PesqPict("SD2","D2_QUANT"),TamSX3("D2_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"PRECO",,"PRECO"+CRLF+"UNITARIO",PesqPict("SD2","D2_PRCVEN"),TamSX3("D2_PRCVEN")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"TOTAL",,"TOTAL"+CRLF+"S/IMPOSTO",PesqPict("SD2","D2_TOTAL"),TamSX3("D2_TOTAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"CUSTO",,"UNIT"+CRLF+"COST",PesqPict("SD2","D2_CUSTO1"),TamSX3("D2_CUSTO1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"CUSTOT",,"CUSTO"+CRLF+"TOTAL",PesqPict("SD2","D2_CUSTO1"),TamSX3("D2_CUSTO1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"BASEICM",,"BASE"+CRLF+"ICMS",PesqPict("SD2","D2_BASEICM"),TamSX3("D2_BASEICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ALIQ_ICM",,"%"+CRLF+"ICMS",PesqPict("SD2","D2_PICM"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ICMS",,"VALOR"+CRLF+"ICMS",PesqPict("SD2","D2_VALICM"),TamSX3("D2_VALICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"BASEIPI",,"BASE"+CRLF+"IPI",PesqPict("SD2","D2_BASEIPI"),TamSX3("D2_BASEIPI")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ALIQ_IPI",,"%"+CRLF+"IPI",PesqPict("SD2","D2_IPI"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"IPI",,"VALOR"+CRLF+"IPI",PesqPict("SD2","D2_VALIPI"),TamSX3("D2_VALIPI")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"BASEPIS",,"BASE"+CRLF+"PIS",PesqPict("SD2","D2_BASIMP6"),TamSX3("D2_BASIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ALIQ_PIS",,"%"+CRLF+"PIS",PesqPict("SD2","D2_ALQIMP6"),TamSX3("D2_ALQIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"PIS",,"VALOR"+CRLF+"PIS",PesqPict("SD2","D2_VALIMP6"),TamSX3("D2_VALIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"BASECOF",,"BASE"+CRLF+"COFINS",PesqPict("SD2","D2_BASIMP5"),TamSX3("D2_BASIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ALIQ_COF",,"%"+CRLF+"COFINS",PesqPict("SD2","D2_ALQIMP5"),TamSX3("D2_ALQIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"COFINS",,"VALOR"+CRLF+"COFINS",PesqPict("SD2","D2_VALIMP5"),TamSX3("D2_VALIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"MARGEM",,"% MARGEM"+CRLF+"S/IMPOSTO","@E 999.99",06,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"VLMARGEM",,"VLR.MARGEM"+CRLF+"S/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"TOTALG",,"VLR.FATURADO"+CRLF+"C/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"MARGEMI",,"% MARGEM"+CRLF+"C/IMPOSTO","@E 999.99",6,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"VLMARGEMI",,"VLR.MARGEM"+CRLF+"C/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

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
Local nOrdem  := oReport:Section(1):GetOrder()
Local cQuery  := " "

Local nTotQtd  := 0
Local nTotal   := 0
Local nTotalG  := 0
Local nTotIcm  := 0
Local nTotBIcm := 0
Local nTotIPI  := 0
Local nTotBIPI := 0
Local nTotBPIS := 0
Local nTotPIS  := 0
Local nTotBCOF := 0
Local nTotCOF  := 0
Local nTotCus  := 0

Local nMArgem   := 0
Local nVlrMarg  := 0
Local nMargemI  := 0
Local nVlrMargI := 0

//oReport:SetTitle(cTitulo)	

cQuery := " SELECT D2_FILIAL,D2_COD, D2_DOC,D2_SERIE, D2_EMISSAO, D2_CLIENTE,D2_LOJA,B1_COD, B1_DESC, B1_TIPO, B1_UM, D2_TIPO, D2_TES, D2_CF, D2_PRCVEN, A1_NOME, "
cQuery += "	  D2_QUANT, D2_TOTAL, D2_CUSTO1, D2_VALBRUT, D2_BASEIPI,D2_VALIPI, D2_IPI, D2_BASEICM, D2_VALICM, D2_PICM, "
cQuery += "	  D2_ALQIMP4, D2_ALQIMP5, D2_ALQIMP6, D2_VALIMP4, D2_VALIMP5, D2_VALIMP6, D2_BASIMP4, D2_BASIMP5, D2_BASIMP6 "
cQuery += "	FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SA1") + " SA1 "
cQuery += " WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "'"
cQuery += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
cQuery += "  AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "'"
cQuery += "  AND SD2.D2_COD     = SB1.B1_COD "
cQuery += "  AND SD2.D2_CLIENTE = SA1.A1_COD "
cQuery += "  AND SD2.D2_LOJA    = SA1.A1_LOJA "
cQuery += "  AND SD2.D2_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
cQuery += "  AND SD2.D2_EMISSAO <= '" + DTOS(MV_PAR02) + "'"
cQuery += "  AND SD2.D2_COD >= '" + MV_PAR03 + "'"
cQuery += "  AND SD2.D2_COD <= '" + MV_PAR04 + "'"
cQuery += "  AND SB1.B1_TIPO >= '" + MV_PAR05 + "'"
cQuery += "  AND SB1.B1_TIPO <= '" + MV_PAR06 + "'"
cQuery += "  AND SB1.B1_GRUPO >= '" + MV_PAR07 + "'"
cQuery += "  AND SB1.B1_GRUPO <= '" + MV_PAR08 + "'"

cQuery += "  AND SD2.D2_TIPO NOT IN('B/D') "

If !Empty(MV_PAR09)
	cQuery += " AND SD2.D2_TES IN " + FormatIn(MV_PAR09,";")
Endif
If !Empty(MV_PAR10)
	cQuery += " AND SD2.D2_TES NOT IN " + FormatIn(MV_PAR10,";")
Endif

cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' "

iF nOrdem == 1  //documento
    cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_COD"
else
    cQuery += " ORDER BY D2_FILIAL, D2_COD, D2_DOC "
Endif    

MPSysOpenQuery( cQuery, "TRBX" )

dbSelectArea("TRBX")
TRBX->(dbGoTop())   

MemoWrite("RFATR01.SQL", cQuery)

oRelat:Init()
 	
While !Eof()

    oReport:IncMeter()

    oRelat:Cell("NOTA"):SetValue(TRBX->D2_DOC)
    oRelat:Cell("SERIE"):SetValue(TRBX->D2_SERIE)
    oRelat:Cell("EMISSAO"):SetValue(STOD(TRBX->D2_EMISSAO))
	oRelat:Cell("CLIENTE"):SetValue(TRBX->D2_CLIENTE)
	oRelat:Cell("LOJA"):SetValue(TRBX->D2_LOJA)
    oRelat:Cell("RAZAO"):SetValue(TRBX->A1_NOME)
    oRelat:Cell("PRODUTO"):SetValue(TRBX->D2_COD)
    oRelat:Cell("DESCRICAO"):SetValue(TRBX->B1_DESC)
    oRelat:Cell("TIPO"):SetValue(TRBX->B1_TIPO)
    oRelat:Cell("UNIDMED"):SetValue(TRBX->B1_UM)
    oRelat:Cell("TES"):SetValue(TRBX->D2_TES)
    oRelat:Cell("CFOP"):SetValue(TRBX->D2_CF)

    oRelat:Cell("QUANTIDADE"):SetValue(TRBX->D2_QUANT)
    oRelat:Cell("PRECO"):SetValue(TRBX->D2_PRCVEN)
    oRelat:Cell("TOTAL"):SetValue(TRBX->D2_TOTAL)

    oRelat:Cell("CUSTO"):SetValue(TRBX->D2_CUSTO1 / TRBX->D2_QUANT)
    oRelat:Cell("CUSTOT"):SetValue(TRBX->D2_CUSTO1)

    oRelat:Cell("BASEICM"):SetValue(TRBX->D2_BASEICM)
    oRelat:Cell("ALIQ_ICM"):SetValue(TRBX->D2_PICM)
    oRelat:Cell("ICMS"):SetValue(TRBX->D2_VALICM)

    oRelat:Cell("BASEIPI"):SetValue(TRBX->D2_BASEIPI)
    oRelat:Cell("ALIQ_IPI"):SetValue(TRBX->D2_IPI)
    oRelat:Cell("IPI"):SetValue(TRBX->D2_VALIPI)

    oRelat:Cell("BASEPIS"):SetValue(TRBX->D2_BASIMP6)
    oRelat:Cell("ALIQ_PIS"):SetValue(TRBX->D2_ALQIMP6)
    oRelat:Cell("PIS"):SetValue(TRBX->D2_VALIMP6)

    oRelat:Cell("BASECOF"):SetValue(TRBX->D2_BASIMP5)
    oRelat:Cell("ALIQ_COF"):SetValue(TRBX->D2_ALQIMP5)
    oRelat:Cell("COFINS"):SetValue(TRBX->D2_VALIMP5)
    
    nMArgem   := Round(((TRBX->D2_VALBRUT - TRBX->D2_CUSTO1) / TRBX->D2_VALBRUT)*100,2)
    nVlrMarg  := TRBX->D2_VALBRUT - TRBX->D2_CUSTO1
    nMargemI  := Round(((TRBX->D2_TOTAL - TRBX->D2_CUSTO1) / TRBX->D2_VALBRUT)*100,2)
    nVlrMargI := TRBX->D2_TOTAL - TRBX->D2_CUSTO1

    oRelat:Cell("MARGEM"):SetValue(nMargem)
    oRelat:Cell("VLMARGEM"):SetValue(nVlrMarg)

    oRelat:Cell("TOTALG"):SetValue(TRBX->D2_VALBRUT)

    oRelat:Cell("MARGEMI"):SetValue(nMargemI)
    oRelat:Cell("VLMARGEMI"):SetValue(nVlrMargI)
    
	nTotQtd  += TRBX->D2_QUANT
	nTotal   += TRBX->D2_TOTAL
	nTotalG  += TRBX->D2_VALBRUT
	nTotBIcm += TRBX->D2_BASEICM
	nTotIcm  += TRBX->D2_VALICM
	nTotBIPI += TRBX->D2_BASEIPI
	nTotIPI  += TRBX->D2_VALIPI
	nTotBPIS += TRBX->D2_BASIMP6
	nTotPIS  += TRBX->D2_VALIMP6
	nTotBCOF += TRBX->D2_BASIMP5
	nTotCOF  += TRBX->D2_VALIMP5
	nTotCUS  += TRBX->D2_CUSTO1
	
    oRelat:PrintLine()

    dbSelectArea("TRBX")
 	dbSkip()
End
		

//--------------------------//
//imprime subtotal Emissao	
//--------------------------//			
oReport:ThinLine() 
        
oRelat:Cell("NOTA"):SetValue("")
oRelat:Cell("SERIE"):SetValue("")
oRelat:Cell("EMISSAO"):SetValue("")
oRelat:Cell("CLIENTE"):SetValue("")
oRelat:Cell("LOJA"):SetValue("")
oRelat:Cell("RAZAO"):SetValue("")
oRelat:Cell("PRODUTO"):SetValue("")
oRelat:Cell("DESCRICAO"):SetValue("T O T A L   G E R A L ==>")
oRelat:Cell("TIPO"):SetValue("")
oRelat:Cell("UNIDMED"):SetValue("")
oRelat:Cell("TES"):SetValue("")
oRelat:Cell("CFOP"):SetValue("")

oRelat:Cell("QUANTIDADE"):SetValue(nTotQtd)
oRelat:Cell("PRECO"):SetValue("")
oRelat:Cell("TOTAL"):SetValue(nTotal)

oRelat:Cell("CUSTO"):SetValue(nTotCus / nTotQtd)
oRelat:Cell("CUSTOT"):SetValue(nTotCus)

oRelat:Cell("BASEICM"):SetValue(nTotBIcm)
oRelat:Cell("ALIQ_ICM"):SetValue(Round((nTotIcm / nTotBIcm)*100,2))
oRelat:Cell("ICMS"):SetValue(nTotIcm)

oRelat:Cell("BASEIPI"):SetValue(nTotBipi)
oRelat:Cell("ALIQ_IPI"):SetValue(Round((nTotIpi / nTotBIpi)*100,2))
oRelat:Cell("IPI"):SetValue(nTotIPI)

oRelat:Cell("BASEPIS"):SetValue(nTotBPis)
oRelat:Cell("ALIQ_PIS"):SetValue(Round((nTotPis / nTotBPis)*100,2))
oRelat:Cell("PIS"):SetValue(nTotPis)

oRelat:Cell("BASECOF"):SetValue(nTotBCof)
oRelat:Cell("ALIQ_COF"):SetValue(Round((nTotCof / nTotBCof)*100,2))
oRelat:Cell("COFINS"):SetValue(nTotCof)

nMArgem   := Round(((nTotalG - nTotCus) / nTotalG)*100,2)
nVlrMarg  := nTotalG - nTotCus
nMargemI  := Round(((nTotal - nTotCus) / nTotalG)*100,2)
nVlrMargI := nTotal - nTotCus

oRelat:Cell("MARGEM"):SetValue(nMargem)
oRelat:Cell("VLMARGEM"):SetValue(nVlrMarg)

oRelat:Cell("TOTALG"):SetValue(nTotalG)

oRelat:Cell("MARGEMI"):SetValue(nMargemI)
oRelat:Cell("VLMARGEMI"):SetValue(nVlrMargI)

oRelat:PrintLine()
oReport:ThinLine()
		
oRelat:Finish()	

TRBX->(DbCloseArea()) 	

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

AADD(aRegs,{PADR(cPerg,10),"01","Emissao Inicial       ",".",".","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"02","Emissao Final         ",".",".","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"03","Produto Inicial       ",".",".","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Produto Final         ",".",".","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"05","Tipo Inicial          ",".",".","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"06","Tipo Final            ",".",".","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"07","Grupo Inicial         ",".",".","mv_ch7","C",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"08","Grupo Final           ",".",".","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"09","Tes a Considerar      ",".",".","mv_ch9","C",99,0,0,"R","","MV_PAR09","","","","F4_CODIGO","","","","","","","","","","","","","","","","","","","","","SF4","","S","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"10","Tes a Desconsiderar   ",".",".","mv_cha","C",99,0,0,"R","","MV_PAR10","","","","F4_CODIGO","","","","","","","","","","","","","","","","","","","","","SF4","","S","","","",""})

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

