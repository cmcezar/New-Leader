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
    Local cImport   := ''
     
    //Parâmetros de execução do MRP podem ser obtidos na tabela HW1
    HW1->(dbSeek(xFilial("HW1") + cTicket))
 
    /* Pré-setup MRP */
    ZZ4->(DbGoTop())
    If !ZZ4->(EOF())
        cImport := ZZ4->ZZ4_IMPORT
    Endif 

    /* Exclui produtos da tabela do MRP */ 
    DbSelectArea('HWA')
    HWA->(DbGoTop())
    While HWA->(!EoF())

        /* Origem do produto */
        If cImport <> 'A'   // Ambos
            SB1->(DbSetOrder(1))
            If SB1->(DbSeek(xFilial('SB1') + HWA->HWA_PROD)) 
                If (cImport = 'I' .And. SB1->B1_IMPORT <> 'S') .Or. (cImport = 'N' .And. SB1->B1_IMPORT = 'S')
                    If RecLock('HWA',.F.)
                        HWA->(DbDelete())
                        HWA->(MsUnlock())
                        HWA->(DbSkip())
                        Loop
                    EndIf
                Endif 
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

