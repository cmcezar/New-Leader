#Include 'Protheus.ch'

//------------------------------------------------------------------------\\
/*/{Protheus.doc} MA103OPC
Ponto de entrada para acrescentar rotinas no browse do documento de entrada
@type 	 Function
@author  Claudio
@since 	 20/12/2017
@version 1.0
@example MA103OPC()
/*/
//------------------------------------------------------------------------\\
User Function MA103OPC()

aAdd(aRotina,{'Log Endereçamento','U_NLEST001(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)',0,5 })

Return aRotina

