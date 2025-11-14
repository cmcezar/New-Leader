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
    SBE->(DbSetOrder(1))

    If SBE->(DbSeek(xFilial('SBE') + SDA->DA_LOCAL + cEnder))
        SBE->(reclock('SBE',.F.))
        SBE->BE_CODPRO := SDA->DA_PRODUTO
        SBE->(MsUnlock())
        MsgInfo('Produto ' + Alltrim(SDA->DA_PRODUTO) + ' vinculado ao endereço ' + cEnder)
    Endif 
Endif 

Return Nil 
