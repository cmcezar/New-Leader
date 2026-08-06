/*/{Protheus.doc} U_NLFATF01()
    Regra:
    - Recalcular automaticamente:

        C5_PESOL  (Peso Líquido total)
        C5_PBRUTO (Peso Bruto total)

      somando, para TODAS as linhas da grade (aCols) que
      ficarão ATIVAS após o toggle de exclusão da linha atual:

        Peso Líquido total  += C6_QTDVEN * B1_PESO
        Peso Bruto total    += C6_QTDVEN * B1_PESBRU
/*/
User Function NLFATF01()
	Local lRet := .T.
	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->( GetArea() )

	Local nPosProd  := GDFIELDPOS( "C6_PRODUTO" )
	Local nPosQtd   := GDFIELDPOS( "C6_QTDVEN" )

	Local nTotPesL  := 0
	Local nTotPesB  := 0
	Local nLin      := 0

	Local cProd     := ""
	Local nQtd      := 0
	Local nPesoL    := 0
	Local nPesoB    := 0

	Local lDelNow   := .F.

	// Se não encontrar as colunas de produto ou quantidade, não faz nada.
	If nPosProd == 0 .OR. nPosQtd == 0
		RestArea( aAreaSB1 )
		RestArea( aArea )
		Return lRet
	EndIf

	// Posiciona SB1 uma vez só
	DbSelectArea( "SB1" )
	DbSetOrder( 1 ) // B1_FILIAL+B1_COD

	// Percorre TODAS as linhas atuais da grade (aCols)
	For nLin := 1 To Len( aCols )

		cProd := AllTrim( aCols[ nLin ][ nPosProd ] )

		If ! Empty( cProd )

			nQtd := aCols[ nLin ][ nPosQtd ]
			If ValType( nQtd ) <> "N"
				nQtd := Val( AllTrim( cValToChar( nQtd ) ) )
			EndIf

			If DbSeek( xFilial( "SB1" ) + cProd )

				nPesoL := SB1->B1_PESO    // Peso Líquido
				nPesoB := SB1->B1_PESBRU  // Peso Bruto

				If ValType( nPesoL ) <> "N"
					nPesoL := 0
				EndIf

				If ValType( nPesoB ) <> "N"
					nPesoB := 0
				EndIf

				lDelNow := GDDeleted(nLin)
				// Só soma se a linha estiver ATIVA após o toggle
				If ! lDelNow
					nTotPesL += ( nQtd * nPesoL )
					nTotPesB += ( nQtd * nPesoB )
				EndIf

			EndIf
		EndIf
	Next nLin

	// Atualiza cabeçalho em memória (SC5) via M->
	M->C5_PESOL  := nTotPesL
	M->C5_PBRUTO := nTotPesB
	RestArea( aAreaSB1 )
	RestArea( aArea )
	GetDRefresh()
return lRet
