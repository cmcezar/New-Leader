#include 'protheus.ch'
#include 'parmtype.ch'

// -------------------------------------------- \\
/*/{Protheus.doc} NLESTA01()
// Cadstro para vicncular produto à um endereço.
@author Claudio Macedo
@since 20/11/2025
@version 1.0
@type Function
/*/
// -------------------------------------------- \\
User Function NLESTA01()

Local aCores  := {{"U_GetSldBF(ZZ2->ZZ2_LOCAL, ZZ2->ZZ2_LOCALI, ZZ2->ZZ2_CODPRO) = 0", "BR_VERDE"},;
          		  {"U_GetSldBF(ZZ2->ZZ2_LOCAL, ZZ2->ZZ2_LOCALI, ZZ2->ZZ2_CODPRO) > 0" , "BR_VERMELHO"}}

Private cCadastro := 'Endereço x Produto'         
                                                                
Private aRotina := {{'Visualizar', 'AxVisual', 0, 2},;
                    {'Incluir'   , 'AxInclui', 0, 3},;
                    {'Excluir'   , 'U_ESTA01A()', 0, 5},;
                    {'Legenda'   , 'LegPCP01', 0, 6}}

MBrowse(,,,,'ZZ2',,,,,2,aCores)

Return Nil

// -------------------------------------------- \\
/*/{Protheus.doc} LegPCP01()
// Legenda.
@author Claudio Macedo
@since 17/04/2019
@version 1.0
@type Function
/*/
// -------------------------------------------- \\
Static Function LegPCP01()

BrwLegenda('Legenda', '', {{'BR_VERDE'   , 'Vazio'},;
                           {'BR_VERMELHO', 'Ocupado'}})
Return .T.

// -------------------------------------------- \\
/*/{Protheus.doc} GetSldBF()
// Retorna o saldo do produto no endereço e armazém
@author Claudio Macedo
@since 20/11/2025
@version 1.0
@type Function
/*/
// -------------------------------------------- \\
User Function GetSldBF(cLocal, cEnder, cProduto)

Local nSaldo := 0

SBF->(DbSetOrder(1))
If SBF->(DbSeek(xFilial('SBF') + cLocal + cEnder + cProduto)) .And. SBF->BF_QUANT > 0
    nSaldo := SBF->BF_QUANT
Endif 

Return nSaldo

// -------------------------------------------- \\
/*/{Protheus.doc} ESTA01A()
// Exclui o vínculo do Endereço x Produto, caso 
   não tenha saldo no endereço.
@author Claudio Macedo
@since 20/11/2025
@version 1.0
@type Function
/*/
// -------------------------------------------- \\
User Function ESTA01A()

// Verifica se existe saldo do produto no endereço
If  U_GetSldBF(ZZ2->ZZ2_LOCAL, ZZ2->ZZ2_LOCALI, ZZ2->ZZ2_CODPRO) = 0

    If MsgYesNo('Confirma a exclusão do vínculo do endereço ' + Alltrim(ZZ2->ZZ2_LOCALI) +;
                ' com o produto '+ Alltrim(ZZ2->ZZ2_CODPRO) + ' ?')
    
        ZZ2->(reclock('ZZ2', .F.))
        ZZ2->(DbDelete())
        ZZ2->(MsUnlock())
        
        MsgInfo('Vínculo do endereço x produto excluído !')

    Endif 
 
Else
    Alert('Não foi possível excluir o vínculo, pois existe saldo do produto no endereço. ')
Endif 

Return Nil
