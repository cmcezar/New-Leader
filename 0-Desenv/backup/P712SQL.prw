#include 'totvs.ch'

//----------------------------------------------\\
/*/{Protheus.doc} P712SQL
// Ponto de entrada utilizado para selecionar somente
   os produtos da tabela HWA onde o campo HWA_MRP = 1
@author Claudio Macedo
@since 06/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function P712SQL()

    Local aRetorno   := {}
    Local cTabela    := Trim(PARAMIXB[1])
    Local cFields    := Trim(PARAMIXB[2])
    Local cQueryCon  := Trim(PARAMIXB[3])
    Local cOrder     := Trim(PARAMIXB[4])
    Local lBeginSql2 := .F.
    Local lBeginSql3 := .F.
    Local lBeginSql4 := .F.
    Local lAlterou   := .T.
 
    //Tratamento BeginSQL
    If Right(cFields, 1) == '%'
        cFields    := StrTran(cFields, "%", "")
        lBeginSql2 := .T.
    EndIf
    If Right(cQueryCon, 1) == '%'
        cQueryCon  := StrTran(cQueryCon, "%", "")
        lBeginSql3 := .T.
    EndIf
    If Right(cOrder, 1) == '%'
        cOrder     := StrTran(cOrder, "%", "")
        lBeginSql4 := .T.
    EndIf
 
    Conout("Query de carga da tabela " + cTabela + ":")
    Conout("SELECT " + cFields + " FROM " + cQueryCon + " ORDER BY " + cOrder)
 
    Do Case
        //Só serão considerados os produtos com o campo B1_MRP = '1' 
        Case cTabela == 'HWA'
            cQueryCon += " AND HWA_MRP = '1' "
 
        //Só consideraremos Pedidos de Compras com quantidade maior que 10
//        Case cTabela == 'T4U'
//        cQueryCon += " AND T4U_QTD > 10 "
 
        //Só consideraremos OPs com quantidade maior que 100
//        Case cTabela == 'T4Q'
//            cQueryCon += " AND T4Q_SALDO > 100 "
 
        //Trocaremos o armazém da demanda pelo armazém do produto
//        Case cTabela == 'T4J'
//            cFields := StrTran(cFields, " T4J.T4J_LOCAL", " HWA.HWA_LOCPAD As T4J_LOCAL")
 
        Otherwise
            lAlterou := .F.
    EndCase
 
    //Só precisa retornar o array aRetorno se realmente a query foi alterada
    If lAlterou
        Conout("A carga da tabela " + cTabela + " utilizara a query especifica:")
        Conout("SELECT " + cFields + " FROM " + cQueryCon + " ORDER BY " + cOrder)
 
        //Tratamento BeginSQL
        If lBeginSql2
            cFields := "% " + cFields + "%"
        EndIf
        If lBeginSql3
            cQueryCon := "% " + cQueryCon + "%"
        EndIf
        If lBeginSql4
            cOrder := "% " + cOrder + "%"
        EndIf
 
        aAdd(aRetorno, cFields)
        aAdd(aRetorno, cQueryCon)
        aAdd(aRetorno, cOrder)
    Else
        Conout("A carga da tabela " + cTabela + " utilizara a query padrao do MRP.")
    EndIf
 
Return aRetorno
