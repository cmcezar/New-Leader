#include 'protheus.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MT103FIM
//TODO Ponto de Entrada ap�s a inclus�o do documento de entrada,
       utilizado para endere�ar os produtos.
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
Local cNota   := SD1->D1_DOC
Local cSerie  := SD1->D1_SERIE
Local cFornec := SD1->D1_FORNECE
Local cLoja   := SD1->D1_LOJA
Local cEnder  := ''

Local cAliasSDA := GetNextAlias()

Private lMsErroAuto := .F.

If Inclui

    BeginSQL Alias cAliasSDA
        SELECT DA_PRODUTO, DA_NUMSEQ, DA_LOCAL, DA_QTDORI
        FROM %Table:SDA% SDA
        WHERE DA_FILIAL   = %xFilial:SDA%
            AND DA_DOC    = %Exp:cNota%
            AND DA_SERIE  = %Exp:cSerie%
            AND DA_CLIFOR = %Exp:cFornec%
            AND DA_LOJA   = %Exp:cLoja%
            AND SDA.%notdel%
    EndSql 

    (cAliasSDA)->(DbGoTop())

    While !(cAliasSDA)->(EOF())

        SBF->(DbSetOrder(2))    // Filial+Produto+Local
        If SBF->(DbSeek(xFilial('SBF') + (cAliasSDA)->DA_PRODUTO + (cAliasSDA)->DA_LOCAL))

            cEnder := SBF->BF_LOCALIZ

            aItens := {}

            //Cabecalho com a informa��o do item e NumSeq que sera endere�ado.
            aCabSDA := {{'DA_PRODUTO' ,(cAliasSDA)->DA_PRODUTO, Nil},;
                        {'DA_NUMSEQ'  ,(cAliasSDA)->DA_NUMSEQ , Nil}}

            //Dados do item que ser� endere�ado
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
                MsgInfo('Produtos endere�ados !', 'Sucesso')
            Endif

        Endif 

        (cAliasSDA)->(DbSkip())

    Enddo 

    (cAliasSDA)->(DbCloseArea())

Endif 

Return Nil

