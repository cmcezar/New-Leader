#INCLUDE "rwmake.ch"

USER FUNCTION LP610VISS()
LOCAL nValISS	:= 0
LOCAL aAREA_ATU	:= GETAREA()

cQuery := "SELECT TOP 1 E1_VALOR ISS FROM "+RetSQLName("SE1")+" SE1 "+Chr(13)
cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND SE1.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"' "+Chr(13) 
cQuery += "AND E1_LOJA = '"+SF2->F2_LOJA+"' "+Chr(13) 
cQuery += "AND E1_PREFIXO = '"+SF2->F2_SERIE+"' "+Chr(13) 
cQuery += "AND E1_NUM = '"+SF2->F2_DOC+"' "+Chr(13) 
cQuery += "AND E1_TIPO  in ('IS-') "+Chr(13) 
cQuery += "ORDER BY E1_PARCELA "

if Select("TMP") > 0
		TMP->(dbCloseArea())
endif

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TMP",.T.,.F.)
nValISS := TMP->ISS 
TMP->(dbCloseArea())



RESTAREA(aAREA_ATU)

RETURN(nValISS)




