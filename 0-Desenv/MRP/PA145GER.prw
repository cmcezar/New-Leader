#include 'totvs.ch'
 
//----------------------------------------------\\
/*/{Protheus.doc} PA145GER
// Ponto de entrada utilizado para antecipar as 
   datas de entrega e início de compras dos produtos
   das solicitações de compras geradas pelo MRP.
@author Claudio Macedo
@since 16/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\ 
User Function PA145GER()

Local cAliasSC1 := GetNextAlias()
Local nDiasAnt  := Val(Alltrim(GetMV('NL_DIASANT')))
Local cOrigem   := 'PCPA144'
Local cTicket   := PARAMIXB[1]

//
//SC1 - Solicitações de Compra
//
BeginSql Alias cAliasSC1
    SELECT C1_FILIAL, C1_NUM, C1_ITEM
    FROM %Table:SC1%
    WHERE C1_SEQMRP = %Exp:cTicket%
        AND C1_ORIGEM = %Exp:cOrigem%
        AND %notDel%
EndSql

// Percorre todos os registros gerados no processamento
While (cAliasSC1)->(!Eof())
    SC1->(DbSetOrder(1))
    If SC1->(DbSeek(xFilial('SC1') + (cAliasSc1)->C1_NUM + (cAliasSc1)->C1_ITEM))
        SC1->(recLock('SC1',.F.))
        SC1->C1_XNECMRP := SC1->C1_DATPRF
        // Data da necessidade
        If Dow(DaySub(SC1->C1_DATPRF, nDiasAnt)) = 1      // Domingo = nDiasAnt-1 -> Segunda-feira
            SC1->C1_DATPRF  := DaySub(SC1->C1_DATPRF, nDiasAnt - 1)
        ElseIf Dow(DaySub(SC1->C1_DATPRF, nDiasAnt)) = 7  // Sábado = nDiasAnt+1 -> Sexta-feira
            SC1->C1_DATPRF  := DaySub(SC1->C1_DATPRF, nDiasAnt + 1)
        Else
            SC1->C1_DATPRF  := DaySub(SC1->C1_DATPRF, nDiasAnt)
        Endif 
        // Data do início de compras
        If Dow(DaySub(SC1->C1_DINICOM, nDiasAnt)) = 1      // Domingo = nDiasAnt-1 -> Segunda-feira
            SC1->C1_DINICOM := DaySub(SC1->C1_DINICOM, nDiasAnt - 1)
        ElseIf Dow(DaySub(SC1->C1_DINICOM, nDiasAnt)) = 7  // Sábado = nDiasAnt+1 -> Sexta-feira
            SC1->C1_DINICOM := DaySub(SC1->C1_DINICOM, nDiasAnt + 1)
        Else
            SC1->C1_DINICOM := DaySub(SC1->C1_DINICOM, nDiasAnt)
        Endif         
        SC1->(MsUnlock())
    Endif 
    (cAliasSC1)->(dbSkip())
Enddo
(cAliasSC1)->(dbCloseArea())
//

Return Nil 
