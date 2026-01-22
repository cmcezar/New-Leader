#include "ACDR100.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDR100  ³ Autor ³ Robson Sales   		³ Data ³ 14/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Ordens de Separacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function NLACDR01()

Local aOrdem		:= {STR0001}//"Ordem de Separação"
Local aDevice		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
Local bParam		:= {|| Pergunte("ACD100", .T.)}
Local cDevice		:= ""
Local cPathDest	:= GetSrvProfString("StartPath","\system\")
Local cRelName	:= 'ACDR100x'
Local cSession	:= GetPrinterSession()
Local lAdjust		:= .F.
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
Local nLocal		:= 1
Local nOrdem		:= 1
Local nOrient		:= 1
Local nPrintType	:= 6
Local oPrinter	:= Nil
Local oSetup		:= Nil
Private nMaxLin	:= 600
Private nMaxCol	:= 800

cSession	:= GetPrinterSession()
cDevice	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nOrient	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
//nOrient	    := 1	// PORTRAIT
nLocal		:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nPrintType	:= aScan(aDevice,{|x| x == cDevice })     

oPrinter	:= FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
oSetup		:= FWPrintSetup():New (nFlags,cRelName)

oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , nOrient)
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
oSetup:SetOrderParms(aOrdem,@nOrdem)
oSetup:SetUserParms(bParam)

If oSetup:Activate() == PD_OK 
	fwWriteProfString(cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )	
	fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )	
	fwWriteProfString(cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		
	oPrinter:lServer			:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER	
	oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	oPrinter:setCopies(Val(oSetup:cQtdCopia))

	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice		:= IMP_SPOOL
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oPrinter:cPrinter		:= oSetup:aOptions[PD_VALUETYPE]
	Else 
		oPrinter:nDevice		:= IMP_PDF
		oPrinter:cPathPDF		:= oSetup:aOptions[PD_VALUETYPE]
		oPrinter:SetViewPDF(.T.)
	Endif
	
	RptStatus({|lEnd| U_NL100Imp(@lEnd,@oPrinter)},STR0003)//"Imprimindo Relatorio..."
Else 
	MsgInfo(STR0004) //"Relatório cancelado pelo usuário."
	oPrinter:Cancel()
EndIf

oSetup		:= Nil
oPrinter	:= Nil

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | NL100Imp  ³ Autor ³ Robson Sales          ³ Data ³14/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o corpo do relatorio                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function NL100Imp(lEnd,oPrinter)

Local nMaxLinha	:= 7//40
Local nLinCount	:= 0
Local aArea		:= GetArea()
Local cQry			:= ""
Local cOrdSep		:= ""
Private cAliasOS	:= GetNextAlias()
Private nMargDir	:= 15
Private nMargEsq	:= 20
Private nColAmz	:= nMargEsq+156
//Private nColEnd	:= nColAmz+45
Private nColEnd	:= nColAmz+143
Private nColLot	:= nColEnd+85
Private nColSLt	:= nColLot+85
Private nSerie	:= nColSLt+40
Private nQtOri	:= nSerie+110
//Private nQtSep	:= nQtOri+85
Private nQtSep	 := nColEnd+222
Private nQtEmb	 := nQtSep+85
Private oFontA7	 := TFont():New('Arial',,7,.T.)
Private oFontA12 := TFont():New('Arial',,12,.T.)
Private oFontC8	 := TFont():New('Courier new',,8,.T.)
//Private li			:= 10
Private li		:= 40
Private nLiItm	:= 0
Private nPag	:= 0
Private nLinCB	:= 13

Pergunte("ACD100",.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o arquivo temporario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQry := "SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
cQry += "CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,CB8_QTDORI,CB8_SALDOS,CB8_SALDOE"
cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
cQry += " CB8_FILIAL = CB7_FILIAL AND"
cQry += " CB8_ORDSEP = CB7_ORDSEP AND"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao Considera as Ordens ja finalizadas ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR05 == 2
	cQry += " CB7_STATUS <> '9' AND"
EndIf
cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
//cQry += " ORDER BY CB7_ORDSEP,CB8_PROD"
cQry += " ORDER BY CB8_LOCAL,CB8_LCALIZ,CB8_PROD"
cQry := ChangeQuery(cQry)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasOS,.T.,.T.)

SetRegua((cAliasOS)->(LastRec()))
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a impressao do relatorio ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAliasOS)->(Eof())
	IncRegua()
	nLiItm		:= 110
	nLinCount	:= 0
	nLinCB	:= 13
	nPag++
	oPrinter:StartPage()
	U_NLCabPag(@oPrinter)
	U_NLCabIt(@oPrinter,(cAliasOS)->CB7_ORIGEM)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os titulos das colunas dos itens ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPrinter:SayAlign(li+100,115 /*15*/,'Armaz�m',oFontC8,200,200,,0)//"Armazem"
	oPrinter:SayAlign(li+100,216 /*116*/,'Endere�o',oFontC8,200,200,,0)//"Endereço"
	oPrinter:SayAlign(li+100,454 /*354*/,'Qtd. a Separar',oFontC8,200,200,,0)//"Qtd. a Separar"
	oPrinter:SayAlign(li+100,668 /*566*/,'Produto',oFontC8,200,200,,0)//"Produto"
	//oPrinter:SayAlign(li+100,nQtEmb,STR0013,oFontC8,200,200,,0)//"Qtd. a Embalar"
	oPrinter:Line(li+110,nMargDir, li+110, nMaxCol-nMargEsq,, "-2")
	
	cOrdSep := (cAliasOS)->CB7_ORDSEP
	
	While !(cAliasOS)->(Eof()) .and. (cAliasOS)->CB8_ORDSEP == cOrdSep
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia uma nova pagina caso nao estiver em EOF ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLinCount == nMaxLinha
			oPrinter:StartPage()
			nPag++
			U_NLCabPag(@oPrinter)
			U_NLCabIt(@oPrinter,(cAliasOS)->CB7_ORIGEM)
			nLiItm		:= li+50
			nLinCount	:= 0
			nLinCB	:= 13

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime os titulos das colunas dos itens ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			oPrinter:SayAlign(li+100,115,'Armaz�m',oFontC8,200,200,,0)//"Armazem"
			oPrinter:SayAlign(li+100,216,'Endere�o',oFontC8,200,200,,0)//"Endereço"
			oPrinter:SayAlign(li+100,454,'Qtd. a Separar',oFontC8,200,200,,0)//"Qtd. a Separar"
			oPrinter:SayAlign(li+100,668,'Produto',oFontC8,200,200,,0)//"Produto"
			//oPrinter:SayAlign(li+100,nQtEmb,STR0013,oFontC8,200,200,,0)//"Qtd. a Embalar"
			oPrinter:Line(li+110,nMargDir, li+110, nMaxCol-nMargEsq,, "-2")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os itens da ordem de separacao ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		oPrinter:SayAlign(li+nLiItm,nMargDir,(cAliasOS)->CB8_PROD,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColAmz,(cAliasOS)->CB8_LOCAL,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColEnd,(cAliasOS)->CB8_LCALIZ,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColLot,(cAliasOS)->CB8_LOTECT,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColSLt,(cAliasOS)->CB8_NUMLOT,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nSerie,(cAliasOS)->CB8_NUMSER,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nQtOri+li,Transform((cAliasOS)->CB8_QTDORI,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0) 
		oPrinter:SayAlign(li+nLiItm,nQtSep+li,Transform((cAliasOS)->CB8_SALDOS,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		oPrinter:SayAlign(li+nLiItm,nQtEmb+li,Transform((cAliasOS)->CB8_SALDOE,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		*/
		
		If MV_PAR06 == 1
			oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLinCB/*nRow*/,2        /*nCol*/,AllTrim((cAliasOS)->CB8_LOCAL)+AllTrim((cAliasOS)->CB8_LCALIZ),oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.5/*nHeigth*/,.T./*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLinCB/*nRow*/,22 /*2*/ /*nCol*/,AllTrim((cAliasOS)->CB8_LOCAL)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.5/*nHeigth*/,.T./*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLinCB/*nRow*/,30 /*10*/ /*nCol*/,AllTrim((cAliasOS)->CB8_LCALIZ)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.5/*nHeigth*/,.T./*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLinCB/*nRow*/,50 /*30*/ /*nCol*/,Alltrim(Str((cAliasOS)->CB8_SALDOS))/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.5/*nHeigth*/,.T./*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLinCB/*nRow*/,58 /*48*/ /*nCol*/,AllTrim((cAliasOS)->CB8_PROD)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.5/*nHeigth*/,.T./*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
//			oPrinter:Line(nLinCB+1, nMargDir, nLinCB+1, nMaxCol-nMargEsq,, "-2")
		EndIf

		nLinCount++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a pagina quando atingir a quantidade maxima de itens ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nLinCount == nMaxLinha
			oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
			oPrinter:EndPage()
		Else
//			nLiItm += li
			nLinCB += 5
		EndIf
			
		(cAliasOS)->(dbSkip())
		Loop
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a pagina se a quantidade de itens for diferente da quantidade ³ 
	//³ maxima, para evitar que a pagina seja finalizada mais de uma vez.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLinCount <> nMaxLinha
		oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
		oPrinter:EndPage()
	EndIf
EndDo

oPrinter:Print()

(cAliasOS)->(dbCloseArea())
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | NLCabPag  ³ Autor ³ Robson Sales          ³ Data ³14/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function NLCabPag(oPrinter)

Private nCol1Dir	:= 720-nMargDir   
Private nCol2Dir	:= 760-nMargDir

oPrinter:Line(li+5, nMargDir, li+5, nMaxCol-nMargEsq,, "-8")

oPrinter:SayAlign(li+10,nMargDir,STR0023,oFontA7,200,200,,0)//"SIGA/ACDR100/v11"
oPrinter:SayAlign(li+20,nMargDir,STR0024+Time(),oFontA7,200,200,,0)//"Hora: "
oPrinter:SayAlign(li+30,nMargDir,STR0025+FWFilialName(,,2) ,oFontA7,300,200,,0)//"Empresa: "

oPrinter:SayAlign(li+20,340,STR0026,oFontA12,nMaxCol-nMargEsq,200,2,0)//"Impressão das Ordens de Separação"

oPrinter:SayAlign(li+10,nCol1Dir,STR0027,oFontA7,200,200,,0)//"Folha   : "
oPrinter:SayAlign(li+20,nCol1Dir,STR0028,oFontA7,200,200,,0)//"Dt. Ref.: "
oPrinter:SayAlign(li+30,nCol1Dir,STR0029,oFontA7,200,200,,0)//"Emissão : "

oPrinter:SayAlign(li+10,nCol2Dir,AllTrim(STR(nPag)),oFontA7,200,200,,0)
oPrinter:SayAlign(li+20,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)
oPrinter:SayAlign(li+30,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)

oPrinter:Line(li+40,nMargDir, li+40, nMaxCol-nMargEsq,, "-8")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | NLCabIt    ³ Autor ³ Robson Sales          ³ Data ³18/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function NLCabIt(oPrinter,cOrigem)

Local cOrdSep		:= AllTrim((cAliasOS)->CB7_ORDSEP)
Local cPedVen		:= AllTrim((cAliasOS)->CB7_PEDIDO)
Local cClient		:= AllTrim((cAliasOS)->CB7_CLIENT)+"-"+AllTrim((cAliasOS)->CB7_LOJA)
Local cNFiscal	:= AllTrim((cAliasOS)->CB7_NOTA)+"-"+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE')))
Local cOP			:= AllTrim((cAliasOS)->CB7_OP)
Local cStatus		:= RetStatus((cAliasOS)->CB7_STATUS)

oPrinter:SayAlign(li+60,nMargDir,STR0030,oFontC8,200,200,,0)//"Ordem de Separação:"
oPrinter:SayAlign(li+60,nMargDir+105,cOrdSep,oFontC8,200,200,,0)

If Alltrim(cOrigem) == "1" // Pedido venda
	oPrinter:SayAlign(li+60,nMargDir+160,STR0031,oFontC8,200,200,,0)//"Pedido de Venda:"
	If Empty(cPedVen) .And. (cAliasOS)->CB7_STATUS <> "9"
		oPrinter:SayAlign(li+60,nMargDir+245,STR0047,oFontC8,200,200,,0)//"Aglutinado"
		oPrinter:SayAlign(li+72,nMargDir,STR0048,oFontC8,200,200,,0)//"PV's Aglutinados:"
		oPrinter:SayAlign(li+72,nMargDir+105,A100AglPd(cOrdSep),oFontC8,550,200,,0)		
	Else
		oPrinter:SayAlign(li+60,nMargDir+245,cPedVen,oFontC8,200,200,,0)
	EndIf
	oPrinter:SayAlign(li+60,nMargDir+310,STR0032,oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
ElseIf Alltrim(cOrigem) == "2" // Nota Fiscal
	oPrinter:SayAlign(li+60,nMargDir+160,STR0033,oFontC8,200,200,,0)//"Nota Fiscal:"
	oPrinter:SayAlign(li+60,nMargDir+230,cNFiscal,oFontC8,200,200,,0)
	oPrinter:SayAlign(li+60,nMargDir+310,STR0034,oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
ElseIf Alltrim(cOrigem) == "3" // Ordem de Producao
	oPrinter:SayAlign(li+60,nMargDir+160,STR0035,oFontC8,200,200,,0)//"Ordem de Produção:"
	oPrinter:SayAlign(li+60,nMargDir+255,cOP,oFontC8,200,200,,0)
EndIf

oPrinter:SayAlign(li+60,nMargDir+430,STR0036,oFontC8,200,200,,0)//"Status:"
oPrinter:SayAlign(li+60,nMargDir+470,cStatus,oFontC8,200,200,,0)
oPrinter:Line(li+90,nMargDir, li+90, nMaxCol-nMargEsq,, "-2")

If MV_PAR06 == 1
	oPrinter:FWMSBAR("CODE128",8/*nRow*/,60/*nCol*/,AllTrim(cOrdSep),oPrinter,,,, 0.049,0.5,,,,.F.,,,)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | RetStatus  ³ Autor ³ Robson Sales          ³ Data ³18/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Status da Ordem de Separacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetStatus(cStatus)

Local cDescri	:= ""

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= STR0037//"Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= STR0038//"Em separacao"
ElseIf cStatus == "2"
	cDescri:= STR0039//"Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= STR0040//"Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= STR0041//"Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= STR0042//"Nota gerada"
ElseIf cStatus == "6"
	cDescri:= STR0043//"Nota impressa"
ElseIf cStatus == "7"
	cDescri:= STR0044//"Volume impresso"
ElseIf cStatus == "8"
	cDescri:= STR0045//"Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:= STR0046//"Finalizado"
EndIf

Return(cDescri)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | A100AglPd  ³ Autor ³ Materiais             ³ Data ³ 08/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna String com os Pedidos de Venda aglutinados na OS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A100AglPd(cOrdSep)

Local cAliasPV	:= GetNextAlias()
Local cQuery		:= ""
Local cPedidos	:= ""
Local aArea		:= GetArea()

cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE C9_ORDSEP = '"+cOrdSep+"' AND "
cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND D_E_L_E_T_ = '' ORDER BY C9_PEDIDO"

cQuery := ChangeQuery(cQuery)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPV,.T.,.T.)

While !(cAliasPV)->(EOF())
	cPedidos += (cAliasPV)->C9_PEDIDO+"/"
	(cAliasPV)->(dbSkip())
EndDo

(cAliasPV)->(dbCloseArea())
RestArea(aArea)

If Len(cPedidos) > 119
	cPedidos := SubStr(cPedidos,1,119)+"..."
EndIf

Return cPedidos
