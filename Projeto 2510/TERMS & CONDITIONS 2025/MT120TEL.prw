#Include "Protheus.ch"
   
 /*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |
 | Desc:  Ponto de Entrada para adicionar campos no cabeçalho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  6, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local oXTermo
    Public cXTermo := ''
  
    //Define o conteúdo para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXTermo := GetMV('NL_XTERMO')
    Else
        cXTermo := SC7->C7_XTERMO
    EndIf
  
    //Criando na janela o campo Termo
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle('C7_XTERMO')) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXTermo VAR cXTermo SIZE 10, 006 OF oDlg COLORS 0, 16777215  PIXEL F3 "ZZ1" 
    oXTermo:bHelp := {|| ShowHelpCpo('C7_XTERMO', {GetHlpSoluc('C7_XTERMO')[1]}, 5  )}
  
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXTermo:lActive := .F.
    EndIf
  
    RestArea(aArea)
Return
   
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MTA120G2                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações no pedido de compra a cada item (usado junto com MT120TEL)   |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6085572                                          |
 *--------------------------------------------------------------------------------------------------------------*/
   
User Function MTA120G2()

Local aArea := GetArea()

//Atualiza o termo com a variável pública criada no ponto de entrada MT120TEL
If FunName() = 'PCEXCEL'
    SC7->C7_XTERMO := GetMV('NL_XTERMO')
Else 
    SC7->C7_XTERMO := cXTermo
Endif 

RestArea(aArea)

Return
