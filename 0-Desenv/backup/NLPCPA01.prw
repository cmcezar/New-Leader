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
User Function NLPCPA01()

Private cCadastro := 'Pré Setup MRP'         
                                                                
Private aRotina := {{'Alterar', 'AxAltera', 0, 4}}

MBrowse(,,,,'ZZ4',,,,,2,)

//AxCadastro('ZZ4')

Return Nil 
