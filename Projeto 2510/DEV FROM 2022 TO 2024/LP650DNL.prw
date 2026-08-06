User Function LP650DNL()

Local cRet := ""

    IF POSICIONE("CTT",1,XFilial("CTT")+SD1->D1_CC,"CTT_XTIPOC")="1"
                cRet := SB1->B1_XCTADIR
    ElseIf POSICIONE("CTT",1,XFilial("CTT")+SD1->D1_CC,"CTT_XTIPOC")="2"
                cRet := SB1->B1_CTDESPES
    Elseif POSICIONE("CTT",1,XFilial("CTT")+SD1->D1_CC,"CTT_XTIPOC")="3"
		cRet := SB1->B1_XCTAIND
    Else   
		cRet := SB1->B1_CONTA
    EndIf
	//    
Return cRet
