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
    Local cLocal  := ""
    Local cProd   := ""
    Local nTamPrd := GetSx3Cache("B2_COD", "X3_TAMANHO")
    Local nTamLoc := GetSx3Cache("B2_LOCAL", "X3_TAMANHO")
    Local cTicket := PARAMIXB
    Local cOrigem := ''
     
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

    /* Pré Setup MRP */
    ZZ4->(DbGoTop())
    If !ZZ4->(EOF())
        cOrigem := IIF(ZZ4->ZZ4_ORIG0 <> 'S', '', '0')
        cOrigem += IIF(ZZ4->ZZ4_ORIG1 <> 'S', '', '1')
        cOrigem += IIF(ZZ4->ZZ4_ORIG2 <> 'S', '', '2')
        cOrigem += IIF(ZZ4->ZZ4_ORIG3 <> 'S', '', '3')
        cOrigem += IIF(ZZ4->ZZ4_ORIG4 <> 'S', '', '4')
        cOrigem += IIF(ZZ4->ZZ4_ORIG5 <> 'S', '', '5')
        cOrigem += IIF(ZZ4->ZZ4_ORIG6 <> 'S', '', '6')
        cOrigem += IIF(ZZ4->ZZ4_ORIG7 <> 'S', '', '7')
        cOrigem += IIF(ZZ4->ZZ4_ORIG8 <> 'S', '', '8')
    Endif 

    /* Exclui produtos da tabela do MRP */ 
    DbSelectArea('HWA')
    HWA->(DbGoTop())
    While HWA->(!EoF())

        /* Origem do produto */
        If !Empty(cOrigem)
            SB1->(DbSetOrder(1))
            If SB1->(DbSeek(xFilial('SB1') + HWA->HWA_PROD)) .And. !SB1->B1_ORIGEM $ cOrigem
                If RecLock('HWA',.F.)
                    HWA->(DbDelete())
                    HWA->(MsUnlock())
                            
                    HWA->(DbSkip())
                    Loop
                EndIf
            Endif 
        Endif 

        /* Entra no MRP */
        If HWA->HWA_MRP <> '1'
            If RecLock('HWA',.F.)
                HWA->(DbDelete())
                HWA->(MsUnlock())
            EndIf
        Endif
        
        HWA->(DbSkip())
    Enddo

Return Nil  
