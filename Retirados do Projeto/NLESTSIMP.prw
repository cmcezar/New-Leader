#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*
Autor: Tiago Dias
Data: 13/07/2023
Descrição: criação de relatório de estrutura simples para comparação e cálculo de custo médio
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
	Aadd(aPergs, {1, "Produto Até"	, aPar[ 02 ], "", "", "SB1", ""		, 061, .F. })//E2_VENCTO

	Aadd(aPergs, {1, "Tipo De"		, aPar[ 03 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
	Aadd(aPergs, {1, "Tipo Até"		, aPar[ 04 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
		
	Aadd(aPergs, {1, "Grupo De"		, aPar[ 05 ], "", "", "", ""		, 061, .F. })//E2_VENCTO
	Aadd(aPergs, {1, "Grupo Até"	, aPar[ 06 ], "", "", "", ""		, 061, .F. })//E2_VENCTO

	Aadd(aPergs, {1, "Data Referência"	, aPar[ 07 ], "", "", "", ""	, 061, .F. })//E2_VENCTO


	//Executa rotina de opção
	If ParamBox(aPergs, "Informe os parâmetros", @aRetorno)

		//Executa rotina para importar Pedidos
		MsAguarde({|| U_EstSimp(aRetorno)}, "Aguarde...", "Processando Registros...")

	ENDIF

Return


