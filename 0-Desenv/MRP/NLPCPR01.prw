#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

//------------------------------------------------------\\
/*/{Protheus.doc} NLPCPR01
// Relatório de análise das SCs geradas pelo MRP com os
   pedidos de compras.
@author Claudio
@since 18/10/2026
@version 1.0
@type Function
/*/
//------------------------------------------------------\\
User Function NLPCPR01()

Local oReport := ReportDef()

oReport:PrintDialog()

Return
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author Claudio
@since 18/10/2026
@version 1.0
@return ${return}, ${return_description}
@param cNome - Nome do relatório
@type Function
/*/
//------------------------------------------------------\\
Static Function ReportDef(cNome)

Local oReport   := Nil
Local oSection1 := Nil
Local cPerg     := PADR('NLPCPR01',10)

Static cAliasSC1 := GetNextAlias()

oReport := TReport():New('NLPCPR01',, cPerg, {|oReport| ReportPrint(oReport, cAliasSC1)})
//oReport := TReport():New('PCPR006',,, {|oReport| ReportPrint(oReport, cAliasSC1)})

Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,'Análise das SCs x Pedidos de Compras', cAliasSC1)                                                                                                                                                                       
oSection1:SetTotalInLine(.F.)
oSection1:nFontBody := 8

oReport:SetPortrait(.T.)
oReport:nFontBody := 8

oReport:SetTitle('Análise das SCs x Pedidos de Compras')

// TRCell():New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)   

TRCell():New(oSection1, 'C1_PRODUTO', cAliasSC1, 'Produto'      , '@!'           , 15,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'B1_DESC'   , cAliasSC1, 'Descrição'    , '@!'           , 60,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'C1_NUM'    , cAliasSC1, 'Número SC'    , '@!'           ,  6,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'C1_ITEM'   , cAliasSC1, 'Item SC'      , '@!'           ,  4,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'C1_QUANT'  , cAliasSC1, 'Qtde SC'      , '@E 999,999.99', 10,,, 'RIGHT',,'RIGHT',,2,,,,.F.)
TRCell():New(oSection1, 'C1_UM'     , cAliasSC1, 'UM SC'        , '@!'           ,  2,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C1_DATPRF' , cAliasSC1, 'Dt Entrega SC', '@!'           , 10,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C7_NUM'    , cAliasSC1, 'Número PC'    , '@!'           ,  6,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C7_FORNECE', cAliasSC1, 'Fornecedor'   , '@!'           ,  6,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C7_LOJA'   , cAliasSC1, 'Loja'         , '@!'           ,  2,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C7_QUANT'  , cAliasSC1, 'Qtde PC'      , '@E 999,999.99', 10,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          
TRCell():New(oSection1, 'C7_UM'     , cAliasSC1, 'UM PC'        , '@!'           ,  2,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'C7_DATPRF' , cAliasSC1, 'Dt Entrega SC', '@!'           , 10,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'NOVA_QTDE' , cAliasSC1, 'Nova Qtde'    , '@E 999,999.99', 10,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          
TRCell():New(oSection1, 'STATUS'    , cAliasSC1, 'Status'       , '@!'           , 80,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          

Return oReport
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportPrint
//Imprime o relatório.
@author Claudio
@since 18/10/2026
@version 1.0
@type function
/*/
//------------------------------------------------------\\
Static Function ReportPrint(oReport, cAliasSC1)

Local oSection1 := oReport:Section(1)
Local cQry := ''

cQry += "WITH PEDIDOS AS ( "
cQry += "SELECT "
cQry += "    C7_PRODUTO, C7_NUM, C7_ITEM, C7_QUANT, C7_UM, C7_DATPRF, C7_FORNECE, C7_LOJA "
cQry += "FROM "+RetSqlName('SC7')+" SC7 "
cQry += "WHERE SC7.D_E_L_E_T_ = '' "
cQry += "	AND C7_FILIAL = '"+xFilial("SC7")+"' "
cQry += "	AND C7_DATPRF >= '" + DTOS(mv_par01) +"' "
cQry += "	AND C7_QUJE < C7_QUANT "
cQry += "	AND C7_RESIDUO <> 'S' "
cQry += "    AND EXISTS ( "
cQry += "		SELECT 1 "
cQry += "		FROM "+RetSqlName('SC1')+" " 
cQry += "		WHERE C1_PRODUTO = C7_PRODUTO "
cQry += "	        AND C1_FILIAL = '"+xFilial("SC1")+"' "
cQry += "			AND C1_SEQMRP = '" + mv_par02 +"' " 
cQry += "			AND C1_RESIDUO <> 'S' "
cQry += "			AND D_E_L_E_T_ = '' "
cQry += "      ) "
cQry += ") "

cQry += "SELECT  C1_PRODUTO, B1_DESC, C1_NUM, C1_ITEM, C1_QUANT, C1_UM, C1_DATPRF, C7_NUM, C7_FORNECE, C7_LOJA, C7_QUANT, C7_UM, C7_DATPRF, " 
cQry += "		C1_QUANT + C7_QUANT AS [NOVA QTDE], "
cQry += "		CASE "
cQry += "		WHEN C7_NUM IS NULL THEN '' "
cQry += "		WHEN C1_DATPRF < C7_DATPRF THEN 'ALTERAR A QUANTIDADE E ANTECIPAR O PEDIDO DE COMPRA' "
cQry += "		ELSE 'ALTERAR A QUANTIDADE DO PEDIDO DE COMPRA' "
cQry += "		END STATUS "
cQry += "FROM "+RetSqlName('SC1')+" SC1 " 
cQry += "	LEFT OUTER JOIN PEDIDOS P ON "
cQry += "			C7_PRODUTO = C1_PRODUTO "
cQry += "		AND YEAR(C7_DATPRF)  = YEAR(C1_DATPRF) "
cQry += "		AND MONTH(C7_DATPRF) = MONTH(C1_DATPRF) " 
cQry += "	INNER JOIN "+RetSqlName('SB1')+" SB1 ON "
cQry += "			B1_COD = C1_PRODUTO "
cQry += "		AND SB1.D_E_L_E_T_ = '' "
cQry += "WHERE C1_SEQMRP = '" + mv_par02 +"' " 
cQry += "	AND C1_FILIAL = '"+xFilial("SC1")+"' "
cQry += "	AND C1_QUJE < C1_QUANT "
cQry += "	AND C1_RESIDUO <> 'S' "
cQry += "	AND SC1.D_E_L_E_T_ = '' "
cQry += "ORDER BY C1_PRODUTO, C1_DATPRF "

DbUseArea(.T., "TOPCONN", TcGenQry(NIL,NIL,cQry), cAliasSC1 , .F., .T. )

(cAliasSC1)->(DbGoTop())

oReport:SetMeter((cAliasSC1)->(LastRec())) 
	 
(cAliasSC1)->(dbGoTop())

oSection1:Init() 

oReport:IncMeter()

While !(cAliasSC1)->(EOF()) 

	If oReport:Cancel()
		Exit
	Endif 
		
	oReport:IncMeter()
	
	oSection1:PrintLine()	  
		
	(cAliasSC1)->(DbSkip())					
		
Enddo		
	
//oReport:ThinLine()
 	
oSection1:Finish()
	
oReport:EndPage()

(cAliasSC1)->(DbCloseArea())

Return
