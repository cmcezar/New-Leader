#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.CH"

/*
Autor: Tiago Dias
Data: 16/05/2023
Descrição: função para validar transmissão de NF, validação dos itens. Retorna aviso em tela caso a quantidade digitada seja maior que a disponível em estoque.
*/
//2785
User Function FISVALNFE()	
Local cNumDoc   := PARAMIXB[4]
Local cCliente  := PARAMIXB[6]
Local cTipo	    := PARAMIXB[1]	
Local cLoja		:= PARAMIXB[7]
Local cQuery    := ""
Local nQtdVen   := 0
Local cProd     := ""
Local cLocal    := ""
Local cSaldoFm  := ""
Local cSaldoAtu := ""
Local cQtdVen   := ""
Local cDesc     := ""
Local cItem     := ""
Local aErroCab  := {}
Local aErroItem := {}
Local lQtd      := .F.

Local cTitulo     := "AVISO !! - Num. Documento: "+cNumDoc
Local cMotivo     := "Quantidade digitada menor que em estoque"

Local cTesSaldo   := "0A1;0A2;1A8;1E1;1F7;1F8;1I8;1I9;1O5;1O6;1O7;1O8;1P1;1P2;1P5;1P6;1P7;1P8;1P9;1Q1;1Q2;1Q3;1T1;1T2;1T3;1T4;1T5;1T6;1T7;1T8;1T9;1U1;1U2;1U3;1U5;1U6;1U7;1U8;1U9;1V1;1V2;1V4;2D1;2D2;2D3;2D4;2D5;2D6;2D7;2D8;2D9;2E1;2E6;2F1;2F2;2F3;2F4;2F5;2F6;2F7;2F8;2F9;2G1;2G7;2H2;2H3;2I5;2J1;2J6;2K1;2K2;2K3;2L1;2L3;2M1;2M2;2M3;2M4;2M5;2M6;2M7;2M8;2N2;2N5;2N6;2N7;2N8;2O1;2O2;2O3;2O4;2O5;2O6;2O7;2O8;2O9;2P1;2P2;2S1;3C1;3C2;3C3;3D1;3D2;3F1;3F2;3F3;3F4;3G3;3G4;3K1;3K2;5J6;5J9;5K9;5N8;5O9;5R8;5R9;5W1;5W2;5W3;5W4;5W5;5W6;5W7;5W8;5W9; 5X1;5X7;5X8;5X9;5Y1;5Y2;5Y3;5Y4;5Y5;5Y6;5Y7;5Z6;6A1;6A2;6A3;6A4;6A5;6A6;6A7;6A8;6A9;6B1;6C1;6C2;6C3;6C4;6C5;6C6;6C7;6C8;6C9;6D1;6D6;6D7;6D8;6D9;6E1;6E2;6E3;6E4;6E5;6F4;6G1;6G2;6Q1;6Q2;6R1;6R2;6R3;6R4;6S1;6S2;6S4;6T1;6T2;6T3;6T4;6U2;6U5;6U6;6U7;6U8;6U9;6V1;6V2;6V3;6V4;6X8;6X9;6Y1;6Y6;6Y7;6Z1;6Z2;7A1;7L1;7Q3;7Q4"
Local cTES        := ""

	cQuery := "	SELECT * FROM SD2010"	            +	CRLF
	cQuery += "	WHERE D_E_L_E_T_ = ''"	            +	CRLF
	cQuery += "	AND D2_DOC = '"+cNumDoc+"'"		    +	CRLF
    cQuery += "	AND D2_CLIENTE = '"+cCliente+"'"	+	CRLF
	cQuery += "	ORDER BY D2_ITEM"		            +	CRLF

    PLSQuery(cQuery, 'QUERYD2')
    DbSelectArea('QUERYD2')
    QUERYD2->(DbGoTop())

    //posiciona tabela de saldo fisico e financeiro de cada produto da NFe
    DBSELECTAREA( "SB2" )
    DBSETORDER( 1 )

    //adiciona cabeçalho do e-mail
    aAdd(aErroCab,{cNumDoc,cTipo,cCliente,cLoja})

    While ! QUERYD2->(EoF())

        nQtdVen     := QUERYD2->D2_QUANT
        cProd       := QUERYD2->D2_COD
        cLocal      := QUERYD2->D2_LOCAL
        cItem       := QUERYD2->D2_ITEM
        cTES        := QUERYD2->D2_TES

        //filtra SB2
        IF SB2->(DbSeek(xFilial("SB2")+ cProd + cLocal ))  

            //apenas se for negativo
            if SB2->B2_QATU < 0

                IF nQtdVen > SB2->B2_QFIM .OR. nQtdVen > SB2->B2_QATU

                    cSaldoFm    := ALLTRIM(STR(SB2->B2_QFIM))
                    cSaldoAtu   := ALLTRIM(STR(SB2->B2_QATU))
                    cQtdVen     := ALLTRIM(STR(nQtdVen))

                    cDesc += "Item: "+cItem+", Produto: "+ALLTRIM(cProd)+", Qtd. Digitada: "+cQtdVen+", Saldo Mês: "+cSaldoFm+ ", Saldo Atual: "+cSaldoAtu+""  +	CRLF
                    cDesc += "" +	CRLF

                    //Adiciona informações para enviar e-mail
                    aAdd(aErroItem,{ALLTRIM(cProd),cItem,cSaldoFm,cSaldoAtu,cQtdVen,cLocal})

                    lQtd    := .T.

                ENDIF

            ENDIF

        ENDIF
    	
        QUERYD2->(DbSkip()) 

	ENDDO

    //valida se teve algum item com quantidade maior que em estoque
    if lQtd .and. !(cTES $ cTesSaldo)

        cDesc += "" +	CRLF
        cDesc += "E-mail automático enviado aos responsáveis! "     +	CRLF

        //envia e-mail automático
        u_NLEMAILPED(cTitulo,aErroCab,aErroItem,cMotivo)

        //retorna mensagem em tela com aviso e listagem de itens com problema
        MSGALERT( cDesc  , "Quantidade digitada menor que em estoque!" )

    endif

Return (.T.)
