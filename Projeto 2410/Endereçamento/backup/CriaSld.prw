#include 'mataimp.ch'
#include 'protheus.ch'

//------------------------------------------------------------------------------\\
/*/{Protheus.doc} CriaSld
// Distribuir saldo por endereço
@author Claudio Macedo
@since 05/10/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------------------------\\
User Function CriaSld(lBat, nOpcao)

Local nOpca := 0
//Local oDlg
Local cCadastro := OemtoAnsi(STR0001)  	//"Importa Dados"
Local aSays     := {}
Local aButtons  := {}
Local cMens     := ''

lBat := If(lBat == NIL,.F.,lBat)
nOpcao := If(ValType(nOpcao) # "N",0,nOpcao)

TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top

If !lBat
	cMens := OemToAnsi(STR0025)+chr(13) //"Esta rotina serÂ  executada em modo"
	cMens += OemToAnsi(STR0026)+chr(13) //"compartilhado , conforme necessidade"
	cMens += OemToAnsi(STR0027)+chr(13) //"do sistema. Continua com o processo ?"

	IF !MsgYesNo(cMens,OemToAnsi(STR0028)) //"ATENCAO"
		Return
	EndIf

	AADD(aSays,OemToAnsi(STR0002)) //"Atraves deste programa o sistema ira importar dados evitando "
	AADD(aSays,OemToAnsi(STR0003)) //"grande volume de digitacao,auxiliando a implantacao de dados "
	AADD(aSays,OemToAnsi(STR0004)) //"no sistema de maneira consistente e rapida."
	AADD(aButtons,{1,.T.,{|o| nOpca:= 1,(nOpca:= 1,nOpcao:=1,o:oWnd:End()) } } )
	AADD(aButtons,{2,.T.,{|o| o:oWnd:End()}})

	FormBatch( cCadastro, aSays, aButtons,,200,405 )
Else
    nOpca:=1
EndIf

If nOpcA == 1
    Processa({|lEnd| MatImpProc(nOpcao),STR0005})  //"Importacao dos endereços"
Endif

Return

//------------------------------------------------------------------------------\\
/*/{Protheus.doc} MatImpProc
// Distribuir saldo por endereço
@author Claudio Macedo
@since 05/06/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------------------------\\
Static Function MatImpProc(nOpcao)

Local aDados   :={{}}
Local aLogs    :={}
LOCAL aCampos  :={}
LOCAL lRet     :=.F.
LOCAL nx,nz,ny
LOCAL nLinhas  :=0
Local nSaldoB2 := 0
Local cNumSeq  
Local cCounter 
Local nRegs := 0
Local nRegProc := 0

// Carrega os dados da importacao atraves de execblock
If ExistBlock("IMPPLAN")
	aDados:=Execblock("IMPPLAN",.F.,.F.,nOpcao)
	lRet:=ValType(aDados) == "A"
EndIf

// Opcao 1 - Importacao dos saldos em estoque                   
If lRet
	If nOpcao == 1

		nRegs := Len(aDados)

		// Estrutura do array para importacao dos dados

		// COLUNA 01- Codigo do produto 
		// COLUNA 02- Almoxarifado 
		// COLUNA 03- Endereço 	
		// COLUNA 04- Descrição do endereço	

		// Monta array para validacao dos dados       

		AADD(aCampos,CriaVar("B1_COD"))
		AADD(aCampos,CriaVar("B1_LOCPAD"))
		AADD(aCampos,CriaVar("BE_LOCALIZ"))
		AADD(aCampos,CriaVar("B2_QATU"))


		// Sorteia dados de acordo com utilizacao na rotina
		For nx:=1 to Len(aDados)
			ASORT(aDados[nx],,,{ |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
		Next nx	

		dbSelectArea("SB1")
		dbSetOrder(1)

		dbSelectArea("SB2")
		dbSetOrder(1)

		dbSelectArea("NNR")
		dbSetOrder(1)

		// Tipo de logs existentes                            

		// 01 TIPO DE DADO INVALIDO
		// 02 ARMAZEM NAO LOCALIZADO
		// 03 PRODUTO NAO ENCONTRADO
		// 04 PRODUTO COM SALDO EM ESTOQUE NEGATIVO
		// 05 PRODUTO SEM SALDO EM ESTOQUE
		// 06 PRODUTO COM ENDERECAMENTO
				
		// Valida os dados passados atraves do array    
/*
		For nx:=1 to Len(aDados)
			ProcRegua(Len(aDados[nx]))
			For nz:=1 to Len(aDados[nx])
				IncProc()
				For ny:=1 to Len(aDados[nx,nz])
					If ValType(aDados[nx,nz,ny]) # ValType(aCampos[ny])
						// Adiciona registro em array para Log   
						MatADDLog(aLogs,STR0006+" -> "+Str(ny),1,NIL,NIL,nx,nz) // "A coluna do array apresenta erro do tipo de dado diferente do necessario "
					EndIf			
				Next ny
			Next nz
		Next nx		
*/
		nx := 0
		nz := 0

		For nx:=1 to Len(aDados)
			For nz:=1 to Len(aDados[nx])
				nLinhas++

				// Verifica se o produto existe no SB1 - Cadastro de Produtos 
				If !Empty(aDados[nx,nz,1]) .And. !SB1->(dbSeek(xFilial("SB1")+aDados[nx,nz,1]))
					// Adiciona registro em array para Log
					MatADDLog(aLogs,STR0016+" -> "+aDados[nx,nz,1],3,aDados[nx,nz,1],aDados[nx,nz,2],nx,nz) // "O produto nao esta cadastrado no arquivo de produtos "
				EndIf

				// Verifica se o local informado existe na NNR - Locais de Estoque                     
				If !NNR->(DbSeek(xFilial('NNR') + aDados[nx,nz,2]))
					// Adiciona registro em array para Log        
					MatADDLog(aLogs,STR0012+" -> "+aDados[nx,nz,1],2,aDados[nx,nz,1],aDados[nx,nz,2],nx,nz) // "Local de estoque não localizado"
				Endif 

			Next nz
		Next nx	

		nx := 0
		nz := 0

		// Executa a gravacao dos dados
		ProcRegua(nLinhas)
		For nx:=1 to Len(aDados)
		
			For nz:=1 to Len(aDados[nx])
				IncProc()

				// Procura log para esse registro
				ny:=aScan(aLogs,{|x| x[5] == nx .And. x[6] == nz})		
				
				// Procura log para esse produto / armazem   

				If ny <= 0
					ny:=aScan(aLogs,{|x| x[3] == aDados[nx,nz,1] .And. x[4] == aDados[nx,nz,2]})						
				EndIf

				// Se nao apresentou inconsistencia distribui os saldos
				If ny <= 0
					cNumSeq  := ProxNum()                      		// Obtem numero sequencial do movimento
					cCounter :=	StrZero(0,TamSx3('DB_ITEM')[1])     // Numero do Item do Movimento
					nSaldoB2 := 0

					// Localiza produto SB1
					If !Empty(aDados[nx,nz,1])
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial('SB1') + aDados[nx,nz,1]))	
						SB1->(reclock('SB1',.F.))
						SB1->B1_LOCALIZ := 'S'
						SB1->(MsUnlock())
					Endif 

					// Inclui o endereço na SBE
					SBE->(DbSetOrder(1))
					If !SBE->(DbSeek(xFilial('SBE') + aDados[nx,nz,2] + aDados[nx,nz,3]))	
						SBE->(reclock('SBE',.T.))
						SBE->BE_FILIAL  := xFilial('SBE')
//						SBE->BE_CODPRO  := aDados[nx,nz,1]
						SBE->BE_LOCAL   := aDados[nx,nz,2]
						SBE->BE_LOCALIZ := aDados[nx,nz,3]
						SBE->(MsUnlock())
					Endif 

					// Vincula Endereço x Produto
					If !Empty(aDados[nx,nz,1])
						ZZ2->(DbSetOrder(1))		// Armazém + Endereço + produto
						If !ZZ2->(DbSeek(xFilial('ZZ2') + aDados[nx,nz,2] + aDados[nx,nz,3] + aDados[nx,nz,1]))	
							ZZ2->(reclock('ZZ2',.T.))
							ZZ2->ZZ2_FILIAL  := xFilial('ZZ2')
							ZZ2->ZZ2_CODPRO  := aDados[nx,nz,1]
							ZZ2->ZZ2_LOCAL   := aDados[nx,nz,2]
							ZZ2->ZZ2_LOCALI  := aDados[nx,nz,3]
							ZZ2->(MsUnlock())
						Endif 
					Endif 

					// Verifica se existe saldo do produto
					If !Empty(aDados[nx,nz,1]) .And. !Empty(aDados[nx,nz,4])

//						SB2->(DbSetOrder(1))
//						If SB2->(DbSeek(xFilial('SB2') + aDados[nx,nz,1] + aDados[nx,nz,2])) .And. SB2->B2_QATU > 0
							
//							nSaldoB2 := SB2->B2_QATU
							nSaldoB2 := Val(aDados[nx,nz,4])

							// Inclui movimento da SDB
							cCounter := Soma1(cCounter)

							CriaSDB(aDados[nx,nz,1],;	// Produto
									aDados[nx,nz,2],;	// Armazem
									nSaldoB2,;	        // Quantidade
									aDados[nx,nz,3],;	// Localizacao
									'',;	            // Numero de Serie
									'SLDINI',;		    // Doc
									'',;		        // Serie
									'',;			    // Cliente / Fornecedor
									'',;			    // Loja
									'',;			    // Tipo NF
									'ACE',;			    // Origem do Movimento
									dDataBase,;		    // Data
									'',;	    		// Lote
									'',; 				// Sub-Lote
									cNumSeq,;		    // Numero Sequencial
									'499',;			    // Tipo do Movimento
									'M',;			    // Tipo do Movimento (Distribuicao/Movimento)
									cCounter,;		    // Item
									.F.,;			    // Flag que indica se e' mov. estorno
									0,;				    // Quantidade empenhado
									0 )		            // Quantidade segunda UM

							// Soma saldo em estoque por localizacao fisica (SBF)

							GravaSBF("SDB")

							nRegProc += 1

							MatADDLog(aLogs,'Saldo distribuido'+" -> "+aDados[nx,nz,1],6,aDados[nx,nz,1],aDados[nx,nz,2],nx,nz) // "Saldo distribuido"

						//Else
							// Adiciona registro em array para Log        
						//	MatADDLog(aLogs,'Produto sem saldo em estoque'+" -> "+aDados[nx,nz,1],6,aDados[nx,nz,1],aDados[nx,nz,2],nx,nz) // "Produto sem saldo em estoque"
						//Endif 

					Endif 

				Endif 

			Next nz

		Next nx	

		// Mostra relatorio com os logs de ocorrencia da importacao

		//MataImpLog(aLogs)	
		dbCloseAll()
		OpenFile(SubStr(cNumEmp,1,2))

		MsgInfo('Total de registros: ' + Str(nRegs) + CRLF +;
				'Processados ......: ' + Str(nRegProc))
	EndIf
Else
	Aviso(STR0001,STR0024,{"Ok"}) // "Importa Dados"###"O RDMAKE para importacao de dados nao existe ou esta retornando dados invalidos !!!"
EndIf

Return

//------------------------------------------------------------------------------\\
/*/{Protheus.doc} MatADDLog
// Gera log
@author Claudio Macedo
@since 05/06/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------------------------\\
Static Function MatADDLog(aLogs,cTexto,nEvento,cProduto,cArmazem,nCount1,nCount2)

Local nAcho:=aScan(aLogs,{|x| x[1] == cTexto .And. x[3] == cProduto .And. x[4] == cArmazem})		

If nAcho <= 0
	AADD(aLogs,{cTexto,nEvento,cProduto,cArmazem,nCount1,nCount2})
EndIf

Return 

//------------------------------------------------------------------------------\\
/*/{Protheus.doc} MataImpLog
// Gera log
@author Claudio Macedo
@since 05/06/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------------------------\\
Static Function MataImpLog(aLogs)

LOCAL titulo   := STR0017	//"Log de itens nao importados"
LOCAL cDesc1   := STR0018	//"Os itens que serao listados nao puderam ser listados por algum tipo de inconsistencia nos dados passados para a rotina."
LOCAL cDesc2   := STR0019	//"Acerte os dados e tente novamente."
LOCAL cDesc3   := ""
LOCAL cString  := ""
LOCAL wnrel    := "MATAIMP"

PRIVATE aReturn:= {STR0020,1,STR0021, 2, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0,cPerg:="      "

wnrel:=	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,,,.F.)
If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| MtImpLog(@lEnd,wnRel,titulo,aLogs)},titulo)

Return NIL

//------------------------------------------------------------------------------\\
/*/{Protheus.doc} MataImpLog
// Gera log
@author Claudio Macedo
@since 05/06/2025
@version 1.0
@return Nil
@type Function
/*/
//------------------------------------------------------------------------------\\
Static Function MtImpLog(lEnd,WnRel,titulo,aLogs)

LOCAL Tamanho  := "M"
LOCAL nTipo    := 0
LOCAL cRodaTxt := STR0022	//"REGISTRO(S)"
LOCAL nCntImpr := 0
LOCAL i

// Inicializa variaveis para controlar cursor de progressao  
SetRegua(Len(aLogs))

// Inicializa os codigos de caracter Comprimido/Normal da impressora
nTipo  := IIF(aReturn[4]==1,15,18)

// Contadores de linha e pagina                                 
PRIVATE li := 80 ,m_pag := 1

// Cria o cabecalho.                                        

cabec1 := STR0023 // "Logs de ocorrencia"
cabec2 := ""

For i:=1 to Len(aLogs)
	IncRegua()
	If li > 58
		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIf
	@ li,000 PSay aLogs[i,1]
	li++
	nCntImpr++
Next i

IF li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIF

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return 
