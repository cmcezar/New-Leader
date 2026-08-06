#include 'protheus.ch'

//--------------------------------------------------------------------\\
/*/{Protheus.doc} NLCOMA02
// Ponto de entrada para adicionar rotinas no browse do pedido de compra.
@author Claudio Macedo
@since 06/05/2021
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function MT120BRW()

//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa‡„o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     

Local aRotina2 := {}

aRotina2  := {{ 'Pedido','U_NLCOMA03(SC7->C7_NUM)', 0, 5},;
			  { 'Item'  ,'U_NLCOMA02(SC7->C7_NUM)', 0, 5}}	

AAdd(aRotina, { 'Alterar Entrega', aRotina2, 0, 4 } )

Return 
