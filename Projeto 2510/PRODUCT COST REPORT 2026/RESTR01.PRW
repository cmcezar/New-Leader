#INCLUDE "Protheus.ch"                                      
#INCLUDE "TbiConn.ch"   
#include "report.ch" 
#Include "Topconn.ch"
#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTR01   บ Autor ณ MARCIO COSTA       บ Data ณ 28/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio REPORT MATERIAL COSTS BY PERIOD                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NEW LEADER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function RESTR01() 

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
ฑฑบPrograma  ณIMPREL   บ Autor ณ MARCIO COSTA       บ Data ณ 28/04/2026  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio REPORT MATERIAL COSTS BY PERIOD                  ฑฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpRel()

Local cPerg		:= "RESTR01   "
Local cTitulo 	:= "REPORT MATERIAL COSTS BY PERIOD"	
Local cDesc1 	:= "Este Relat๓rio irแ imprimir Saldos e Custos de Produtos"	
Local oRelat
Local aOrdem    := {}

ValidPerg(cPerg)
Pergunte(cPerg,.F.)

oReport := TReport():New("RESTR01",cTitulo,cPerg,{|oReport| fR42Print(oReport,cTitulo)},cDesc1)
oReport:DisableOrientation()
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

TReport():SetTitle( cTitulo ) 
			 	
oRelat := TRSection():New(oReport,cTitulo,{"SD2"},aOrdem,,,,,,,,,,,,.F. )  

TRCell():New(oRelat,"PRODUTO",,"PRODUTO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"DESCRICAO",,"DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"UNIDMED",,"U.M.",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"TIPO",,"TIPO",PesqPict("SB1","B1_TIPO"),TamSX3("B1_TIPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")

TRCell():New(oRelat,"ARMAZEM",,"ARMAZEM",PesqPict("SB2","B2_LOCAL"),TamSX3("B2_LOCAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")
TRCell():New(oRelat,"NOMEARM",,"NOME"+CRLF+"ARMAZEM",PesqPict("SB2","B2_LOCAL"),TamSX3("B2_LOCAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"LEFT")

TRCell():New(oRelat,"SALDO",,"SALDO",PesqPict("SB2","B2_QATU"),TamSX3("B2_QATU")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"VSALDO",,"VALOR",PesqPict("SB2","B2_VATU1"),TamSX3("B2_VATU1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"CUSTO",,"CUSTO"+CRLF+"UNITARIO",PesqPict("SB2","B2_CM1"),TamSX3("B2_CM1")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"ULTSAI",,"DT.ULTIMA"+CRLF+"SAIDA",PesqPict("SB2","B2_USAI"),TamSX3("B2_USAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"ULTMOV",,"DT.ULTIMO"+CRLF+"MOVIMENTO",PesqPict("SB2","B2_DMOV"),TamSX3("B2_DMOV")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"HORAMOV",,"HORA ULTIMO"+CRLF+"MOVIMENTO",PesqPict("SB2","B2_HMOV"),TamSX3("B2_HMOV")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

TRCell():New(oRelat,"ALIQ_ICM",,"% MEDIO"+CRLF+"ICMS",PesqPict("SD2","D2_PICM"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"ICMS",,"VALOR MEDIO"+CRLF+"ICMS",PesqPict("SD2","D2_VALICM"),TamSX3("D2_VALICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_IPI",,"% MEDIO"+CRLF+"IPI",PesqPict("SD2","D2_IPI"),TamSX3("D2_PICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"IPI",,"VALOR MEDIO"+CRLF+"IPI",PesqPict("SD2","D2_VALIPI"),TamSX3("D2_VALIPI")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_PIS",,"% MEDIO"+CRLF+"PIS",PesqPict("SD2","D2_ALQIMP6"),TamSX3("D2_ALQIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"PIS",,"VALOR MEDIO"+CRLF+"PIS",PesqPict("SD2","D2_VALIMP6"),TamSX3("D2_VALIMP6")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"ALIQ_COF",,"% MEDIO"+CRLF+"COFINS",PesqPict("SD2","D2_ALQIMP5"),TamSX3("D2_ALQIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	
TRCell():New(oRelat,"COF",,"VALOR MEDIO"+CRLF+"COFINS",PesqPict("SD2","D2_VALIMP5"),TamSX3("D2_VALIMP5")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")	

TRCell():New(oRelat,"TOTALG",,"TOTAL CUSTO"+CRLF+"C/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
TRCell():New(oRelat,"TOTALV",,"TOTAL VALOR"+CRLF+"C/IMPOSTO",PesqPict("SD2","D2_VALBRUT"),TamSX3("D2_VALBRUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

oRelat:SetHeaderPage()
oRelat:SetHeaderBreak()
oRelat:SetReadOnly()
oRelat:SetTotalInLine(.F.)
	
Return oReport 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfR42Print  บ Autor ณ MARCIO COSTA       บ Data ณ 28/04/2026 บฑฑ
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
Local cQuery  := " "

Local dDataIni := dtos(MV_PAR01 - MV_PAR02)
Local dDataFim := dtos(MV_PAR01)

Local aSaldo := {}
Local nIcm :=  nIpi := nPis := nCof := nTotI := nTotV := 0

cQuery := " SELECT B1_COD, B1_DESC, B1_GRUPO, B1_TIPO, B1_UM, B2_LOCAL, B2_USAI, B2_DMOV, B2_HMOV, B2_LOCALIZ, NNR_DESCRI, "

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
cQuery += " INNER JOIN " + RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD "
cQuery += "                       AND SB2.D_E_L_E_T_ <> '*' AND SB2.B2_LOCAL >= '" + MV_PAR09 + "' AND SB2.B2_LOCAL <= '" + MV_PAR10 + "' "
cQuery += " INNER JOIN " + RetSqlName("NNR")+" NNR ON NNR.NNR_FILIAL = '" + xFilial("NNR") + "' AND SB2.B2_LOCAL = NNR.NNR_CODIGO AND NNR.D_E_L_E_T_ <> '*' "
cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND SB1.B1_COD   >= '" + MV_PAR03 + "' " 
cQuery += " AND SB1.B1_COD   <= '" + MV_PAR04 + "' " 
cQuery += " AND SB1.B1_GRUPO >= '" + MV_PAR05 + "' " 
cQuery += " AND SB1.B1_GRUPO <= '" + MV_PAR06 + "' " 
cQuery += " AND SB1.B1_TIPO >=  '" + MV_PAR07 + "' " 
cQuery += " AND SB1.B1_TIPO <=  '" + MV_PAR08 + "' " 
cQuery += " AND SB1.D_E_L_E_T_ <> '*' 	
cQuery += " ORDER BY B1_COD, B2_LOCAL 

//MemoWrite("RESTR01.SQL", cQuery)

MPSysOpenQuery( cQuery, "TRBX" )

dbSelectArea("TRBX")
TRBX->(dbGoTop())   

oRelat:Init()
 	
While !Eof()

    oReport:IncMeter()

    aSaldo := {}
    aSaldo := CalcEst(TRBX->B1_COD,TRBX->B2_LOCAL,MV_PAR01+1,cFilAnt)
    
    nIcm  := aSaldo[08] * (TRBX->PERC_ICM / 100)
    nIpi  := aSaldo[08] * (TRBX->PERC_IPI / 100)
    nPis  := aSaldo[08] * (TRBX->PERC_PIS / 100)
    nCof  := aSaldo[08] * (TRBX->PERC_COF / 100)
    
    nTotI := aSaldo[08] + nIPI + nIcm + nPis + nCof 
    nTotV := aSaldo[02] + (aSaldo[01] * nIPI) + (aSaldo[01] * nIcm) + (aSaldo[01] * nPis) + (aSaldo[01] * nCof) 

    oRelat:Cell("PRODUTO"):SetValue(TRBX->B1_COD)
    oRelat:Cell("DESCRICAO"):SetValue(TRBX->B1_DESC)
    oRelat:Cell("TIPO"):SetValue(TRBX->B1_TIPO)
    oRelat:Cell("UNIDMED"):SetValue(TRBX->B1_UM)
    
    oRelat:Cell("ARMAZEM"):SetValue(TRBX->B2_LOCAL)
    oRelat:Cell("NOMEARM"):SetValue(TRBX->NNR_DESCRI)

    oRelat:Cell("SALDO"):SetValue(aSaldo[01])
    oRelat:Cell("VSALDO"):SetValue(aSaldo[02])
    oRelat:Cell("CUSTO"):SetValue(aSaldo[08])

    oRelat:Cell("ULTSAI"):SetValue(STOD(TRBX->B2_USAI))
    oRelat:Cell("ULTMOV"):SetValue(STOD(TRBX->B2_DMOV))
    oRelat:Cell("HORAMOV"):SetValue(TRBX->B2_HMOV)

    oRelat:Cell("ALIQ_ICM"):SetValue(Round(TRBX->PERC_ICM,2))
    oRelat:Cell("ICMS"):SetValue(nIcm)
    oRelat:Cell("ALIQ_IPI"):SetValue(Round(TRBX->PERC_IPI,2))
    oRelat:Cell("IPI"):SetValue(nIPI)
    oRelat:Cell("ALIQ_PIS"):SetValue(Round(TRBX->PERC_PIS,2))
    oRelat:Cell("PIS"):SetValue(nPis)
    oRelat:Cell("ALIQ_COF"):SetValue(Round(TRBX->PERC_COF,2))
    oRelat:Cell("COF"):SetValue(nCof)

    oRelat:Cell("TOTALG"):SetValue(nTotI)
    oRelat:Cell("TOTALV"):SetValue(nTotV)

    oRelat:PrintLine()

    dbSelectArea("TRBX")
 	dbSkip()
End
		
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

AADD(aRegs,{PADR(cPerg,10),"01","Data Referencia Custo   ?",".",".","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"02","Nro.Dias p/Base Impostos?",".",".","mv_ch2","N",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"03","Produto Inicial         ?",".",".","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Produto Final       	 ?",".",".","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"05","Grupo Inicial           ?",".",".","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"06","Grupo Final             ?",".",".","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"07","Tipo Inicial            ?",".",".","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"08","Tipo Final              ?",".",".","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"09","Armazem Inicial         ?",".",".","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","NNR","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"10","Armazem Final           ?",".",".","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","NNR","","","","",""})

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

