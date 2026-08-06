User Function ajusd1()
dbSelectArea("SD1")
	dbSetOrder(1)
	While SD1->(!Eof())
				Reclock("SD1",.T.)
				SD1->D1_ZZDESC    := Alltrim(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"))
				SD1->(MsUnlock())		
		SD1->(DbSkip())
	EndDo
Return	
