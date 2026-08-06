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

Local aCores := {{ "ZZ3_STATUS = '2'", 'BR_VERMELHO', 'Erro'},;
                 { "ZZ3_STATUS = '3'", 'BR_CINZA'   , 'Estornado'},;
				 { "ZZ3_TIPO = '1'"  , 'BR_VERDE'   , 'Inclusão'},;
                 { "ZZ3_TIPO = '2'"  , 'BR_AMARELO' , 'Alteração'}}

Local aSeek := {}
Local nI := 0

Private cCadastro := 'Log de Importação de Produtos'
Private aRotina   := MenuDef()
Private oMBrowse  := FWMBrowse():New()

aVisual := {'ZZ3_ID', 'ZZ3_LINHA', 'ZZ3_DATA', 'ZZ3_CODPRO', 'ZZ3_USER', 'ZZ3_TIPO', 'ZZ3_CAMPO', 'ZZ3_ANT', 'ZZ3_DEP'}

Aadd(aRotina, {'Legenda', 'U_Legend()'  , 0, 7, 0,.F.}) // 'Legenda'

oMBrowse:SetAlias('ZZ3')            
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
                  {'BR_VERDE'   , 'Inclusão'},;
				  {'BR_VERMELHO', 'Erro'},;
				  {'BR_CINZA'   , 'Estornado'}}

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
                                                      
Private aRotina2 := {{'Por ID'   , 'U_NLESTA3A(ZZ3->ZZ3_ID)', 0, 5},;
					 {'Por Linha', 'U_NLESTA3A(ZZ3->ZZ3_ID,ZZ3->ZZ3_LINHA)', 0, 5}}	

Private aRotina := {{'Pesquisar' , 'AxPesqui' , 0, 1},;	                	// Pesquisar
					{'Visualizar', "AxVisual('ZZ3',,,aVisual)",  0, 2},;	// Visualizar
					{'Rollback'   , aRotina2   , 0, 5}}

Return(aRotina) 

//---------------------------------------------------------------\\
/*/{Protheus.doc} NLESTA3A
//TODO Log de importação de produtos
@author Claudio
@since 03/02/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
User Function NLESTA3A(cId, cLinha)

Local cGrupos   := GetMV('NL_GRPROLB')
Local aGrupos   := UsrRetGrp(RETCODUSR())
Local lGrupo    := .F.
Local cPergunta := ''
Local nI := 0

For nI := 1 to Len(aGrupos)
	If aGrupos[nI] $ cGrupos
		lGrupo := .T.
		Exit
	Endif 
Next nI 

If !lGrupo
	Alert('Grupo do usuário sem permissão para executar essa rotina !')
	Return Nil 
Endif 

If cLinha <> Nil
	cPergunta := 'Confirma o rollback do ID '+ Alltrim(cID) + ', linha ' + Alltrim(cLinha) +' ?'
Else
	cPergunta := 'Confirma o rollback do ID '+ Alltrim(cID) + ' ?'
Endif 

If MsgYesNo(cPergunta)
	Processa( {|| RollBack(cID, cLinha) }, 'Rollback', 'Executando rollback dos registros ...', .F.)
Endif 

Return Nil

//---------------------------------------------------------------\\
/*/{Protheus.doc} RollBack
//TODO Processa rollback dos registros
@author Claudio
@since 25/02/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
Static Function RollBack(cId, cLinha)

Local cAliasZZ3 := GetNextAlias()
Local cWhere := ''

If cLinha <> Nil
	cWhere := "%ZZ3_ID = '"+cID+"' AND ZZ3_LINHA = '"+cLinha+"'%"
Else
	cWhere := "%ZZ3_ID = '"+cID+"'%" 
Endif

BeginSQL Alias cAliasZZ3

	SELECT ZZ3_ID, ZZ3_LINHA, ZZ3_CODPRO, ZZ3_TIPO, ZZ3_STATUS, ZZ3_CAMPO, ZZ3_ANT 
	FROM %Table:ZZ3% ZZ3 
	WHERE   ZZ3_FILIAL = %xFilial:ZZ3%
		AND %Exp:cWhere%
		AND ZZ3.%notdel%

EndSQL 

(cAliasZZ3)->(DbGoTop())

While !(cAliasZZ3)->(EOF())

	If (cAliasZZ3)->ZZ3_STATUS = '1'	// Registro processado
		If (cALiasZZ3)->ZZ3_TIPO = '1'
			ExcluiReg((cAliasZZ3)->ZZ3_ID, (cAliasZZ3)->ZZ3_LINHA, (cAliasZZ3)->ZZ3_CODPRO)
		Else 
			AlteraReg((cAliasZZ3)->ZZ3_ID, (cAliasZZ3)->ZZ3_LINHA, (cAliasZZ3)->ZZ3_CODPRO, (cAliasZZ3)->ZZ3_CAMPO, (cAliasZZ3)->ZZ3_ANT)		
		Endif 
	Endif 

	(cAliasZZ3)->(DbSkip())

EndDo 

(cAliasZZ3)->(DbCloseArea())

Return Nil

//---------------------------------------------------------------\\
/*/{Protheus.doc} ExcluiReg
//TODO Exclui o produto que foi incluído pelo ID.
@author Claudio
@since 20/02/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
Static Function ExcluiReg(cID, cLinha, cProduto)

/* Exclui o registro */
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + cProduto))
	SB1->(reclock('SB1',.F.))
	SB1->(DbDelete())
	SB1->(MsUnlock())

	/* Altera o status do registro na tabela ZZ3 para "Rollback" */
	ZZ3->(DbSetOrder(1))
	If ZZ3->(DbSeek(xFilial('ZZ3') + cID + cLinha))
		ZZ3->(reclock('ZZ3',.F.))
		ZZ3->ZZ3_DTROLL := dDatabase
		ZZ3->ZZ3_USRROL := Alltrim(USRRETNAME(RETCODUSR()))
		ZZ3->ZZ3_STATUS := '3'	// Rollback
		ZZ3->(MsUnlock())
	Endif 

Endif 

Return Nil 

//---------------------------------------------------------------\\
/*/{Protheus.doc} AlteraReg
//TODO Desfaz as alterações dos produtos alterados pelo ID.
@author Claudio
@since 20/02/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
Static Function AlteraReg(cID, cLinha, cProduto, cCampo, cConteudo)

/* Altera o registro */
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial('SB1') + cProduto))
	SB1->(reclock('SB1',.F.))

	If TamSx3(cCampo)[3] = 'D'
		SB1->&cCampo := Ctod(cConteudo)
	ElseIf TamSx3(cCampo)[3] = 'N'
		SB1->&cCampo := Val(cConteudo)
	Else 
		SB1->&cCampo := cConteudo
	Endif 	
	SB1->(MsUnlock())

	/* Altera o status do registro na tabela ZZ3 para "Rollback" */
	ZZ3->(DbSetOrder(1))
	If ZZ3->(DbSeek(xFilial('ZZ3') + cID + cLinha + cProduto + cCampo))
		ZZ3->(reclock('ZZ3',.F.))
		ZZ3->ZZ3_DTROLL := dDatabase
		ZZ3->ZZ3_USRROL := Alltrim(USRRETNAME(RETCODUSR()))
		ZZ3->ZZ3_STATUS := '3'	// Rollback
		ZZ3->(MsUnlock())
	Endif 

Endif 

Return Nil 
