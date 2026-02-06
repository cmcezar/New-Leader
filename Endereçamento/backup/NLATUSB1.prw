#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Directry.ch"

//----------------------------------------------\\
/*/{Protheus.doc} NLATUSB1
// Rotina para atualizar o cadastro de produtos
   apartir de um arquivo txt.
@author Claudio Macedo
@since 09/11/2023
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function NLATUSB1()

Local cArquivo	:=	""

Private cNomeArq :=	""  
Private nPos     := 0
Private nLinhas  := 0	// Produtos lidos

nPos :=	Aviso('Atualizar Produtos','Esta rotina tem como objetivo atualizar'+CRLF+'o cadastro de produtos a partir de um arquivo txt.',{'Atualizar','Sair'}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( 'Arquivo |*.txt|' , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)

		FT_FUse()       // Fecha se houver arquivo aberto/em uso.
		FT_FUse(cArquivo) 
		FT_FGoTop()

		nLinhas := FT_FLastRec() - 1
		FT_FGoTop()

		Processa( {|| ImportaTxt() }, 'Processando arquivo ' + cNomeArq, 'Atualizando produtos ...', .F.)
				
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
Local aCampos := StrTokArr(cString,';')
Local cCampo  := ''
Local aInfo   := {}
Local nProc   := 0	// Produtos atualizados

Local nI := 0
		
FT_FSkip()	

While !FT_FEOF()

	cString := FT_FReadln()

	aInfo := StrTokArr(cString,';')

	SB1->(DbSetOrder(1))
	
	If SB1->(DbSeek(xFilial('SB1') + aInfo[1]))
			
		SB1->(reclock('SB1', .F.))
			
		For nI := 2 to Len(aInfo)

			cCampo := Alltrim(aCampos[nI])

			SB1->&cCampo := aInfo[nI]

		Next nI 

		nProc += 1

		SB1->(MsUnlock())

	Endif 

	FT_FSkip()	

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo('Arquivo ' + Alltrim(cNomeArq) + ' importado.' + CRLF + CRLF +;
        'Registros lidos'+Space(6)+': ' + Transform(nLinhas,'@E 999,999') + CRLF +;
		'Registros processados: ' + Transform(nProc,'@E 999,999'))

Return Nil

