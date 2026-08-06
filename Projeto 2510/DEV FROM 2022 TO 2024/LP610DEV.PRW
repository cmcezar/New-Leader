//---------------------------------------------------------------------------------------------------------------------------------=
//LANCAMENTO CONTABIL NOTA FISCAL DE DEVOLUCAO DE COMPRAS BUSCANDO CONTA DA NATUREZA DO TÍTULO DE DEVOLUCAO                        =
//---------------------------------------------------------------------------------------------------------------------------------=
//POR WALDIR ARRUDA 																						                   	   =
//---------------------------------------------------------------------------------------------------------------------------------=

USER FUNCTION LP610DEV()
LOCAL cConta	:= ""
LOCAL aAREA_ATU	:= GETAREA()

If SF2->F2_TIPO == "D" //devolucao

	SD2->(dbSetOrder(3))
	SD2->(MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	
	
	cBusca := SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_SERIORI+SD2->D2_NFORI

	SE2->(DBSetOrder(6))
	SE2->(DBSeeK(xFilial("SE2") +cBusca))
    

	SED->(DBSetOrder(1))
	SED->(DBSeek( XFILIAL("SED") + SE2->E2_NATUREZ ))
	cConta := SED->ED_DEBITO

EndIf

RESTAREA(aAREA_ATU)
RETURN(cConta)