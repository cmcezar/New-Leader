#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'
#include 'FWMBrowse.ch'

//---------------------------------------------------------------\\
/*/{Protheus.doc} NLESTA03
//TODO Log de importação de produtos
@author Claudio
@since 03/02/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
User Function NLESTA03()

Local aCores := {{ "ZZ3_TIPO = '1'", 'BR_VERDE'  , 'Inclusão'},;
                 { "ZZ3_TIPO = '2'" ,'BR_AMARELO', 'Alteração'}}

Local aSeek := {}
Local nI := 0

Private cCadastro := 'Log de Importação de Produtos'
Private aRotina   := MenuDef()
Private oMBrowse  := FWMBrowse():New()
//Private aVisual   := {}
//Private aAltera   := {}

aVisual := {'ZZ3_ID', 'ZZ3_DATA', 'ZZ3_CODPRO', 'ZZ3_USER', 'ZZ3_TIPO', 'ZZ3_CAMPO', 'ZZ3_ANT', 'ZZ3_DEP'}
//aAltera := {'Z3_STATUS', 'Z3_DTAUTOR', 'Z3_NOME'}

Aadd(aRotina, {'Legenda', 'U_Legend()'  , 0, 7, 0,.F.}) // 'Legenda'

oMBrowse:SetAlias('ZZ3')            
//oMBrowse:SetOnlyFields({'Z3_NUM', 'Z3_PEDCLI', 'Z3_CLIENTE', 'Z3_LOJA', 'Z3_NOMECLI', 'Z3_DATA', 'Z3_OBS'})
oMBrowse:SetDescription(cCadastro)
oMBrowse:SetTemporary(.F.)

aAdd(aSeek, {'ID' ,{{'','C',9,0,TamSX3('ZZ3_ID')[01] ,'@!','ZZ3_ID'}}, 1, .T.})

oMBrowse:SetSeek(.T.,aSeek)

//Adiciona a legenda
For nI := 1 To Len(aCores)
    oMBrowse:AddLegend(aCores[nI][1], aCores[nI][2], aCores[nI][3])
Next nI

oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Legend()
Legenda dos status da autorização

@author    Cláudio Macedo
@version   1.0
@since     03/02/2026
/*/
//------------------------------------------------------------------------------------------
User Function Legend()

Local aCores  := {{'BR_AMARELO' , 'Alteração'},;
                  {'BR_VERDE'   , 'Inclusão'}}

BrwLegenda(cCadastro,'Produtos',aCores)

Return(.T.)                            
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional.

retorno aRotina - Array com opcoes da rotina.
param 	1. Nome a aparecer no cabecalho
		2. Nome da Rotina associada
		3. Reservado
		4. Tipo de Transação a ser efetuada:
			1 - Pesquisa e Posiciona em um Banco de Dados
			2 - Simplesmente Mostra os Campos
			3 - Inclui registros no Bancos de Dados
			4 - Altera o registro corrente
			5 - Remove o registro corrente do Banco de Dados
		5. Nivel de acesso
		6. Habilita Menu Funcional

@author    Cláudio Macedo
@version   1.0
@since     16/11/2021
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
                                                      
Private aRotina := {{'Pesquisar' , 'AxPesqui'  ,   0, 1},;	                // Pesquisar
					{'Visualizar', "AxVisual('ZZ3',,,aVisual)",  0, 2}}		// Visualizar

Return(aRotina) 



//Local bNoTTS := { || U_GravaSDB()}


/* --------------------------------------------------------------------------------------------------------------------------------------

AxCadastro([cAlias],[cTitle],[cDel],[cOk],[aRotAdic],[bPre],[bOK],[bTTS],[bNoTTS],[aAuto],[nOpcAuto],[aButtons],[aACS],[cTela])

cAlias	 	Alias da Tabela cadastrada no dicionário (SX2) que será baseada a mBrowse.	 	 	 	 	 	 	 	 	 	 
cTitle	 	Título da janela.	 	 	 	 	 	 	 	 	 	 
cDel	 	Função a ser executada ao deletar o registro.	 	 	 	 	 	 	 	 	 	 
cOk	 	 	Função a ser executada ao clicar no botão OK para gravar o registro(inclusão e alteração).	 	 	 	 	 	 	 	 	 	 
aRotAdic	Array contendo as rotinas adicionais para ser acrescentado ao array aRotina.	 	 	 	 	 	 	 	 	 	 
bPre	 	Codeblock a ser executado antes da abertura do diálogo de inclusão, alteração ou exclusão.	 	 	 	 	 	 	 	 	 	 
bOK	 	 	Codeblock a ser executado ao clicar no botão OK do diálogo de inclusão, alteração ou exclusão.	 	 	 	 	 	 	 	 	 	 
bTTS	 	Codeblock a ser executado durante a transação de inclusão, alteração ou exclusão.	 	 	 	 	 	 	 	 	 	 
bNoTTS	 	Codeblock a ser executado após a transação de inclusão, alteração ou exclusão.	 	 	 	 	 	 	 	 	 	 
aAuto	 	Array com os campos a serem considerados pela rotina automática.	 	 	 	 	 	 	 	 	 	 
nOpcAuto	Numero da opção selecionada (Inclusão, Alteração, Exclusão, Visualização) para a rotina automática.	 	 	 	 	 	 	 	 	 	 
aButtons	Array contendo os botões da EnchoiceBar com a seguinte estrutura: aButtons[1][1] – Nome do arquivo da imagem do botão.aButtons[1][2] – Bloco de execução.aButtons[1][3] – Mensagem de exibição no ToolTip.aButtons[1][4] – Nome do botão.	 	 	 	 	 	 	 	 	 	 
aACS	 	Array que substituí o controle de acessos das funções básicas do aRotina (Pesquisar, Visualizar, Incluir, Alterar, Excluir).
cTela	 	Nome da variável tipo "private" que a enchoice utilizará no lugar da variável aTela.
------------------------------------------------------------------------------------------------------------------------------------------- */
	
//AxCadastro('ZZ3','Log de importação de produtos', /*cDel*/, /*cOk*/, /*aRotAdic*/, /*bPre*/, /*bOK*/, /*bTTS*/, /*bNoTTS*/, /*aAuto*/, /*nOpcAuto*/, /*aButtons*/, /*aACS*/, /*cTela*/)

//Return Nil


