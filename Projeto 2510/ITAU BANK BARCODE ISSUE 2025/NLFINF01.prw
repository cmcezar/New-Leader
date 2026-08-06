#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} NLFINF01
Função principal da rotina de emissão de boletos Itau, responsável por aplicar
parâmetros, selecionar títulos elegíveis e disponibilizar a geração dos boletos.
@type  function
@version P12
@author Tecnosiga
@since 26/11/2025
/*/
User Function NLFINF01()

    Local lContinua := .T.
    Local cFilter   := ""

    // PRIVATE mantidas exatamente como no código anterior
    Private cMarca    := GetMark()
    Private aCampos   := {}
    Private aRotina   := {}
    Private aArqTemp  := {}
    Private cCadastro := "Emissao de Titulos - Boleto ITAÚ"
    Private cTmpSE1   := CriaTrab(, .F.)
    Private cAliasSE1 := GetNextAlias()

    // 1) Monta os campos do browse (MarkBrowse)
    aCampos := MntCampos()

    // 2) Loop de parâmetros (ParamBox / MontaPerg) e seleção de títulos
    While lContinua

        // MontaPerg usa ParamBox e retorna .T. se usuário confirmar
        lContinua := MontaPerg()

        If lContinua

            // Monta filtro da SE1 com base em MV_PARxx
            cFilter := MntFiltSE1()

            // Processa seleção de títulos (TRB, índice, MarkBrowse, limpeza)
            PrSelTit(cFilter, aCampos)

        EndIf

    EndDo

    // Fecha cAliasSE1 se ainda estiver aberta
    If Select(cAliasSE1) <> 0
        (cAliasSE1)->( DbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} MntCampos
Monta e retorna o array de campos utilizados no MarkBrowse de títulos (SE1).
@type  function
@version P12
@author Consultor Protheus
@since  26/11/2025
/*/
Static Function MntCampos()

    Local aCampos  := {}
    Local aOrdem   := {}
    Local nX       := 0
    Local cX3Arq   := ""

    // -----------------------------------------------------------------
    // Campos principais exibidos no browse (header)
    // -----------------------------------------------------------------
    aOrdem := {}
    //AAdd(aOrdem, 'E1_FILIAL' )
    AAdd(aOrdem, 'E1_PREFIXO' )
    AAdd(aOrdem, 'E1_NUM'     )
    AAdd(aOrdem, 'E1_PARCELA' )
    AAdd(aOrdem, 'E1_TIPO'    )
    AAdd(aOrdem, 'E1_CLIENTE' )
    AAdd(aOrdem, 'E1_LOJA'    )
    AAdd(aOrdem, 'E1_NOMCLI'  )
    AAdd(aOrdem, 'E1_EMISSAO' )
    AAdd(aOrdem, 'E1_VENCTO'  )
    AAdd(aOrdem, 'E1_VENCREA' )
    AAdd(aOrdem, 'E1_BAIXA'   )
    AAdd(aOrdem, 'E1_VALOR'   )
    AAdd(aOrdem, 'E1_SALDO'   )
    AAdd(aOrdem, 'E1_PORTADO' )
    AAdd(aOrdem, 'E1_AGEDEP'  )
    AAdd(aOrdem, 'E1_CONTA'   )
    AAdd(aOrdem, 'E1_CODBAR'  )
    AAdd(aOrdem, 'E1_CODDIG'  )
    AAdd(aOrdem, 'E1_HIST'    )
    AAdd(aOrdem, 'E1_DESCFIN' )
    AAdd(aOrdem, 'E1_PORCJUR' )
    AAdd(aOrdem, 'E1_VALJUR'  )
    AAdd(aOrdem, 'E1_DECRESC' )
    AAdd(aOrdem, 'E1_ACRESC'  )

    // Campo de marca para o browse
    AAdd(aCampos, { "E1_OK", "", "", "" } )

    // -----------------------------------------------------------------
    // Para cada campo da ordem, busca título/picture no SX3
    // -----------------------------------------------------------------
    DbSelectArea("SX3")
    DbSetOrder(2)
    DbGoTop()

    For nX := 1 To Len(aOrdem)
        If DbSeek(aOrdem[nX], .F.)
            AAdd(aCampos, { ;
                AllTrim(SX3->X3_CAMPO), ;
                SX3->X3_TITULO, ;
                AllTrim(SX3->X3_TITULO), ;
                SX3->X3_PICTURE ;
            } )
        EndIf
    Next

    // -----------------------------------------------------------------
    // Inclui demais campos da SE1, desconsiderando campos específicos (E1_USVLGA / E1_USVLGI)
    // -----------------------------------------------------------------
    DbSelectArea("SX3")
    DbSetOrder(1)
    DbGoTop()
    DbSeek("SE1" + "01", .F.)

    If Found()

        cX3Arq := SX3->X3_ARQUIVO

        Do While cX3Arq == SX3->X3_ARQUIVO

            If AllTrim(SX3->X3_CAMPO) $ "E1_USVLGA\E1_USVLGI"
                DbSkip()
                Loop
            Else
                If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT != "V" )
                    AAdd(aCampos, { ;
                        AllTrim(SX3->X3_CAMPO), ;
                        SX3->X3_TITULO, ;
                        AllTrim(SX3->X3_TITULO), ;
                        SX3->X3_PICTURE ;
                    } )
                EndIf
            EndIf

            DbSkip()

        EndDo

    EndIf

Return aCampos

/*/{Protheus.doc} MntFiltSE1
Monta e retorna a expressão de filtro (cFilter) utilizada na seleção dos 
títulos da SE1 para geração de boletos.
@type  function
@version P12@author Consultor Protheus
@since  26/11/2025
/*/
Static Function MntFiltSE1()

    Local cFilter := ""

    cFilter  := "E1_FILIAL == '" + xFilial("SE1") + "' .And. "
    cFilter  += "E1_PREFIXO >= '" + MV_PAR01 + "' .And. "
    cFilter  += "E1_PREFIXO <= '" + MV_PAR02 + "' .And. "
    cFilter  += "E1_NUM     >= '" + MV_PAR03 + "' .And. "
    cFilter  += "E1_NUM     <= '" + MV_PAR04 + "' .And. "
    cFilter  += "DtoS(E1_EMISSAO) >= '" + DtoS(MV_PAR09) + "' .And. "
    cFilter  += "DtoS(E1_EMISSAO) <= '" + DtoS(MV_PAR10) + "' .And. "
    cFilter  += "E1_CLIENTE >= '" + MV_PAR11 + "' .And. "
    cFilter  += "E1_LOJA    >= '" + MV_PAR12 + "' .And. "
    cFilter  += "E1_CLIENTE <= '" + MV_PAR13 + "' .And. "
    cFilter  += "E1_LOJA    <= '" + MV_PAR14 + "' .And. "
    // Somente títulos em aberto, tipos NF/BOL/NDC
    cFilter  += "E1_SALDO > 0 .And. (E1_TIPO == 'NF ' .Or. E1_TIPO == 'BOL' .Or. E1_TIPO == 'NDC') "

Return cFilter

/*/{Protheus.doc} PrSelTit
Processa a seleção de títulos para boleto: cria TRB, aplica filtro na SE1,
gera índice temporário, abre o MarkBrowse e limpa arquivos temporários.
@type  function
@version P12
@author Tecnosiga-NS
@since  26/11/2025
/*/
Static Function PrSelTit(cFilter, aCampos)

    Local cIndexName := ""
    Local cIndexKey  := ""
    Local nArq       := 0

    // Fecha cAliasSE1 anterior, se existir
    If Select(cAliasSE1) <> 0
        (cAliasSE1)->( DbCloseArea() )
    EndIf

    // Seleciona SE1 para aplicar filtro
    DbSelectArea("SE1")

    // Índice temporário baseado em PREFIXO+NUM+PARCELA
    cIndexName := CriaTrab(Nil, .F.)
    cIndexKey  := "E1_PREFIXO + E1_NUM + E1_PARCELA"

    // 1) Cria índice temporário + aplica filtro com barra de progresso
    IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde. Selecionando Registros....")

    DbSelectArea("SE1")
    DbGoTop()

    // 2) Copia SE1 filtrada para arquivo físico temporário (TRB cTmpSE1)
    Copy To &(cTmpSE1)

    // Fecha SE1 e garante reabertura padrão
    If Select("SE1") <> 0
        SE1->( DbCloseArea() )
    EndIf
    ChkFile("SE1")

    // Abre o TRB com alias cAliasSE1
    DbUseArea(.T., , cTmpSE1, cAliasSE1, .F., .F.)
    DbSelectArea(cAliasSE1)
    DbGoTop()

    // Guarda nomes dos arquivos temporários para limpar depois
    AAdd(aArqTemp, cTmpSE1)
    AAdd(aArqTemp, cIndexName)

    // 3) Define menu (aRotina) – apenas o botão "Gerar Boleto"
    aRotina := {}
    AAdd(aRotina, { "Gerar Boleto", "U_IMPBOL01()", 0, 6 })

    // 4) Abre o MarkBrowse para o usuário marcar os títulos
    cMarca := GetMark()

    MarkBrowse( ;
        cAliasSE1, ;        // Alias
        "E1_OK", ;         // Campo de marca
        , ;                // Ordem (usa índice atual)
        aCampos, ;         // Campos do browse
        , ;                // Código de saída
        cMarca, ;          // Marca
        "U_fNLMkAll()", ;  // Função de marcação (stub)
        , ;                // Título
        , ;                // nOpc
        , ;                // aRotina via PRIVATE
        , ;                // lMatriz
        ;                  // aColsSize
    )

    // 5) Limpa arquivos temporários gerados (TRBs e índices)
    For nArq := 1 To Len(aArqTemp)
        FErase(aArqTemp[nArq])
    Next

Return

/*/{Protheus.doc} fNLMkAll
Função stub para marcação/desmarcação de todos os registros no MarkBrowse.
@type  function
@version P12
@author Tecnosiga-NS
@since 26/11/2025
/*/
User Function fNLMkAll()
	Local aArea  := GetArea()
	Local lMarca := Nil

	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbGoTop())
	Do While (cAliasSE1)->(!Eof())

		If (lMarca == Nil)
			lMarca := ((cAliasSE1)->E1_OK == cMarca)
		EndIf
		RecLock(cAliasSE1,.F.)
		(cAliasSE1)->E1_OK := If( lMarca,"",cMarca )
		MsUnLock()
		DbSkip()

	EndDo

	RestArea(aArea)
	MarkBRefresh()

Return

/*/{Protheus.doc} IMPBOL01
Valida se há títulos selecionados e executa a impressão do boleto (MontaRel).
@type  function
@version P12
/*/
User Function IMPBOL01()

    // Validação da seleção
    If !ValSelBol()
        Return  // Nenhum título marcado ? não imprime
    EndIf

    // Executa impressao
    MsAguarde({|| MontaRel() },'Aguarde...','Gerando Boleto...')

Return

/*/{Protheus.doc} ValSelBol
Valida se há pelo menos um título marcado no cAliasSE1 antes da impressão.
@type  function
@version P12
/*/
Static Function ValSelBol()

    Local lTemMarcado := .F.

    If Select(cAliasSE1) == 0
        MsgStop("Nenhuma tabela de seleção carregada.", "Atenção")
        Return .F.
    EndIf

    DbSelectArea(cAliasSE1)
    (cAliasSE1)->(dbGoTop())

    Do While !(cAliasSE1)->(Eof())
        If !Empty((cAliasSE1)->E1_OK)
            lTemMarcado := .T.
            Exit
        EndIf
        (cAliasSE1)->(DbSkip())
    EndDo

    If !lTemMarcado
        MsgStop("Nenhum título foi selecionado.", "Atenção")
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} MontaRel
Função responsável por preparar os dados e o ambiente para geração dos boletos Itaú,
incluindo carregamento das informações e configuração inicial da impressão. 
Controla também o deslocamento do layout através das variáveis nLinha e nColuna, 
permitindo ajustar a posição de todos os elementos do boleto.
@type  function
@version P12
@since 26/11/2025
/*/
Static Function MontaRel()
	Local aDadosTit
	Local nX
	Local aDadosBanco
	Local aDatSacado
	Local aBolText
	Local aDadosEmp := 	{}
	Local aErro		:=	{}
	Local oPrint
	Local lVisualiza:=	.F.
	Local cInstr1 := ""
	Local cInstr2 := ""
	Local cInstr3 := ""
	Local cVlrMora := ""
	Local cPerMora := ""
	Private _NumBco := 	''
	Private _NumConv:=	''
	// Offsets de impressão (permite deslocar tudo se precisar)
    Private nLinha  := 0
    Private nColuna := 0

	Aadd(aDadosEmp, SM0->M0_NOMECOM)																// [01] Nome da Empresa
	Aadd(aDadosEmp, SM0->M0_ENDCOB )																// [02] Endereço
	Aadd(aDadosEmp, AllTrim(SM0->M0_BAIRCOB)+",  "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB)	// [03] Complemento
	Aadd(aDadosEmp, "CEP: "  + Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3))				// [04] CEP
	Aadd(aDadosEmp, "FONE: " + SM0->M0_TEL)															// [05] Telefones
	Aadd(aDadosEmp, "CNPJ: " + Transform(SM0->M0_CGC, '@R 99.999.999/9999-99'))					// [06] CNPJ
	Aadd(aDadosEmp, "I.E.: " + ALLTRIM(SM0->M0_INSC))												// [07] Inscricao Estadual

    oPrint  := TMSPrinter():New("Boleto Laser")
    lImpBol := oPrint:Setup()		// Se retorna .T. imprime direto na impressora
    IF !(lImpBol)
	    RETURN
    ENDIF
    oPrint:SetPortrait()			// ou SetLandscape()
    oPrint:SetPaperSize(9)			// Seta para papel A4
    oPrint:StartPage()				// Inicia uma nova pagina

	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbGoTop())
	Do While (cAliasSE1)->(!Eof())

		aErro := {}

		// INCIO DE FILTROS E VALIDACAO, CARREGA VARIAVEIS	
		If Empty((cAliasSE1)->E1_OK) 
				(cAliasSE1)->(DbSkip())
				Loop
		Else
			DbSelectArea("SA6"); DbSetOrder(1)
			If !DbSeek(xFilial("SA6") + MV_PAR05 + MV_PAR06 + MV_PAR07, .F.)
				Aadd(aErro, "Banco / Agência / Conta nao cadastrados: " + MV_PAR05 + ' / ' + MV_PAR06 + ' / ' + MV_PAR07 )
			Elseif AllTrim(SA6->A6_BLOCKED) == '1'
				Aadd(aErro, "Banco / Agência / Conta BLOQUEADO!!!" + ENTER + MV_PAR05 + ' / ' + MV_PAR06 + ' / ' + MV_PAR07 )
			EndIf

			//	If Alltrim(E1_TIPO) <> 'NF' .AND. Alltrim(E1_TIPO) <> 'FT' .AND. Alltrim(E1_TIPO) <> 'DP'
			If AllTrim((cAliasSE1)->E1_TIPO) == "NCC"
				Aadd(aErro, "Tipo do Título NCC.  Prefixo [ "+ (cAliasSE1)->E1_PREFIXO +" ]  Titulo [ " + (cAliasSE1)->E1_NUM + "]  Parcela [ "+(cAliasSE1)->E1_PARCELA+" ] "+;
					"Cliente:  "+(cAliasSE1)->E1_CLIENTE +" / "+(cAliasSE1)->E1_LOJA+"  -  "+ AllTrim((cAliasSE1)->E1_NOMCLI) )
			EndIf

			If (cAliasSE1)->E1_SALDO == 0
				Aadd(aErro, "Tit. ja baixado.  Prefixo [ "+ (cAliasSE1)->E1_PREFIXO +" ]  Titulo [ " + (cAliasSE1)->E1_NUM + "]  Parcela [ "+(cAliasSE1)->E1_PARCELA+" ] "+;
					"Cliente:  "+(cAliasSE1)->E1_CLIENTE +" / "+(cAliasSE1)->E1_LOJA+"  -  "+ AllTrim((cAliasSE1)->E1_NOMCLI) )
			EndIf

			DbSelectArea("SA1");DbSetOrder(1)
			If !DbSeek(xFilial("SA1")+ (cAliasSE1)->E1_CLIENTE + (cAliasSE1)->E1_LOJA, .F.)
				Aadd(aErro, "Cliente " + (cAliasSE1)->E1_CLIENTE + "/" + (cAliasSE1)->E1_LOJA + " nao Cadastrado." )
			EndIf

			DbSelectArea("SEE"); DbSetOrder(1);DbGoTop()
			If !DbSeek(xFilial("SEE")+ MV_PAR05 + MV_PAR06 + MV_PAR07 /*+ MV_PAR08*/, .F.)	//	EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

				Aadd(aErro, "Não encontrados dados Parâm. Banco   [ "+MV_PAR05+" ] "+ENTER+;
					"Agência   [ " +MV_PAR06+" ]"+ENTER+;
					"Conta     [ " +MV_PAR07+" ]"+ENTER+;
					"Sub-Conta [ " +MV_PAR08+" ]"+ENTER+;
					"Verifique cadastro de parametros bancario - CNAB - Tab.SEE ")

			EndIf

			If Len(aErro) == 0

				// ARRAY aDadosBanco - DADOS BANCO
				aDadosBanco := {}
				Aadd(aDadosBanco, AllTrim(SA6->A6_COD)		)						 							// 01 - Numero do Banco
				Aadd(aDadosBanco, AllTrim(SA6->A6_NREDUZ)	)						 							// 02 - Nome do Banco
				Aadd(aDadosBanco, AllTrim(SA6->A6_AGENCIA)	)			  										// 03 - Agência
				Aadd(aDadosBanco, AllTrim(SA6->A6_NUMCON)	)			   	      								// 04 - Conta Corrente
				Aadd(aDadosBanco, AllTrim(SA6->A6_DVCTA)	)			   	      								// 05 - Digito Conta Corrente
				Aadd(aDadosBanco, '109'						)			   	      								// 06 - Codigo da Carteira
				//Aadd(aDadosBanco, AllTrim(SA6->A6_CARTEIR)	)		   	      								// 07 - Codigo da Carteira

				// ARRAY aDatSacado - DADOS SACADO
				_xCgcCpf := IIF( Len(AllTrim(SA1->A1_CGC)) <> 14, Transform(SA1->A1_CGC,"@R 999.999.999-99"), Transform(SA1->A1_CGC,"@R 99.999.999/9999-99") )
				If Empty(SA1->A1_ENDCOB)
					aDatSacado   := {	AllTrim(SA1->A1_NOME)                            ,;		// [1]Razão Social
					AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;	// [2]Código
					AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),; 	// [3]Endereço
					AllTrim(SA1->A1_MUN )                             ,;	// [4]Cidade
					SA1->A1_EST                                       ,; 	// [5]Estado
					SA1->A1_CEP                                       ,;	// [6]CEP
					SA1->A1_CGC									  }  		// [7]CGC
				Else
					aDatSacado   := {	AllTrim(SA1->A1_NOME)                               ,;   	// [1]Razão Social
					AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
					AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
					AllTrim(SA1->A1_MUNC)	                              ,;   	// [4]Cidade
					SA1->A1_ESTC	                                      ,;   	// [5]Estado
					SA1->A1_CEPC                                         ,;   	// [6]CEP
					SA1->A1_CGC										   }    	// [7]CGC
				Endif


				_cNossoNum 	:= 	''
				aAreaTmpSE1	:=	GetArea()
				DbSelectArea("SE1");DbSetOrder(1);DbGoTop()
				If DbSeek(xFilial("SE1") + (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_PARCELA + (cAliasSE1)->E1_TIPO, .F.)
					_cNossoNum := Left(AllTrim(SE1->E1_NUMBCO),08)
				EndIf
				RestArea(aAreaTmpSE1)

				// ARRAY aDadosTit - DADOS TITULOS
				If !Empty((cAliasSE1)->E1_PARCELA)
                    _nPar := (Asc(UPPER((cAliasSE1)->E1_PARCELA))-64)
					If _nPar < 10
						_cPar := strzero(_nPar,1)
					Else 
						_cPar := strzero(_nPar,2)
					EndIf
				Else
					_cPar := "0"
					_nPar := 0
				EndIf

				aDadosTit   := 	{}
				_cNossoNum 	:= 	IIF(!Empty(AllTrim(_cNossoNum)), _cNossoNum, PadL(AllTrim(Soma1(SEE->EE_NUMBCO)),08, '0')) // cFilant + SubStr((StrZero(Val(Alltrim((cAliasSE1)->E1_NUM)),6)),2,5) + (cAliasSE1)->E1_PARCELA //Composicao Filial + Titulo + Parcela
				//RAV-20211013 - AJUSTE PARA INCLUIR A PARCELA
				If _nPar < 10
					cNumNN  	:= strzero(VAL(ALLTRIM(cValToChar(mdl11nn((cAliasSE1)->E1_FILIAL)))+ALLTRIM(cValToChar(VAL((cAliasSE1)->E1_NUM))) + _cPar),12)
				Else
					cNumNN  	:= strzero(VAL(ALLTRIM(cValToChar(VAL((cAliasSE1)->E1_NUM))) + _cPar),12)
				EndIf
	
				nVlrAbat    :=  SomaAbat((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,"R",1,,(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA)

				CB_RN_NN    := 	Ret_cBarra(Subs(aDadosBanco[01],1,3)+"9",aDadosBanco[03],aDadosBanco[04],aDadosBanco[05],_cNossoNum,((cAliasSE1)->E1_VALOR-nVlrAbat - (cAliasSE1)->E1_DECRESC),(cAliasSE1)->E1_VENCREA)

				Aadd(aDadosTit, AllTrim((cAliasSE1)->E1_NUM) + AllTrim((cAliasSE1)->E1_PARCELA) ) 		 	// 01 - Número do título
				Aadd(aDadosTit, (cAliasSE1)->E1_EMISSAO)						    						// 02 - Data da emissão do título
				Aadd(aDadosTit, Date())									   							// 03 - Data da emissão do boleto
				Aadd(aDadosTit, (cAliasSE1)->E1_VENCREA)   						 						// 04 - Data do vencimento
				//RAV-20230929
				Aadd(aDadosTit, ((cAliasSE1)->E1_SALDO+ (cAliasSE1)->E1_ACRESC)-nVlrAbat-(cAliasSE1)->E1_DECRESC)  // 05 - Valor do título
				Aadd(aDadosTit, _cNossoNum)		   													// 06 - Nosso número (Ver fórmula para calculo)
				Aadd(aDadosTit, (cAliasSE1)->E1_PREFIXO)						    						// 07 - Prefixo da NF
				Aadd(aDadosTit, (cAliasSE1)->E1_TIPO)
                
                 //Parametro -> valor Mora ao dia, a ser cobrado pelo nao pgto do boleto
                If ValType(SuperGetMv("NL_VLRMORA", .F., "" )) = "C"
                    cVlrMora := AllTrim(SuperGetMv("NL_VLRMORA", .F., "" ))
                Else
                    cVlrMora := cValToChar(SuperGetMv("NL_VLRMORA", .F., "" ))
                EndIf

                //Parametro -> valor de Porcentagem ao dia, a ser cobrado pelo nao pgto do boleto
                If ValType(SuperGetMv("NL_PERMORA", .F., "" )) = "C"
                    cPerMora := AllTrim(SuperGetMv("NL_PERMORA", .F., "" ))
                Else
                    cPerMora := cValToChar(SuperGetMv("NL_PERMORA", .F., "" ))
                EndIf

				If !Empty(cVlrMora) .And. Val(StrTran(cVlrMora, ",", ".")) > 0
					cInstr1	:= 	'APÓS O VENCIMENTO COBRAR MORA DE R$ '+cVlrMora+' AO DIA.'
					cInstr2 := 	'COBRANCA ESCRITURAL.'
					cInstr3 := 	'APÓS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO'
				ElseIf !Empty(cPerMora) .And. Val(StrTran(cPerMora, ",", ".")) > 0
					cInstr1	:= 	'APÓS O VENCIMENTO COBRAR MORA DE '+cPerMora+' % AO DIA DO VALOR DO TITULO'
					cInstr2 := 	'COBRANCA ESCRITURAL.'
					cInstr3 := 	'APÓS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO'
				EndIf
		
				aBolText    := {}
				If !Empty(cInstr1)
					Aadd(aBolText, cInstr1)			   												// 1a. Linha da Instrução Bancária
				EndIf
				If !Empty(cInstr2)
					Aadd(aBolText, cInstr2)															// 2a. Linha da Instrução Bancária
				EndIf
				If !Empty(cInstr3)
					Aadd(aBolText, cInstr3)															// 3a. Linha da Instrução Bancária
				EndIf

				// Impress - Funcao Impressao Boleto 
				Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, lVisualiza)
			Else

				cMsgErro := ''
				For nX:= 1 To Len(aErro)
					cMsgErro += aErro[nX]+ENTER
				Next
				Aviso('Erro',cMsgErro,{'Ok'},3)

			EndIf

			DbSelectArea(cAliasSE1)
			(cAliasSE1)->(DbSkip())
			
		EndIf
	EndDo
	oPrint:EndPage()	// Finaliza a Pagina.
	oPrint:Preview()	// Visualiza antes de Imprimir.

RETURN nil

/*/{Protheus.doc} Impress
Função que realiza a impressão do boleto bancario Itau. 
Todas as coordenadas de impressão respeitam os campos nLinha e nColuna, 
permitindo ajuste flexível sem alterar o layout original.
@type  function
@version P12
@author Tecnosiga-NS
@since 26/11/2025
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,lVisualiza)
    Local aAreaTmp  := GetArea()
    Local cLogoBco  := "\system\logo_itau.bmp" // Logo do Banco
    Local nX
    Local oFont2n
    Local oFont8
    Local oFont9
    Local oFont10
    Local oFont15n
    Local oFont16
    Local oFont16n
    Local oFont14n
    Local oFont24
    Local i := 0
    Local oBrush
	Local cNomeBanco := AllTrim(aDadosBanco[2])//"Banco Itaú S.A."
	Local cLocalPagto := 'PAGÁVEL PREFERENCIALMENTE NO ITAÚ OU EM QUALQUER BANCO ATÉ O VENCIMENTO.'+ENTER+'APÓS O VENCIMENTO, SOMENTE NO ITAÚ.'

    // Objetos para tamanho e tipo das fontes
    oFont8   := TFont():New("Times New Roman",,8 ,,.F.,,,,,.F.)
    oFont10CN:= TFont():New("Courier New"    ,,10,,.T.,,,,,.F.)
    oFont12CN:= TFont():New("Courier New"    ,,12,,.T.,,,,,.F.)
    oFont14CN:= TFont():New("Courier New"    ,,14,,.T.,,,,,.F.)
    oFont10  := TFont():New("Times New Roman",,10,,.T.,,,,,.F.)
    oFont12  := TFont():New("Times New Roman",,12,,.T.,,,,,.F.)
    oFont16  := TFont():New("Times New Roman",,16,,.T.,,,,,.F.)
    oFont16n := TFont():New("Times New Roman",,16,,.T.,,,,,.F.)
    oFont24  := TFont():New("Times New Roman",,20,,.T.,,,,,.F.)

    // Parâmetros de TFont.New()
    // 1.Nome da Fonte (Windows)
    // 3.Tamanho em Pixels
    // 5.Bold (T/F)

    oFont2n := TFont():New("Times New Roman",,10,,.T.,,,,,.F. )
    oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
    oFont9  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
    oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
    oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont16n:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

    oBrush := TBrush():New("",5)//4

    //---------------------------------------------------------------------------
    // Desenha o Comprovante de Entrega do Boleto Bancario.
    //---------------------------------------------------------------------------
	nLinha += 5
    // Bloco superior (Recibo do Sacado)
	
    If File(cLogoBco)
        oPrint:SayBitmap( nLinha + 40 , nColuna + 100 , cLogoBco, 100, 100 )
        oPrint:Say      ( nLinha + 84 , nColuna + 240 , cNomeBanco, oFont10 )   // [2] Nome do Banco
    Else
        oPrint:Say      ( nLinha + 84 , nColuna + 100 , aDadosBanco[2] , oFont15n )  // [2] Nome do Banco
    EndIf

    oPrint:Line ( nLinha + 70 , nColuna + 560 , nLinha + 150 , nColuna + 560 )  // linha vertical
    oPrint:Say  ( nLinha + 80 , nColuna + 569 , "341-7", oFont24 )
    oPrint:Line ( nLinha + 70 , nColuna + 760 , nLinha + 150 , nColuna + 760 ) // linha vertical

    oPrint:Say  ( nLinha + 84 , nColuna + 1835, "Comprovante de Entrega", oFont14n )

    oPrint:Line ( nLinha + 150, nColuna + 100, nLinha + 150, nColuna + 2300) // linha horizontal 1
	oPrint:Line ( nLinha + 250, nColuna + 100, nLinha + 250, nColuna + 2300) // linha horizontal 2
    oPrint:Line ( nLinha + 320, nColuna + 100, nLinha + 320, nColuna + 2300) // linha horizontal 3
    oPrint:Line ( nLinha + 390, nColuna + 100, nLinha + 390, nColuna + 2300) // linha horizontal 4	
    oPrint:Line ( nLinha + 460, nColuna + 100, nLinha + 460, nColuna + 2300) // linha horizontal 5
	oPrint:Line ( nLinha + 560, nColuna + 100, nLinha + 560, nColuna + 2300) // linha horizontal 6
	oPrint:Line ( nLinha + 700, nColuna + 100, nLinha + 700, nColuna + 2300) // linha horizontal 7

	oPrint:Line ( nLinha + 150 , nColuna + 0100, nLinha + 700 , nColuna + 0100 )  // linha vertical 1
	oPrint:Line ( nLinha + 390 , nColuna + 0465, nLinha + 700 , nColuna + 0465 )  // linha vertical 2
	oPrint:Line ( nLinha + 390 , nColuna + 0950, nLinha + 700 , nColuna + 0950 )  // linha vertical 3
	oPrint:Line ( nLinha + 150 , nColuna + 1900, nLinha + 460 , nColuna + 1900 )  // linha vertical 4
    oPrint:Line ( nLinha + 150 , nColuna + 2300, nLinha + 700 , nColuna + 2300 )  // linha vertical 5

	//---------------------------------------------------------------------------
	// Linhas de informações do boleto
	//---------------------------------------------------------------------------	
	// Linha 2 
    oPrint:Say  ( nLinha + 150, nColuna + 110 , "Local de Pagamento", oFont8)
    oPrint:Say  ( nLinha + 180, nColuna + 150 , cLocalPagto, oFont9)

    oPrint:Say  ( nLinha + 150, nColuna + 1910, "Vencimento" , oFont8)
    oPrint:Say  ( nLinha + 190, nColuna + 2000, DTOC(aDadosTit[4]), oFont10)

	// Linha 3
    oPrint:Say  ( nLinha + 250, nColuna + 110 , "Beneficiário" , oFont8)
    oPrint:Say  ( nLinha + 280, nColuna + 110 , aDadosEmp[1]+"                  - "+aDadosEmp[6], oFont10) //Nome + CNPJ

    oPrint:Say  ( nLinha + 250, nColuna + 1910, "Agência/Código Beneficiário" , oFont8)
    oPrint:Say  ( nLinha + 280, nColuna + 2000, aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5], oFont10)

	// Linha 4
    oPrint:Say  ( nLinha + 320, nColuna + 110 , "Pagador" , oFont8)
    oPrint:Say  ( nLinha + 350, nColuna + 110 , aDatSacado[1], oFont8) //Nome

    oPrint:Say  ( nLinha + 320, nColuna + 1910, "Nosso Número", oFont8)
    oPrint:Say  ( nLinha + 350, nColuna + 2000, aDadosTit[6],   oFont10)
	
	// Linha 5
    oPrint:Say  ( nLinha + 390, nColuna + 110 , "Data do Processamento", oFont8)
    oPrint:Say  ( nLinha + 420, nColuna + 110 , DTOC(aDadosTit[3]),  oFont10) //  Data impressao

	oPrint:Say  ( nLinha + 390, nColuna + 480, "Nro.Documento" , oFont8)
    oPrint:Say  ( nLinha + 420, nColuna + 505, (alltrim(aDadosTit[7]))+aDadosTit[1], oFont10) //Prefixo +Numero+Parcela

    oPrint:Say  ( nLinha + 390, nColuna + 0960, "Espécie Moeda", oFont8)
    oPrint:Say  ( nLinha + 420, nColuna + 1000, "R$",   oFont10) //Moeda

    oPrint:Say  ( nLinha + 390, nColuna + 1910, "Valor do Documento", oFont8)
    oPrint:Say  ( nLinha + 420, nColuna + 2000, AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")), oFont10)

	// Linha 6
	oPrint:Say  ( nLinha + 480, nColuna + 120 , "Recebi(emos) o bloqueto/título", oFont8)
    oPrint:Say  ( nLinha + 520, nColuna + 120 , "com as características acima.",  oFont8)

	oPrint:Say  ( nLinha + 470, nColuna + 480, "Data" , oFont8)
	oPrint:Say  ( nLinha + 470, nColuna + 0960, "Assinatura", oFont8)

	// Linha 7
	oPrint:Say  ( nLinha + 560, nColuna + 110 , "Data", oFont8)
	oPrint:Say  ( nLinha + 560, nColuna + 480, "Entregado" , oFont8)
	oPrint:Say  ( nLinha + 560, nColuna + 960, "Motivos de não entrega. (Para uso da empresa entregadora)", oFont8)

	oPrint:Say  ( nLinha + 590, nColuna + 980, "( )Mudou-se", oFont8)
	oPrint:Say  ( nLinha + 590, nColuna + 1350, "( )Recusado", oFont8)
	oPrint:Say  ( nLinha + 590, nColuna + 1750, "( )Desconhecido", oFont8)

	oPrint:Say  ( nLinha + 620, nColuna + 980, "( )Ausente", oFont8)
	oPrint:Say  ( nLinha + 620, nColuna + 1350, "( )Não Procurado", oFont8)
	oPrint:Say  ( nLinha + 620, nColuna + 1750, "( )Falecido", oFont8)

	oPrint:Say  ( nLinha + 650, nColuna + 980, "( )Não existe nº. indicado", oFont8)
	oPrint:Say  ( nLinha + 650, nColuna + 1350, "( )Endereço insuficiente", oFont8)
	oPrint:Say  ( nLinha + 650, nColuna + 1750, "( )Outros (Anotar no verso)", oFont8)
	
	nLinha += 150 

    // linhas tracejadas ----------------------
    For i := 100 To 2300 Step 50
        oPrint:Line( nLinha + 590, nColuna + i, nLinha + 590, nColuna + i + 30)
    Next i

	nLinha += 30

	//---------------------------------------------------------------------------
	// Primeiro Recibo do Sacado.
	//---------------------------------------------------------------------------
    oPrint:Line ( nLinha + 710, nColuna + 100 , nLinha + 710, nColuna + 2300) //Primeira linha horizontal

	//Linhas verticais 
    oPrint:Line ( nLinha + 910, nColuna + 500 , nLinha + 1050, nColuna + 500)
    oPrint:Line ( nLinha + 980, nColuna + 750 , nLinha + 1050, nColuna + 750)
    oPrint:Line ( nLinha + 910, nColuna + 1000, nLinha + 1050, nColuna + 1000)
    oPrint:Line ( nLinha + 910, nColuna + 1350, nLinha + 980 , nColuna + 1350)
    oPrint:Line ( nLinha + 910, nColuna + 1550, nLinha + 1050, nColuna + 1550)

    // LOGOTIPO segunda parte (Recibo)
    If File(cLogoBco)
        oPrint:SayBitmap( nLinha + 600, nColuna + 100, cLogoBco, 100, 100 )
        oPrint:Say      ( nLinha + 640, nColuna + 240, cNomeBanco, oFont10 )   // [2]Nome do Banco
    Else
        oPrint:Say      ( nLinha + 644, nColuna + 100, aDadosBanco[2], oFont15n )   // [2]Nome do Banco
    EndIf

    oPrint:Line ( nLinha + 608, nColuna + 560 , nLinha + 608 + 100 , nColuna + 560 )  // Linha vertical
	oPrint:Say  ( nLinha + 618, nColuna + 569, "341-7", oFont24 )      			// Numero do Banco
	oPrint:Line ( nLinha + 608, nColuna + 760 , nLinha + 608 + 100 , nColuna + 760 )  // Linha vertical
	
    oPrint:Say  ( nLinha + 644, nColuna + 820, CB_RN_NN[2], oFont14n)  // Linha Digitavel do Codigo de Barras

    oPrint:Line ( nLinha + 810, nColuna + 100 , nLinha + 810, nColuna + 2300)
    oPrint:Line ( nLinha + 910, nColuna + 100 , nLinha + 910, nColuna + 2300)
    oPrint:Line ( nLinha + 980, nColuna + 100 , nLinha + 980, nColuna + 2300)
    oPrint:Line ( nLinha + 1050, nColuna + 100, nLinha + 1050, nColuna + 2300)

	//Linhas verticais 
    oPrint:Line ( nLinha + 910, nColuna + 500 , nLinha + 1050, nColuna + 500)
    oPrint:Line ( nLinha + 980, nColuna + 750 , nLinha + 1050, nColuna + 750)
    oPrint:Line ( nLinha + 910, nColuna + 1000, nLinha + 1050, nColuna + 1000)
    oPrint:Line ( nLinha + 910, nColuna + 1350, nLinha + 980 , nColuna + 1350)
    oPrint:Line ( nLinha + 910, nColuna + 1550, nLinha + 1050, nColuna + 1550)

	// Linha 1	
    oPrint:Say  ( nLinha + 710, nColuna + 110 , "Local de Pagamento", oFont8)
    oPrint:Say  ( nLinha + 730, nColuna + 400 , cLocalPagto, oFont9)

    oPrint:Say  ( nLinha + 710, nColuna + 1910, "Vencimento" , oFont8)
    oPrint:Say  ( nLinha + 750, nColuna + 2000, DTOC(aDadosTit[4]), oFont10)

	// Linha 2
    oPrint:Say  ( nLinha + 810, nColuna + 110 , "Beneficiário" , oFont8)
    oPrint:Say  ( nLinha + 850, nColuna + 110 , aDadosEmp[1]+"                  - "+aDadosEmp[6], oFont10) //Nome + CNPJ

    oPrint:Say  ( nLinha + 810, nColuna + 1910, "Agência/Código Beneficiário" , oFont8)
    oPrint:Say  ( nLinha + 850, nColuna + 2000, aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5], oFont10)

	// Linha 3
    oPrint:Say  ( nLinha + 910, nColuna + 110 , "Data do Documento", oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 110 , DTOC(aDadosTit[2]),  oFont10) // Emissao do Titulo (E1_EMISSAO)

    oPrint:Say  ( nLinha + 910, nColuna + 505 , "Nro.Documento", oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 605 , (alltrim(aDadosTit[7]))+aDadosTit[1], oFont10) //Prefixo +Numero+Parcela

    oPrint:Say  ( nLinha + 910, nColuna + 1005, "Espécie Doc.", oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 1050, aDadosTit[8],   oFont10) //Tipo do Titulo

    oPrint:Say  ( nLinha + 910, nColuna + 1355, "Aceite" , oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 1455, "N"     , oFont10)

    oPrint:Say  ( nLinha + 910, nColuna + 1555, "Data do Processamento", oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 1655, DTOC(aDadosTit[3]),      oFont10) // Data impressao

    oPrint:Say  ( nLinha + 910, nColuna + 1910, "Nosso Número", oFont8)
    oPrint:Say  ( nLinha + 940, nColuna + 2000, aDadosTit[6],   oFont10)

	// Linha 4
    oPrint:Say  ( nLinha + 980, nColuna + 110 , "Uso do Banco", oFont8)

    oPrint:Say  ( nLinha + 980, nColuna + 505 , "Carteira", oFont8)
    oPrint:Say  ( nLinha + 1010, nColuna + 555, aDadosBanco[6], oFont10)

    oPrint:Say  ( nLinha + 980, nColuna + 755 , "Espécie", oFont8)
    oPrint:Say  ( nLinha + 1010, nColuna + 805, "R$",     oFont10)

    oPrint:Say  ( nLinha + 980, nColuna + 1005, "Quantidade", oFont8)
    oPrint:Say  ( nLinha + 980, nColuna + 1555, "Valor"     , oFont8)

    oPrint:Say  ( nLinha + 980, nColuna + 1910, "Valor do Documento", oFont8)
    oPrint:Say  ( nLinha + 1010, nColuna + 2000, AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")), oFont10)

	// Linha 5
    oPrint:Say  ( nLinha + 1050, nColuna + 110, "Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)", oFont8)

    nLin := nLinha + 1090
	//Teste de instruções do boleto bancário
    For nX := 1 To Len(aBolText)
        nLin += IIF(Len(aBolText) < 9 .And. nX==1, 40, 0)
        oPrint:Say( nLin , nColuna + 110 , aBolText[nX], oFont10)
        nLin += 40
    Next

    oPrint:Say  ( nLinha + 1050, nColuna + 1910, "(-)Desconto/Abatimento", oFont8)
    oPrint:Say  ( nLinha + 1120, nColuna + 1910, "(-)Outras Deduções"    , oFont8)
    oPrint:Say  ( nLinha + 1190, nColuna + 1910, "(+)Mora/Multa"         , oFont8)
    oPrint:Say  ( nLinha + 1260, nColuna + 1910, "(+)Outros Acréscimos"  , oFont8)
    oPrint:Say  ( nLinha + 1330, nColuna + 1910, "(=)Valor Cobrado"      , oFont8)

    oPrint:Say  ( nLinha + 1400, nColuna + 110 , "Pagador" , oFont8)
    oPrint:Say  ( nLinha + 1430, nColuna + 400 , aDatSacado[1]+" ("+aDatSacado[2]+")", oFont10)
    oPrint:Say  ( nLinha + 1483, nColuna + 400 , aDatSacado[3], oFont10)
    oPrint:Say  ( nLinha + 1536, nColuna + 400 , ;
                  aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5], oFont10) // CEP+Cidade+Estado

    If Len(Alltrim(aDatSacado[7])) == 14
        oPrint:Say  ( nLinha + 1589, nColuna + 400 , "C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"), oFont10) // CGC
    Else
        oPrint:Say  ( nLinha + 1589, nColuna + 400 , "C.P.F.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"), oFont10) // CPF
    EndIf
    oPrint:Say  ( nLinha + 1589, nColuna + 1850, Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1), oFont10)

    oPrint:Say  ( nLinha + 1605, nColuna + 110 , "Sacador/Avalista" , oFont8)
    oPrint:Say  ( nLinha + 1645, nColuna + 1500, "Autenticação Mecânica -" , oFont8)
    oPrint:Say  ( nLinha + 1645, nColuna + 1900, "Recibo do Sacado"        , oFont10)

	oPrint:Line ( nLinha + 710, nColuna + 100, nLinha + 1640, nColuna + 100) // Linha 1 vertical
	oPrint:Line ( nLinha + 710, nColuna + 2300, nLinha + 1640, nColuna + 2300) // Ultima Linha vertical
    oPrint:Line ( nLinha + 710 , nColuna + 1900, nLinha + 1400, nColuna + 1900)
    oPrint:Line ( nLinha + 1120, nColuna + 1900, nLinha + 1120, nColuna + 2300)
    oPrint:Line ( nLinha + 1190, nColuna + 1900, nLinha + 1190, nColuna + 2300)
    oPrint:Line ( nLinha + 1260, nColuna + 1900, nLinha + 1260, nColuna + 2300)
    oPrint:Line ( nLinha + 1330, nColuna + 1900, nLinha + 1330, nColuna + 2300)
    oPrint:Line ( nLinha + 1400, nColuna + 100 , nLinha + 1400, nColuna + 2300)
    oPrint:Line ( nLinha + 1640, nColuna + 100 , nLinha + 1640, nColuna + 2300)

	nLinha -= 200
    // tracejado inferior ---------
    For i := 100 To 2300 Step 50
        oPrint:Line( nLinha + 1930, nColuna + i, nLinha + 1930, nColuna + i + 30)
    Next i

    oPrint:Line ( nLinha + 2080, nColuna + 100 , nLinha + 2080, nColuna + 2300) // Primeira Linha horizontal
    oPrint:Line ( nLinha + 2080, nColuna + 550 , nLinha + 1980, nColuna + 0550) //Linha vertical
    oPrint:Line ( nLinha + 2080, nColuna + 800 , nLinha + 1980, nColuna + 0800) //Linha vertical

    // LOGOTIPO – Ficha de Compensação
    If File(cLogoBco)
        oPrint:SayBitmap( nLinha + 1970, nColuna + 100, cLogoBco, 100, 100 )
        oPrint:Say      ( nLinha + 2010, nColuna + 240, cNomeBanco, oFont10 ) // [2]Nome do Banco
    Else
        oPrint:Say      ( nLinha + 2014, nColuna + 100, aDadosBanco[2], oFont15n ) // [2]Nome do Banco
    EndIf

    oPrint:Line ( nLinha + 1978, nColuna + 560 , nLinha+1978+100 , nColuna + 560 )  // Linha vertical
    oPrint:Say  ( nLinha + 1988, nColuna + 569, "341-7", oFont24 )      		// Numero do Banco
	oPrint:Line ( nLinha + 1978, nColuna + 760 , nLinha+1978+100 , nColuna + 760 )  // Linha vertical

    oPrint:Say  ( nLinha + 2014, nColuna + 820, CB_RN_NN[2], oFont14n) // Linha Digitavel

    oPrint:Line ( nLinha + 2180, nColuna + 100 , nLinha + 2180, nColuna + 2300)
    oPrint:Line ( nLinha + 2280, nColuna + 100 , nLinha + 2280, nColuna + 2300)
    oPrint:Line ( nLinha + 2350, nColuna + 100 , nLinha + 2350, nColuna + 2300)
    oPrint:Line ( nLinha + 2420, nColuna + 100 , nLinha + 2420, nColuna + 2300)

	//linhas verticais
    oPrint:Line ( nLinha + 2280, nColuna + 500 , nLinha + 2420, nColuna + 500)
    oPrint:Line ( nLinha + 2350, nColuna + 750 , nLinha + 2420, nColuna + 750)
    oPrint:Line ( nLinha + 2280, nColuna + 1000, nLinha + 2420, nColuna + 1000)
    oPrint:Line ( nLinha + 2280, nColuna + 1350, nLinha + 2350, nColuna + 1350)
    oPrint:Line ( nLinha + 2280, nColuna + 1550, nLinha + 2420, nColuna + 1550)

	// Linha 1
    oPrint:Say  ( nLinha + 2080, nColuna + 110 , "Local de Pagamento", oFont8)
    oPrint:Say  ( nLinha + 2100, nColuna + 400 , cLocalPagto, oFont9)

    oPrint:Say  ( nLinha + 2080, nColuna + 1910, "Vencimento" , oFont8)
    oPrint:Say  ( nLinha + 2120, nColuna + 2000, DTOC(aDadosTit[4]), oFont10)

	// Linha 2
    oPrint:Say  ( nLinha + 2180, nColuna + 110 , "Beneficiário" , oFont8)
    oPrint:Say  ( nLinha + 2220, nColuna + 110 , ;
                  aDadosEmp[1]+"                  - "+aDadosEmp[6], oFont10) //Nome + CNPJ

    oPrint:Say  ( nLinha + 2180, nColuna + 1910, "Agência/Código Beneficiário", oFont8)
    oPrint:Say  ( nLinha + 2220, nColuna + 2000, ;
                  aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5], oFont10)

	// Linha 3
    oPrint:Say  ( nLinha + 2280, nColuna + 110 , "Data do Documento", oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 110 , DTOC(aDadosTit[2]),  oFont10) // Emissao do Titulo

    oPrint:Say  ( nLinha + 2280, nColuna + 505 , "Nro.Documento", oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 605 , (alltrim(aDadosTit[7]))+aDadosTit[1], oFont10) //Prefixo +Numero+Parcela

    oPrint:Say  ( nLinha + 2280, nColuna + 1005, "Espécie Doc." , oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 1050, aDadosTit[8]   , oFont10) //Tipo do Titulo

    oPrint:Say  ( nLinha + 2280, nColuna + 1355, "Aceite" , oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 1455, "N"     , oFont10)

    oPrint:Say  ( nLinha + 2280, nColuna + 1555, "Data do Processamento", oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 1655, DTOC(aDadosTit[3])     , oFont10)

    oPrint:Say  ( nLinha + 2280, nColuna + 1910, "Nosso Número" , oFont8)
    oPrint:Say  ( nLinha + 2310, nColuna + 2000, aDadosTit[6]   , oFont10)

	// Linha 4
    oPrint:Say  ( nLinha + 2350, nColuna + 110 , "Uso do Banco", oFont8)

    oPrint:Say  ( nLinha + 2350, nColuna + 505 , "Carteira", oFont8)
    oPrint:Say  ( nLinha + 2380, nColuna + 555 , aDadosBanco[6], oFont10)

    oPrint:Say  ( nLinha + 2350, nColuna + 755 , "Espécie", oFont8)
    oPrint:Say  ( nLinha + 2380, nColuna + 805 , "R$",     oFont10)

    oPrint:Say  ( nLinha + 2350, nColuna + 1005, "Quantidade", oFont8)
    oPrint:Say  ( nLinha + 2350, nColuna + 1555, "Valor"     , oFont8)

    oPrint:Say  ( nLinha + 2350, nColuna + 1910, "Valor do Documento", oFont8)
    oPrint:Say  ( nLinha + 2380, nColuna + 2000, AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")), oFont10)

	// Linha 5
    oPrint:Say  ( nLinha + 2420, nColuna + 110 , "Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)", oFont8)

    nLin := nLinha + 2460
	//Teste de instruções do boleto bancário
    For nX := 1 To Len(aBolText)
        nLin += IIF(Len(aBolText) < 9 .And. nX==1, 40, 0)
        oPrint:Say( nLin , nColuna + 110 , aBolText[nX], oFont10)
        nLin += 40
    Next

    oPrint:Say  ( nLinha + 2420, nColuna + 1910, "(-)Desconto/Abatimento", oFont8)
    oPrint:Say  ( nLinha + 2490, nColuna + 1910, "(-)Outras Deduções"    , oFont8)
    oPrint:Say  ( nLinha + 2560, nColuna + 1910, "(+)Mora/Multa"         , oFont8)
    oPrint:Say  ( nLinha + 2630, nColuna + 1910, "(+)Outros Acréscimos"  , oFont8)
    oPrint:Say  ( nLinha + 2700, nColuna + 1910, "(=)Valor Cobrado"      , oFont8)

    oPrint:Say  ( nLinha + 2770, nColuna + 110 , "Pagador" , oFont8)
    oPrint:Say  ( nLinha + 2800, nColuna + 400 , aDatSacado[1]+" ("+aDatSacado[2]+")", oFont10)
    oPrint:Say  ( nLinha + 2853, nColuna + 400 , aDatSacado[3], oFont10)
    oPrint:Say  ( nLinha + 2906, nColuna + 400 , aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5], oFont10)

    IF Len(Alltrim(aDatSacado[7])) == 14
        oPrint:Say  ( nLinha + 2959, nColuna + 400 , ;
                      "C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"), oFont10)
    ELSE
        oPrint:Say  ( nLinha + 2959, nColuna + 400 , ;
                      "C.P.F.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"), oFont10)
    ENDIF

    oPrint:Say  ( nLinha + 2959, nColuna + 1850, ;
                  Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1), oFont10)

    oPrint:Say  ( nLinha + 2975, nColuna + 110 , "Sacador/Avalista", oFont8)
    oPrint:Say  ( nLinha + 3015, nColuna + 1500, "Autenticação Mecânica -", oFont8)
    oPrint:Say  ( nLinha + 3015, nColuna + 1850, "Ficha de Compensação",   oFont10)

	oPrint:Line ( nLinha + 2080, nColuna + 100, nLinha + 3010, nColuna + 100) // Linha 1 vertical
	oPrint:Line ( nLinha + 2080, nColuna + 2300, nLinha + 3010, nColuna + 2300) // Ultima vertical

    oPrint:Line ( nLinha + 2080, nColuna + 1900, nLinha + 2770, nColuna + 1900) // Linha vertical
    oPrint:Line ( nLinha + 2490, nColuna + 1900, nLinha + 2490, nColuna + 2300) 
    oPrint:Line ( nLinha + 2560, nColuna + 1900, nLinha + 2560, nColuna + 2300)
    oPrint:Line ( nLinha + 2630, nColuna + 1900, nLinha + 2630, nColuna + 2300)
    oPrint:Line ( nLinha + 2700, nColuna + 1900, nLinha + 2700, nColuna + 2300)
    oPrint:Line ( nLinha + 2770, nColuna + 100 , nLinha + 2770, nColuna + 2300)

    oPrint:Line ( nLinha + 3010, nColuna + 100 , nLinha + 3010, nColuna + 2300) // ultima linha horizontal

	nLinha := 0	
    nCB1Linha := 14.5
    nCB2Linha := 25.8 //26.1
    nCBColuna := 1.3
    nCBLargura := 0.0280
    nCBAltura  := 1.4

	//Imprime o Codigo de Barras
    //MsBar("INT25", nLinha + nCB1Linha, nColuna + nCBColuna, CB_RN_NN[1], oPrint,.F.,,, nCBLargura, nCBAltura,,,,.F.)
    MsBar("INT25", nLinha + nCB2Linha, nColuna + nCBColuna, CB_RN_NN[1], oPrint,.F.,,, nCBLargura, nCBAltura,,,,.F.)
    
    oPrint:EndPage()    // Finaliza a Pagina

    DbSelectArea("SE1")
    DbSetOrder(1)
    DbGoTop()
    If DbSeek(xFilial("SE1") + (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_PARCELA + (cAliasSE1)->E1_TIPO, .F.)
        If Empty(SE1->E1_NUMBCO) // atualiza somente se ainda não tiver num.banco
            RecLock("SE1", .F.)
            SE1->E1_CODBAR := CB_RN_NN[1]                                           // Código de Barras
            SE1->E1_CODDIG := StrTran(StrTran(CB_RN_NN[2], '.',''),' ','')          // Código Digitável
            SE1->E1_NUMBCO := aDadosTit[6]                                          // Nosso número
            SE1->E1_PORTADO:= SEE->EE_CODIGO
            SE1->E1_AGEDEP := SEE->EE_AGENCIA
            SE1->E1_CONTA  := SEE->EE_CONTA
            MsUnlock()

            DbSelectArea("SEE")
            RecLock("SEE", .F.)
            SEE->EE_NUMBCO := Soma1(SEE->EE_NUMBCO)
            MsUnlock()
        EndIf
    EndIf

    RestArea(aAreaTmp)
Return

/*/{Protheus.doc} MontaPerg
Função responsavel por exibir a tela de parâmetros da rotina utilizando ParamBox.
@type  function
@version P12
@author Consultor Protheus
@since 26/11/2025
/*/
Static Function MontaPerg()
    Local aPergs      := {}

    // Valores padrão (pode ajustar como preferir)
    Local cPrefixoDe  := Space(3)
    Local cPrefixoAte := Replicate("Z", 3)

    Local cTitDe      := Space(9)
    Local cTitAte     := Replicate("Z", 9)

    Local cBanco      := Space(3)
    Local cAgencia    := Space(5)
    Local cConta      := Space(10)
    Local cSubConta   := Space(1)

    Local dEmisDe     := FirstDate(Date())
    Local dEmisAte    := LastDate(Date())

    Local cCliDe      := Space(6)
    Local cLojaDe     := Space(2)
    Local cCliAte     := Replicate("Z", 6)
    Local cLojaAte    := Replicate("Z", 2)

    // ------------------------------------------------------------------------
    // Estrutura do tipo 1 (MsGet) para ParamBox:
    // { 1, "Descrição", uValor, "Picture", "Validação", "F3", "When", nTam, lObrig }
    // ------------------------------------------------------------------------

    // 01 - Prefixo De
    AAdd(aPergs, { 1, "Prefixo De",  cPrefixoDe,  "", ".T.", "",    ".T.", 20, .F. })

    // 02 - Prefixo Até
    AAdd(aPergs, { 1, "Prefixo Até", cPrefixoAte, "", ".T.", "",    ".T.", 20, .T. })

    // 03 - Título De  (F3 em SE1)
    AAdd(aPergs, { 1, "Título De",   cTitDe,      "", ".T.", "SE1", ".T.", 40, .F. })

    // 04 - Título Até (F3 em SE1)
    AAdd(aPergs, { 1, "Título Até",  cTitAte,     "", ".T.", "SE1", ".T.", 40, .T. })

    // 05 - Banco p/ Emissão (F3 SA6 + validação ExistCpo)
    AAdd(aPergs, { 1, "Banco p/ Emissão", cBanco, "", "ExistCpo('SA6', &(ReadVar()))", "SA6", ".T.", 20, .F. })

    // 06 - Agência
    AAdd(aPergs, { 1, "Agência",     cAgencia, "", ".T.", "", ".T.", 15, .F. })

    // 07 - Conta
    AAdd(aPergs, { 1, "Conta",       cConta,   "", ".T.", "", ".T.", 20, .F. })

    // 08 - Sub-Conta
    AAdd(aPergs, { 1, "Sub-Conta",   cSubConta, "", ".T.", "", ".T.", 10, .F. })

    // 09 - Emissão De (Data)
    AAdd(aPergs, { 1, "Emissão De",  dEmisDe,  "", ".T.", "", ".T.", 80, .F. })

    // 10 - Emissão Até (Data)
    AAdd(aPergs, { 1, "Emissão Até", dEmisAte, "", ".T.", "", ".T.", 80, .T. })

    // 11 - Cliente De (F3 SA1)
    AAdd(aPergs, { 1, "Cliente De",  cCliDe,  "", ".T.", "SA1", ".T.", 30, .F. })

    // 12 - Loja De
    AAdd(aPergs, { 1, "Loja De",     cLojaDe, "", ".T.", "",    ".T.", 10, .F. })

    // 13 - Cliente Até (F3 SA1)
    AAdd(aPergs, { 1, "Cliente Até", cCliAte, "", ".T.", "SA1", ".T.", 30, .T. })

    // 14 - Loja Até
    AAdd(aPergs, { 1, "Loja Até",    cLojaAte, "", ".T.", "", ".T.", 10, .T. })

    // Chamada do ParamBox 
    If ParamBox(aPergs, "Parâmetros do Relatório")
        Return .T.
    EndIf

Return .F.

/*/{Protheus.doc} Ret_cBarra
Gera o codigo de barras, a linha digitavel e o número "Nosso Numero" do boleto
Itaú, aplicando os cálculos de DV via Módulo 10 e 11, fator de vencimento e
montagem completa dos campos do padrão bancário. Retorna {CB, RN, NN}.
@type  function
@version P12
@since  26/11/2025
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
	LOCAL bldocnufinal := strzero(val(cNroDoc),8)
	LOCAL blvalorfinal := strzero(int(nValor*100),10)
	LOCAL dvnn         := 0
	LOCAL dvcb         := 0
	LOCAL dv           := 0
	LOCAL NN           := ''
	LOCAL RN           := ''
	LOCAL CB           := ''
	LOCAL s            := ''
	LOCAL _cfator      := ''
	LOCAL _cCart	   := "109" //carteira de cobranca

	If dVencto <= ctod("21/02/2025")
		_cfator  := strzero(dVencto - ctod("07/10/1997"), 4)
	Else
		_cfator  := strzero(dVencto - ctod("29/05/2022"), 4) //Retorna para 1000
	EndIf

	//-------- Definicao do NOSSO NUMERO
	s    :=  cAgencia + cConta + _cCart + bldocnufinal
	dvnn :=  Modulo10(s) // digito verifacador Agencia + Conta + Carteira + Nosso Num
	NN   := _cCart + bldocnufinal + '-' + AllTrim(Str(dvnn))

	//	-------- Definicao do CODIGO DE BARRAS
	s    := cBanco + _cfator + blvalorfinal + _cCart + bldocnufinal + AllTrim(Str(dvnn)) + cAgencia + cConta + cDacCC + '000'
	dvcb := modulo11(s)
	CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)

	//
	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCDDX		DDDDD.DEFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
	//
	// 	CAMPO 1:
	//	AAA	= Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//	CCC = Codigo da Carteira de Cobranca
	//	 DD = Dois primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	//
	s    := cBanco + _cCart + SubStr(bldocnufinal,1,2)
	dv   := Modulo10(s)
	RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '

	// 	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	//	   FFF = Tres primeiros numeros que identificam a agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	s    := SubStr(bldocnufinal, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
	dv   := Modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//
	// 	CAMPO 3:
	//	     F = Restante do numero que identifica a agencia
	//	GGGGGG = Numero da Conta + DAC da mesma
	//	   HHH = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	s    := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
	dv   := Modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '


	//
	// 	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN   := RN + AllTrim(Str(dvcb)) + '  '
	//
	// 	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN   := RN + _cfator + StrZero(Int(nValor * 100),14-Len(_cfator))

	MemoWrite(GetTempPath()+'BOLETO_ITAU.TXT', 'Cod.Barra:'+ENTER+CB+ENTER+'Linha Dig:'+ENTER+RN)
Return({CB,RN,NN})

/*/{Protheus.doc} Modulo10
Calcula o digito verificador pelo algoritmo bancario de Modulo 10, utilizado
na composição da linha digitavel e do nosso número do boleto Itau.
@type  function
@version P12
@since  26/11/2025
/*/
Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)

/*/{Protheus.doc} Modulo11
Calcula o digito verificador pelo algoritmo de Módulo 11 usando pesos de 2 a 9,
conforme padrão bancário, para validação do código de barras do boleto.
@type  function
@version P12
@since  11/2025
/*/
Static Function Modulo11(cData)
	Local L, D, P := 0
	
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	D := 11 - (Mod(D,11))
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)

/*/{Protheus.doc} mdl11nn
Calcula o digito verificador do “Nosso Numero” utilizando o algoritmo específico
de Módulo 11 empregado pelo Itau, com regras proprias de substituição do DV.
@type  function
@version P12
@since  26/11/2025
/*/
Static Function mdl11nn(cData)
	LOCAL L, D, P,R := 0
	LOCAL _cData := ALLTRIM(cData)
	L := Len(_cData)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(_cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End

	R := mod(D,11)
	If (R == 10)
		D := 1
	ElseIf (R == 0 .or. R == 1)
		D := 0
	Else
		D := (11 - R)
	End

Return(D)
