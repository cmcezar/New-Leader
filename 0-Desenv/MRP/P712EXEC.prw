#include 'protheus.ch'  

//----------------------------------------------\\
/*/{Protheus.doc} P712EXEC
// Ponto de entrada utilizado para selecionar somente
   os produtos da tabela HWA onde o campo HWA_MRP = 1
@author Claudio Macedo
@since 06/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\ 
User Function P712EXEC()
    Local cEmpBusca := "01"
    Local cFilBusca := "01"
    Local cLocal    := ""
    Local cProd     := ""
    Local nTamPrd   := GetSx3Cache("B2_COD", "X3_TAMANHO")
    Local nTamLoc   := GetSx3Cache("B2_LOCAL", "X3_TAMANHO")
    Local cTicket   := PARAMIXB
     
    //Parâmetros de execução do MRP podem ser obtidos na tabela HW1
    HW1->(dbSeek(xFilial("HW1") + cTicket))
 
    // Abre a tabela da outra empresa para buscar os dados
    //NGPrepTBL({{"SB2",1}}, cEmpBusca, cFilBusca)
  
    /*
    DbSelectArea("T4V")
    T4V->(DbGoTop())
    While T4V->(!EoF())
        cProd  := PadR(T4V->T4V_PROD , nTamPrd)
        cLocal := PadR(T4V->T4V_LOCAL, nTamLoc)
    
        If SB2->(DbSeek(xFilial('SB2') + cProd + cLocal))
            If RecLock('T4V',.F.)
                T4V->T4V_QTD += SB2->B2_QATU //soma o saldo de outra filial no saldo atual do MRP.
                T4V->(MsUnlock())
            EndIf
        EndIf
        T4V->(DbSkip())
    End
    */

    DbSelectArea('HWA')
    HWA->(DbGoTop())
    While HWA->(!EoF())
        If HWA->HWA_MRP <> '1'
            If RecLock('HWA',.F.)
                HWA->(DbDelete())
                HWA->(MsUnlock())
            EndIf
        Endif
        HWA->(DbSkip())
    Enddo

Return Nil  
