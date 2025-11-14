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
Local cEnder  := aCols[nLinha,3]

SBE->(DbSetOrder(1))

If SBE->(DbSeek(xFilial('SBE') + SDA->DA_LOCAL + cEnder))
    SBE->(reclock('SBE',.F.))
    SBE->BE_CODPRO := ''
    SBE->(MsUnlock())
    MsgInfo('Produto ' + Alltrim(SDA->DA_PRODUTO) + ' desvinculado do endereço ' + cEnder)
Endif 

Return Nil 
