#include 'protheus.ch'
#include 'parmtype.ch'

//---------------------------------------------------------------\\
/*/{Protheus.doc} NLESTA03
//TODO Log de importação de produtos
@author Claudio
@since 29/05/2025
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
User Function NLESTA03()

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
	
AxCadastro('ZZ3','Log de importação de produtos', /*cDel*/, /*cOk*/, /*aRotAdic*/, /*bPre*/, /*bOK*/, /*bTTS*/, /*bNoTTS*/, /*aAuto*/, /*nOpcAuto*/, /*aButtons*/, /*aACS*/, /*cTela*/)

Return Nil


