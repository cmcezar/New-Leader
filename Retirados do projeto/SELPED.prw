#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*
Autor: Tiago Dias
Data: 30/05/2023
Descrição: monta a tela para selecionar os CLIENTES
*/
User Function SELPED(aDados,aPed)
Local aArea         := GetArea()
Local aCampos 		:= {}
Local aColunas 		:= {}
Local cFontPad    	:= 'Tahoma'
Local oFontGrid   	:= TFont():New(cFontPad,,-14)

//Janela e componentes
Private oDlgMark
Private oPanGrid
Private oMarkBrowse
Private cAliasTmp 	:= GetNextAlias()
Private aRotina   	:= MenuDef()

//Tamanho da janela
Private aTamanho 	:= MsAdvSize()
Private nJanLarg 	:= 1700//aTamanho[5]
Private nJanAltu 	:= 800//aTamanho[6]
Private oTempTable 	:= Nil

Default aPed        := {}

    //Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, {'OK',                "C", 2	, 0}) //Flag para marca	
    aAdd(aCampos, {"LINHA",             "C", 04	, 0})
    aAdd(aCampos, {"TIPO",              "C", 15	, 0})
    aAdd(aCampos, {"DT_ENT",        "C", 09	, 0})
    aAdd(aCampos, {"DT_EMB",       "C", 09	, 0})
    aAdd(aCampos, {"UNIDADE",           "C", 30	, 0})
    aAdd(aCampos, {"NUM_OC",            "C", 15	, 0})
    aAdd(aCampos, {"LIN_OC",      "C", 03	, 0})
    aAdd(aCampos, {"COD_MAT",      "C", 15	, 0})
    aAdd(aCampos, {"TP_COMM",    "C", 15	, 0})
    aAdd(aCampos, {"QUANT",        "C", 12	, 0})
    aAdd(aCampos, {"QTD_PREV", "C", 12	, 0})
    aAdd(aCampos, {"NUM_PED", "C", 06	, 0})

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:Create()  

    //Popula a tabela temporária
    Processa({|| fPopula(aDados)}, 'Processando...')

    //Adiciona as colunas que serão exibidas no FWMarkBrowse
    aColunas := fCriaCols()
     
    //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE 'PEDIDOS NOVOS - JOHN DEERE' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        //Dados
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cAliasTmp)                
        oMarkBrowse:SetDescription('SELECIONE PARA CRIAR PEDIDO:')
        oMarkBrowse:DisableFilter()
        oMarkBrowse:DisableConfig()
        oMarkBrowse:DisableSeek()
        oMarkBrowse:DisableSaveConfig()
        oMarkBrowse:SetFontBrowse(oFontGrid)
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:SetColumns(aColunas)
        //oMarkBrowse:AllMark() //Cria todos já selecionados
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:Activate()

    ACTIVATE MsDialog oDlgMark CENTERED
    
    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oMarkBrowse:DeActivate()
    
    RestArea(aArea)

Return

/*
Autor: Tiago Dias
Data: 24/01/2023
Descrição: chama função para processar os itens selecionados
*/
Static Function MenuDef()
Local aRotina := {}
     
    //Criação das opções
    //ADD OPTION aRotina TITLE 'PESQUISAR'  ACTION 'AxPesqui("SA1")'     OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE 'CRIAR PEDIDOS'     ACTION 'u_CRIAPED'            OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'IMPORTAR TODOS'    ACTION 'u_PEDALL'             OPERATION 2 ACCESS 0

Return aRotina

/*
Autor: Tiago Dias
Data: 24/01/2023
Descrição: executa a query para popular a tabela temporária usada no browse
*/
Static Function fPopula(aDados)
Local nTotal 	:= 0
Local nAtual 	:= 0
Local nLinha    := 3
Local nX        := 1

    //Enquanto houver registros, adiciona na temporária
    For nX := 1 to len(aDados)

        nAtual++
        nLinha++
        IncProc('Alimentando tabela com os pedidos do arquivo CSV... ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		//Popula tabela temporaria
        RecLock(cAliasTmp, .T.)

            (cAliasTmp)->OK                 := Space(2)
            (cAliasTmp)->LINHA              := ALLTRIM(STR(nLinha))
            (cAliasTmp)->TIPO               := aDados[nX][1]
            (cAliasTmp)->DT_ENT         := aDados[nX][2]
            (cAliasTmp)->DT_EMB        := aDados[nX][3]
            (cAliasTmp)->UNIDADE            := aDados[nX][4]
            (cAliasTmp)->NUM_OC             := aDados[nX][5]
            (cAliasTmp)->LIN_OC       := aDados[nX][6]
            (cAliasTmp)->COD_MAT       := aDados[nX][7]
            (cAliasTmp)->TP_COMM     := aDados[nX][8]
            (cAliasTmp)->QUANT         := aDados[nX][9]
            (cAliasTmp)->QTD_PREV  := aDados[nX][10]
            (cAliasTmp)->NUM_PED  := aDados[nX][47]

        (cAliasTmp)->(MsUnlock())

    Next nX

    (cAliasTmp)->(DbGoTop())

Return

/*
Autor: Tiago Dias
Data: 24/01/2023
Descrição: gera as colunas que serão visiveis no browse
*/
Static Function fCriaCols()
Local nAtual       := 0 
Local aColunas := {}
Local aEstrut  := {}
Local oColumn
    
    //Adicionando campos que serão mostrados na tela
    aAdd(aEstrut, {"LINHA"			    ,"Num. Linha Excel"		    ,"C", 04	, 0, ''})
	aAdd(aEstrut, {"TIPO"		        ,"Tipo"		                ,"C", 15	, 0, ''})
	aAdd(aEstrut, {"DT_ENT"		    ,"Dt. de Entrega"			,"C", 09	, 0, ''})
	aAdd(aEstrut, {"DT_EMB"		,"Dt. de Embarque"		    ,"C", 09	, 0, ''})
	aAdd(aEstrut, {"UNIDADE"		    ,"Unidade"		            ,"C", 30	, 0, ''})
	aAdd(aEstrut, {"NUM_OC"		        ,"Num. OC"		            ,"C", 15	, 0, ''})
	aAdd(aEstrut, {"LIN_OC"		,"Num. linha OC"		    ,"C", 03	, 0, ''})
	aAdd(aEstrut, {"COD_MAT"		,"Cod. Material"		    ,"C", 15	, 0, ''})
	aAdd(aEstrut, {"TP_COMM"		,"Tipo de Commodity"		,"C", 15	, 0, ''})
	aAdd(aEstrut, {"QUANT"		    ,"Quantidade"		        ,"C", 12	, 0, ''})
	aAdd(aEstrut, {"QTD_PREV"  ,"Quantidade prev."		    ,"C", 12	, 0, ''})
    aAdd(aEstrut, {"NUM_PED"  ,"Num. Pedidos"		    ,"C", 06	, 0, ''})

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])

        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next

Return aColunas

/*
Autor: Tiago Dias
Data: 24/01/2023
Descrição: aciona após confirmar os itens
*/
User Function CRIAPED()

    Processa({|| fProcessa()}, 'Criando Pedidos...')

    cAliasTmp 	:= GetNextAlias()

Return()

/*
Autor: Tiago Dias
Data: 24/01/2023
Descrição: percorre os registro da tela
*/
Static Function fProcessa()
Local aArea     := FWGetArea()
Local cMarca    := oMarkBrowse:Mark()
Local nAtual    := 0
Local nTotal    := 0
Local nTotMarc 	:= 0

    //Define o tamanho da régua
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
    
    //Percorrendo os registros
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        nAtual++
    
        //Caso esteja marcado
        If oMarkBrowse:IsMark(cMarca)
            nTotMarc++

			//Alimenta array para ExecAuto dos itens selecionados
            aAdd(aPed,{nAtual})

        EndIf
         
        (cAliasTmp)->(DbSkip())

    EndDo

    
Return(aPed)

User Function PEDALL()

    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oMarkBrowse:DeActivate()
    
    RestArea(aArea)

Return
