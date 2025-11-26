#include 'protheus.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MTA265E
//TODO Ponto de Entrada após o estorno do endereçamento dos 
  saldos, usado para limpar o campo BE_CODPRO.
@author Claudio Macedo
@since 05/11/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function MTA265E()

Local nLinha  := ParamIXB[1]
//Local cEnder  := aCols[nLinha,3]
Local cEnder := aCols[nLinha, GDFieldPos('DB_LOCALIZ')]
//Local nQuant := aCols[nLinha, GDFieldPos('DB_QUANT')]

/*
SBE->(DbSetOrder(1))

If SBE->(DbSeek(xFilial('SBE') + SDA->DA_LOCAL + cEnder))
    SBE->(reclock('SBE',.F.))
    SBE->BE_CODPRO := ''
    SBE->(MsUnlock())
    MsgInfo('Produto ' + Alltrim(SDA->DA_PRODUTO) + ' desvinculado do endereço ' + cEnder)
Endif 
*/

//If SldZero(SDA->DA_LOCAL, cEnder, SDA->DA_PRODUTO, nQuant)    // Verifica se a quantidade estornada é igual ao saldo do produto no endereço

If U_GetSldBF(SDA->DA_LOCAL, cEnder, SDA->DA_PRODUTO) = 0    // Verifica se o saldo do produto no endereço é igual à zero

    // Vincula Endereço x Produto
    ZZ2->(DbSetOrder(1))		// Armazém + Endereço + produto

    If ZZ2->(DbSeek(xFilial('ZZ2') + SDA->DA_LOCAL + cEnder + SDA->DA_PRODUTO))	
        ZZ2->(reclock('ZZ2',.F.))
        ZZ2->(DbDelete())
        ZZ2->(MsUnlock())
    Endif 

Endif 

Return Nil

//------------------------------------------------------------\\
/*/{Protheus.doc} SldZero
//TODO Verifica se a quantidade estornada é igual ao saldo do 
       produto no endereço.
@author Claudio Macedo
@since 05/11/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
/*
Static Function SldZero(cLocal, cEnder, cProduto, nQuant)

Local lRet := .F.

SBF->(DbSetOrder(1))
If SBF->(DbSeek(xFilial('SBF') + cLocal + cEnder + cProduto)) .And. SBF->BF_QUANT = nQuant
    lRet := .T.
Endif 

Return lRet
*/
