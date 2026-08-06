#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: Ponto de entrada na execução da rotina de Monitoramento Sefaz - NFe Saída. Função responsável por gatilhar nome de cliente no cabeçalho de documentos de entrada
*/
User Function FISTRFNFE()    
Local cQuery 	:= ""
Local cFil 		:= ""
Local cCodCLi	:= ""
Local cLoja		:= ""
Local cQueryUpd := ""
Local cNomeCli  := ""

	cQuery := "	SELECT * FROM SF2010"	+	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	+	CRLF
	cQuery += "	AND F2_ZDESCC = ''"		+	CRLF
	cQuery += "	ORDER BY F2_DOC"		+	CRLF

    PLSQuery(cQuery, 'QUERYF2')
    DbSelectArea('QUERYF2')
    QUERYF2->(DbGoTop())

	//Posiciona
	//DBSELECTAREA( "SF2" )
	//DBSETORDER( 1 )

	//Loop na estração da query
	While ! QUERYF2->(EoF())
		
		//Indice
		//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO

			cFil		:= QUERYF2->F2_FILIAL
			cCodCLi		:= QUERYF2->F2_CLIENTE
			cLoja 		:= QUERYF2->F2_LOJA

            IF ALLTRIM(QUERYF2->F2_TIPO) == 'B' .OR. ALLTRIM(QUERYF2->F2_TIPO) == 'D'

                cNomeCli    := NOMEFOR(cFil,cCodCLi,cLoja)

            ELSE

                cNomeCli    := NOMECLI(cFil,cCodCLi,cLoja)

            ENDIF

            if !empty(cNomeCli)

                Begin Transaction

                    cQueryUpd := " UPDATE SF2010 SET F2_ZDESCC = '"+cNomeCli+"' "
                    cQueryUpd += " WHERE D_E_L_E_T_=''   "
                    cQueryUpd += " AND F2_DOC = '" + QUERYF2->F2_DOC + "'   "
                    cQueryUpd += " AND F2_SERIE = '" + QUERYF2->F2_SERIE + "'   "
                    cQueryUpd += " AND F2_CLIENTE = '" + QUERYF2->F2_CLIENTE + "'   "
                    cQueryUpd += " AND F2_LOJA = '" + QUERYF2->F2_LOJA + "'   "
                    cQueryUpd += " AND F2_FORMUL = '" + QUERYF2->F2_FORMUL + "'   "
                    cQueryUpd += " AND F2_TIPO = '" + QUERYF2->F2_TIPO + "'   "
                    cQueryUpd += " AND F2_FILIAL = '" + cFil + "'   "

                    tcSqlExec(cQueryUpd)
                    tcSqlExec('commit')

                End Transaction 

            endif      


		QUERYF2->(DbSkip()) 

	ENDDO

	DbCloseArea()

Return              

/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: função estática responsável por retornar nome do cliente
*/
Static Function NOMECLI(cFil,cCodCLi,cLoja)
Local cDescCli 	:= ""
Local cQueryA1  := ""


	cQueryA1 := "	SELECT * FROM SA1010"	    +	CRLF
	cQueryA1 += "	WHERE D_E_L_E_T_ = ''"	    +	CRLF
	cQueryA1 += "	AND A1_COD = '"+cCodCLi+"'"	+	CRLF
	cQueryA1 += "	AND A1_LOJA = '"+cLoja+"'"	+	CRLF
    cQueryA1 += "	AND A1_FILIAL= '"+xFilial("SA1")+"'"	+	CRLF

    PLSQuery(cQueryA1, 'QUERYA1')
    DbSelectArea('QUERYA1')
    QUERYA1->(DbGoTop())

    While ! QUERYA1->(EoF())

        cDescCli	:= ALLTRIM(QUERYA1->A1_NOME)

		QUERYA1->(DbSkip()) 

	ENDDO

Return cDescCli


/*
Autor: Tiago Dias
Data: 17/05/2023
Descrição: função estática responsável por retornar nome do cliente
*/
Static Function NOMEFOR(cFil,cCodCLi,cLoja)
Local cDescCli 	:= ""
Local cQueryA2  := ""


	cQueryA2 := "	SELECT * FROM SA2010"	    +	CRLF
	cQueryA2 += "	WHERE D_E_L_E_T_ = ''"	    +	CRLF
	cQueryA2 += "	AND A2_COD = '"+cCodCLi+"'"	+	CRLF
	cQueryA2 += "	AND A2_LOJA = '"+cLoja+"'"	+	CRLF
    cQueryA2 += "	AND A2_FILIAL= '"+xFilial("SA2")+"'"	+	CRLF

    PLSQuery(cQueryA2, 'QUERYA2')
    DbSelectArea('QUERYA2')
    QUERYA2->(DbGoTop())

    While ! QUERYA2->(EoF())

        cDescCli	:= ALLTRIM(QUERYA2->A2_NOME)

		QUERYA2->(DbSkip()) 

	ENDDO

Return cDescCli
