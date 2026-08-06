#INCLUDE "rwmake.ch"

USER FUNCTION LP650C()
LOCAL cConta	:= ""
LOCAL aAREA_ATU	:= GETAREA()

cQuery := "SELECT TOP 1 E2_NATUREZ NATUREZ FROM "+RetSQLName("SE2")+" SE2 "+Chr(13)
cQuery += "WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND SE2.D_E_L_E_T_ = ' ' "+Chr(13)
cQuery += "AND E2_FORNECE = '"+SF1->F1_FORNECE+"' "+Chr(13) 
cQuery += "AND E2_LOJA = '"+SF1->F1_LOJA+"' "+Chr(13) 
cQuery += "AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "+Chr(13) 
cQuery += "AND E2_NUM = '"+SF1->F1_DOC+"' "+Chr(13) 
cQuery += "AND E2_TIPO  in ('NF') "+Chr(13) 
cQuery += "ORDER BY E2_PARCELA "

if Select("TMP") > 0
		TMP->(dbCloseArea())
endif

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TMP",.T.,.F.)
cXNaturez := TMP->NATUREZ 
TMP->(dbCloseArea())
cConta := GETADVFVAL("SED","ED_CREDIT",xFilial("SED")+cXNaturez , 1)


RESTAREA(aAREA_ATU)

RETURN(cConta)
