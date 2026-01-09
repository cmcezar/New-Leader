#include 'protheus.ch'
#include 'apvt100.ch'
#include 'fwmvcdef.ch'

//-----------------------------------------------------\\
/*/{Protheus.doc} ACD166FM
// Ponto de entrada no final do processo de separação.
@author Claudio Macedo
@since 24/11/2025
@version 1.0
@return Nil
@type Function 
/*/
//-----------------------------------------------------\\
User Function ACD166FM()

CBAlert('ACD166FM','.:Aviso:.',.T.,,2)
CBAlert(CB7->CB7_ORDSEP,'.:Aviso:.',.T.,,2)

Return Nil
