#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.CH"

/*
Autor: Tiago Dias
Data: 16/05/2023
Descrição: Ponto de entrada na execução da rotina de Documento de Entrada. Função responsável por gatilhar nome de fornecedor no cabeçalho de documentos de entrada
*/
User Function M103BROW()
Local cQuery 	:= ""
Local cFil 		:= ""
Local cCodForn	:= ""
Local cLoja		:= ""

	cQuery := "	SELECT * FROM SF1010"	+	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	+	CRLF
	cQuery += "	AND F1_ZDESCF = ''"		+	CRLF
	cQuery += "	ORDER BY F1_DOC"		+	CRLF

    PLSQuery(cQuery, 'QUERYF1')
    DbSelectArea('QUERYF1')
    QUERYF1->(DbGoTop())

	//Posiciona
	DBSELECTAREA( "SF1" )
	DBSETORDER( 1 )

	//Loop na estração da query
	While ! QUERYF1->(EoF())
		
		//Indice
		//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
		If SF1->(DbSeek(xFilial("SF1")+ QUERYF1->F1_DOC + QUERYF1->F1_SERIE + QUERYF1->F1_FORNECE + QUERYF1->F1_LOJA + QUERYF1->F1_TIPO))  

			cFil		:= SF1->F1_FILIAL
			cCodForn	:= SF1->F1_FORNECE
			cLoja 		:= SF1->F1_LOJA

			Begin Transaction

				RECLOCK( "SF1", .F. )

					SF1->F1_ZDESCF := NOMEFORN(cFil,cCodForn,cLoja)

				SF1->(MsUnlock())

			End Transaction       

		endif     

		QUERYF1->(DbSkip()) 

	ENDDO

	DbCloseArea()

Return

/*
Autor: Tiago Dias
Data: 16/05/2023
Descrição: função estática responsável por retornar nome de fornecedor
*/
Static Function NOMEFORN(cFil,cCodForn,cLoja)
Local cDescForn 	:= ""

	//Indice
	//A2_FILIAL + A2_COD + A2_LOJA
	DBSELECTAREA( "SA2" )
	DBSETORDER( 1 )

	If SA2->(DbSeek(xFilial("SA2") + cCodForn + cLoja )) 

		cDescForn	:= ALLTRIM(SA2->A2_NOME)

	ENDIF


Return cDescForn

