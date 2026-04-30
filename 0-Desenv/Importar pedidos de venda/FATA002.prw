#include 'Protheus.ch'
#include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := 'Importação de Previsão e Pedidos de Venda'

//-------------------------------------------------\\
/*/{Protheus.doc} FATA002
// Importação de previsão e pedido de venda
@type function
@author Claudio Macedo
@since 21/03/2026
@version 1.0
/*/
//-------------------------------------------------\\
User Function FATA002()

Local aArea   := GetArea()
Local oBrowse

Private oView := Nil
Private cID   := Nil

// Instânciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()

// Setando a tabela do cabeçalho do picklist
oBrowse:SetAlias("ZZ5")

// Setando a descrição da rotina
oBrowse:SetDescription(cTitulo)

// Legendas
//oBrowse:AddLegend("ZZ5->ZZ5_STATUS == ' '", "GREEN" , "Separação não iniciada")
//oBrowse:AddLegend("ZZ5->ZZ5_STATUS == '1'", "YELLOW", "Em Separação")
//oBrowse:AddLegend("ZZ5->ZZ5_STATUS == '2'", "RED"   , "Separação Finalizada")
//oBrowse:AddLegend("ZZ5->ZZ5_STATUS == '3'", "BLUE"  , "Faturado")
//oBrowse:AddLegend("ZZ5->ZZ5_STATUS == '4'", "GRAY"  , "Iten(s) Cancelado(s)")

// Ativa a Browse
oBrowse:Activate()

RestArea(aArea)

Return Nil

//-------------------------------------------------\\
/*/{Protheus.doc} MenuDef
// Criação do menu MVC
@type function
@author Claudio Macedo
@since 21/03/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function MenuDef()
	Local aRot := {}
	
	// Adicionando opções
	ADD OPTION aRot TITLE 'Importar'   ACTION 'u_NLFATA01'  OPERATION 6        ACCESS 0 //OPERATION 6
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.FATA002' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	// ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
//	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.FATA002' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	// ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.FATA002' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'u_FATA002A' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

//-------------------------------------------------\\
/*/{Protheus.doc} ModelDef
// Criação do modelo de dados MVC
@type function
@author Claudio Macedo
@since 21/03/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStruZZ5 	:= FWFormStruct(1, 'ZZ5')
	Local oStruZZ6 	:= FWFormStruct(1, 'ZZ6')
	Local aZZ6Rel	:= {}
	
    // Removendo so campos não visualizados na grid
    // oStruZZ6:RemoveField('ZZ6_NUMPL')

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('FATA002M')
	oModel:AddFields('ZZ5MASTER',/*cOwner*/,oStruZZ5)
	oModel:AddGrid('ZZ6DETAIL','ZZ5MASTER',oStruZZ6,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	// Desativando a alteração de linhas
    oModel:GetModel('ZZ6DETAIL'):SetNoUpdateLine(.T.)

	// Desativando a exclusão de linhas
    oModel:GetModel('ZZ6DETAIL'):SetNoDeleteLine(.T.)

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZZ6Rel, {'ZZ6_FILIAL', 'xFilial("ZZ6")'} )
	aAdd(aZZ6Rel, {'ZZ6_ID'    , 'ZZ5_ID'}) 
	
	oModel:SetRelation('ZZ6DETAIL', aZZ6Rel, ZZ6->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZZ6DETAIL'):SetUniqueLine({'ZZ6_FILIAL','ZZ6_ID','ZZ6_ITEM'})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Previsão e Pedido de Venda")
	oModel:GetModel('ZZ5MASTER'):SetDescription('Cabeçalho')
	oModel:GetModel('ZZ6DETAIL'):SetDescription('Itens')
Return oModel

//-------------------------------------------------\\
/*/{Protheus.doc} ViewDef
// Criação da visão MVC
@type function
@author Claudio Macedo
@since 21/03/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ViewDef()

// Local oView		:= Nil
Local oModel	:= FWLoadModel('FATA002')
Local oStruZZ5	:= FWFormStruct(2, 'ZZ5')
Local oStruZZ6	:= FWFormStruct(2, 'ZZ6')

// Removendo campo
//oStruZZ5:RemoveField('ZZ5_STATUS')

// Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

// oView:AddUserButton(,'',{|| ()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE})

// Adiciona botões direto no Outras Ações da ViewDef
// Parâmetros do método addUserButton - (<cTitle >, <cResource >, <bBloco >, [ cToolTip ], [ nShortCut ], [ aOptions ], [lShowBar])
//oView:addUserButton('Importar pedidos de venda','teste', {|| u_FATA002a()},/*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_INSERT}, .T.)
       
// Adicionando os campos do cabeçalho e o grid dos filhos
oView:AddField('VIEW_ZZ5',oStruZZ5,'ZZ5MASTER')
oView:AddGrid('VIEW_ZZ6',oStruZZ6,'ZZ6DETAIL')

// Setando o dimensionamento de tamanho
oView:CreateHorizontalBox('CABEC',35)
oView:CreateHorizontalBox('GRID',65)

// Amarrando a view com as box
oView:SetOwnerView('VIEW_ZZ5','CABEC')
oView:SetOwnerView('VIEW_ZZ6','GRID')

// Habilitando título
oView:EnableTitleView('VIEW_ZZ5','Cabeçalho')
oView:EnableTitleView('VIEW_ZZ6','Itens')

// Ativando o campo de pesquisar e ativando o botão de Filtrar
oView:SetViewProperty('VIEW_ZZ6', "GRIDSEEK",    {.T.})
oView:SetViewProperty('VIEW_ZZ6', "GRIDFILTER",  {.T.})

Return oView

//-------------------------------------------------\\
/*/{Protheus.doc} FATA002A
// Excluir o arquivo importado
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
User Function FATA002A()

If MsgYesNo('Deseja excluir o arquivo importado ?')
	Processa( {|| ExcluiArq() }, 'Arquivo: ' + Alltrim(ZZ5->ZZ5_ID), 'Excluindo o arquivo ...', .F.)
	MsgInfo('Arquivo excluído !')

	Processa( {|| ExcluiSC4() }, 'Arquivo: ' + Alltrim(ZZ5->ZZ5_ID), 'Excluindo as previsões de venda ...', .F.)
	MsgInfo('Previsões de venda excluídas !')

	Processa( {|| ExcluiSC5() }, 'Arquivo: ' + Alltrim(ZZ5->ZZ5_ID), 'Excluindo os pedidos de venda ...', .F.)
	MsgInfo('Pedidos de venda excluídos !')

Endif 

Return Nil 

//-------------------------------------------------\\
/*/{Protheus.doc} ExcluiArq
// Excluir o arquivo importado
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ExcluiArq()

cID := ZZ5->ZZ5_ID 

/* Excluindo o cabeçalho do arquivo */
ZZ5->(reclock('ZZ5',.F.))
ZZ5->(DbDelete())
ZZ5->(MsUnlock())

/* Excluindo os itens do arquivo */
ZZ6->(DbSetOrder(1))
ZZ6->(DbSeek(xFilial('ZZ6') + cID))

While !ZZ6->(EOF()) .AND. ZZ6->ZZ6_ID = cID

	ZZ6->(reclock('ZZ6',.F.))
	ZZ6->(DbDelete())
	ZZ6->(MsUnlock())

	ZZ6->(DbSkip())
Enddo 

Return Nil 

//-------------------------------------------------\\
/*/{Protheus.doc} ExcluiSC4
// Excluir as previsões de venda
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ExcluiSC4()

/* Excluindo as previsões de venda */
SC4->(DbSetOrder(3))
SC4->(DbSeek(xFilial('SC4') + cID))

While !SC4->(EOF()) .AND. SC4->C4_DOC = cID 

	SC4->(reclock('SC4',.F.))
	SC4->(DbDelete())
	SC4->(MsUnlock())

	SC4->(DbSkip())
Enddo 

Return Nil 

//-------------------------------------------------\\
/*/{Protheus.doc} ExcluiSC5
// Excluir as pedido de venda
@type function
@author Claudio Macedo
@since 16/04/2026
@version 1.0
/*/
//-------------------------------------------------\\
Static Function ExcluiSC5()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.

/* Excluindo as previsões de venda */
SC5->(DbSetOrder(12))
SC5->(DbSeek(xFilial('SC5') + cID))

While !SC5->(EOF()) .AND. SC5->C5_XIDEDI = cID 

//	SC5->(reclock('SC5',.F.))
//	SC5->(DbDelete())
//	SC5->(MsUnlock())
 
   aadd(aCabec, {"C5_NUM"    , SC5->C5_NUM    , Nil})
//   aadd(aCabec, {"C5_TIPO"   , SC5->C5_TIPO   , Nil})
//   aadd(aCabec, {"C5_CLIENTE", SC5->C5_CLIENTE, Nil})
//   aadd(aCabec, {"C5_LOJACLI", SC5->C5_LOJACLI, Nil})
//   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
//   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
	
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))

	While !SC6->(EOF()) .And. SC6->C6_FILIAL = xFilial('SC6') .And. SC6->C6_NUM = SC5->C5_NUM

		//--- Informando os dados do item do Pedido de Venda
		aLinha := {}
		aadd(aLinha,{"C6_ITEM"   , SC6->C6_ITEM   , Nil})
		aadd(aLinha,{"C6_PRODUTO", SC6->C6_PRODUTO, Nil})
		aadd(aLinha,{"C6_QTDVEN" , SC6->C6_QTDVEN , Nil})
		aadd(aLinha,{"C6_PRCVEN" , SC6->C6_PRCVEN , Nil})
		aadd(aLinha,{"C6_PRUNIT" , SC6->C6_PRUNIT , Nil})
		aadd(aLinha,{"C6_VALOR"  , SC6->C6_VALOR  , Nil})
		aadd(aLinha,{"C6_TES"    , SC6->C6_TES    , Nil})
		aadd(aItens, aLinha)

		SC6->(DbSkip())

	Enddo 
 
   MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
   If !lMsErroAuto
      Alert('Erro !')
   Else
      Alert('Excluído !')
   EndIf

	SC5->(DbSkip())
Enddo 

Return Nil 
