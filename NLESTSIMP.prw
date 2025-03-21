#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*
Autor: Tiago Dias
Data: 13/07/2023
Descri��o: cria��o de relat�rio de estrutura simples para compara��o e c�lculo de custo m�dio
*/
User Function NLPEDJF()
Local aPergs   	:= {}
Local nTipo    	:= ""
Local aPar 		:= {}
Local aRetorno	:= {}

Private cTipo	:= ""

aPar	:= 	{;
			Space( TamSx3( "G1_COD" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "G1_COD" )[ 01 ] ),;
			Space( TamSx3( "B1_TIPO" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "B1_TIPO" )[ 01 ] ),;
			Space( TamSx3( "B1_GRUPO" )[ 01 ] ),;
			Replicate( "Z" , TamSx3( "B1_GRUPO" )[ 01 ] ),;
			dDatabase,;
			}

	// Produto de           
	// Produto ate          
	// Tipo de              
	// Tipo ate             
	// Grupo de             
	// Grupo ate            
	// Salta Pagina: Sim/Nao
	// Qual Rev da Estrut   
	// Imprime Ate Nivel ?  
	// Data de referencia?  

	Aadd(aPergs, {1, "Produto De"	, aPar[ 01 ], "", "", "SB1", ""		, 061, .F. })//E2_VENCTO
	Aadd(aPergs, {1, "Produto At�"	, aPar[ 02 ], "", "", "SB1", ""		, 061, .F. })//E2_VENCTO

	Aadd(aPergs, {1, "Tipo De"		, aPar[ 03 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
	Aadd(aPergs, {1, "Tipo At�"		, aPar[ 04 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
		
	Aadd(aPergs, {1, "Grupo De"		, aPar[ 05 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
	Aadd(aPergs, {1, "Grupo At�"	, aPar[ 06 ], "", "", "", ""		, 061, .F. })//E2_VENCTO

	Aadd(aPergs, {1, "Data Refer�ncia"	, aPar[ 07 ], "", "", "", ""	, 061, .F. })//E2_VENCTO


	//Executa rotina de op��o
	If ParamBox(aPergs, "Informe os par�metros", @aRetorno)

		//Executa rotina para importar Pedidos
		MsAguarde({|| U_EstSimp(aRetorno)}, "Aguarde...", "Processando Registros...")

	ENDIF

Return


