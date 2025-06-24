#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'

//--------------------------------------------------------------------\\
/*/{Protheus.doc} NLCOMA02
// Alterar a data de entrega dos itens de um pedido de compra.
@author Claudio Macedo
@since 01/06/2025
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function NLCOMA02(cNumPed)

Local oDlg 

Local aSize    := {}
Local cTitulo  := OemToAnsi('Itens do Pedido de Compra')
Local bCancel  := {||oDlg:End()} 
Local bOk	   := {||Processa( {|| U_Confirmar(oDlg,oGetDados,cNumPed) }, 'Aguarde', 'Atualizando as datas de entrega',.F.)}
Local aButtons := {}              

/* ------------------------- Variáveis do MsGetDados ------------------------- */

Local nTop      := 35				        // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contém.
Local nLeft     := 60				        // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contém.
Local nBottom   := 250				        // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contém.
Local nRight    := 640				        // Distancia entre a MsNewGetDados e o extremidade direita do objeto que a contém.
Local nStyle    := GD_UPDATE				// Essa nova propriedade, passada via parâmetro, substitui a passagem das variáveis nOpc. 
									        // Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade 
									        // da MsNewGetdados.
/*Local cLinhaOK  := ''	                    // Função executada para validar o contexto da linha atual do aCols.*/
/*Local cTudoOK   := ''				        // Função executada para validar o contexto geral da MsNewGetDados (todo aCols).*/
/*Local cIniCpos  := ''				        // Nome dos campos do tipo caracter que utilizarão incremento automático. Este parametro deve ser no formato “+++...”.*/
Local aAlter    := {'DATAENT'}  		    // Vetor com os campos que poderão ser alterados.
/*Local nFreeze   := 0				        // Congela a coluna da esquerda para a direita. Se 0 não congela, se 1 congela a primeira coluna. */
									        // Obs: atualmente só é possivel congelar a primeira coluna, devido a limitação do objeto.
Local nMax      := 900				        // Número máximo de linhas permitidas. Valor padrão 99.*/
/*Local cFieldOK	:= ''				    // Função executada na validação do campo. */
/*Local cSuperDel := ''				        // Função executada quando pressionada as teclas +.*/
/*Local cDelOK	:= ''				        // Função executada para validar a exclusão de uma linha do aCols.*/
/*Local oWnd							    // Objeto no qual a MsGetDados será criada.*/
/*Local aPartHeader := {}				    // aHeader*/
/*Local aParCols	  := {}	 			    // aCols*/
/*Local uChange	  := {||}			        // Bloco de código	Bloco de execução a ser executado na propriedade bChange do Objeto.*/
/*Local cTela		  := ''				    // Caracter	String contendo os campos contidos no X3_TELA.*/

Private aHeader   := {}
Private aCols     := {}
Private cAliasSC7 := GetNextAlias()

Processa( {|| U_GetDadosSC7(cNumPed) }, 'Aguarde...', 'Carregando pedido de compra ...',.F.)

aSize := MsAdvSize()

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL	      	

oGetdados := MsNewGetDados():New(nTop,nLeft,nBottom,nRight,nStyle,/*cLinhaOK*/,/*cTudoOK*/,/*cIniCpos*/,aAlter,/*nFreeze*/,nMax,/*cFieldOK*/,/*cSuperDel*/,/*cDelOK*/,oDlg,aHeader,aCols,/*uChange*/,/*cTela*/)		

ACTIVATE MSDIALOG oDlg ON INIT (oGetDados:oBrowse:Refresh(),EnchoiceBar(oDlg, bOk, bCancel, ,aButtons)) 

Return Nil

//--------------------------------------------------------------------\\
/*/{Protheus.doc} GetDadosSC7
// Criar aHeader, aCols.
@author Claudio Macedo
@since 01/06/2025
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function GetDadosSC7(cNumPed)

aAdd(aHeader,{'Item'		   , 'C7_ITEM'   , '@!'			       , 15, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','C',/*F3*/,'V'})
aAdd(aHeader,{'Produto'		   , 'C7_PRODUTO', '@!'			       , 15, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','C',/*F3*/,'V'})
aAdd(aHeader,{'Descrição'	   , 'B1_DESC'   , '@!'			       , 30, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','C',/*F3*/,'V'})
aAdd(aHeader,{'Quantidade'	   , 'C7_QUANT'  , '@E 999,999,999.99' , 12, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','N',/*F3*/,'V'})
aAdd(aHeader,{'UM'			   , 'C7_UM'     , '@!'			       ,  2, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','C',/*F3*/,'V'})
aAdd(aHeader,{'Data de Entrega', 'DATAENT'   , '99/99/9999'		   ,  8, 0, '', 'ÿÿu¤'+chr(65533)+chr(65533)+'nA€'+chr(65533)+'€€€ƒ€','D',/*F3*/,'V'})

BeginSQL Alias cAliasSC7

	SELECT C7_ITEM, C7_PRODUTO, B1_DESC, B1_UM, C7_QUANT, C7_DATPRF AS DATAENT
	FROM %Table:SC7% SC7 INNER JOIN %Table:SB1% SB1 ON 
			B1_COD = C7_PRODUTO
		AND B1_FILIAL = %xFilial:SB1%
		AND B1_MSBLQL <> '1'
		AND SB1.%notdel% 
	WHERE SC7.%notdel% 
		AND C7_NUM = %Exp:cNumPed%
		AND C7_QUJE < C7_QUANT
	ORDER BY C7_ITEM
	
EndSQL

TcSetField((cAliasSC7),'DATAENT','D')

ProcRegua((cAliasSC7)->(RecCount()))

(cAliasSC7)->(DbGoTop())

While !(cAliasSC7)->(Eof())
 	IncProc()
	
	aAdd(aCols,{(cAliasSC7)->C7_ITEM, (cAliasSC7)->C7_PRODUTO, (cAliasSC7)->B1_DESC, (cAliasSC7)->C7_QUANT, (cAliasSC7)->B1_UM,  DTOC((cAliasSC7)->DATAENT), .F.})
	
	(cAliasSC7)->(DbSkip())
Enddo

(cAliasSC7)->(DbCloseArea())

Return Nil

//--------------------------------------------------------------------\\
/*/{Protheus.doc} Confirmar
// Liberar pedidos de venda
@author Cláudio Macedo
@since 09/11/2018
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function Confirmar(oDlg,oGrid,cNumPed)

Local nI := 0

ProcRegua(Len(oGrid:aCols))

For nI := 1 to Len(oGrid:aCols)
    
    IncProc() 

    If oGrid:aCols[nI][Len(oGrid:aCols[nI])] = .F.
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial('SC7') + cNumPed + aCols[nI][1]))
			SC7->(reclock('SC7',.F.))
			SC7->C7_DATPRF := Ctod(oGrid:aCols[nI][6])
			SC7->(MsUnlock())
		Endif 
    Endif

Next nI

MsgInfo('Datas atualizadas com sucesso !')

oDlg:End()

Return Nil

