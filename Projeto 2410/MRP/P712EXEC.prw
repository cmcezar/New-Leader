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

Local cTicket   := PARAMIXB
    
//Parâmetros de execução do MRP podem ser obtidos na tabela HW1
HW1->(dbSeek(xFilial("HW1") + cTicket))

/* Exclui produtos da tabela do MRP */ 
DbSelectArea('HWA')
HWA->(DbGoTop())
While HWA->(!EoF())
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

