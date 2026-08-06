/*/{Protheus.doc} MTA410E
    P.E. - Executado ANTES de deletar/reativar o registro no SC6 (item do pedido de venda).
/*/
User Function M410LDel()
	Local lRet := .T.
	// Chama a rotina de recálculo dos pesos totais dos itens do pedido
	lRet := U_NLFATF01()
Return lRet
