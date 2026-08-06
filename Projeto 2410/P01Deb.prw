//LP P01

User Function P01DEB()

Local cRet := ""

    If SRZ->RZ_VAL > 0
        If Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "1" //DIRETO
            cRet := SRV->RV_XDEBDIR
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "2" //DESPESA 
                cRet := SRV->RV_XDEBDES
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") == "3" //INDIRETO
                cRet := SRV->RV_XDEBIND                      
            Else
                cRet := " "
            EndIf
    ElseIf SRZ->RZ_VAL < 0
	      If Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "1" //DIRETO
            cRet := SRV->RV_XCREDIR
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "2" //DESPESA 
                cRet := SRV->RV_XCREDES
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") == "3" //INDIRETO
                cRet := SRV->RV_XCREIND            
            Else
                cRet := " "
        EndIf
    EndIf
Return cRet

User Function P02DEB()

Local cRet := ""

    If SRZ->RZ_VAL > 0
        If Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "1" //DIRETO
            cRet := SRV->RV_XDEBDIR
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "2" //DESPESA 
                cRet := SRV->RV_XDEBDES
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") == "3" //INDIRETO
                cRet := SRV->RV_XDEBIND                      
            Else
                cRet := " "
            EndIf
    ElseIf SRZ->RZ_VAL < 0
	      If Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "1" //DIRETO
            cRet := SRV->RV_XCREDIR
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") $ "2" //DESPESA 
                cRet := SRV->RV_XCREDES
            ElseIf Posicione("CTT", 1, xFilial("CTT") + SRZ->RZ_CC, "CTT_XTIPOC") == "3" //INDIRETO
                cRet := SRV->RV_XCREIND            
            Else
                cRet := " "
        EndIf
    EndIf
Return cRet
