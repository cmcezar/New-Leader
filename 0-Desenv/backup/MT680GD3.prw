#include 'protheus.ch'
#include 'parmtype.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MT680GD3
//TODO Ponto de Entrada após a inclusão do movimento na tabela
       SD3, usado para endereçar o produto apontado.
@author Claudio Macedo
@since 15/09/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function MT680GD3()

//Local cProduto    := PARAMIXB[1] // H6_PRODUTO
//Local cOp         := PARAMIXB[2] // H6_OP
//Local cIdentOpPai := PARAMIXB[3] // H6_IDENT

Local aCabSDA := {}
Local aItem   := {}
Local aItens  := {}
Local cEnder  := ''
Local cDoc    := SD3->D3_DOC

Local lRet    := PARAMIXB[4]

Local cAliasSDA := GetNextAlias()

Private lMsErroAuto := .F.

If SD3->D3_CF = 'PR0' .And. Localiza(SD3->D3_COD) // Apontamento de produção com controle de endereço

    // Endereça os produtos que já possuem saldo em um endereço

    BeginSQL Alias cAliasSDA
        SELECT DA_PRODUTO, DA_NUMSEQ, DA_LOCAL, DA_QTDORI
        FROM %Table:SDA% SDA
        WHERE DA_FILIAL   = %xFilial:SDA%
            AND DA_DOC    = %Exp:cDoc%
            AND DA_SALDO  > 0
            AND SDA.%notdel%
    EndSql 

    (cAliasSDA)->(DbGoTop())

    While !(cAliasSDA)->(EOF())

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
            Endif

        Endif 

        (cAliasSDA)->(DbSkip())

    Enddo 

    (cAliasSDA)->(DbCloseArea())

Endif 

Return lRet

//------------------------------------------------------------\\
/*/{Protheus.doc} Localiza
//TODO Verifica se o produto tem controle de endereço.
@author Claudio Macedo
@since 15/09/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
Static Function Localiza(cProduto)

Local lRet := .F.

SB1->(DbSetOrder(1))
IF SB1->(DbSeek(xFilial('SB1') + cProduto)) .And. SB1->B1_LOCALIZ = 'S'
    lRet := .T.
Endif 

Return lRet
