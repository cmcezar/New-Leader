#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Directry.ch"

//----------------------------------------------\\
/*/{Protheus.doc} NLFATA01
// Rotina para importar pedido de venda em formato texto.
@author Claudio Macedo
@since 20/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
User Function NLFATA01()

Local cArquivo := ''
Local cPath	   := ''
Local cPerg	   :=  PADR('NLFATA01', 10)

Private cNomeArq :=	""  
Private nPos     := 0
Private nLinhas  := 0

If !Pergunte(cPerg, .T.)
    Return Nil
Endif

nPos :=	Aviso("Importação de Previsão e Pedido de Venda","Esta rotina tem como objetivo importar"+CRLF+" previsões e pedidos de venda.",{"Importar","Sair"}, 3)

If nPos = 1                 
	cArquivo :=	cGetFile( "Previsão e Pedido de Venda |*.txt|" , 'Selecione o arquivo', 1, 'C:\', .T., GETF_LOCALFLOPPY + GETF_LOCALHARD )
	
	If !Empty(cArquivo)
		cPath	 :=	Substring(cArquivo,0,RAT("\",cArquivo))
		cNomeArq :=	Substring(cArquivo,RAT("\",cArquivo)+1,Len(cArquivo))
	
		FT_FUse()       // Fecha se houver arquivo aberto/em uso.
		FT_FUse(cArquivo) 
		FT_FGoTop()

		nLinhas := FT_FLastRec() - 1
		FT_FGoTop()
		FT_FSkip()
		//oArq := Arquivo():New(cPath,cNomeArq)
		//oArq:Open()
		//oArq:Use()
		
		//nLinhas := nLinArq()
		//oArq:GoTop()
		
		ProcRegua(nLinhas)
	
		Processa( {|| ImportaTxt() }, "Processando arquivo " + cNomeArq, "Importando previsão e pedido de venda ...", .F.)
				
	Endif
Endif

Return Nil

//----------------------------------------------\\
/*/{Protheus.doc} ImportaTxt
// Importa arquivo texto
@author Claudio Macedo
@since 20/03/2026
@version 1.0
@return Nil
@type Function
/*/
//----------------------------------------------\\
Static Function ImportaTxt()
                                  
Local aString := {}
Local cItem   := '0001'
Local nLinha  := 1
Local cID	  := GetSXeNum('ZZ5','ZZ5_ID')

If !FT_FEOF()
	ZZ5->(reclock('ZZ5',.T.))
	ZZ5->ZZ5_FILIAL  := xFilial('ZZ5')
	ZZ5->ZZ5_ID		 := cID
	ZZ5->ZZ5_NOMARQ  := cNomeArq
	ZZ5->ZZ5_DATA	 := dDatabase
	ZZ5->ZZ5_CLIENT  := mv_par01
	ZZ5->ZZ5_LOJA    := mv_par02
	ZZ5->(MsUnlock())
	ConfirmSX8()
Endif 

While !FT_FEOF() 

	//cString := FT_FReadln()
	aString := StrTokArr(FT_FReadln(),';')

	ZZ6->(reclock('ZZ6',.T.))
	ZZ6->ZZ6_FILIAL := xFilial('ZZ6')
	ZZ6->ZZ6_ID		:= cID
	ZZ6->ZZ6_ITEM	:= cItem
	ZZ6->ZZ6_TIPO   := IIF(aString[1] = 'Forecast', '1', '2')
	ZZ6->ZZ6_DATA	:= Ctod(aString[2])
	ZZ6->ZZ6_PLANTA	:= aString[3]
	ZZ6->ZZ6_ORDCOM	:= aString[4]
	ZZ6->ZZ6_ITCOM	:= aString[5]
	ZZ6->ZZ6_PNCLI	:= aString[6]
	ZZ6->ZZ6_QTDENT	:= Val(aString[7])
	ZZ6->ZZ6_QTDANT	:= Val(aString[8])
	ZZ6->ZZ6_PRCUNI	:= Val(aString[9])
	ZZ6->ZZ6_PNNWL	:= Posicione('SA7',3,xFilial('SA7') + mv_par01 + mv_par02 + aString[6], 'A7_CODCLI') // Amarração Produto x Cliente

	cItem := Soma1(cItem)
	ZZ6->(MsUnlock())

	FT_FSkip()

	IncProc('Linha atual: '+Alltrim(Str(nLinha += 1))+' de '+Alltrim(Str(nLinhas)))

EndDo

FT_FUse()

MsgInfo("Arquivo "+Alltrim(cNomeArq)+" importado.")

Return Nil

