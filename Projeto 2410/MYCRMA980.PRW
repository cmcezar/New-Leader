#include "Protheus.ch"
#include "FWMVCDEF.CH"

Static __LogTela    := NIL

//-------------------------------------------------------------------

/*/{Protheus.doc} CRMA980

Ponto de Entrada do Cadastro de Clientes (MVC)
@param      Nao ha
@return     Varios. Dependerá de qual PE esta sendo executado.
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/

//-------------------------------------------------------------------

User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6
    Local aParam        := PARAMIXB
    Local xRet          := .T.
    Local lIsGrid       := .F.
//  Local nLinha        := 0
//  Local nQtdLinhas    := 0
//  Local cRotMVC       := "CRMA980"
    Local cIDPonto      := ''
    Local cIDModel      := ''
//  Local cIDForm       := ''
//  Local cEvento       := ''
//  Local cCampo        := ''
//  Local cConteudo     := ''
//  Local cMsg          := ''
    Local oObj          := NIL

    If __LogTela == NIL
        /*__LogTela   := ApMsgYesNo("A geracao do 'LOG de processamento' dos PE 'CRMA980' (MVC) sera exibido em TELA?" + CRLF + CRLF +;
            'SIM = TELA' + CRLF +;
            'NAO = CONSOLE do AppServer')*/
    EndIf

    If aParam <> NIL
        oObj        := aParam[1]
        cIDPonto    := aParam[2]
        cIDModel    := aParam[3]
        lIsGrid     := (Len(aParam) > 3)
        nOperation := oObj:GetOperation()

        If cIDPonto == 'MODELCOMMITTTS'
            // Mostra o tipo de Operacao
            //MsgAlert("Operacao " + CValToChar(nOperation), "Tipo de operacao MODELCOMMITTTS")
            // Inclusao

            //If nOperation == 3
                //MsgAlert("Entrou no PE - Operacao de Inclusao", "Tipo de operacao 3 MODELCOMMITTTS")
                //MsgAlert("entrou no ponto", "MYCRMA980")
                u_AtuClasse()
           //EndIf

            // Alteracao
            //If nOperation == 4
            //    MsgAlert("Entrou no PE - Operacao de Alteracao", "Tipo de operacao 4 MODELCOMMITTTS")
            //EndIf

            // Exclusao
            If nOperation == 5
                //MsgAlert("Entrou no PE - Operacao de Exclusao", "Tipo de operacao 5 MODELCOMMITTTS")
            EndIf
        EndIf
    EndIf
Return xRet
User Function MA030TOK
Local lRet := .T.

    u_AtuClasse()
Return lRet
