User function LPCCD()
Local RETORNO := " "
	Do Case
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XDEBDIR"),1,1)$ ("1/2")
			RETORNO := " "		
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XDEBIND"),1,1)$ ("1/2")
			RETORNO := " "
		Case substring(Posicione("SRV",1,xFilial("SRV")+SRZ->RZ_PD,"SRV->RV_XDEBDES"),1,1)$ ("1/2")
			RETORNO := " "
		otherwise
			RETORNO := SRZ->RZ_CC
	EndCase        

Return    RETORNO        
