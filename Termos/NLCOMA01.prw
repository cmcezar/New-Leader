#include 'protheus.ch'
#include 'parmtype.ch'

//---------------------------------------------------------------\\
/*/{Protheus.doc} NLCOMA01
//TODO Cadastro de Termos e Condi��es.
@author Claudio
@since 29/05/2025
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
User Function NLCOMA01()

Local bOK := { || U_DelZZ1()}

//Local bNoTTS := { || U_GravaSDB()}


/* --------------------------------------------------------------------------------------------------------------------------------------

AxCadastro([cAlias],[cTitle],[cDel],[cOk],[aRotAdic],[bPre],[bOK],[bTTS],[bNoTTS],[aAuto],[nOpcAuto],[aButtons],[aACS],[cTela])

cAlias	 	Alias da Tabela cadastrada no dicion�rio (SX2) que ser� baseada a mBrowse.	 	 	 	 	 	 	 	 	 	 
cTitle	 	T�tulo da janela.	 	 	 	 	 	 	 	 	 	 
cDel	 	Fun��o a ser executada ao deletar o registro.	 	 	 	 	 	 	 	 	 	 
cOk	 	 	Fun��o a ser executada ao clicar no bot�o OK para gravar o registro(inclus�o e altera��o).	 	 	 	 	 	 	 	 	 	 
aRotAdic	Array contendo as rotinas adicionais para ser acrescentado ao array aRotina.	 	 	 	 	 	 	 	 	 	 
bPre	 	Codeblock a ser executado antes da abertura do di�logo de inclus�o, altera��o ou exclus�o.	 	 	 	 	 	 	 	 	 	 
bOK	 	 	Codeblock a ser executado ao clicar no bot�o OK do di�logo de inclus�o, altera��o ou exclus�o.	 	 	 	 	 	 	 	 	 	 
bTTS	 	Codeblock a ser executado durante a transa��o de inclus�o, altera��o ou exclus�o.	 	 	 	 	 	 	 	 	 	 
bNoTTS	 	Codeblock a ser executado ap�s a transa��o de inclus�o, altera��o ou exclus�o.	 	 	 	 	 	 	 	 	 	 
aAuto	 	Array com os campos a serem considerados pela rotina autom�tica.	 	 	 	 	 	 	 	 	 	 
nOpcAuto	Numero da op��o selecionada (Inclus�o, Altera��o, Exclus�o, Visualiza��o) para a rotina autom�tica.	 	 	 	 	 	 	 	 	 	 
aButtons	Array contendo os bot�es da EnchoiceBar com a seguinte estrutura: aButtons[1][1] � Nome do arquivo da imagem do bot�o.aButtons[1][2] � Bloco de execu��o.aButtons[1][3] � Mensagem de exibi��o no ToolTip.aButtons[1][4] � Nome do bot�o.	 	 	 	 	 	 	 	 	 	 
aACS	 	Array que substitu� o controle de acessos das fun��es b�sicas do aRotina (Pesquisar, Visualizar, Incluir, Alterar, Excluir).
cTela	 	Nome da vari�vel tipo "private" que a enchoice utilizar� no lugar da vari�vel aTela.
------------------------------------------------------------------------------------------------------------------------------------------- */
	
AxCadastro('ZZ1','Termos e Condi��es', /*cDel*/, /*cOk*/, /*aRotAdic*/, /*bPre*/, bOK, /*bTTS*/, /*bNoTTS*/, /*aAuto*/, /*nOpcAuto*/, /*aButtons*/, /*aACS*/, /*cTela*/)

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} DelZZ1()
// Verifica se pode deletar o registro.
@author    Cl�udio Macedo
@version   1.0
@since     06/09/2023
/*/
//-----------------------------------------------------------
User Function DelZZ1()

Local cAliasSC7 := GetNextAlias()
Local lRet := .T.

BeginSQL Alias cAliasSC7

    SELECT TOP 1 C7_NUM FROM %Table:SC7% SC7 WHERE SC7.%notdel% AND C7_XTERMO = %Exp:ZZ1->ZZ1_CODIGO%

EndSQL

(cAliasSC7)->(DbGoTop())

If !(cAliasSC7)->(EOF())
    Alert('Este c�digo foi utilizado em um ou mais pedidos de compra e n�o poder� ser exclu�do.')
    lRet := .F.
Endif 

(cAliasSC7)->(DbCloseArea())

Return lRet 

