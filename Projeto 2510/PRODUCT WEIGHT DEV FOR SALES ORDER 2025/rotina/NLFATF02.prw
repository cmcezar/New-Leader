//Bibliotecas
#Include "TOTVS.ch"
/*/{Protheus.doc} U_NLFATF02
    ValidUser - executada ao sair dos campos C6_QTDVEN e C6_PRODUTO
    na rotina MATA410 (itens do pedido de venda).

    Regra:
    - Sempre que o usuário sair de C6_QTDVEN ou C6_PRODUTO,
      recalcular automaticamente:

        C5_PESOL  (Peso Líquido total)
        C5_PBRUTO (Peso Bruto total)

      somando, para TODAS as linhas da grade (aCols):

        Peso Líquido total  += C6_QTDVEN * B1_PESO
        Peso Bruto total    += C6_QTDVEN * B1_PESBRU
/*/
User Function NLFATF02()

	Local lRet      := .T.
	Local cCampo    := Upper( StrTran( ReadVar(), "M->", "" ) )
	Local cFunc     := Upper( FunName() )

	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->( GetArea() )

	Local nPosProd  := 0
	Local nPosQtd   := 0

	Local nTotPesL  := 0
	Local nTotPesB  := 0
	Local nLin      := 0

	Local oCABSC5   := GetWndDefault()
	Local cProd     := ""
	Local nQtd      := 0
	Local nPesoL    := 0
	Local nPesoB    := 0

	// Garante que só rode dentro da MATA410 (grade de itens do pedido)
	If cFunc <> "MATA410" .AND. ! FWIsInCallStack( "MATA410" )
		RestArea( aAreaSB1 )
		RestArea( aArea )
		Return lRet
	EndIf

	// Só faz algo se o campo for C6_QTDVEN ou C6_PRODUTO
	If !( cCampo $ "C6_QTDVEN|C6_PRODUTO" )
		RestArea( aAreaSB1 )
		RestArea( aArea )
		Return lRet
	EndIf

	// Posições dos campos na grade (GetDados)
	nPosProd := GDFIELDPOS( "C6_PRODUTO" )
	nPosQtd  := GDFIELDPOS( "C6_QTDVEN" )

	If nPosProd == 0 .OR. nPosQtd == 0
		RestArea( aAreaSB1 )
		RestArea( aArea )
		Return lRet
	EndIf

	// Percorre TODAS as linhas atuais da grade (aCols)
	For nLin := 1 To Len( aCols )

		cProd := AllTrim( aCols[ nLin ][ nPosProd ] )

		If ! Empty( cProd ) .AND. !GDDeleted(nLin)

			nQtd := aCols[ nLin ][ nPosQtd ]
			If ValType( nQtd ) <> "N"
				nQtd := Val( AllTrim( cValToChar( nQtd ) ) )
			EndIf

			// Busca o produto no cadastro SB1
			SB1->( DbSelectArea( "SB1" ) )
			SB1->( DbSetOrder( 1 ) ) // normalmente B1_FILIAL + B1_COD
			If SB1->( DbSeek( xFilial( "SB1" ) + cProd ) )

				nPesoL := SB1->B1_PESO    // Peso Líquido
				nPesoB := SB1->B1_PESBRU  // Peso Bruto

				If ValType( nPesoL ) <> "N"
					nPesoL := 0
				EndIf

				If ValType( nPesoB ) <> "N"
					nPesoB := 0
				EndIf

				// Acumula totais
				nTotPesL += ( nQtd * nPesoL )
				nTotPesB += ( nQtd * nPesoB )

			EndIf
		EndIf
	Next nLin

	// Atualiza o cabeçalho em memória (SC5) via M->
	M->C5_PESOL  := nTotPesL
	M->C5_PBRUTO := nTotPesB
	GetDRefresh()
	RestArea( aAreaSB1 )
	RestArea( aArea )

Return lRet
