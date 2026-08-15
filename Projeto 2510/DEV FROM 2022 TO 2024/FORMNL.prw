#include 'protheus.ch'
#Include "TopConn.ch"

#DEFINE CRLF chr(13)+chr(10)


//-------------------------------------------------------------------
/*/{Protheus.doc} FORMNL()
@Description      Gera Formulario de Proposta Comercial 
@type  			  Rotina
@Dev              Rodrigo Salomão
@since 			  07/03/2024
@version 		  1.0
/*/
//------------------------------------------------------------------- 
User Function FORMNL()		

	Local aParamBox     := {}
	Local aParamRet     := {}
	Local lRet          := .T.

	///Parametros
	Public VSPACE       := 100
	Public HMARGEM      := 170
	Public VMARGEM      := 100
	Public PULALINHA    := 060
	Public Li      	    := 1
	Public nPosV		:= VMARGEM
	Public nLinMax		:= 1900  // Número máximo de Linhas  A4 - 2250 // Oficio - 2800
	Public nColMax		:= 2770  // Número máximo de Colunas A4 - 3310 // Oficio - 3955
	
 	aAdd(aParamBox,{1,"N° do Orçamento"    ,Space(TamSX3("CJ_NUM")[1]),"",".T.","",".T."   ,50,.F.}) // Tipo caractere
	aAdd(aParamBox,{1,"Nome Contato"       ,Space(50)                 ,"",""   ,""   ,""   ,50 ,.F.}) // Tipo caractere
	aAdd(aParamBox,{1,"Telefone Contato"   ,Space(11) , "" , "U_VldTel(MV_PAR03)", "",,50, .T.} )
	
	While .T.

		///Variavel de controle
		lRet:= .T.

		
		If ParamBox(aParamBox,"Parametros",@aParamRet,,,,,,,,,.T.)
			
			//Valida N° do Orçamento 
			if !Empty(AllTrim(MV_PAR01)) 

				///Procura o Orçamento 
                SCJ->(DbSetOrder(1))
                if !SCJ->(DbSeek(xFilial("SCJ") + MV_PAR01 ))
                    MsgAlert("N° do Orçamento não encontrado." + CRLF + "Favor digite um numero válido.","Atenção.")
                    lRet := .F.
                Endif
			Else
				MsgAlert("N° do Orçamento em branco." + CRLF + "Favor digite o numero do orçamento.","Atenção.")
                lRet := .F.
            Endif

			//Valida Nome contato
			if Empty(AllTrim(MV_PAR02)) 
				MsgAlert("O nome do contato está em branco." + CRLF + "Favor digite o nome do Contato.","Atenção.")
                lRet := .F.
			Endif

			//Valida Telefone contato
			if Empty(AllTrim(MV_PAR03)) 
				MsgAlert("O Telefone do contato está em branco." + CRLF + "Favor digite o Telefone do Contato.","Atenção.")
                lRet := .F.
			Endif


			if lRet == .T.
				Processa({|lEnd|PrepInfoNL()},"Imprimindo relatório")
				Exit
			Endif

		Else
			MsgAlert("Não foi possível encontrar os parâmetros.","Atenção.")
			Exit
		Endif
	
	End	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrepInfoNL()
@Description      Prepara informações da Proposta Comercial 
@type  			  Rotina
@Dev              Rodrigo Salomão
@since 			  07/03/2024
@version 		  1.0
/*/
//------------------------------------------------------------------- 
Static Function PrepInfoNL()

///----------------- Variaveis ---------------------------------------------------------------///
	
	Local cQuery          := ""
	Local cHora 	      := SUBSTR(TIME(), 1, 2)              // Resulta: 10
	Local cMinut 	      := SUBSTR(TIME(), 4, 2)              // Resulta: 37
	Local cHoje           := AllTrim(STR(DAY(DATE())))+"-"+AllTrim(STR(MONTH(DATE())))+"-"+AllTrim(STR(YEAR(DATE())))
	Local cFilename       := "Orcamento-"+Alltrim(SCJ->CJ_NUM)+"_"+"Data_"+cHoje+"_"+"Hora_"+cHora+"_"+ cMinut + ".rel"
	Local cLocal          := GetSrvProfString("Startpath","")
	Local lAdjustToLegacy := .T.
	Local lDisableSetup   := .T. 
	Local IMP_PDF         := 6
	Local cImgSer         := "\system\imagens\"

	Private cLogo         := ""
	Private cLayout       := ""
	Private oFont13T
	Private oFont10C
	Private oFont10G

	Public oPrint
	Public nRegSCJ        := ""

    cLogo    := "\system\imagens\logo_nlma.jpg"
	cLayout  := "C:\temp\New Leader\cLayout.png"
	
	//Copia a Imagem do local para o servidor se não existir
	if !File(cImgSer + "cLayout.png")
		__CopyFile(cLayout , cImgSer + "cLayout.png" )
	Endif

	cLayout := cImgSer + "cLayout.png"

	oPrint  := FWMSPrinter():New(cFilename, IMP_PDF, lAdjustToLegacy,cLocal,lDisableSetup,/*TReport*/,/*oPrintSetup*/,"Microsoft Print to PDF"/*Impressora*/,/*Imprimir via Server*/,/*PDFasPNG*/,.F. , )

	oPrint:CORIENTCTRL := 2                        ///<== Orientação da Pagina 1 = Retrato 2 = Paisagem
	oPrint:nPapersize  := 9                        ///<== Tamanho do papel
	oPrint:NPAGEHEIGHT := 2400                     ///<== Altura da pagina
	oPrint:NPAGEWIDTH  := 3110                     ///<== Altura da pagina
	oPrint:NQTDCOPIES  := 1                        ///<== Quantidade de copias
	oPrint:SetLandScape()
	oPrint:SetPaperSize(9)   // 9=Papel A4 210x297 mm
	
	//oPrint:= SetParans(oPrint)	

	oFont13T := TFont():New("Arial Black",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10C := TFont():New("Arial Black",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10G := TFont():New("Arial"      ,9,11,.T.,.T.,5,.T.,5,.T.,.F.)


	///Se tiver aberto, fecha tabela
	if Select("TRB1") > 0
		TRB1->(DbCloseArea())
	Endif

	//Query que efetua a contagem de registros a serem processados
	cQuery := "SELECT count(*) as QTDE, SUM(CK_VALOR) AS TOTAL "
	cQuery += "FROM "+RetSqlName("SCK")+" SCK "	
	cQuery += "WHERE SCK.CK_FILIAL = '" + xFilial("SCK") + "' AND SCK.CK_NUM = '" + SCJ->CJ_NUM + "' AND "
	cquery += "SCK.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "TRB1"

	nSomaValor := TRB1->TOTAL
	nPag       := IIF(Round((TRB1->QTDE/17),0) < 1,1,Round((TRB1->QTDE/17),0))
	nPagAtu    := 1

	///Monta Cabeçalho
	U_CABECPC(nPagAtu,nPag)

	///Monta Itens
	U_ITENSPC(nPagAtu,nPag)

	///Monta Total
	U_IMPTOTPC(nPagAtu,nPag)

	///Monta Rodapé
	U_RODAPEPC(nPagAtu,nPag)

///--------------------- Gera o relatório ----------------------------------------------------------------///
	
	oPrint:Preview()


	///Volta pro inicio da Rotina
	U_FORMNL()

Return

/*/{Protheus.doc}    CABECPC
	@Description     Monta o cabeçalho do relatório da Proposta Comercial
	@type  			 Function
	@author          Rodrigo Salomão
	@since 			 07/03/2024
	@version 		 1.0
	@param 		     nReg,nPagAtu,nPag
	@return 
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function CABECPC(nPagAtu,nPag)
	
///SCJ
	Local cCliente   := ""
	Local cLoja      := ""   
	Local cCondPag   := ""
	Local cDesc1     := 0
	Local cDesc2     := 0
	Local cDesc3     := 0
	Local cDesc4     := 0

///SA1
	Local cNome      := ""
	Local cEmail     := ""
	Local cContato   := ""
	Local cTelefone  := ""
	Local cEndereco  := ""
	Local cBairro    := ""
	Local cMunicipio := ""
	Local cEstado    := ""
	Local cCEP       := ""
	Local cCGC       := ""

	Private cOrc     := SCJ->CJ_NUM

///---------------------------------------- Prepara dados SCJ -----------------------------------///
	
	cCliente := SCJ->CJ_CLIENTE 
	cLoja    := SCJ->CJ_LOJA
	cCondPag := SCJ->CJ_CONDPAG
	
	///Descontos
	cDesc1   := AllTrim(Str(SCJ->CJ_DESC1))
	cDesc2   := AllTrim(Str(SCJ->CJ_DESC2))
	cDesc3   := AllTrim(Str(SCJ->CJ_DESC3))
	cDesc4   := AllTrim(Str(SCJ->CJ_DESC4))

	nRegSCJ := SCJ->(Recno())  

///---------------------------------------- Prepara dados SA1 -----------------------------------///

	///Procura os dados do Cliente
	SA1->(DbSetOrder(1))
	if !SA1->(DbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE  ))
		MsgAlert("Dados do Cliente não encontrados." + CRLF + "Favor verifique o cadastro do cliente " + SCJ->CJ_CLIENTE + " .","Atenção.")
		Return()
	Endif

	cNome      := SA1->A1_NOME
	cEmail     := SA1->A1_EMAIL
	cContato   := SA1->A1_CONTATO
	cTelefone  := AllTrim(SA1->A1_TEL)
	cEndereco  := SA1->A1_END
	cBairro    := SA1->A1_BAIRRO
	cMunicipio := SA1->A1_MUN
	cEstado    := SA1->A1_EST
	cCEP       := SA1->A1_CEP
	cCGC       := AllTrim(SA1->A1_CGC)

	///Telefone DDD, Digito 9 ou sem 9 
	if Len(cTelefone) > 9
		if Len(SubStr(cTelefone,3,Len(cTelefone))) > 8
			cTelefone := "("+SubStr(cTelefone,1,2)+")"+Substr(cTelefone,3,5) + "-" + Substr(cTelefone,8,4)
		Else
			cTelefone := "("+SubStr(cTelefone,1,2)+")"+Substr(cTelefone,3,4) + "-" + Substr(cTelefone,7,4)
		Endif
	Elseif Len(cTelefone) > 8
		cTelefone := "("+SubStr(cTelefone,1,1)+")"+Substr(cTelefone,2,4) + "-" + Substr(cTelefone,6,4)
	Else
		cTelefone := Substr(cTelefone,1,4) + "-" + Substr(cTelefone,5,4)
	Endif

	///Trata CEP
	cCEP := SubStr(cCEP,1,5) +"-"+ SubStr(cCEP,6,3) 

	///Trata CNPJ e CPF
	If Len(cCGC) > 12
		cCGC := SubStr(cCGC,1,2)+"."+SubStr(cCGC,3,3)+"."+SubStr(cCGC,6,3)+"/"+SubStr(cCGC,9,4)+"-"+SubStr(cCGC,13,2)
	Else
		cCGC := SubStr(cCGC,1,3)+"."+SubStr(cCGC,4,3)+"."+SubStr(cCGC,7,3)+"/"+SubStr(cCGC,10,2)
	Endif


///---------------------------------------- Imprime Cabeçalho --------------------------------------------------------///

	///Inicia Nova página
	oPrint:StartPage() 

	///Espaçamento linha
	Li := VSPACE

	///Imprime Logo 
	oPrint:SayBitmap(Li,150,cLayout,2800,1930)

	///Imprime Logo
	//oPrint:SayBitmap(Li,HMARGEM+50,cLogo,150,150)
	
	///Imprime titulo
	oPrint:Say(Li+150,HMARGEM + ((nColMax/2)-200), "Orçamento N°:" + SCJ->CJ_NUM , oFont13T,,,,)

	///Espaço para Separação
	Li    += 210

	///Adiciona Separação
	//oPrint:Line(Li,HMARGEM,lI,nColMax)

	///Espaço para começar relatório
	Li    += PULALINHA + 10

	///Salva posição da Linha 1
	nPosV := Li

	///Linha 1:

		///Caixas:
			///                      Posição                          |             Tamanho
			//oPrint:Box(Li+25/*Linha*/,HMARGEM                  /*Coluna*/,Li - 45/*Linha*/,(HMARGEM + ( nColMax/2   )) /*Coluna*/) ///Cliente  == CJ_CLIENTE + CJ_LOJA 
			//oPrint:Box(Li+25/*Linha*/,HMARGEM + (nColMax/2)    /*Coluna*/,Li - 45/*Linha*/,(HMARGEM + ((nColMax/4)*3)) /*Coluna*/) ///Contato  == A1_CONTATO
			//oPrint:Box(Li+25/*Linha*/,HMARGEM + ((nColMax/4)*3)/*Coluna*/,Li - 45/*Linha*/,(HMARGEM +   nColMax      ) /*Coluna*/) ///Telefone == A1_TEL
		
		///Textos:
			///                  Posição               |             Informações
			oPrint:Say(li,HMARGEM                      ," Cliente: "  + cCliente + " " + cLoja,oFont10G,,,,)///Cliente  == CJ_CLIENTE + CJ_LOJA 
			oPrint:Say(li,HMARGEM + (nColMax/2)-130    ," Contato: "  + cContato              ,oFont10G,,,,)///Contato  == A1_CONTATO
			oPrint:Say(li,HMARGEM + ((nColMax/4)*3)-250," Telefone: " + cTelefone             ,oFont10G,,,,)///Telefone == A1_TEL

	Li += PULALINHA - 5
	
	///Linha 2:

		///Caixas:
			///                      Posição                      |             Tamanho
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM              /*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + (nColMax/2)) /*Coluna*/  )///Nome     == A1_NOME
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + (nColMax/2)/*Coluna*/,Li - 45 /*Linha*/,(HMARGEM +  nColMax   ) /*Coluna*/  )///Endereço == A1_END

		///Textos:
			///                  Posição           |             Informações
			oPrint:Say(li,HMARGEM                  ," Nome: "     + cNome                 ,oFont10G,,,,)///Nome     == A1_NOME
			oPrint:Say(li,HMARGEM + (nColMax/2)-130," Endereço: " + cEndereco             ,oFont10G,,,,)///Endereço == A1_END

	Li += PULALINHA - 5

	///Linha 3:

		///Caixas: 
			///                          Posição                      |             Tamanho
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM                  /*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + ( nColMax/2   ))/*Coluna*/)///E-mail   == A1_EMAIL
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + (nColMax/2)    /*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + ((nColMax/6)*4))/*Coluna*/)///Bairro   == A1_BAIRRO
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + ((nColMax/6)*4)/*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + ((nColMax/6)*5))/*Coluna*/)///Cidade   == A1_MUN / A1_EST
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + ((nColMax/6)*5)/*Coluna*/,Li - 45 /*Linha*/,(HMARGEM +   nColMax      )/*Coluna*/)///CEP      == A1_CEP

		///Textos:
			///                  Posição           |             Informações
			oPrint:Say(li,HMARGEM                           ," Email: "    + cEmail                          ,oFont10G,,,,)///E-mail   == A1_EMAIL
			oPrint:Say(li,HMARGEM + (nColMax/2)-130         ," Bairro: "   + cBairro                         ,oFont10G,,,,)///Bairro   == A1_BAIRRO
//			oPrint:Say(li,HMARGEM + Int((nColMax/6)*4) -180 ," Cidade: "   + RTrim(cMunicipio)+" - "+cEstado ,oFont10G,,,,)///Cidade   == A1_MUN / A1_EST
//			oPrint:Say(li,HMARGEM + Int((nColMax/6)*5) -10  ," CEP: "      + cCEP                            ,oFont10G,,,,)///CEP      == A1_CEP
			oPrint:Say(li,HMARGEM + Int((nColMax/6)*4) +25 ," Cidade: "   + RTrim(cMunicipio)+" - "+cEstado ,oFont10G,,,,)///Cidade   == A1_MUN / A1_EST
			oPrint:Say(li,HMARGEM + Int((nColMax/6)*5) +190  ," CEP: "      + cCEP                            ,oFont10G,,,,)///CEP      == A1_CEP
	
	Li += (PULALINHA)

	///Linha 4:

			///Caixas:
			///                      Posição                          |             Tamanho
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM                  /*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + ( nColMax/2   )) /*Coluna*/)///Descontos== CJ_DESC1 / CJ_DESC2 / CJ_DESC3 / CJ_DESC4
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + (nColMax/2)    /*Coluna*/,Li - 45 /*Linha*/,(HMARGEM + ((nColMax/4)*3)) /*Coluna*/)///CNPJ     == A1_CGC
			//oPrint:Box(Li + 25/*Linha*/,HMARGEM + ((nColMax/4)*3)/*Coluna*/,Li - 45 /*Linha*/,(HMARGEM +   nColMax      ) /*Coluna*/)///Cond.Pgto== CJ_CONDPAG
		
		///Textos:
			///                  Posição               |             Informações
			oPrint:Say(li,HMARGEM                      ," Descontos: "  + "R$"+cDesc1+" R$"+cDesc2+" R$"+cDesc3+" R$"+cDesc4,oFont10G,,,,)///Descontos== CJ_DESC1 / CJ_DESC2 / CJ_DESC3 / CJ_DESC4
			oPrint:Say(li,HMARGEM + (nColMax/2)-130    ," CNPJ: "      + cCGC                                               ,oFont10G,,,,)///CNPJ     == A1_CGC
			oPrint:Say(li,HMARGEM + ((nColMax/4)*3)-250," Cond.Pgto: "  + cCondPag                                          ,oFont10G,,,,)///Cond.Pgto== CJ_CONDPAG

	///Espaço para Separação
	Li += PULALINHA 
	
	///Adiciona Separação
	//oPrint:Line(Li,HMARGEM,lI,nColMax)

	Li += PULALINHA + 20

Return (nPagAtu,nPag)


/*/{Protheus.doc}  ITENSPC
	@Description   Monta os itens do relatório da Proposta comercial
	@type  		   Function
	@author 	   Rodrigo Salomão
	@since         07/03/2024
	@version 	   1.0
	@param 		   nPagAtu,nPag
	@return 		
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function ITENSPC(nPagAtu,nPag)

	Local nIpi	       := 0
	Local nTotal	   := 0
	Local nVlrIpi	   := 0
	Local nQtdVen      := 0
	Local nValVen      := 0
	Local nValTot      := 0
	Local nTotalGeral  := 0
	Local nLinhas      := 0
	Local nI           := 0
	Local cDescr       := ""
	
	

///---------------------------------------- Prepara dados SCK -----------------------------------------///

	SCK->(DbSetOrder(1))
	If !SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM ))
		MsgAlert("Dados do Cliente não encontrados." + CRLF + "Favor verifique o cadastro do cliente " + SCJ->CJ_CLIENTE + " .","Atenção.")
		Return()
	Endif

///---------------------------------------- Calcula Total ---------------------------------------------///
	
	///Calcula o total
	While SCK->(!Eof()) .and. SCK->(CK_FILIAL + CK_NUM) == SCJ->CJ_FILIAL + SCJ->CJ_NUM

		nIpi	:= 0
		nTotal	:= SCK->CK_VALOR

		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SCK->CK_TES))
		If SF4->(F4_IPI)=="S"
			nIpi	:= POSICIONE("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_IPI")
			nTotal	:= SCK->CK_VALOR// + nVlrIpi + SCJ->CJ_FRETE
			nVlrIpi	+= Round((nTotal + (SCJ->CJ_FRETE * (nTotal / nSomaValor))) * nIpi/100,3)
		Endif

		nTotalGeral += nTotal

		SCK->(DbSkip())
	EndDo

///--------------------------------------- Cabeçalho itens --------------------------------------------///

	///Caixas:
		///                      Posição                          |             Tamanho
		//oPrint:Box(Li+25/*Linha*/,HMARGEM                  /*Coluna*/,Li - 45/*Linha*/,(HMARGEM + nColMax) /*Coluna*/) /// Cabeçalho

	///Imprime os dados
	oPrint:Say(Li,HMARGEM+070                    ,"Produtos"                   ,oFont10C,0,,,0)
	oPrint:Say(Li,HMARGEM+430                    ,"NCM"                        ,oFont10C, ,,,0) 
	oPrint:Say(Li,HMARGEM+1050                   ,"Descrição"                  ,oFont10C, ,,,0) 
	oPrint:Say(Li,HMARGEM+(nColMax/2) + 310      ,"Qtda Vendida"               ,oFont10C, ,,,1)
	oPrint:Say(Li,HMARGEM+Int((nColMax/6)*4)+180 ,"Valor Venda"                ,oFont10C, ,,,1)
	oPrint:Say(Li,HMARGEM+HMARGEM+(nColMax - 500),"Valor Total"                ,oFont10C, ,,,1)

	Li += PULALINHA - 6

///---------------------------------------- Imprime Itens ---------------------------------------------///

	///Posiciona SCK
	SCK->(DbSetOrder(1))
	SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM))

	///Imprime item a item
	While SCK->(!Eof()) .and. SCK->(CK_FILIAL + CK_NUM) == SCJ->CJ_FILIAL + SCJ->CJ_NUM
		
		nLinhas++

		//Valores do Item
		nTotal	:= AllTrim(Str(SCK->CK_VALOR))
		cDescr  := POSICIONE("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_DESC")
		nQtdVen := Alltrim(Transform(SCK->CK_QTDVEN, PesqPict("SCK","CK_QTDVEN")))  
		nValVen := Alltrim(Transform(SCK->CK_PRCVEN, PesqPict("SCK","CK_PRCVEN")))
		nValTot := Alltrim(Transform(SCK->CK_VALOR , PesqPict("SCK","CK_VALOR" )))


		///Caixas:
			///                      Posição                          |             Tamanho
			//oPrint:Box(Li+25/*Linha*/,HMARGEM                  /*Coluna*/,Li - 45/*Linha*/,(HMARGEM + nColMax) /*Coluna*/) /// Cabeçalho


		///Imprime os dados
		oPrint:Say(Li,HMARGEM+090                   ,SCK->CK_ITEM + " - " + SCK->CK_PRODUTO,oFont10G,0,,,0)
	    oPrint:Say(Li,HMARGEM+410                   ,SCK->CK_XPOSI                         ,oFont10G, ,,,0) 
	  //oPrint:Say(Li,HMARGEM+750                   ,SCK->CK_DESCRI                        ,oFont10G, ,,,0) ///<== Caso Descrição venha da SCK
		oPrint:Say(Li,HMARGEM+660                   ,cDescr                                ,oFont10G, ,,,0) 
		oPrint:Say(Li,HMARGEM+(nColMax/2) + 415     ,nQtdVen                               ,oFont10G, ,,,1)
		oPrint:Say(Li,HMARGEM+Int((nColMax/6)*4)+250,nValVen                               ,oFont10G, ,,,1)
		oPrint:Say(Li,HMARGEM+(nColMax - 285)       ,nValTot                               ,oFont10G, ,,,1)

		SCK->(DbSkip())

		Li += PULALINHA - 3.5 

		////Continue aqui
		If nLinhas == 17 .and. SCK->(!Eof()) .and. SCK->(CK_FILIAL + CK_NUM) == SCJ->CJ_FILIAL + SCJ->CJ_NUM 
		
			///Cria espaço dos Totais sem adiciona-los 
				nLinhas := 0

				///Espaço para Separação
				Li    += 015
				
				///Espaço para Separação
				Li    += 148.5

			///Imprime o rodape
			U_RODAPEPC(nPagAtu,nPag)

			nPagAtu ++
		
			///Prepara o cabeçalho da nova pagina
			U_CABECPC(nPagAtu,nPag)

			///--------------------------------------- Cabeçalho itens --------------------------------------------///
			oPrint:Say(Li,HMARGEM+070                    ,"Produtos"                   ,oFont10C,0,,,0)
			oPrint:Say(Li,HMARGEM+430                    ,"NCM"                        ,oFont10C, ,,,0) 
			oPrint:Say(Li,HMARGEM+1050                   ,"Descrição"                  ,oFont10C, ,,,0) 
			oPrint:Say(Li,HMARGEM+(nColMax/2) + 310      ,"Qtda Vendida"               ,oFont10C, ,,,1)
			oPrint:Say(Li,HMARGEM+Int((nColMax/6)*4)+180 ,"Valor Venda"                ,oFont10C, ,,,1)
			oPrint:Say(Li,HMARGEM+HMARGEM+(nColMax - 500),"Valor Total"                ,oFont10C, ,,,1)

			Li += PULALINHA - 6

		EndIf

	EndDo
	
	///Numero de Registros
	if nLinhas < 17
		
		///Preenche linhas vazias para formato de relatório
		for nI := 1 To (17 - nLinhas)
			
			///Caixas:
				///                      Posição                          |             Tamanho
				//oPrint:Box(Li+25/*Linha*/,HMARGEM               /*Coluna*/,Li - 45/*Linha*/,(HMARGEM + nColMax) /*Coluna*/) /// Cabeçalho

				Li += PULALINHA - 3.5 
		Next nI
	Endif

Return 

/*/{Protheus.doc}  IMPTOTPC
	@Description   Monta o Total Geral e Quantidade Geral do relatório da Proposta comercial
	@type  		   Function
	@author 	   Rodrigo Salomão
	@since         07/03/2024
	@version 	   1.0
	@param 		   nPagAtu,nPag
	@return 		
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function IMPTOTPC(nPagAtu,nPag)

	///Espaço para Separação
	Li    += 053.5
	
	///Adiciona Separação
	//oPrint:Line(Li,HMARGEM,lI,nColMax)


	///Caixas:
		///                      Posição                          |             Tamanho
		////oPrint:Box(Li + 25/*Linha*/,HMARGEM + (nColMax/2)    /*Coluna*/,Li - 45 /*Linha*/,nColMax/4 /*Coluna*/) ///Qtde Total  == TRB1->QTDE
		////oPrint:Box(Li + 25/*Linha*/,HMARGEM + ((nColMax/4)*3)/*Coluna*/,Li - 45 /*Linha*/,nColMax/4 /*Coluna*/) ///Total Geral == A1_TEL
	
	///Textos:
		///                  Posição               |             Informações
		oPrint:Say(li,HMARGEM + (nColMax/2)+110    ,"Qtde Total: "  + AllTrim(Str(TRB1->QTDE )),oFont10G,,,,)///Qtde Total  == TRB1->QTDE
		oPrint:Say(li,HMARGEM + ((nColMax/4)*3)-070,"Total Geral: " + AllTrim(Str(TRB1->TOTAL)),oFont10G,,,,)///Total Geral == TRB1->TOTAL 

	///Espaço para Separação
	Li    += 020
	
	///Adiciona Separação
	//oPrint:Line(Li,HMARGEM,lI,nColMax)

	///Espaço para Separação
	Li    += 090
	
Return


/*/{Protheus.doc}  RODAPEPC
	@Description   Monta o rodapé do relatório da Proposta comercial
	@type  		   Function
	@author 	   Rodrigo Salomão
	@since         07/03/2024
	@version 	   1.0
	@param 		   nPagAtu,nPag
	@return 		
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function RODAPEPC(nPagAtu,nPag)

	Local cRazao    := ""
	Local cEnd      := ""
	Local cCEP      := ""
	Local cContato  := ""
	Local cTelefone := ""
	//Local cImgRPe   := "C:\temp\New Leader\" + "logo_Rodape" + ".jpg"

	///Posiciona no Registro do SCJ
	DbSelectArea("SCJ")
	DbGoTo(nRegSCJ)
	
	///Puxa as Informações do Roda Pé
	SM0->(DbSetOrder(1))
	SM0->(DbSeek("01" + "01001       "))
	cRazao	  := SM0->M0_NOMECOM  ///"New Leader máquinas Agricolas Ltda."                 ///SUS->US_NOME
	cEnd	  := RTrim(SM0->M0_ENDENT)+" - "+RTrim(SM0->M0_BAIRENT)+" - "+RTrim(SM0->M0_CIDENT)+" - "+RTrim(SM0->M0_ESTENT) ///"Rua Fortuanato José Deltreggia, 170 - Park Comercial de Indaiatuba - Indaiatuba - SP"             ///SUS->US_END + " - " + SUS->US_BAIRRO + " - " + SUS->US_MUN	
	cContato  := RTrim(MV_PAR02)                ///"Sarah Oliveira"                                      ///Alltrim(SCJ->CJ_XCONTAT) <== Campo não existe
	cTelefone := MV_PAR03                ///"1931167361"                                          ///Alltrim(SCJ->CJ_XTELCON) <== Campo não existe
	cCEP	  := SM0->M0_CEPENT  ///"01347441"                                            ///SUS->US_CEP

	///Telefone DDD, Digito 9 ou sem 9 
	if Len(cTelefone) > 9
		if Len(SubStr(cTelefone,3,Len(cTelefone))) > 8
			cTelefone := "("+SubStr(cTelefone,1,2)+")"+Substr(cTelefone,3,5) + "-" + Substr(cTelefone,8,4)
		Else
			cTelefone := "("+SubStr(cTelefone,1,2)+")"+Substr(cTelefone,3,4) + "-" + Substr(cTelefone,7,4)
		Endif
	Elseif Len(cTelefone) > 8
		cTelefone := "("+SubStr(cTelefone,1,1)+")"+Substr(cTelefone,2,4) + "-" + Substr(cTelefone,6,4)
	Else
		cTelefone := Substr(cTelefone,1,4) + "-" + Substr(cTelefone,5,4)
	Endif

	///Trata CEP
	cCEP := SubStr(cCEP,1,5) +"-"+ SubStr(cCEP,6,3) 

	///Linha 1:
		
		///Textos:
			///                  Posição           |             Informações
			oPrint:Say(li,HMARGEM                  ,cRazao                               ,oFont10G,,,,)///Razão Social == SUS->US_NOME
			oPrint:Say(li,HMARGEM + (nColMax/2)    ,"Contato: " + cContato               ,oFont10G,,,,)///Contato      == SCJ->CJ_XCONTAT

		///Imprime Logo
		//oPrint:SayBitmap(Li-050,(HMARGEM + (nColMax - 150)),cImgRPe,150,150)

	Li += PULALINHA 

	///Linha 2:
		
		///Textos:
			///                  Posição           |             Informações
			oPrint:Say(li,HMARGEM                  ,cEnd                                 ,oFont10G,,,,)///Endereço     == SUS->US_END + SUS->US_BAIRRO + SUS->US_MUN
			oPrint:Say(li,HMARGEM + (nColMax/2)    ,"Telefone: " + cTelefone             ,oFont10G,,,,)///Telefone     == SCJ->CJ_XTELCON

	Li += PULALINHA 

	///Linha 3:
		
		///Textos:
			///                  Posição           |             Informações
			oPrint:Say(li,HMARGEM                  ,"CEP: " + cCEP                        ,oFont10G,,,,)///CEP          == SUS->US_CEP
			
	Li += PULALINHA  
	
	oPrint:EndPage() ///Finaliza a pagina

Return oPrint


/*/{Protheus.doc}  VldTel
	@Description   Valida o telefone
	@type  	       Function
	@author        Rodrigo Salomão
	@since 		   18/03/2024
	@version 	   1.0
	@param 		   MV_PAR03
	@return        lRet
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function VldTel(MV_PAR03)
	Local lRet   := .T.
	Local nI     := 0

	///Verifica o texto
	For nI := 1 To Len(MV_PAR03)
		
		///Se diferente de Numeros
		if !SubStr(MV_PAR03,nI,1) $ "0|1|2|3|4|5|6|7|8|9"
			MsgAlert("Este campo permite apenas numeros." + CRLF + "Favor digite um telefone valido.")
			lRet := .F.
			Exit
		Endif
	Next nI

Return lRet
