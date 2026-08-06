#include 'protheus.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MTA265I
//TODO Ponto de Entrada após a distribuição dos saldos por 
  endereço, usado para gravar o campo BE_CODPRO.
@author Claudio Macedo
@since 05/11/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function MTA265I()

Local nLinha  := ParamIXB[1]
Local cEnder  := aCols[nLinha,3]

If Alltrim(FunName()) == 'MATA265'

    // Vincula Endereço x Produto
    ZZ2->(DbSetOrder(1))		// Armazém + Endereço + produto
    If !ZZ2->(DbSeek(xFilial('ZZ2') + SDA->DA_LOCAL + cEnder + SDA->DA_PRODUTO))	
      ZZ2->(reclock('ZZ2',.T.))
      ZZ2->ZZ2_FILIAL := xFilial('ZZ2')
      ZZ2->ZZ2_CODPRO := SDA->DA_PRODUTO
      ZZ2->ZZ2_LOCAL  := SDA->DA_LOCAL
      ZZ2->ZZ2_LOCALI := cEnder
      ZZ2->(MsUnlock())
    Endif 

Endif 

Return Nil 
