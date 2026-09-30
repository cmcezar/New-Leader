#include "protheus.ch"
/*
sandro desenvolver
*/

User Function impped()
MsAguarde({|| importped()}, "Aguarde...", "Processando Registros...")
Return
Static Function importped()
 
Local cArq    := "pedven.csv"
Local cDir    := "C:\IMPORTADORPED\"  
Local cEnd			:= "C:" //GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr			:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath			:= "\IMPORT\"
Local cTipoLog		:= "Import_"
Local cExtensao     := "_Log.txt"
Local cNomeLog		:=	cPath+cTipoLog+cDtHr
Local cArql			:=	cEnd+cNomeLog   
Local cCdAlias		:= "SC5"
Local _import		:= "S"
Local cLinha  		:= ""
Local lTerc   		:= .T.
Local _contl  		:= 0
Local aDados  		:= {}
Local _aItem  		:= {}
Local _ni     		:= 0 
Local aCabec  		:= {}
Local _preco  		:= 0
Local _dtfor  		:= dDataBase
Private aErro 		:= {}
Private lSel		:= .F.

//Valida pedido duplicado
Private dDtEntrega	:= ""
Private cCodProd	:= ""
Private nQtdVen 	:= 0
Private nTot		:= 0
Private lDupli 		:= .F.
Private cNumPed 	:= .F.
Private cItemPed 	:= .F.
Private cProdPed 	:= .F.
Private aPed      	:= {}
Private aExcel		:= {}
Private nAtual		:= 0

lMsErroAuto := .F.
If !File(cDir+cArq)
		MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impaprov] - ATENCAO")
		Return
	Else 
		MSGALERT("O arquivo " +cDir+cArq + " foi encontrado. A importacao sera executada!","[impaprov] - ATENCAO")
		
EndIf
		nHdl := fOpen(cDir+cArq,0)
		aCamposPE:={}
		If nHdl == -1
			If !Empty(cDir+cArq)
				MsgAlert("O arquivo de nome "+cDir+cArq+" nao pode ser aberto! Verifique os parametros.","Atencao!")
			Endif
			Return
		Endif

If !File(cDir+cArq)
	MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impped] - ATENCAO")
	Return
EndIf
 
FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 lTerc := .F.
	cLinha := FT_FREADLN()
    _contl	:= _contl + 1
	If  _contl > 3
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo
 	nHdl := fCreate(cArql+'-'+cCdAlias+cExtensao)
	If nHdl == -1
		MsgAlert("O arquivo  "+cArql+'-'+cCdAlias+cExtensao+" nao pode ser criado!","Atencao!")
		fClose(nHdl)
		fErase(cArql+'-'+cCdAlias+cExtensao)
		RestArea(aArea)
	 	Return()
	EndIf
	fWrite(nHdl, Replicate( '=', 80 ) 											+ CHR(13)+CHR(10))
	fWrite(nHdl, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S'		+ CHR(13)+CHR(10))
	fWrite(nHdl, Replicate( '-', 80 ) 											+ CHR(13)+CHR(10))
	fWrite(nHdl, 'Lista de itens processados ' +   DtoC( dDataBase ) 			+ CHR(13)+CHR(10))

//Executa tela para selecionar os pedidos a serem criados no protheus
U_SELPED(aDados,aPed)

//CABEÇALHO
DBSELECTAREA( "SC5" )
SC5->(DBSETORDER( 1 ))

//ITENS
DBSELECTAREA( "SC6" )
SC6->(DBSETORDER( 1 ))

//MsgRun("Aguarde...","Criando Pedidos!",{|| CursorWait(),RunReport(),CursorArrow()})
//MsAguarde({|| fExemplo1()}, "Aguarde...", "Processando Registros...")


For _ni:=1 to Len(aDados)

	nAtual++
	MsProcTxt("Importando Registros " + cValToChar(nAtual) + " de " + cValToChar(Len(aDados)))

	fWrite(nHdl, ' Linha processada ' +  str(_ni)			+ CHR(13)+CHR(10))	

 	dEntr	:= aDados[_ni,2]
	fWrite(nHdl, 'Data entrega ' +   dEntr 			+ CHR(13)+CHR(10))	

 	dEmba	:= aDados[_ni,3]
	fWrite(nHdl, 'Data embalagem ' +   dEmba 			+ CHR(13)+CHR(10))
			
	Do Case
		Case substr(dEmba,4,3) = "jan"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "01" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "fev"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "02" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "mar"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "03" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "abr"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "04" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "mai"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "05" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "jun"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "06" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "jul"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "07" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "ago"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "08" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "set"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "09" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "out"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "10" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEmba,4,3) = "nov"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "11" + substr(aDados[_ni,3],1,2)) 
		Case substr(dEmba,4,3) = "dez"
			dEmba 	:= stod("20"+substr(aDados[_ni,3],8,2) + "12" + substr(aDados[_ni,3],1,2)) 
	EndCase

	Do Case
		Case substr(dEntr,4,3) = "jan"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "01" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "fev"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "02" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "mar"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "03" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "abr"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "04" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "mai"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "05" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "jun"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "06" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "jul"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "07" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "ago"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "08" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "set"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "09" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "out"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "10" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "nov"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "11" + substr(aDados[_ni,2],1,2)) 
		Case substr(dEntr,4,3) = "dez"
			dEntr 	:= stod("20"+substr(aDados[_ni,2],8,2) + "12" + substr(aDados[_ni,2],1,2)) 
	EndCase
	_dtfor := dEmba	

	_tpop := "F"

 	If alltrim(aDados[_ni,4]) = "John Deere Brazil"
			//John Deere Brasil - Catalão
			_codcli	:= "00000101"
			_coper	:= "01"
			//_ctes	:= "5A8"
			/*If len(AllTrim(aDados[_ni,3])) = 0
					_dtfor := dDataBase
				Else 
					_dtfor  := dEntr
			EndIf */			
			 		
		Else
			//John Deere Campinas
			
			_codcli	:= "00000102"
			_coper	:= "01"
			//_ctes	:= "5B1"
			If len(AllTrim(aDados[_ni,2])) = 0
					_dtfor := dEmba
				Else 
					_dtfor := dEntr
			EndIf 			
			
	EndIf

	fWrite(nHdl, 'Codigo Cliente ' +   _codcli			+ CHR(13)+CHR(10))	
	_import	:= "N"	
	If Substr(alltrim(aDados[_ni,1]),1,5) = "Firme"  
			_import	:= "S"
			_tpop := "F"

		If val(aDados[_ni,9]) > 0
				_import	:= "S"
			Else 
				_import	:= "N"
		EndIf 			
	EndIf
	If Substr(alltrim(aDados[_ni,1]),1,5) = "Previ" 
			_import	:= "S"
			_tpop := "P"
		If val(aDados[_ni,9]) > 0
				_import	:= "S"
			Else 
				_import	:= "N"
		EndIf 			
	EndIf 
	fWrite(nHdl, 'Tipo Pedido ' +   Substr(alltrim(aDados[_ni,1]),1,5) 			+ CHR(13)+CHR(10))
	If _import = "N"
		//fWrite(nHdl, 'Tipo Pedido que nao pode ser importado' +   Substr(alltrim(aDados[_ni,1]),1,5) 			+ CHR(13)+CHR(10))
	Endif 	
	_preco  := 0
	_tabel	:= " "
	_condp	:= " " 
	_codpro := Posicione("SA7",3,xFilial("SA7")+_codcli+aDados[_ni,7],"A7_PRODUTO")
	 
	fWrite(nHdl, 'Codigo produto na tabela Produto x Cliente ' +   aDados[_ni,7] 			+ CHR(13)+CHR(10))	

	If Len(Alltrim(_codpro)) = 0
			_import	:= "N"
			//MsgAlert("O Produto "+aDados[_ni,7]+ " nao foi encontrado no cadastro de produto x Cliente!", "Produto nao encontrado")
			If _import = "N"
				fWrite(nHdl, "O Produto "+aDados[_ni,7]+ " nao foi encontrado no cadastro de produto x Cliente!" 			+ CHR(13)+CHR(10))
			Endif 
		Else
			_tabel	:= Posicione("SA1",1,xFilial("SA1")+_codcli,"A1_TABELA")
			_condp	:= Posicione("SA1",1,xFilial("SA1")+_codcli,"A1_COND")
			_preco  := Posicione("DA1",1,xFilial("DA1")+_tabel+_codpro,"DA1_PRCVEN")
			If _preco > 0
				Else
					_preco := 1
					fWrite(nHdl, "O Preco está como 0 e o pedido sera importado com o valor 1" 			+ CHR(13)+CHR(10))

			EndIf 
	EndIf

	_prctot	:= _preco* val(aDados[_ni,9]) 


	If val(substr(aDados[_ni,3],8,2)) < Val(substr(dtos(ddatabase),3,2))
		If val(substr(aDados[_ni,3],1,2)) < Val(substr(dtos(ddatabase),6,2))  
			_import := "N"
		EndIf	
	EndIf 
	IF _import = "S"
			fWrite(nHdl, "O pedido foi importado " 			+ CHR(13)+CHR(10)) 		
		Else 
			fWrite(nHdl, "O pedido nao foi importado " 			+ CHR(13)+CHR(10)) 		
	EndIf 	

	//Função criada para validar se já existe pedido criado
	//Data de Entrega -> C6_ENTREG + Código do Produto -> C6_PRODUTO + Quantidade -> C6_QTDVEN + Valor -> C6_VALOR
	//lDupli	:= U_VALDUPLI(dtos(_dtfor),_codpro,val(aDados[_ni,9]),_prctot)

	//Se for verdadeiro, nao grava pedido. CAUSA: DUPLICADO
	//if !lDupli

	if EMPTY(aDados[_ni,47])

		//if len(aPed) > 0

			//lSel := .T.

		//endif

		/*if lSel*/

		If _import = "S"
			aCabec 	:= {}
			_numped	:= GETSX8NUM('SC5','C5_NUM')	
			aadd(aCabec,{"C5_FILIAL"   		,xFilial("SC5")    						,Nil })
			aadd(aCabec,{"C5_NUM"   		,_numped								,Nil })
			aadd(aCabec,{"C5_TIPO" 			,"N"									,Nil })
			aadd(aCabec,{"C5_CLIENTE"		,substr(_codcli,1,6)					,Nil })
			aadd(aCabec,{"C5_LOJACLI"		,substr(_codcli,7,2)					,Nil })
			aadd(aCabec,{"C5_LOJAENT"		,substr(_codcli,7,2)					,Nil })
			aadd(aCabec,{"C5_CONDPAG"		,_condp									,Nil })
			aadd(aCabec,{"C5_MENNOTA"		,aDados[_ni,5]	+" "+  aDados[_ni,6]	,Nil })
			aLinha :={}
			_aItem  := {}
			aadd(aLinha,{"C6_FILIAL"		,xFilial("SC5") 						, Nil})
			aadd(aLinha,{"C6_NUM"			,_numped								, Nil})
			aadd(aLinha,{"C6_ITEMPC"			,aDados[_ni,6]						, Nil})
			//aadd(aLinha,{"C6_ITPC"			,aDados[_ni,6]						, Nil})
			aadd(aLinha,{"C6_PRODUTO"		,_codpro								, Nil})
			aadd(aLinha,{"C6_ENTREG"		,_dtfor									, Nil})		
			aadd(aLinha,{"C6_DATAEMB"		,_dtfor									, Nil})
			aadd(aLinha,{"C6_QTDVEN"		,val(aDados[_ni,9])						, Nil})
			aadd(aLinha,{"C6_PRCVEN"		,_preco									, Nil})
			aadd(aLinha,{"C6_VALOR"			,_prctot								, Nil})
			aadd(aLinha,{"C6_OPER"			,_coper									, Nil})
			//aadd(aLinha,{"C6_TES"			,_ctes									, Nil})
			aadd(aLinha,{"C6_PRUNIT"		,_preco									, Nil})
			//aadd(aLinha,{"C6_PEDCLI"		,aDados[_ni,5]							, Nil})
			aadd(aLinha,{"C6_NUMPCOM"		,aDados[_ni,5]							, Nil})
			aadd(aLinha,{"C6_XVLRLIQ"		,val(aDados[_ni,23])					, Nil})	
			aadd(aLinha,{"C6_XPROD"		    ,aDados[_ni,7]      					, Nil})
			aadd(aLinha,{"C6_TPOP"		    ,_tpop		      					    , Nil})
			aadd(_aitem,aLinha)                       
			msexecauto({|x,y,z| mata410(x,y,z)},aCabec,_aitem,3)
			IF lMsErroAuto //SE HOUVE ERRO
				MostraErro()
			else
				
				aAdd(aExcel,{aDados[_ni][1],aDados[_ni][2],aDados[_ni][3],aDados[_ni][4],aDados[_ni][5],aDados[_ni][6],aDados[_ni][7],aDados[_ni][8],;
				aDados[_ni][9],aDados[_ni][10],aDados[_ni][11],aDados[_ni][12],aDados[_ni][13],aDados[_ni][14],aDados[_ni][15],aDados[_ni][16],;
				aDados[_ni][17],aDados[_ni][18],aDados[_ni][19],aDados[_ni][20],aDados[_ni][21],aDados[_ni][22],aDados[_ni][23],aDados[_ni][24],;
				aDados[_ni][25],aDados[_ni][26],aDados[_ni][27],aDados[_ni][28],aDados[_ni][29],aDados[_ni][30],aDados[_ni][31],aDados[_ni][32],;
				aDados[_ni][33],aDados[_ni][34],aDados[_ni][35],aDados[_ni][36],aDados[_ni][37],aDados[_ni][38],aDados[_ni][39],aDados[_ni][40],;
				aDados[_ni][41],aDados[_ni][42],aDados[_ni][43],aDados[_ni][44],aDados[_ni][45],aDados[_ni][46],_numped})

			EndIf
				ConfirmSX8()
			EndIf 

		//endif
	
	ELSE

		//Altera o registro - CABEÇALHO
		//if SC5->(dbSeek(xFilial("SC5") + ALLTRIM(aDados[_ni,47])))

			/*Begin Transaction

				RecLock("SC5",.F.)

					SC5->C5_FILIAL		:=
					SC5->C5_NUM 		:=  
					SC5->C5_TIPO 		:=	
					SC5->C5_CLIENTE 	:=
					SC5->C5_LOJACLI 	:=
					SC5->C5_LOJAENT 	:=
					SC5->C5_CONDPAG 	:=
					SC5->C5_MENNOTA 	:=

				SC5->(MsUnlock())

			End Transaction*/

		//ENDIF

		//Altera o registro - ITENS
		if SC6->(dbSeek(xFilial("SC6") +ALLTRIM(aDados[_ni,47]) + '01'))

			//Só altera se for diferente
			if SC6->C6_ENTREG <> _dtfor .or. SC6->C6_QTDVEN <> val(aDados[_ni,9])

				Begin Transaction

					RecLock("SC6",.F.)

						SC6->C6_ENTREG	:= _dtfor
						SC6->C6_QTDVEN 	:= val(aDados[_ni,9])	

					SC6->(MsUnlock())

				End Transaction

			endif

		ENDIF

	ENDIF
	
	/*else

		fWrite(nHdl, " " 																+ CHR(13)+CHR(10))
		fWrite(nHdl, "O pedido nao foi importado " 										+ CHR(13)+CHR(10))
		fWrite(nHdl, "Motivo: DATA DE ENTREGA, PRODUTO, QUANTIDADE e VALOR " 			+ CHR(13)+CHR(10))
		fWrite(nHdl, "Descrição: informações iguais encontradas em outro pedido " 		+ CHR(13)+CHR(10)) 		 
		fWrite(nHdl, "Pedido com as mesmas informações (JÁ CADASTRADO): " 				+ CHR(13)+CHR(10))
		fWrite(nHdl, "	 |	Numero do Pedido  -  "+cNumPed+" " 							+ CHR(13)+CHR(10)) 		
 		fWrite(nHdl, "	 |	Item do Pedido    -  "+cItemPed+" " 						+ CHR(13)+CHR(10)) 		
		fWrite(nHdl, "	 |	Produto do Pedido - "+cProdPed+" " 							+ CHR(13)+CHR(10)) 	
		fWrite(nHdl, "	 |	DT de Entrega     - "+dtos(_dtfor)+" " 						+ CHR(13)+CHR(10)) 		
		fWrite(nHdl, "	 |	Quantidade 		  - "+aDados[_ni,9]+" " 					+ CHR(13)+CHR(10)) 		
		fWrite(nHdl, "	 |	Valor 			  - "+ALLTRIM(STR(_prctot))+" " 			+ CHR(13)+CHR(10)) 		
	
	endif*/

Next _ni

//Executa excel com numero dos pedidos criados
U_EXCELPED(aExcel)


FT_FUSE()
	fClose(nHdl)
ApMsgInfo("Importacao dos Pedidos de venda concluida, consulte o log para mais informacoes!","[IMPPED] - SUCESSO")


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AchaFil  ºAutor  ³Fabricio Stefanini  º Data ³  23/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AchaFil(cCodBar)
	Local cCaminho 	:= Caminho
	Local lOk 		:= .F.
	Local nArq		:= 0

	If Empty(cCodBar)
		Return .t.
	Endif

	aFiles := Directory(cCaminho+"\*.CSV", "D")

	For nArq := 1 To Len(aFiles)
		cFile := AllTrim(cCaminho+aFiles[nArq,1])

		nHdl    := fOpen(cFile,0)
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)
		If AT(AllTrim(cCodBar),AllTrim(cBuffer)) > 0
			cCodBar := cFile
			lOk := .t.
			Exit
		Endif
	Next

	If !lOk
		Alert("Nenhum Arquivo Encontrado, Por Favor Selecione a Opção Arquivo e Faça a Busca na Arvore de Diretórios!")
	Endif

Return lOk


/*
Autor: Tiago Dias
Data: 16/05/2023
Descrição: função resposável por verificar se já foi cadastrato pedido com as mesmas informações no arquivo csv usado na importação
*/
/*User Function VALDUPLI(dDtEntrega,cCodProd,nQtdVen,nTot)
Local cQuery	:= ""

	//Data de Entrega -> C6_ENTREG + Código do Produto -> C6_PRODUTO + Quantidade -> C6_QTDVEN + Valor -> C6_VALOR
   	cQuery := "	SELECT * FROM " + RetSqlName("SC6") +""    	+	CRLF
    cQuery += "	WHERE D_E_L_E_T_ = ''"      				+	CRLF
    cQuery += "	AND C6_ENTREG = '"+dDtEntrega+"'"     		+	CRLF
	cQuery += "	AND C6_PRODUTO = '"+ALLTRIM(cCodProd)+"'"     		+	CRLF
    cQuery += "	AND C6_QTDVEN = "+ALLTRIM(STR(nQtdVen))+""  +	CRLF
    cQuery += "	AND C6_VALOR = "+ALLTRIM(STR(nTot))+""     	+	CRLF

    PLSQuery(cQuery, 'QRYVALPED')
    DbSelectArea('QRYVALPED')
    QRYVALPED->(DbGoTop())

	//Se entrar no laço, encontrou registros e retorna duplicado
    While ! QRYVALPED->(EoF())

		lDupli				:= .T.

		cNumPed		:= QRYVALPED->C6_NUM	
		cItemPed	:= QRYVALPED->C6_ITEM
		cProdPed	:= QRYVALPED->C6_PRODUTO 	

		EXIT

		//QRYVALPED->(DbSkip())

	ENDDO
	
Return(lDupli)
*/
