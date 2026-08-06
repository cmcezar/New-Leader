#include 'protheus.ch'
#include 'apvt100.ch'
#include 'fwmvcdef.ch'

//-----------------------------------------------------\\
/*/{Protheus.doc} ACD166FI
// Ponto de entrada no final do processo de separação, 
   usado para endereçar os produtos separados.
@author Claudio Macedo
@since 24/11/2025
@version 1.0
@return Nil
@type Function 
/*/
//-----------------------------------------------------\\
User Function ACD166FI()

U_EndProd(CB7->CB7_ORDSEP)

Return Nil

//-----------------------------------------------------\\
/*/{Protheus.doc} EndProd
// Endereçar os produtos separados.
@author Claudio Macedo
@since 24/11/2025
@version 1.0
@return Nil
@type Function 
/*/
//-----------------------------------------------------\\
User Function EndProd(cOrdSep)

Local aCabSDA := {}
Local aItem   := {}
Local aItens  := {}

Local cAliasSDA := GetNextAlias()

Private lMsErroAuto := .F.

// Endereça os produtos que já possuem saldo em um endereço

BeginSQL Alias cAliasSDA

    SELECT CB9_ORDSEP, CB9_DOC, DA_PRODUTO, DA_NUMSEQ, DA_LOCAL, DA_QTDORI
    FROM %Table:CB9% CB9 INNER JOIN %Table:SDA% SDA ON
            DA_FILIAL = %xFilial:SDA%
        AND DA_DOC    = CB9_DOC
        AND DA_SALDO  > 0
        AND SDA.%notdel%
    WHERE CB9_FILIAL   = %xFilial:CB9%
        AND CB9_ORDSEP = %Exp:cOrdSep%
        AND CB9.%notdel%

EndSql 

(cAliasSDA)->(DbGoTop())

While !(cAliasSDA)->(EOF())

    aItens := {}

    //Cabecalho com a informação do item e NumSeq que sera endereçado.
    aCabSDA := {{'DA_PRODUTO' ,(cAliasSDA)->DA_PRODUTO, Nil},;
                {'DA_NUMSEQ'  ,(cAliasSDA)->DA_NUMSEQ , Nil}}

    //Dados do item que será endereçado
    aItem := {{'DB_ITEM'   , '0001'   , Nil},;
                {'DB_ESTORNO', ' '      , Nil},;
                {'DB_LOCAL'  , (cAliasSDA)->DA_LOCAL , Nil},;
                {'DB_LOCALIZ', 'PADRAO'   , Nil},;
                {'DB_DATA'   , dDataBase, Nil},;
                {'DB_QUANT'  , (cAliasSDA)->DA_QTDORI, Nil}}

    aadd(aItens,aItem)

    //Executa o endereçamento do item
    MATA265(aCabSDA, aItens, 3)

    If lMsErroAuto
        MostraErro()
    Endif

    (cAliasSDA)->(DbSkip())

Enddo 

(cAliasSDA)->(DbCloseArea())

Return Nil 
