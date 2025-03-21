User function LPCCC()
Local RETORNO := " "
	Do Case
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XCREDIR"),1,1)$ ("1/2")
			RETORNO := ""
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XCREIND"),1,1)$ ("1/2")
			RETORNO := " "
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XCREDES"),1,1)$ ("1/2")
			RETORNO := ""
		otherwise
			RETORNO := SRZ->RZ_CC
	EndCase        

Return    RETORNO        
