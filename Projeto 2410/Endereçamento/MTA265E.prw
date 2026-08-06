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
Local cEnder := aCols[nLinha, GDFieldPos('DB_LOCALIZ')]

If U_GetSldBF(SDA->DA_LOCAL, cEnder, SDA->DA_PRODUTO) = 0    // Verifica se o saldo do produto no endereço é igual à zero

    // Desvincula Endereço x Produto
    ZZ2->(DbSetOrder(1))		// Armazém + Endereço + produto

    If ZZ2->(DbSeek(xFilial('ZZ2') + SDA->DA_LOCAL + cEnder + SDA->DA_PRODUTO))	
        ZZ2->(reclock('ZZ2',.F.))
        ZZ2->(DbDelete())
        ZZ2->(MsUnlock())
    Endif 

Endif 

Return Nil

