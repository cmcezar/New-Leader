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

Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO

If Inclui .And. nConfirma = 1

    Processa( {|| U_PutSDB(nOpcao) }, 'Aguarde...', 'Endereçando produtos ...',.F.) 	

Endif

Return Nil

//------------------------------------------------------------\\
/*/{Protheus.doc} PutSDB
//TODO Executa o endereçamento dos produtos.
@author Claudio Macedo
@since 15/09/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function PutSDB(nOpcao)

Local aCabSDA := {}
Local aItem   := {}
Local aItens  := {}
Local cEnder  := ''
Local lEnder  := .F.
Local lErro   := .F.

Local cAliasSDA := GetNextAlias()

Private cNota   := SD1->D1_DOC
Private cSerie  := SD1->D1_SERIE
Private cFornec := SD1->D1_FORNECE
Private cLoja   := SD1->D1_LOJA

Private lMsErroAuto := .F.

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

ProcRegua((cAliasSDA)->(RecCount()))

(cAliasSDA)->(DbGoTop())

While !(cAliasSDA)->(EOF())

 	IncProc()

    ZZ2->(DbSetOrder(2))    // Filial+Produto+Local
    If ZZ2->(DbSeek(xFilial('ZZ2') + (cAliasSDA)->DA_PRODUTO + (cAliasSDA)->DA_LOCAL))

        cEnder := ZZ2->ZZ2_LOCALI      // Pega o primeiro endereço

        aItens := {}

        //Cabecalho com a informação do item e NumSeq que sera endereçado.
        aCabSDA := {{'DA_PRODUTO' ,(cAliasSDA)->DA_PRODUTO, Nil},;
                    {'DA_NUMSEQ'  ,(cAliasSDA)->DA_NUMSEQ , Nil}}

        //Dados do item que será endereçado
        aItem := {{'DB_ITEM'   , '0001'   , Nil},;
                    {'DB_ESTORNO', ' '      , Nil},;
                    {'DB_LOCAL'  , (cAliasSDA)->DA_LOCAL , Nil},;
                    {'DB_LOCALIZ', cEnder   , Nil},;
                    {'DB_DATA'   , dDataBase, Nil},;
                    {'DB_QUANT'  , (cAliasSDA)->DA_QTDORI, Nil}}

        aadd(aItens,aItem)

        //Executa o endereçamento do item
        MATA265(aCabSDA, aItens, nOpcao)

        If lMsErroAuto
            MostraErro()
        Else
            lEnder := .T.
            //MsgInfo('Produtos endereçados !', 'Sucesso')
        Endif

    Endif 

    (cAliasSDA)->(DbSkip())

Enddo 

(cAliasSDA)->(DbCloseArea())

// Imprime o relatório dos endereços dos produtos da nota fiscal

If lEnder .And. !lErro
    If MsgYesNo('Produtos endereçados com sucesso !' + CRLF +;
                'Deseja imprimir o relatório de endereços dos produtos ?')
        U_NLEST001(cNota, cSerie, cFornec, cLoja)
    Endif
ElseIf lEnder .And. lErro
    If MsgYesNo('Ocorreram erros em alguns produtos no momento do endereçamento.' + CRLF +;
                'Deseja imprimir o relatório de endereços dos produtos ?')
        U_NLEST001(cNota, cSerie, cFornec, cLoja)
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
User Function NLEST001(cNota, cSerie, cFornec, cLoja)

Local oReport := ReportDef(cNota, cSerie, cFornec, cLoja)

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
//Static Function ReportDef(cNome)
Static Function ReportDef(cNota, cSerie, cFornec, cLoja)

Local oReport   := Nil
Local oSection1 := Nil

Static cAliasSDA := GetNextAlias()

oReport := TReport():New('NLEST001',,, {|oReport| ReportPrint(oReport, cAliasSDA, cNota, cSerie, cFornec, cLoja)})

oSection1 := TRSection():New(oReport,'Endereços dos produtos da NF', cAliasSDA)                                                                                                                                                                       
oSection1:SetTotalInLine(.F.)
oSection1:nFontBody := 8

oReport:SetPortrait(.T.)
oReport:nFontBody := 8

oReport:SetTitle('Endereços dos produtos da NF')

// TRCell():New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)                                                                                                                                                                  

TRCell():New(oSection1, 'D1_DOC'    , cAliasSDA, 'Nota Fiscal', '@!'        ,  9,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)
TRCell():New(oSection1, 'D1_SERIE'  , cAliasSDA, 'Série'      , '@!'        ,  3,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)
TRCell():New(oSection1, 'A2_NREDUZ' , cAliasSDA, 'Nome'       , '@!'        , 20,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)
TRCell():New(oSection1, 'D1_COD'    , cAliasSDA, 'Produto'    , '@!'        , 15,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)
TRCell():New(oSection1, 'B1_LOCALIZ', cAliasSDA, 'Cont. End.' , '@!'        , 12,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)             
TRCell():New(oSection1, 'D1_DTDIGIT', cAliasSDA, 'Data'       , '@!'        , 10,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)
TRCell():New(oSection1, 'D1_QUANT'  , cAliasSDA, '   Qtde'    , '@E 999,999',  7,,, 'RIGHT',,'RIGHT',,1,,,,.F.)          
TRCell():New(oSection1, 'B1_UM'     , cAliasSDA, 'UM'         , '@!'        ,  2,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)          
TRCell():New(oSection1, 'D1_LOCAL'  , cAliasSDA, 'Local'      , '@!'        ,  2,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)          
TRCell():New(oSection1, 'DB_LOCALIZ', cAliasSDA, 'Endereço'   , '@!'        , 12,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)             
TRCell():New(oSection1, 'B1_DESC'   , cAliasSDA, 'Descrição'  , '@!'        , 50,,, 'LEFT' ,,'LEFT' ,,1,,,,.F.)

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
Static Function ReportPrint(oReport, cAliasSDA, cNota, cSerie, cFornec, cLoja)

Local oSection1 := oReport:Section(1)

BeginSQL Alias cAliasSDA

	Column D1_DTDIGIT as Date		

	SELECT D1_DOC, D1_SERIE, D1_COD, B1_LOCALIZ, D1_DTDIGIT, D1_QUANT, B1_UM, D1_LOCAL, ISNULL(DB_LOCALIZ,'') AS DB_LOCALIZ, B1_DESC, A2_NREDUZ
	FROM %Table:SD1% SD1 LEFT OUTER JOIN %Table:SDA% SDA ON
            DA_FILIAL  = %xFilial:SDA%    
        AND DA_DOC     = D1_DOC
        AND DA_SERIE   = D1_SERIE
        AND DA_CLIFOR  = D1_FORNECE
        AND DA_LOJA    = D1_LOJA
        AND DA_PRODUTO = D1_COD
        AND SDA.%notdel% LEFT OUTER JOIN %Table:SDB% SDB ON 
			DB_FILIAL = %xFilial:SDB%
		AND DB_NUMSEQ = DA_NUMSEQ
		AND SDB.%notdel% INNER JOIN %Table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
		AND	B1_COD    = D1_COD
        AND B1_MSBLQL <> '1'
		AND SB1.%notdel% INNER JOIN %Table:SA2% SA2 ON
            A2_FILIAL  = %xFilial:SA2%
        AND A2_COD     = D1_FORNECE
        AND A2_LOJA    = D1_LOJA
        AND SA2.%notdel%
	WHERE D1_FILIAL    = %xFilial:SD1%
        AND D1_DOC     = %Exp:cNota%
        AND D1_SERIE   = %Exp:cSerie%
        AND D1_FORNECE = %Exp:cFornec%
        AND D1_LOJA    = %Exp:cLoja%
        AND SD1.%notdel%
	ORDER BY DA_LOCAL, D1_COD

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

