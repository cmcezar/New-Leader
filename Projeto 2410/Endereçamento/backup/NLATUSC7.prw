#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Directry.ch"

//----------------------------------------------\\
/*/{Protheus.doc} NLATUSC7
// Rotina para atualizar os itens dos pedidos de compra
   apartir de um arquivo txt.
@author Claudio Macedo
@since 09/11/2023
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function NLATUSC7()

Local cArquivo	:=	""

Private cNomeArq :=	""  
Private nPos     := 0
Private nLinhas  := 0	// Produtos lidos

nPos :=	Aviso('Atualizar Produtos','Esta rotina tem como objetivo atualizar'+CRLF+'os itens dos pedidos de compra a partir de um arquivo txt.',{'Atualizar','Sair'}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( 'Arquivo |*.txt|' , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)

		FT_FUse()       // Fecha se houver arquivo aberto/em uso.
		FT_FUse(cArquivo) 
		FT_FGoTop()

		nLinhas := FT_FLastRec() - 1
		FT_FGoTop()

		Processa( {|| ImportaTxt() }, 'Processando arquivo ' + cNomeArq, 'Atualizando pedidos de compra ...', .F.)
				
	Endif
Endif

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} ImportaTxt
// Importa arquivo texto
@author Claudio Macedo
@since 15/04/2019
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function ImportaTxt()
                                  
Local cString := FT_FReadln()
Local nLinha  := 1
Local aInfo   := {}
Local nProc   := 0	// Produtos atualizados
		
FT_FSkip()	

While !FT_FEOF()

	cString := FT_FReadln()

	aInfo := StrTokArr(cString,';')

	SC7->(DbSetOrder(1))
	
	If SC7->(DbSeek(xFilial('SC7') + aInfo[1] + aInfo[2]))

		SC7->(reclock('SC7', .F.))
		SC7->C7_LOCAL := aInfo[3]
		SC7->(MsUnlock())

		nProc += 1
	Endif 

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999'))

Return Nil

