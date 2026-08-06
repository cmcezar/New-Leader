#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'

//--------------------------------------------------------------------\\
/*/{Protheus.doc} NLCOMA03
// Alterar a data de entrega de todos os itens de um pedido de compra.
@author Claudio Macedo
@since 01/06/2025
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function NLCOMA03(cNumPed)

Local oDlg 
Local cTitulo  := OemToAnsi('Alterar data de entrega')
Local bCancel  := {||oDlg:End()} 
Local bOk	   := {||Processa( {|| U_GRAVASC7(cNumPed, oDlg) }, 'Aguarde', 'Gravando a nova data de entrega.',.F.)}       

Local lHasButton := .T.

Private cData := '  /  /    '
Private oFont    := TFont():New('Arial',,-12,.T.)

DEFINE MSDIALOG oDlg FROM  0,0 TO 140,250 TITLE cTitulo PIXEL	

oSay1 := TSay():New(12,10,{||'Nova data de entrega:'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
oSay1:lTransparent = .T.
oSay1:lWordWrap = .F.

oGet1 := TGet():New( 12, 75, { | u | If( PCount() == 0, cData, cData := u ) },oDlg, ;
    035, 010, "99/99/9999",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,'cData',,,,lHasButton  )

SButton():New(40, 50, 02, bCancel, oDlg, .T.,,)
SButton():New(40, 90, 13, bOk,     oDlg,.T.,,)

ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

//--------------------------------------------------------------------\\
/*/{Protheus.doc} GRAVASC7
// Grava a nova data de entrega em todos os itens do pedido de compra.
@author Claudio Macedo
@since 05/06/2025
@version 1.0
@return Nil
@type Function
/*/
//--------------------------------------------------------------------\\
User Function GRAVASC7(cNumPed, oDlg)
 
SC7->(DbSetOrder(1))
SC7->(DbSeek(xFilial('SC7') + cNumPed))

While !(SC7->(EOF())) .And. cNumPed = SC7->C7_NUM

    SC7->(reclock('SC7',.F.))
    SC7->C7_DATPRF := CTOD(cData)
    SC7->(MsUnlock())

    SC7->(DbSkip())

Enddo 

MsgInfo('Datas atualizadas com sucesso !')
oDlg:End()

Return
