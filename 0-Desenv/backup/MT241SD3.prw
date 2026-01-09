#include 'protheus.ch'

//------------------------------------------------------------\\
/*/{Protheus.doc} MT241SD3
//TODO Ponto de Entrada após a inclusão do movimento na tabela
       SD3, usado para endereçar o produto produzido.
@author Claudio Macedo
@since 15/11/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------\\
User Function MT241SD3()

Alert('MT241SD3 - ' + SD3->D3_TM)

Return Nil
