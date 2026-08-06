#INCLUDE "TOTVS.CH"


/*
Programa	: NLPCPF01
Autor		: Tecnorav
Data		: 12-09-25 
Uso			: 
Objetivo	: <<<<<<<<<<<<<<<<<<<<<<<<<< teste dgs >>>>>>>>>>>>>>>>>>>>>>>>

*/
User  Function NLPCPF01()

	Local aArea    := FWGetArea()        as Array  
	//Local aAreaSH6 := SH6->(FWGetArea()) as Array
	//Local aAreaSC2 := SC2->(FWGetArea()) as Array
	Local cProdnf	:= GETMV("MV_ZZOPNF")
	Local cRetorno	:= ""
	Local lRet		:= .T.

	If INCLUI

		If Alltrim(FunName())  $ "MATA681"

			If Alltrim(M->H6_PRODUTO) $ Alltrim(cProdnf)
				cRetorno := FWInputBox("Digite os dados da NF", "")
				//If(Empty(M->H6_ZZNUMNF))
				If Empty(cRetorno) 
					FWAlertInfo("O preenchimento do campo Nota Fiscal é obrigatório para o produto " + AllTrim(M->H6_PRODUTO), "Campo Obrigatório Nota Fiscal")
					lRet := .F.
				else
					M->H6_ZZNUMNF := alltrim(cRetorno)
				endif
			Endif

		elseif Alltrim(FunName())  $ "MATA680"

			If Alltrim(M->H6_PRODUTO) $ Alltrim(cProdnf)
				cRetorno := FWInputBox("Digite os dados da NF", "")
				//If(Empty(M->H6_ZZNUMNF))
				If Empty(cRetorno) 
					FWAlertInfo("O preenchimento do campo Nota Fiscal é obrigatório para o produto " + AllTrim(M->H6_PRODUTO), "Campo Obrigatório Nota Fiscal")
					lRet := .F.
				else
					M->H6_ZZNUMNF := alltrim(cRetorno)
				endif
			Endif

		endif
	Endif

	//FWRestArea(aAreaSH6)
	//FWRestArea(aAreaSC2)
	FWRestArea(aArea)

Return lRet

