
User function MT120BRW()

	dbSelectArea("SC7")
	dbSetOrder(1)
	while !SC7->(eof())
		If len(alltrim(SC7->C7_NOMEFOR)) = 0
			Reclock("SC7",.F.)
			_nomFor := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")
			SC7->C7_NOMEFOR := _nomFor
			SC7->(MsUnlock())        
		EndIf
			SC7->(DbSkip())
			
	ENDDO	



Return
