#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.CH"

/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: Ponto de entrada na execução da rotina de Pedido de Venda. Função responsável por gatilhar nome de cliente no cabeçalho de documentos de entrada
*/
User Function MT410BRW()
Local cQuery 	:= ""
Local cFil 		:= ""
Local cCodCLi	:= ""
Local cLoja		:= ""

	cQuery := "	SELECT * FROM SC5010"	+	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	+	CRLF
	cQuery += "	AND C5_ZDESCC = ''"		+	CRLF
	cQuery += "	ORDER BY C5_NUM"		+	CRLF

    PLSQuery(cQuery, 'QUERYC5')
    DbSelectArea('QUERYC5')
    QUERYC5->(DbGoTop())

	//Posiciona
	DBSELECTAREA( "SC5" )
	DBSETORDER( 1 )

	//Loop na estração da query
	While ! QUERYC5->(EoF())

		cNum 		:= QUERYC5->C5_NUM
		
		//Indice
		//C5_NUM
		If SC5->(DbSeek(xFilial("SC5")+ QUERYC5->C5_NUM))  

			cFil		:= SC5->C5_FILIAL
			cCodCLi		:= SC5->C5_CLIENTE
			cLoja 		:= SC5->C5_LOJACLI

			Begin Transaction

				RECLOCK( "SC5", .F. )


					if ALLTRIM(SC5->C5_TIPO) == 'D' .OR. ALLTRIM(SC5->C5_TIPO) == 'B'

						SC5->C5_ZDESCC 	:= NOMEFOR(cFil,cCodCLi,cLoja)

					ELSE

						SC5->C5_ZDESCC 	:= NOMECLI(cFil,cCodCLi,cLoja)
						//SC5->C5_VALTOT	:= TOTALIT(cNum)

					ENDIF

				SC5->(MsUnlock())

			End Transaction       

		endif     

		QUERYC5->(DbSkip()) 

	ENDDO

	u_VALT()

	DbCloseArea()

Return

/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: função estática responsável por retornar nome do cliente
*/
Static Function NOMECLI(cFil,cCodCLi,cLoja)
Local cDescCli 	:= ""

	//Indice
	//A1_FILIAL + A1_COD + A1_LOJA
	DBSELECTAREA( "SA1" )
	DBSETORDER( 1 )

	If SA1->(DbSeek(xFilial("SA1") + cCodCLi + cLoja )) 

		cDescCli	:= ALLTRIM(SA1->A1_NOME)

	ENDIF


Return cDescCli


/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: função estática responsável por retornar nome do cliente
*/
Static Function NOMEFOR(cFil,cCodCLi,cLoja)
Local cDescCli 	:= ""

	//Indice
	//A1_FILIAL + A1_COD + A1_LOJA
	DBSELECTAREA( "SA2" )
	DBSETORDER( 1 )

	If SA2->(DbSeek(xFilial("SA2") + cCodCLi + cLoja )) 

		cDescCli	:= ALLTRIM(SA2->A2_NOME)

	ENDIF


Return cDescCli

/*
Retorna valor total
*/
User Function VALT()
Local cQuery 	:= ""

	cQuery := "	SELECT * FROM SC5010"	+	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	+	CRLF
	cQuery += "	AND C5_LIBEROK = '' "	+	CRLF
	cQuery += "	AND C5_NOTA= '' "		+	CRLF
	cQuery += "	AND C5_VALTOT= 0 "		+	CRLF
	cQuery += "	ORDER BY C5_NUM"		+	CRLF

    PLSQuery(cQuery, 'QUERYC5')
    DbSelectArea('QUERYC5')
    QUERYC5->(DbGoTop())

	//Posiciona
	DBSELECTAREA( "SC5" )
	DBSETORDER( 1 )

	//Loop na estração da query
	While ! QUERYC5->(EoF())

		cNum 		:= QUERYC5->C5_NUM
		
		//Indice
		//C5_NUM
		If SC5->(DbSeek(xFilial("SC5")+ QUERYC5->C5_NUM))  

			Begin Transaction

				RECLOCK( "SC5", .F. )

					//SC5->C5_ZDESCC 	:= NOMECLI(cFil,cCodCLi,cLoja)
					SC5->C5_VALTOT	:= TOTALIT(cNum)	

				SC5->(MsUnlock())

			End Transaction       

		endif     

		QUERYC5->(DbSkip()) 

	ENDDO

	DbCloseArea()

Return

/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: função estática responsável por retornar valor total de acordo com os itens
*/
Static Function TOTALIT(cNum)
Local cQuery 	:= ""
Local nTot 		:= 0

	cQuery := "	SELECT * FROM SC6010"	    +	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	    +	CRLF
	cQuery += "	AND C6_NUM = '"+cNum+"'"	+	CRLF
    cQuery += "	ORDER BY C6_ITEM"			+	CRLF

    PLSQuery(cQuery, 'QUERYC6')
    DbSelectArea('QUERYC6')
    QUERYC6->(DbGoTop())

    While ! QUERYC6->(EoF())

        nTot	+= QUERYC6->C6_VALOR

		QUERYC6->(DbSkip()) 

	ENDDO

Return nTot


