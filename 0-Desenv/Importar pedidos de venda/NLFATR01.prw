#include 'protheus.ch'

//------------------------------------------------------\\
/*/{Protheus.doc} NLFATR01
// Relatório de histórico de importação de previsão e 
   pedidos de venda.
@author Claudio
@since 15/05/2026
@version 1.0
@type Function
/*/
//------------------------------------------------------\\
User Function NLFATR01()

Local oReport := ReportDef()

oReport:PrintDialog()

Return
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author Claudio
@since 30/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cNome - Nome do relatório
@type Function
/*/
//------------------------------------------------------\\
Static Function ReportDef(cNome)

Local oReport   := Nil
Local oSection1 := Nil
Local cPerg     := PADR('NLFATR01',10)

Static cAliasZZ6 := GetNextAlias()

//oReport := TReport():New('PCPR006',, cPerg, {|oReport| ReportPrint(oReport, cAliasSB1)})
oReport := TReport():New('NLFATR01',, cPerg, {|oReport| ReportPrint(oReport, cAliasZZ6)})

Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,'Histórico de Importação', cAliasZZ6)                                                                                                                                                                       
oSection1:SetTotalInLine(.F.)
oSection1:nFontBody := 8

oReport:SetPortrait(.T.)
oReport:nFontBody := 8

oReport:SetTitle('Histórico de Importação')

// TRCell():New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)   

TRCell():New(oSection1, 'ZZ6_ID'    , cAliasZZ6, 'ID'             , '@!'             ,  9,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ5_DATA'  , cAliasZZ6, 'Data Importação', '@!'             , 10,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'ZZ6_TIPO'  , cAliasZZ6, 'Tipo Demanda'   , '@!'             , 15,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'ZZ6_PLANTA', cAliasZZ6, 'Planta'         , '@!'             ,  4,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'A1_NREDUZ' , cAliasZZ6, 'Nome'           , '@!'             , 25,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'A1_MUN'    , cAliasZZ6, 'Cidade'         , '@!'             , 25,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ6_PNNWL' , cAliasZZ6, 'Produto'        , '@!'             , 15,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'B1_DESC'   , cAliasZZ6, 'Descrição'      , '@!'             , 60,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ6_DATA'  , cAliasZZ6, 'Data Entrega'   , '@!'             , 10,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ6_QTDENT', cAliasZZ6, 'Qtd Entrega'    , '@E 999,999.999' , 11,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ6_QTDANT', cAliasZZ6, 'Qtd Anterior'   , '@E 999,999.999' , 11,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          
TRCell():New(oSection1, 'ZZ6_PRCUNI', cAliasZZ6, 'Preço Unitário' , '@E 9,999,999.99', 12,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          

Return oReport
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportPrint
//Imprime o relatório.
@author Claudio
@since 08/12/2023
@version 1.0
@type function
/*/
//------------------------------------------------------\\
Static Function ReportPrint(oReport, cAliasZZ6)

Local oSection1 := oReport:Section(1)

Local cDoc  := ''
Local cTipo := '%'
Local aTipos  := ''
Local nI := 0

If mv_par07 = 1
	cDoc := "%ZZ6_TIPO = '1'%"
ElseIf mv_par07 = 2
	cDoc := "%ZZ6_TIPO = '2'%"
Else
	cDoc := "%ZZ6_TIPO IN ('1','2')%" 
Endif

If !Empty(mv_par08)
	aTipos := StrTokArr2(mv_par08, ';')
	cTipo  := "%B1_TIPO IN ('"
	For nI := 1 to Len(aTipos)
		If nI = 1
			cTipo += Alltrim(aTipos[nI]) + "'"
		Else
			cTipo += ",'" +Alltrim(aTipos[nI]) + "'"
		Endif 
	Next nI 
	cTipo += ")%"
Else 
	cTipo := "%B1_TIPO <> ''%"
Endif 


BeginSQL Alias cAliasZZ6

	COLUMN ZZ5_DATA AS DATE
	COLUMN ZZ6_DATA AS DATE

	SELECT ZZ6_ID, ZZ5_DATA, ZZ6_TIPO, ZZ6_PLANTA, A1_NREDUZ, A1_MUN, 
	ZZ6_PNNWL, B1_DESC, ZZ6_DATA, ZZ6_QTDENT, ZZ6_QTDANT, ZZ6_PRCUNI
	FROM %Table:ZZ6% ZZ6 INNER JOIN %Table:SB1% SB1 ON
	        B1_FILIAL = %xFilial:SB1%
		AND B1_COD = ZZ6_PNNWL 
		AND B1_TIPO IN ('PA','ME')
		AND SB1.%notdel% INNER JOIN %Table:SA1% SA1 ON
			A1_FILIAL = %xFilial:SA1%
		AND A1_XPLANTA = ZZ6_PLANTA
		AND SA1.%notdel% INNER JOIN %Table:ZZ5% ZZ5 ON
			ZZ5_FILIAL = %xFilial:ZZ5%
		AND ZZ5_ID = ZZ6_ID
		AND ZZ5.%notdel%
	WHERE ZZ6_FILIAL = %xFilial:ZZ6%
		AND ZZ6_PLANTA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND ZZ6_PNNWL BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		AND ZZ6_DATA BETWEEN %Exp:Dtos(mv_par05)% AND %Exp:Dtos(mv_par06)%
		AND %Exp:cDoc%
		AND %Exp:cTipo%
		AND ZZ6.%notdel%

EndSql 

oReport:SetMeter((cAliasZZ6)->(LastRec())) 
	 
(cAliasZZ6)->(dbGoTop())

oSection1:Init() 

oReport:IncMeter()

While !(cAliasZZ6)->(EOF()) 

	If oReport:Cancel()
		Exit
	Endif 
		
	oReport:IncMeter()
	
	oSection1:PrintLine()	  
		
	(cAliasZZ6)->(DbSkip())					
		
Enddo		
	
oReport:ThinLine()
 	
oSection1:Finish()
	
oReport:EndPage()

(cAliasZZ6)->(DbCloseArea())

Return

