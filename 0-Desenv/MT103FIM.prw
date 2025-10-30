#include 'protheus.ch'
#include 'parmtype.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MT103FIM
//TODO Ponto de Entrada após a inclusão do documento de entrada,
       utilizado para endereçar os produtos.
@author Claudio Macedo
@since 15/09/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function MT103FIM()

Local aCabSDA := {}
Local aItem   := {}
Local aItens  := {}
Local cEnder  := ''

Local cAliasSDA := GetNextAlias()

Private cNota   := SD1->D1_DOC
Private cSerie  := SD1->D1_SERIE
Private cFornec := SD1->D1_FORNECE
Private cLoja   := SD1->D1_LOJA

Private lMsErroAuto := .F.

If Inclui

    // Endereça os produtos que já possuem saldo em um endereço

    BeginSQL Alias cAliasSDA
        SELECT DA_PRODUTO, DA_NUMSEQ, DA_LOCAL, DA_QTDORI
        FROM %Table:SDA% SDA
        WHERE DA_FILIAL   = %xFilial:SDA%
            AND DA_DOC    = %Exp:cNota%
            AND DA_SERIE  = %Exp:cSerie%
            AND DA_CLIFOR = %Exp:cFornec%
            AND DA_LOJA   = %Exp:cLoja%
            AND DA_SALDO > 0
            AND SDA.%notdel%
    EndSql 

    (cAliasSDA)->(DbGoTop())

    While !(cAliasSDA)->(EOF())

        SBF->(DbSetOrder(2))    // Filial+Produto+Local
        If SBF->(DbSeek(xFilial('SBF') + (cAliasSDA)->DA_PRODUTO + (cAliasSDA)->DA_LOCAL))

            cEnder := SBF->BF_LOCALIZ

            aItens := {}

            //Cabecalho com a informação do item e NumSeq que sera endereçado.
            aCabSDA := {{'DA_PRODUTO' ,(cAliasSDA)->DA_PRODUTO, Nil},;
                        {'DA_NUMSEQ'  ,(cAliasSDA)->DA_NUMSEQ , Nil}}

            //Dados do item que será endereçado
            aItem := {{'DB_ITEM'   , '0001'   , Nil},;
                      {'DB_ESTORNO', ' '      , Nil},;
                      {'DB_LOCALIZ', cEnder   , Nil},;
                      {'DB_DATA'   , dDataBase, Nil},;
                      {'DB_QUANT'  , (cAliasSDA)->DA_QTDORI, Nil}}

            aadd(aItens,aItem)

            //Executa o endere?amento do item
            MATA265(aCabSDA, aItens, 3)

            If lMsErroAuto
                MostraErro()
            Else
                MsgInfo('Produtos endereçados !', 'Sucesso')
            Endif

        Endif 

        (cAliasSDA)->(DbSkip())

    Enddo 

    (cAliasSDA)->(DbCloseArea())

    // Imprime o relatório dos endereços dos produtos da nota fiscal

    If MsgYesNo('Deseja imprimir o relatório de endereços dos produtos ?')
        U_NLEST001()
    Endif

Endif 

Return Nil

//------------------------------------------------------\\
/*/{Protheus.doc} NLEST001
// Imprime o relatório de endereços dos produtos do 
   documento de entrada
@author Claudio
@since 18/10/2025
@version 1.0
@type Function
/*/
//------------------------------------------------------\\
User Function NLEST001()

Local oReport := ReportDef()

oReport:PrintDialog()

Return
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author Claudio
@since 18/10/2025
@version 1.0
@return ${return}, ${return_description}
@param cNome - Nome do relatório
@type Function
/*/
//------------------------------------------------------\\
Static Function ReportDef(cNome)

Local oReport   := Nil
Local oSection1 := Nil

Static cAliasSDA := GetNextAlias()

oReport := TReport():New('NLEST001',,, {|oReport| ReportPrint(oReport,cAliasSDA)})

oSection1 := TRSection():New(oReport,'Endereços dos produtos da NF', cAliasSDA)                                                                                                                                                                       
oSection1:SetTotalInLine(.F.)
oSection1:nFontBody := 8

oReport:SetPortrait(.T.)
oReport:nFontBody := 8

oReport:SetTitle('Endereços dos produtos da NF')

// TRCell():New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)                                                                                                                                                                  

TRCell():New(oSection1, 'DA_DOC'    , cAliasSDA, 'Nota Fiscal', '@!'        ,  9,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'DA_SERIE'  , cAliasSDA, 'Série'      , '@!'        ,  3,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'DA_DATA'   , cAliasSDA, 'Data'       , '@!'        , 10,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'DA_PRODUTO', cAliasSDA, 'Produto'    , '@!'        , 15,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)
TRCell():New(oSection1, 'DA_QTDORI' , cAliasSDA, 'Quantidade' , '@E 999,999',  7,,, 'RIGHT',,'RIGHT',,2,,,,.F.)          
TRCell():New(oSection1, 'B1_UM'     , cAliasSDA, 'UM'         , '@!'        ,  2,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'DA_LOCAL'  , cAliasSDA, 'Local'      , '@!'        ,  2,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)          
TRCell():New(oSection1, 'DB_LOCALIZ', cAliasSDA, 'Endereço'   , '@!'        , 12,,, 'LEFT' ,,'LEFT' ,,2,,,,.F.)             

oSection1:SetHeaderPage(.F.)
oSection1:SetPageBreak(.F.)     
 
Return oReport
 
//------------------------------------------------------\\
/*/{Protheus.doc} ReportPrint
//Imprime o relatório.
@author Claudio
@since 18/10/2025
@version 1.0
@type function
/*/
//------------------------------------------------------\\
Static Function ReportPrint(oReport, cAliasSDA)

Local oSection1 := oReport:Section(1)

BeginSQL Alias cAliasSDA

	Column DA_DATA  as Date		
		
	SELECT DA_DOC, DA_SERIE, DA_DATA, DA_PRODUTO, DA_QTDORI, B1_UM, DA_LOCAL, ISNULL(DB_LOCALIZ,'') AS DB_LOCALIZ
	FROM %Table:SDA% SDA LEFT OUTER JOIN %Table:SDB% SDB ON 
			DB_FILIAL = %xFilial:SDB%
		AND DB_NUMSEQ = DA_NUMSEQ
		AND SDB.%notdel% INNER JOIN %Table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
		AND	B1_COD    = DA_PRODUTO
        AND B1_MSBLQL <> '1'
		AND SB1.%notdel% 
	WHERE DA_FILIAL   = %xFilial:SDA%
        AND DA_DOC    = %Exp:cNota%
        AND DA_SERIE  = %Exp:cSerie%
        AND DA_CLIFOR = %Exp:cFornec%
        AND DA_LOJA   = %Exp:cLoja%
        AND SDA.%notdel%
	ORDER BY DA_LOCAL

EndSQL
	
oReport:SetMeter((cAliasSDA)->(LastRec())) 

oSection1:Init() 

(cAliasSDA)->(DbGoTop())

While !(cAliasSDA)->(EOF()) 

	If oReport:Cancel()
		Exit
	Endif
	
	oReport:IncMeter()
	
	oSection1:PrintLine()	  
	
 	(cAliasSDA)->(DbSkip())
 			
Enddo 

oSection1:Finish()

oReport:EndPage()
	
(cAliasSDA)->(DbCloseArea())

Return

