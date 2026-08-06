#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "ap5mail.ch"
#INCLUDE "TOTVS.CH"

#define PAD_LEFT          0
#define PAD_RIGHT         1
#define PAD_CENTE         2


#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030

/*
   Programa  ³ NLESPNF ³ Autor ³ Sandro Delfino                       ³ Data ³ 03/12/22 ³±±
   Descricao ³ Impressao da Danfe antes do envio  (MODO GRAFICO)                         ³±±
Impressão de danfe sem autorizacao 
U_NLESPNF()
*/

USER FUNCTION NLESPNF()
LOCAL aArea      := GetArea()

Private oPrn
Private cTitulo		  	:= "Impressão Espelho NF"
Private Wnrel		  	:= "FATVCIRC"
Private cDesc1  	  	:= "Emite " + cTitulo
Private cDesc2  	  	:= ""
Private cDesc3  	  	:= ""
Private nNroTotLin 		:= 80
Private nValores   		:= 0
Private nEnvMail   		:= 0
Private cNomArq    		:= ""
PRIVATE cPerg 			:= "RELNF"
Private cLogo      		:= "/system/logo.bmp"//Alltrim(SuperGetMV("MV_X_LOGPV",,"")) 

//_pergsx1()
Pergunte(cPerg,.T.)
cNomArq := "NF_" + Alltrim(SF2->F2_DOC) + ".pdf"

oPrn   := FWMSPrinter():New(cNomArq, IMP_SPOOL, .F.,, .T.)
oPrn:SetResolution(78) //Tamanho estipulado para a Danfe
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(60,60,60,60)
oPrn:nDevice := IMP_PDF
// ----------------------------------------------
// Define para salvar o PDF
// ----------------------------------------------
oPrn:cPathPDF := GETTEMPPATH() 

RptStatus({|| RunReport(cTitulo) },cTitulo)

oPrn:Preview()//Visualiza antes de imprimir
 
PswOrder(1)
PswSeek(__CUSERID,.T.)
aUsuario  := PSWRET(1) 
cMailUser := aUsuario[1][14]
cMailRem := cMailUser  

cAssunto  := "FATURA DE VENDAS Nº " + SC5->C5_NUM
cMensagem := ""
cAnexos   := ""         

//            MailTo    Cc Bcc                                        From          MostraTela	

FreeObj(oPrn)
oPrn := Nil

RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunReport ºAutor  ³Microsiga           º Data ³  08/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de impressao                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(cTitulo)   
LOCAL aArea    := GetArea()
Local nTotOrc  := 0
Local nTotIpi  := 0
Local nTotIcm  := 0, nTotIcmR := 0

Local nX	   := 0	
Local nY	   := 0
Private nLinI      := 000
Private nCol       := 000
Private nSalto     := 010
Private nSaltoSay  := 008
	PRIVATE oFont10N   := TFontEx():New(oPrn,"Times New Roman",08,08,.T.,.T.,.F.)// 1
	PRIVATE oFont07N   := TFontEx():New(oPrn,"Times New Roman",06,06,.T.,.T.,.F.)// 2
	PRIVATE oFont07    := TFontEx():New(oPrn,"Times New Roman",06,06,.F.,.T.,.F.)// 3
	PRIVATE oFont08    := TFontEx():New(oPrn,"Times New Roman",07,07,.F.,.T.,.F.)// 4
	PRIVATE oFont08N   := TFontEx():New(oPrn,"Times New Roman",06,06,.T.,.T.,.F.)// 5
	PRIVATE oFont09N   := TFontEx():New(oPrn,"Times New Roman",08,08,.T.,.T.,.F.)// 6
	PRIVATE oFont09    := TFontEx():New(oPrn,"Times New Roman",08,08,.F.,.T.,.F.)// 7
	PRIVATE oFont10    := TFontEx():New(oPrn,"Times New Roman",09,09,.F.,.T.,.F.)// 8
	PRIVATE oFont11    := TFontEx():New(oPrn,"Times New Roman",10,10,.F.,.T.,.F.)// 9
	PRIVATE oFont12    := TFontEx():New(oPrn,"Times New Roman",11,11,.F.,.T.,.F.)// 10
	PRIVATE oFont11N   := TFontEx():New(oPrn,"Times New Roman",10,10,.T.,.T.,.F.)// 11
	PRIVATE oFont18N   := TFontEx():New(oPrn,"Times New Roman",17,17,.T.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(oPrn,"Times New Roman",11,11,.T.,.T.,.F.)// 12
Private oBrush     := TBrush():New( , RGB( 200, 200, 200 ) )  // Cinza

Private m_pag      := 0

Private PixelX := oPrn:nLogPixelX()
Private PixelY := oPrn:nLogPixelY()
Private nLinMax := 800  // 3168 / 10 = 316 linhas
Private nColMax := 600  // 2400 / 4  = 600 colunas

Private	nQbrLin := 26

//InicPage()
nHPage := oPrn:nHorzRes() //2400
nHPage *= (300/PixelX)
nHPage -= HMARGEM  //2370
nVPage := oPrn:nVertRes() //3168
nVPage *= (300/PixelY)
nVPage -= VBOX  //3088

	cSql := "SELECT * 
	cSql += " FROM " 
    cSql += RetSqlName("SF2")+" SF2, " 
    cSql += RetSqlName("SD2")+" SD2 "     
    //cSql += RetSqlName("SA2")+" SA2 " 
	cSql += " WHERE SF2.D_E_L_E_T_ <> '*' 
	cSql += " AND SD2.D_E_L_E_T_ <> '*'"
 	cSql += " AND SF2.F2_DOC = SD2.D2_DOC"
	cSql += " AND SF2.F2_SERIE = SD2.D2_SERIE"    
	cSql += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
 	cSql += " AND SF2.F2_DOC ='" + MV_PAR01 + "'"
	//cSql += " AND SC7.C7_FORNECE = SA2.A2_COD "
	//MemoWrite('D:\Totvs\cSql.txt',cSql)
	/*cSql += " WHERE SF2.D_E_L_E_T_ <> '*' 
	cSql += " AND SD2.D_E_L_E_T_ <> '*'"
 	cSql += " AND SF2.F2_DOC = SD2.D2_DOC"*/
	cSql := ChangeQuery(cSql)
 TCQUERY cSql NEW ALIAS "TMP"
TMP->(dbGoTop())
_contar := 0
	while !tmp->(eof())
		_contar := _contar + 1
		TMP->(dbSkip())       
	End
TMP->(dbGoTop())
If _contar <= 40
		_folha := 1
	Else 
		_folha := int(_contar/40)
EndIf 

nPDesCab := ""
nValTot := 0
 If Eof()
  MsgStop("Nenhum registro foi encontrado!")
  TMP->(DbCloseArea())
  Return()
 EndIf
 
 TMP->(dbgotop())
 InicPage()




  	nTotIpi  := 0
  	nTotIcm  := 0
  	nTotIcmR := 0 
  	nTotOrc  := 0

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	If TMP->F2_TIPO = "B"
  			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA2") + _Infcli[5]  , "YA_DESCR")
 		Else 
  			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA1") + _Infcli[5]  , "YA_DESCR")
  	EndIf 

  	cLogo    := GetSrvProfString("Startpath","") + "DANFE0100.BMP"
  	_cond    := Alltrim(posicione("SE4",1, xfilial("SE4") + TMP->F2_COND  , "E4_DESCRI"))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Box - Recibo de entrega                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(000,000,010,501)
	oprn:Say(006, 002, "RECEBEMOS DE "+ _Infcli[01] +" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
	oprn:Box(009,000,037,101)
	oprn:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
	oprn:Box(009,100,037,500)
	oprn:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
	oprn:Box(000,500,037,603)
	oprn:Say(007, 542, "NF-e", oFont08N:oFont)
	oprn:Say(017, 510, "N. "+MV_PAR01, oFont08:oFont)
	oprn:Say(027, 510, "SÉRIE "+TMP->F2_SERIE, oFont08:oFont)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(042,000,137,250)
	oprn:Say(052,096, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	065
	cStrAux		:=	AllTrim(SM0->M0_NOMECOM)
	nForTo		:=	Len(cStrAux)/24
	nForTo		:=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1,Round(nForTo,0))
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*24)+1),24), oFont12N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	AllTrim(SM0->M0_ENDENT)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX

		cStrAux		:=	"Complemento: "+AllTrim(SM0->M0_COMPENT)
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(SM0->M0_BAIRENT)
		cStrAux		+=	" Cep:"+TransForm(SM0->M0_CEPENT,"@r 99999-999")
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oprn:Say(nLinCalc,096, SM0->M0_CIDENT+"/"+SM0->M0_ESTENT,oFont08N:oFont)
		nLinCalc+=9
		oprn:Say(nLinCalc,096, "Fone: "+SM0->M0_TEL,oFont08N:oFont)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 2                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFolha := 1
	oprn:Box(042,248,137,351)
	oprn:Say(055,275, "DANFE",oFont18N:oFont)
	oprn:Say(055,375, "SEM VALOR FISCAL",oFont18N:oFont)
	oprn:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oprn:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oprn:Say(085,266, "0-ENTRADA",oFont08:oFont)
	oprn:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
	oprn:Box(078,315,095,325)
	oprn:Say(089,318, "1",oFont08N:oFont)
	oprn:Say(110,255,"N. "+TMP->F2_DOC,oFont10N:oFont)
	oprn:Say(120,255,"SÉRIE "+TMP->F2_SERIE,oFont10N:oFont)
	oprn:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolha,2),oFont10N:oFont)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)

	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

 			cLogo := GetSrvProfString("Startpath","") + "lgmid.png"//"LGMID" + cDescLogo + ".BMP"
			oprn:SayBitmap(045,003,cLogo,090,090)



		RestArea(aArea)
	cCtaTES := Posicione("SF4",1,xFilial("SF4")+TMP->D2_TES,"F4_TEXTO")
	//Quadro 4
	oprn:Box(139,000,162,603)
	oprn:Box(139,000,162,350)
	oprn:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oprn:Say(158,002,cCtaTES,oFont08:oFont)

	nFolha++

	//Quadro 5
	oprn:Box(164,000,187,603)
	oprn:Box(164,000,187,200)
	oprn:Box(164,200,187,400)
	oprn:Box(164,400,187,603)
	oprn:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(180,002,SM0->M0_INSC,oFont08:oFont)
	oprn:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oprn:Say(180,205,"",oFont08:oFont)
	oprn:Say(172,405,"CNPJ/CPF",oFont08N:oFont)
	cAux := TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99")


	oprn:Say(180,405,cAux,oFont08:oFont)
	//Quadro destinatário/remetente
	If TMP->F2_TIPO = "B"
			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS","A2_CGC","A2_CEP","A2_TEL","A2_EST","A2_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
		Else 
			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS","A1_CGC","A1_CEP","A1_TEL","A1_EST","A1_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
	EndIf 	
	oprn:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oprn:Box(197,000,217,450)
	oprn:Say(205,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(215,002,_Infcli[1],oFont08:oFont)
	oprn:Box(197,280,217,500)
	oprn:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(215,283,_Infcli[6],oFont08:oFont)

	oprn:Box(217,000,237,500)
	oprn:Box(217,000,237,260)
	oprn:Say(224,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(234,002,_Infcli[2],oFont08:oFont)
	oprn:Box(217,230,237,380)
	oprn:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oprn:Say(234,232,_Infcli[3],oFont08:oFont)
	oprn:Box(217,380,237,500)
	oprn:Say(224,382,"CEP",oFont08N:oFont)
	oprn:Say(234,382,_Infcli[7],oFont08:oFont)

	oprn:Box(236,000,257,500)
	oprn:Box(236,000,257,180)
	oprn:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(255,002,_Infcli[4],oFont08:oFont)
	oprn:Box(236,150,257,256)
	oprn:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oprn:Say(255,152,_Infcli[8],oFont08:oFont)
	oprn:Box(236,255,257,341)
	oprn:Say(245,257,"UF",oFont08N:oFont)
	oprn:Say(255,257,_Infcli[9],oFont08:oFont)
	oprn:Box(236,340,257,500)
	oprn:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(255,342,_Infcli[10],oFont08:oFont)

	oprn:Box(197,502,217,603)
	oprn:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
	_dtemis	:= SubStr(TMP->F2_EMISSAO,7,2) + "/" + SubStr(TMP->F2_EMISSAO,5,2) + "/" + SubStr(TMP->F2_EMISSAO,1,4)
	oprn:Say(215,504,_dtemis,oFont08:oFont)
	oprn:Box(217,502,237,603)
	oprn:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)

	oprn:Say(233,504,_dtemis,oFont08:oFont)
	oprn:Box(236,502,257,603)
	oprn:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
	oprn:Say(252,503,TMP->F2_HORA,oFont08:oFont)

	//Busco as faturas da NF
		cSql := "SELECT * 
		cSql += " FROM " 
		cSql += RetSqlName("SE1")+" SE1 " 
		cSql += " WHERE SE1.D_E_L_E_T_ <> '*' 
		cSql += " AND SE1.E1_NUM = '"+MV_PAR01+"'"
		cSql += " AND SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
		//cSql += " AND SC7.C7_FORNECE = SA2.A2_COD "
		//MemoWrite('D:\Totvs\cSql.txt',cSql)
		_parc 	:= {}
		_data 	:= {}
		_valor 	:= {}
		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "TMP2"
		while !TMP2->(eof())
			aadd(_parc,TMP2->E1_PARCELA)
			aadd(_data,TMP2->E1_VENCREA)
			aadd(_valor,TMP2->E1_VALOR)
			TMP2->(dbSkip())       
		End
		TMP2->(DbCloseArea())

	//Quadro fatura


	nAjustaFat := 0
	oprn:Say(263+nAjustaFat,002,"FATURA",oFont08N:oFont)
	oprn:Box(265+nAjustaFat,000,296+nAjustaFat,068)
	oprn:Box(265+nAjustaFat,067,296+nAjustaFat,134)
	oprn:Box(265+nAjustaFat,134,296+nAjustaFat,202)
	oprn:Box(265+nAjustaFat,201,296+nAjustaFat,268)
	oprn:Box(265+nAjustaFat,268,296+nAjustaFat,335)
	oprn:Box(265+nAjustaFat,335,296+nAjustaFat,403)
	oprn:Box(265+nAjustaFat,402,296+nAjustaFat,469)
	oprn:Box(265+nAjustaFat,469,296+nAjustaFat,537)
	oprn:Box(265+nAjustaFat,536,296+nAjustaFat,603)

	nColuna := 002
	If Len(_parc) >0
		For nY := 1 To LEN(_parc)
			_datac := substr(_data[nY],7,2)+"/"+substr(_data[nY],5,2)+"/"+substr(_data[nY],1,4) 
			oprn:Say(273+nAjustaFat,nColuna,_parc[nY],oFont08:oFont)
			oprn:Say(281+nAjustaFat,nColuna,_datac,oFont08:oFont)
			oprn:Say(289+nAjustaFat,nColuna,Transform(_valor[nY],"@e 999,999.99"),oFont08:oFont)
			nColuna:= nColuna+67
		Next nY
	Endif
 	
	nAjustImp  := 1
	//Calculo do imposto
	oprn:Say(305+nAjustImp,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oprn:Box(307+nAjustImp,000,330+nAjustImp,121)
	oprn:Say(316+nAjustImp,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,002,Transform(TMP->F2_BASEICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,120,330+nAjustImp,200)
	oprn:Say(316+nAjustImp,125,"VALOR DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,125,Transform(TMP->F2_VALICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,199,330+nAjustImp,360)
	oprn:Say(316+nAjustImp,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,202,Transform(TMP->F2_BASIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,360,330+nAjustImp,490)
	oprn:Say(316+nAjustImp,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,363,Transform(TMP->F2_VALIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,490,330+nAjustImp,603)
	oprn:Say(316+nAjustImp,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	oprn:Say(327+nAjustImp,491,Transform(TMP->F2_VALMERC,"@e 9,999,999.99"),oFont08:oFont)
	
	oprn:Box(330+nAjustImp,000,353+nAjustImp,110)
	oprn:Say(339+nAjustImp,002,"VALOR DO FRETE",oFont08N:oFont)
	oprn:Say(349+nAjustImp,002,Transform(TMP->F2_FRETE,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,100,353+nAjustImp,190)
	oprn:Say(339+nAjustImp,102,"VALOR DO SEGURO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,102,Transform(TMP->F2_SEGURO,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,190,353+nAjustImp,290)
	oprn:Say(339+nAjustImp,194,"DESCONTO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,194,Transform(TMP->F2_DESCONT,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,290,353+nAjustImp,415)
	oprn:Say(339+nAjustImp,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
	oprn:Say(349+nAjustImp,295,Transform(TMP->F2_DESPESA,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,414,353+nAjustImp,500)
	oprn:Say(339+nAjustImp,420,"VALOR DO IPI",oFont08N:oFont)
	oprn:Say(349+nAjustImp,420,Transform(TMP->F2_VALIPI,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,500,353+nAjustImp,603)
	oprn:Say(339+nAjustImp,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	oprn:Say(349+nAjustImp,506,Transform(TMP->F2_VALBRUT,"@e 9,999,999.99"),oFont08:oFont)

			nAjustaVt  := 1
	//Transportador/Volumes transportados
	_transp := GetAdvFVal( "SA4",{ "A4_NOME","A4_ANTT","A4_EST","A4_CGC","A4_END","A4_MUN","A4_EST","A4_INSEST" } , FwxFilial("SA4") +TMP->F2_TRANSP, 1, Array(05))

	oprn:Say(361+nAjustaVt,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oprn:Box(363+nAjustaVt,000,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,002,"RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,002,_transp[01],oFont08:oFont)
	oprn:Box(363+nAjustaVt,243,386+nAjustaVt,315)
	oprn:Say(372+nAjustaVt,245,"FRETE POR CONTA",oFont08N:oFont)
	If TMP->F2_TPFRETE =="C"
		oprn:Say(382+nAjustaVt,245,"C-CIF",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="F"
		oprn:Say(382+nAjustaVt,245,"F-FOB",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="T"
		oprn:Say(382+nAjustaVt,245,"T-POR CONTA TERCEIROS",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="R"
		oprn:Say(382+nAjustaVt,245,"R-POR CONTA REMETENTE",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="D"
		oprn:Say(382+nAjustaVt,245,"D-POR CONTA DESTINATARIO",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="S"
		oprn:Say(382+nAjustaVt,245,"S-SEM FRETE",oFont08:oFont)
	Else
		oprn:Say(382+nAjustaVt,245,"",oFont08:oFont)
	Endif
	//oprn:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
	oprn:Box(363+nAjustaVt,315,386+nAjustaVt,370)
	oprn:Say(372+nAjustaVt,317,"CÓDIGO ANTT",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,319,_transp[02],oFont08:oFont)
	oprn:Box(363+nAjustaVt,370,386+nAjustaVt,490)
	oprn:Say(372+nAjustaVt,375,"PLACA DO VEÍCULO",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,375,TMP->F2_VEICUL1,oFont08:oFont)
	oprn:Box(363+nAjustaVt,450,386+nAjustaVt,510)
	oprn:Say(372+nAjustaVt,452,"UF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,452,_transp[03],oFont08:oFont)
	oprn:Box(363+nAjustaVt,510,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,512,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,512,_transp[04],oFont08:oFont)

	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,603)
	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,241)
	oprn:Say(393+nAjustaVt,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,002,_transp[05],oFont08:oFont)
	oprn:Box(385+nAjustaVt,240,409+nAjustaVt,341)
	oprn:Say(393+nAjustaVt,242,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,242,_transp[06],oFont08:oFont)
	oprn:Box(385+nAjustaVt,340,409+nAjustaVt,440)
	oprn:Say(393+nAjustaVt,342,"UF",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,342,_transp[07],oFont08:oFont)
	oprn:Box(385+nAjustaVt,440,409+nAjustaVt,603)
	oprn:Say(393+nAjustaVt,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,442,_transp[08],oFont08:oFont)

	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,603)
	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,101)
	oprn:Say(418+nAjustaVt,002,"QUANTIDADE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,002,Transform(TMP->F2_VOLUME1,"@e 99.99"),oFont08:oFont)
	oprn:Box(408+nAjustaVt,59,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,61,"ESPECIE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,61,TMP->F2_ESPECI1,oFont08:oFont)
	//oprn:Say(428,102,aEspVol[1][1],oFont08:oFont)
	oprn:Box(408+nAjustaVt,285,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,287,"MARCA",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,287,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,385,432+nAjustaVt,385)
	oprn:Say(418+nAjustaVt,387,"NUMERAÇÃO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,387,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,485,432+nAjustaVt,485)
	oprn:Say(418+nAjustaVt,487,"PESO BRUTO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,487,Transform(TMP->F2_PBRUTO,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
	oprn:Box(408+nAjustaVt,544,432+nAjustaVt,603)
	oprn:Say(418+nAjustaVt,546,"PESO LIQUIDO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,546,Transform(TMP->F2_PLIQUI,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

	//Calculo do ISSQN
	oprn:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oprn:Box(688,000,711,151)
	oprn:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
	oprn:Say(706,002,"",oFont08:oFont)
	oprn:Box(688,150,711,301)
	oprn:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
	oprn:Say(706,152,"",oFont08:oFont)
	oprn:Box(688,300,711,451)
	oprn:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
	oprn:Say(706,302,"",oFont08:oFont)
	oprn:Box(688,450,711,603)
	oprn:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oprn:Say(706,452,"",oFont08:oFont)
	
	//Dados Adicionais
	oprn:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oprn:Box(721,000,865,351)
	oprn:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	aMensagem := TMP->F2_MENNOTA
	nLenMensagens:= Len(aMensagem)
	nLin:= 741
	nMensagem := 0
	oprn:Say( nLin, 002, SUBSTR(aMensagem,1,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,71,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,141,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,212,38), oFont08N:oFont )
	nLin:= nLin+10

	oprn:Box(721,350,865,603)
	oprn:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

	//Logotipo Rodape
	/*if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oprn:SayBitmap(866,484,cLogoTotvs,120,20)
	endif*/

	//Dados do produto ou servico
	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0


	// Retorna o tamanho das colunas baseado em seu conteudo
	//aTamCol := RetTamCol(aAuxCabec, aAux, oprn, oFont08:oFont, oFont08N:oFont)
	nAjustaPro := 1
	oprn:Say(440+nAjustaPro,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
	oprn:Box(442+nAjustaPro,000,678,603)
	nAuxH := 0
	//Desenha os box dos itens
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//"COD. PROD"
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 100)//"DESCRIÇÃO DO PROD./SERV."
	nAuxH += 100
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 38)//"NCM/SH"
	nAuxH += 38
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//"CST"
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//CFOP
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//UN
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 25)//QUANT
	nAuxH += 25
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.UNITARIO
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.TOTAL
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//BC.ICMS
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 60)//V.ICMS
	nAuxH += 60
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 35)//V.IPI
	nAuxH += 35
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 40)//A.ICMS
	nAuxH += 40
	//oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 15 )
	nAuxH := 0	
	oprn:Say(450+nAjustaPro, nAuxH + 2, "COD. PROD",oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 52, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 152, "NCM/SH", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 190, "CST", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 210, "CFOP", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 230, "UN", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 250, "QUANT.", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 280, "V.UNITARIO", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 340, "V.TOTAL", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 390, "BC.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 435, "V.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 495, "V.IPI", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 535, "A.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 565, "A.IPI", oFont08N:oFont)
		TMP->(dbGoTop())
		_contit	:= 0
		nLinha := 1
		nAjustaPro := nAjustaPro + 10
		nAuxH := 0
		while !tmp->(eof())

			_contit := _contit + 1
			If _contit <= 40
				oprn:Say(450+nAjustaPro, nAuxH +2, alltrim(tmp->d2_cod),oFont08N:oFont)
				nAuxH += 25
				_infpro	:= GetAdvFVal("SB1",{"B1_DESC","B1_POSIPI"},XFilial("SB1")+alltrim(tmp->d2_cod),1,Array(02))			
				oprn:Say(450+nAjustaPro, nAuxH + 27, substr(_infpro[01],1,30), oFont07:oFont)
				nAuxH += 120
				oprn:Say(450+nAjustaPro, nAuxH + 7, _infpro[02], oFont08N:oFont)
				nAuxH += 25
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CLASFIS, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CF, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_UM, oFont08N:oFont)
				nAuxH += 20
				
				oprn:Say(450+nAjustaPro, nAuxH + 20, Transform(TMP->D2_QUANT,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 23
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_PRCVEN,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 40
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_TOTAL,"@e 9,999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 45, Transform(TMP->D2_BASEICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 45
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALIPI,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50,Transform(TMP->D2_PICM,"@e 99.99") + " %", oFont08N:oFont)
				nAuxH += 35
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_IPI,"@e 99.99") + " %", oFont08N:oFont)
				nAjustaPro := nAjustaPro + 5
				//	nLin:= nLin+10
				nAuxH := 0	
				nLinha := 1
			EndIf			
			TMP->(dbSkip())       
		End
		If _folha = 1
			TMP->(DbCloseArea())
		EndIf 
		nLinha :=nLinha + 10
If _folha > 1
 TMP->(dbgotop())
 InicPage()




  	nTotIpi  := 0
  	nTotIcm  := 0
  	nTotIcmR := 0 
  	nTotOrc  := 0

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	If TMP->F2_TIPO = "B"
  			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA2") + _Infcli[5]  , "YA_DESCR")
 		Else 
  			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA1") + _Infcli[5]  , "YA_DESCR")
  	EndIf 
  	cLogo    := GetSrvProfString("Startpath","") + "DANFE0100.BMP"
  	_cond    := Alltrim(posicione("SE4",1, xfilial("SE4") + TMP->F2_COND  , "E4_DESCRI"))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Box - Recibo de entrega                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(000,000,010,501)
	oprn:Say(006, 002, "RECEBEMOS DE "+ _Infcli[01] +" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
	oprn:Box(009,000,037,101)
	oprn:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
	oprn:Box(009,100,037,500)
	oprn:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
	oprn:Box(000,500,037,603)
	oprn:Say(007, 542, "NF-e", oFont08N:oFont)
	oprn:Say(017, 510, "N. "+MV_PAR01, oFont08:oFont)
	oprn:Say(027, 510, "SÉRIE "+TMP->F2_SERIE, oFont08:oFont)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(042,000,137,250)
	oprn:Say(052,096, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	065
	cStrAux		:=	AllTrim(SM0->M0_NOMECOM)
	nForTo		:=	Len(cStrAux)/24
	nForTo		:=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1,Round(nForTo,0))
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*24)+1),24), oFont12N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	AllTrim(SM0->M0_ENDENT)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX

		cStrAux		:=	"Complemento: "+AllTrim(SM0->M0_COMPENT)
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(SM0->M0_BAIRENT)
		cStrAux		+=	" Cep:"+TransForm(SM0->M0_CEPENT,"@r 99999-999")
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oprn:Say(nLinCalc,096, SM0->M0_CIDENT+"/"+SM0->M0_ESTENT,oFont08N:oFont)
		nLinCalc+=9
		oprn:Say(nLinCalc,096, "Fone: "+SM0->M0_TEL,oFont08N:oFont)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 2                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFolha := 1
	oprn:Box(042,248,137,351)
	oprn:Say(055,275, "DANFE",oFont18N:oFont)
	oprn:Say(055,475, "SEM VALOR FISCAL",oFont18N:oFont)	
	oprn:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oprn:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oprn:Say(085,266, "0-ENTRADA",oFont08:oFont)
	oprn:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
	oprn:Box(078,315,095,325)
	oprn:Say(089,318, "1",oFont08N:oFont)
	oprn:Say(110,255,"N. "+TMP->F2_DOC,oFont10N:oFont)
	oprn:Say(120,255,"SÉRIE "+TMP->F2_SERIE,oFont10N:oFont)
	oprn:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolha,2),oFont10N:oFont)
	//oprn:Say(130,355," SEM VALOR FISCAL ",oFont12N:oFont)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)

	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

 			cLogo := GetSrvProfString("Startpath","") + "lgmid.png"//"LGMID" + cDescLogo + ".BMP"
			oprn:SayBitmap(045,003,cLogo,090,090)



		RestArea(aArea)
	cCtaTES := Posicione("SF4",1,xFilial("SF4")+TMP->D2_TES,"F4_TEXTO")
	//Quadro 4
	oprn:Box(139,000,162,603)
	oprn:Box(139,000,162,350)
	oprn:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oprn:Say(158,002,cCtaTES,oFont08:oFont)

	nFolha++

	//Quadro 5
	oprn:Box(164,000,187,603)
	oprn:Box(164,000,187,200)
	oprn:Box(164,200,187,400)
	oprn:Box(164,400,187,603)
	oprn:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(180,002,SM0->M0_INSC,oFont08:oFont)
	oprn:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oprn:Say(180,205,"",oFont08:oFont)
	oprn:Say(172,405,"CNPJ/CPF",oFont08N:oFont)
	cAux := TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99")


	oprn:Say(180,405,cAux,oFont08:oFont)
	//Quadro destinatário/remetente
	If TMP->F2_TIPO = "B"
			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS","A2_CGC","A2_CEP","A2_TEL","A2_EST","A2_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
		Else 
			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS","A1_CGC","A1_CEP","A1_TEL","A1_EST","A1_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
	EndIf 
	oprn:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oprn:Box(197,000,217,450)
	oprn:Say(205,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(215,002,_Infcli[1],oFont08:oFont)
	oprn:Box(197,280,217,500)
	oprn:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(215,283,_Infcli[6],oFont08:oFont)

	oprn:Box(217,000,237,500)
	oprn:Box(217,000,237,260)
	oprn:Say(224,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(234,002,_Infcli[2],oFont08:oFont)
	oprn:Box(217,230,237,380)
	oprn:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oprn:Say(234,232,_Infcli[3],oFont08:oFont)
	oprn:Box(217,380,237,500)
	oprn:Say(224,382,"CEP",oFont08N:oFont)
	oprn:Say(234,382,_Infcli[7],oFont08:oFont)

	oprn:Box(236,000,257,500)
	oprn:Box(236,000,257,180)
	oprn:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(255,002,_Infcli[4],oFont08:oFont)
	oprn:Box(236,150,257,256)
	oprn:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oprn:Say(255,152,_Infcli[8],oFont08:oFont)
	oprn:Box(236,255,257,341)
	oprn:Say(245,257,"UF",oFont08N:oFont)
	oprn:Say(255,257,_Infcli[9],oFont08:oFont)
	oprn:Box(236,340,257,500)
	oprn:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(255,342,_Infcli[10],oFont08:oFont)

	oprn:Box(197,502,217,603)
	oprn:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
	oprn:Say(215,504,TMP->F2_EMISSAO,oFont08:oFont)
	oprn:Box(217,502,237,603)
	oprn:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
	oprn:Say(233,504,TMP->F2_EMISSAO,oFont08:oFont)
	oprn:Box(236,502,257,603)
	oprn:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
	oprn:Say(252,503,TMP->F2_HORA,oFont08:oFont)

	//Busco as faturas da NF
		cSql := "SELECT * 
		cSql += " FROM " 
		cSql += RetSqlName("SE1")+" SE1 " 
		cSql += " WHERE SE1.D_E_L_E_T_ <> '*' 
		cSql += " AND SE1.E1_NUM = '"+MV_PAR01+"'"
		cSql += " AND SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
		//cSql += " AND SC7.C7_FORNECE = SA2.A2_COD "
		//MemoWrite('D:\Totvs\cSql.txt',cSql)
		_parc 	:= {}
		_data 	:= {}
		_valor 	:= {}
		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "TMP2"
		while !TMP2->(eof())
			aadd(_parc,TMP2->E1_PARCELA)
			aadd(_data,TMP2->E1_VENCREA)
			aadd(_valor,TMP2->E1_VALOR)
			TMP2->(dbSkip())       
		End
		TMP2->(DbCloseArea())

	//Quadro fatura


	nAjustaFat := 0
	oprn:Say(263+nAjustaFat,002,"FATURA",oFont08N:oFont)
	oprn:Box(265+nAjustaFat,000,296+nAjustaFat,068)
	oprn:Box(265+nAjustaFat,067,296+nAjustaFat,134)
	oprn:Box(265+nAjustaFat,134,296+nAjustaFat,202)
	oprn:Box(265+nAjustaFat,201,296+nAjustaFat,268)
	oprn:Box(265+nAjustaFat,268,296+nAjustaFat,335)
	oprn:Box(265+nAjustaFat,335,296+nAjustaFat,403)
	oprn:Box(265+nAjustaFat,402,296+nAjustaFat,469)
	oprn:Box(265+nAjustaFat,469,296+nAjustaFat,537)
	oprn:Box(265+nAjustaFat,536,296+nAjustaFat,603)

	nColuna := 002
	If Len(_parc) >0
		For nY := 1 To LEN(_parc)
			_data := substr(_parc[nY],7,2)+"/"+substr(_parc[nY],5,2)+"/"+substr(_parc[nY],1,4) 
			oprn:Say(273+nAjustaFat,nColuna,_data,oFont08:oFont)
			oprn:Say(281+nAjustaFat,nColuna,_data[nY],oFont08:oFont)
			oprn:Say(289+nAjustaFat,nColuna,Transform(_valor[nY],"@e 999,999.99"),oFont08:oFont)
			nColuna:= nColuna+67
		Next nY
	Endif
 	
	nAjustImp  := 80
	//Calculo do imposto
	oprn:Say(305+nAjustImp,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oprn:Box(307+nAjustImp,000,330+nAjustImp,121)
	oprn:Say(316+nAjustImp,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,002,Transform(TMP->F2_BASEICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,120,330+nAjustImp,200)
	oprn:Say(316+nAjustImp,125,"VALOR DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,125,Transform(TMP->F2_VALICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,199,330+nAjustImp,360)
	oprn:Say(316+nAjustImp,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,202,Transform(TMP->F2_BASIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,360,330+nAjustImp,490)
	oprn:Say(316+nAjustImp,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,363,Transform(TMP->F2_VALIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,490,330+nAjustImp,603)
	oprn:Say(316+nAjustImp,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	oprn:Say(327+nAjustImp,491,Transform(TMP->F2_VALMERC,"@e 999,999.99"),oFont08:oFont)
	
	oprn:Box(330+nAjustImp,000,353+nAjustImp,110)
	oprn:Say(339+nAjustImp,002,"VALOR DO FRETE",oFont08N:oFont)
	oprn:Say(349+nAjustImp,002,Transform(TMP->F2_FRETE,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,100,353+nAjustImp,190)
	oprn:Say(339+nAjustImp,102,"VALOR DO SEGURO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,102,Transform(TMP->F2_SEGURO,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,190,353+nAjustImp,290)
	oprn:Say(339+nAjustImp,194,"DESCONTO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,194,Transform(TMP->F2_DESCONT,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,290,353+nAjustImp,415)
	oprn:Say(339+nAjustImp,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
	oprn:Say(349+nAjustImp,295,Transform(TMP->F2_DESPESA,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,414,353+nAjustImp,500)
	oprn:Say(339+nAjustImp,420,"VALOR DO IPI",oFont08N:oFont)
	oprn:Say(349+nAjustImp,420,Transform(TMP->F2_VALIPI,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,500,353+nAjustImp,603)
	oprn:Say(339+nAjustImp,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	oprn:Say(349+nAjustImp,506,Transform(TMP->F2_VALBRUT,"@e 999,999.99"),oFont08:oFont)

			nAjustaVt  := 80

	//Transportador/Volumes transportados
	_transp := GetAdvFVal( "SA4",{ "A4_NOME","A4_ANTT","A4_EST","A4_CGC","A4_END","A4_MUN","A4_EST","A4_INSEST" } , FwxFilial("SA4") +TMP->F2_TRANSP, 1, Array(05))

	oprn:Say(361+nAjustaVt,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oprn:Box(363+nAjustaVt,000,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,002,"RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,002,_transp[01],oFont08:oFont)
	oprn:Box(363+nAjustaVt,243,386+nAjustaVt,315)
	oprn:Say(372+nAjustaVt,245,"FRETE POR CONTA",oFont08N:oFont)
	If TMP->F2_TPFRETE =="C"
		oprn:Say(382+nAjustaVt,245,"C-CIF",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="F"
		oprn:Say(382+nAjustaVt,245,"F-FOB",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="T"
		oprn:Say(382+nAjustaVt,245,"T-POR CONTA TERCEIROS",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="R"
		oprn:Say(382+nAjustaVt,245,"R-POR CONTA REMETENTE",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="D"
		oprn:Say(382+nAjustaVt,245,"D-POR CONTA DESTINATARIO",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="S"
		oprn:Say(382+nAjustaVt,245,"S-SEM FRETE",oFont08:oFont)
	Else
		oprn:Say(382+nAjustaVt,245,"",oFont08:oFont)
	Endif
	//oprn:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
	oprn:Box(363+nAjustaVt,315,386+nAjustaVt,370)
	oprn:Say(372+nAjustaVt,317,"CÓDIGO ANTT",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,319,_transp[02],oFont08:oFont)
	oprn:Box(363+nAjustaVt,370,386+nAjustaVt,490)
	oprn:Say(372+nAjustaVt,375,"PLACA DO VEÍCULO",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,375,TMP->F2_VEICUL1,oFont08:oFont)
	oprn:Box(363+nAjustaVt,450,386+nAjustaVt,510)
	oprn:Say(372+nAjustaVt,452,"UF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,452,_transp[03],oFont08:oFont)
	oprn:Box(363+nAjustaVt,510,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,512,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,512,_transp[04],oFont08:oFont)

	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,603)
	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,241)
	oprn:Say(393+nAjustaVt,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,002,_transp[05],oFont08:oFont)
	oprn:Box(385+nAjustaVt,240,409+nAjustaVt,341)
	oprn:Say(393+nAjustaVt,242,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,242,_transp[06],oFont08:oFont)
	oprn:Box(385+nAjustaVt,340,409+nAjustaVt,440)
	oprn:Say(393+nAjustaVt,342,"UF",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,342,_transp[07],oFont08:oFont)
	oprn:Box(385+nAjustaVt,440,409+nAjustaVt,603)
	oprn:Say(393+nAjustaVt,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,442,_transp[08],oFont08:oFont)

	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,603)
	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,101)
	oprn:Say(418+nAjustaVt,002,"QUANTIDADE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,002,Transform(TMP->F2_VOLUME1,"@e 99.99"),oFont08:oFont)
	oprn:Box(408+nAjustaVt,59,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,61,"ESPECIE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,61,TMP->F2_ESPECI1,oFont08:oFont)
	//oprn:Say(428,102,aEspVol[1][1],oFont08:oFont)
	oprn:Box(408+nAjustaVt,285,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,287,"MARCA",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,287,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,385,432+nAjustaVt,385)
	oprn:Say(418+nAjustaVt,387,"NUMERAÇÃO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,387,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,485,432+nAjustaVt,485)
	oprn:Say(418+nAjustaVt,487,"PESO BRUTO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,487,Transform(TMP->F2_PBRUTO,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
	oprn:Box(408+nAjustaVt,544,432+nAjustaVt,603)
	oprn:Say(418+nAjustaVt,546,"PESO LIQUIDO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,546,Transform(TMP->F2_PLIQUI,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

	//Calculo do ISSQN
	oprn:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oprn:Box(688,000,711,151)
	oprn:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
	oprn:Say(706,002,"",oFont08:oFont)
	oprn:Box(688,150,711,301)
	oprn:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
	oprn:Say(706,152,"",oFont08:oFont)
	oprn:Box(688,300,711,451)
	oprn:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
	oprn:Say(706,302,"",oFont08:oFont)
	oprn:Box(688,450,711,603)
	oprn:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oprn:Say(706,452,"",oFont08:oFont)
	
	//Dados Adicionais
	oprn:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oprn:Box(721,000,865,351)
	oprn:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	aMensagem := TMP->F2_MENNOTA
	nLenMensagens:= Len(aMensagem)
	nLin:= 741
	nMensagem := 0
	oprn:Say( nLin, 002, SUBSTR(aMensagem,1,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,71,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,141,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,212,38), oFont08N:oFont )
	nLin:= nLin+10

	oprn:Box(721,350,865,603)
	oprn:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

	//Logotipo Rodape
	/*if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oprn:SayBitmap(866,484,cLogoTotvs,120,20)
	endif*/

	//Dados do produto ou servico
	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0
	aAuxCabec := {}
	// Popula o array de cabeçalho das colunas de produtos/serviços.
	aAuxCabec := {;
		"COD. PROD",;
		"DESCRIÇÃO DO PROD./SERV.",;
		"NCM/SH",;
		"CST" ,;
		"CFOP",;
		"UN",;
		"QUANT.",;
		"V.UNITARIO",;
		"V.TOTAL",;
		"BC.ICMS",;
		"V.ICMS",;
		"V.IPI",;
		"A.ICMS",;
		"A.IPI";
	}

	// Retorna o tamanho das colunas baseado em seu conteudo
	//aTamCol := RetTamCol(aAuxCabec, aAux, oprn, oFont08:oFont, oFont08N:oFont)
	nAjustaPro := 80
	//Desenha os box dos itens
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//"COD. PROD"
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 100)//"DESCRIÇÃO DO PROD./SERV."
	nAuxH += 100
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 38)//"NCM/SH"
	nAuxH += 38
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//"CST"
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//CFOP
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//UN
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 25)//QUANT
	nAuxH += 25
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.UNITARIO
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.TOTAL
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//BC.ICMS
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 60)//V.ICMS
	nAuxH += 60
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 35)//V.IPI
	nAuxH += 35
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 40)//A.ICMS
	nAuxH += 40
	//oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 15 )
	nAuxH := 0	
	oprn:Say(450+nAjustaPro, nAuxH + 2, "COD. PROD",oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 52, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 152, "NCM/SH", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 190, "CST", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 210, "CFOP", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 230, "UN", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 250, "QUANT.", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 280, "V.UNITARIO", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 340, "V.TOTAL", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 390, "BC.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 435, "V.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 495, "V.IPI", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 535, "A.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 565, "A.IPI", oFont08N:oFont)
		TMP->(dbGoTop())
		_contit	:= 0
		nLinha := 1
		nAjustaPro := nAjustaPro + 10
		nAuxH := 0

		while !tmp->(eof())
			_contit := _contit + 1
			If _contit > 40 


				oprn:Say(450+nAjustaPro, nAuxH +2, alltrim(tmp->d2_cod),oFont08N:oFont)
				nAuxH += 25
				_infpro	:= GetAdvFVal("SB1",{"B1_DESC","B1_POSIPI"},XFilial("SB1")+alltrim(tmp->d2_cod),1,Array(02))			
				oprn:Say(450+nAjustaPro, nAuxH + 27, substr(_infpro[01],1,50), oFont08N:oFont)
				nAuxH += 120
				oprn:Say(450+nAjustaPro, nAuxH + 7, _infpro[02], oFont08N:oFont)
				nAuxH += 25
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CLASFIS, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CF, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_UM, oFont08N:oFont)
				nAuxH += 20
				
				oprn:Say(450+nAjustaPro, nAuxH + 20, Transform(TMP->D2_QUANT,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 23
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_PRCVEN,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 40
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_TOTAL,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 45, Transform(TMP->D2_BASEICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 45
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALIPI,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50,Transform(TMP->D2_PICM,"@e 99.99") + " %", oFont08N:oFont)
				nAuxH += 35
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_IPI,"@e 99.99") + " %", oFont08N:oFont)
				nAjustaPro := nAjustaPro + 5
				//	nLin:= nLin+10
				nAuxH := 0	
				nLinha := 1				
			EndIf 
			TMP->(dbSkip())       
		End
		TMP->(dbGoTop())
EndIf  
	If _folha = 2
	  TMP->(DbCloseArea())
	EndIf
If _folha = 3

 TMP->(dbgotop())
 InicPage()




  	nTotIpi  := 0
  	nTotIcm  := 0
  	nTotIcmR := 0 
  	nTotOrc  := 0

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	If TMP->F2_TIPO = "B"
  			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA2") + _Infcli[5]  , "YA_DESCR")
 		Else 
  			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(05))
			_pais    := posicione("SYA",1, xfilial("SA1") + _Infcli[5]  , "YA_DESCR")
  	EndIf 
  	cLogo    := GetSrvProfString("Startpath","") + "DANFE0100.BMP"
  	_cond    := Alltrim(posicione("SE4",1, xfilial("SE4") + TMP->F2_COND  , "E4_DESCRI"))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Box - Recibo de entrega                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(000,000,010,501)
	oprn:Say(006, 002, "RECEBEMOS DE "+ _Infcli[01] +" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
	oprn:Box(009,000,037,101)
	oprn:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
	oprn:Box(009,100,037,500)
	oprn:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
	oprn:Box(000,500,037,603)
	oprn:Say(007, 542, "NF-e", oFont08N:oFont)
	oprn:Say(017, 510, "N. "+MV_PAR01, oFont08:oFont)
	oprn:Say(027, 510, "SÉRIE "+TMP->F2_SERIE, oFont08:oFont)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oprn:Box(042,000,137,250)
	oprn:Say(052,096, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	065
	cStrAux		:=	AllTrim(SM0->M0_NOMECOM)
	nForTo		:=	Len(cStrAux)/24
	nForTo		:=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1,Round(nForTo,0))
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*24)+1),24), oFont12N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	AllTrim(SM0->M0_ENDENT)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX

		cStrAux		:=	"Complemento: "+AllTrim(SM0->M0_COMPENT)
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(SM0->M0_BAIRENT)
		cStrAux		+=	" Cep:"+TransForm(SM0->M0_CEPENT,"@r 99999-999")
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oprn:Say(nLinCalc,096,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oprn:Say(nLinCalc,096, SM0->M0_CIDENT+"/"+SM0->M0_ESTENT,oFont08N:oFont)
		nLinCalc+=9
		oprn:Say(nLinCalc,096, "Fone: "+SM0->M0_TEL,oFont08N:oFont)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 2                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFolha := 1
	oprn:Box(042,248,137,351)
	oprn:Say(055,275, "DANFE",oFont18N:oFont)
	oprn:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oprn:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oprn:Say(085,266, "0-ENTRADA",oFont08:oFont)
	oprn:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
	oprn:Box(078,315,095,325)
	oprn:Say(089,318, "1",oFont08N:oFont)
	oprn:Say(110,255,"N. "+TMP->F2_DOC,oFont10N:oFont)
	oprn:Say(120,255,"SÉRIE "+TMP->F2_SERIE,oFont10N:oFont)
	oprn:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolha,2),oFont10N:oFont)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())
	_dtformat	:= substr(TMP->F2_EMISSAO,7,2)+"/"+substr(TMP->F2_EMISSAO,5,2)+"/"+substr(TMP->F2_EMISSAO,1,4)

	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

 			cLogo := GetSrvProfString("Startpath","") + "lgmid.png"//"LGMID" + cDescLogo + ".BMP"
			oprn:SayBitmap(045,003,cLogo,090,090)



		RestArea(aArea)
	cCtaTES := Posicione("SF4",1,xFilial("SF4")+TMP->D2_TES,"F4_TEXTO")
	//Quadro 4
	oprn:Box(139,000,162,603)
	oprn:Box(139,000,162,350)
	oprn:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oprn:Say(158,002,cCtaTES,oFont08:oFont)

	nFolha++

	//Quadro 5
	oprn:Box(164,000,187,603)
	oprn:Box(164,000,187,200)
	oprn:Box(164,200,187,400)
	oprn:Box(164,400,187,603)
	oprn:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(180,002,SM0->M0_INSC,oFont08:oFont)
	oprn:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oprn:Say(180,205,"",oFont08:oFont)
	oprn:Say(172,405,"CNPJ/CPF",oFont08N:oFont)
	cAux := TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99")


	oprn:Say(180,405,cAux,oFont08:oFont)
	//Quadro destinatário/remetente
	If TMP->F2_TIPO = "B"
			_Infcli  := GetAdvFVal( "SA2",{ "A2_NOME","A2_END","A2_BAIRRO","A2_MUN","A2_PAIS","A2_CGC","A2_CEP","A2_TEL","A2_EST","A2_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
		Else 
			_Infcli  := GetAdvFVal( "SA1",{ "A1_NOME","A1_END","A1_BAIRRO","A1_MUN","A1_PAIS","A1_CGC","A1_CEP","A1_TEL","A1_EST","A1_INSCR" } , FwxFilial("SA1") +TMP->F2_CLIENTE, 1, Array(10))
	EndIf 
	oprn:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oprn:Box(197,000,217,450)
	oprn:Say(205,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(215,002,_Infcli[1],oFont08:oFont)
	oprn:Box(197,280,217,500)
	oprn:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(215,283,_Infcli[6],oFont08:oFont)

	oprn:Box(217,000,237,500)
	oprn:Box(217,000,237,260)
	oprn:Say(224,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(234,002,_Infcli[2],oFont08:oFont)
	oprn:Box(217,230,237,380)
	oprn:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oprn:Say(234,232,_Infcli[3],oFont08:oFont)
	oprn:Box(217,380,237,500)
	oprn:Say(224,382,"CEP",oFont08N:oFont)
	oprn:Say(234,382,_Infcli[7],oFont08:oFont)

	oprn:Box(236,000,257,500)
	oprn:Box(236,000,257,180)
	oprn:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(255,002,_Infcli[4],oFont08:oFont)
	oprn:Box(236,150,257,256)
	oprn:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oprn:Say(255,152,_Infcli[8],oFont08:oFont)
	oprn:Box(236,255,257,341)
	oprn:Say(245,257,"UF",oFont08N:oFont)
	oprn:Say(255,257,_Infcli[9],oFont08:oFont)
	oprn:Box(236,340,257,500)
	oprn:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(255,342,_Infcli[10],oFont08:oFont)

	oprn:Box(197,502,217,603)
	oprn:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
	oprn:Say(215,504,TMP->F2_EMISSAO,oFont08:oFont)
	oprn:Box(217,502,237,603)
	oprn:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
	oprn:Say(233,504,TMP->F2_EMISSAO,oFont08:oFont)
	oprn:Box(236,502,257,603)
	oprn:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
	oprn:Say(252,503,TMP->F2_HORA,oFont08:oFont)

	//Busco as faturas da NF
		cSql := "SELECT * 
		cSql += " FROM " 
		cSql += RetSqlName("SE1")+" SE1 " 
		cSql += " WHERE SE1.D_E_L_E_T_ <> '*' 
		cSql += " AND SE1.E1_NUM = '"+MV_PAR01+"'"
		cSql += " AND SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
		//cSql += " AND SC7.C7_FORNECE = SA2.A2_COD "
		//MemoWrite('D:\Totvs\cSql.txt',cSql)
		_parc 	:= {}
		_data 	:= {}
		_valor 	:= {}
		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "TMP2"
		while !TMP2->(eof())
			aadd(_parc,TMP2->E1_PARCELA)
			aadd(_data,TMP2->E1_VENCREA)
			aadd(_valor,TMP2->E1_VALOR)
			TMP2->(dbSkip())       
		End
		TMP2->(DbCloseArea())

	//Quadro fatura


	nAjustaFat := 0
	oprn:Say(263+nAjustaFat,002,"FATURA",oFont08N:oFont)
	oprn:Box(265+nAjustaFat,000,296+nAjustaFat,068)
	oprn:Box(265+nAjustaFat,067,296+nAjustaFat,134)
	oprn:Box(265+nAjustaFat,134,296+nAjustaFat,202)
	oprn:Box(265+nAjustaFat,201,296+nAjustaFat,268)
	oprn:Box(265+nAjustaFat,268,296+nAjustaFat,335)
	oprn:Box(265+nAjustaFat,335,296+nAjustaFat,403)
	oprn:Box(265+nAjustaFat,402,296+nAjustaFat,469)
	oprn:Box(265+nAjustaFat,469,296+nAjustaFat,537)
	oprn:Box(265+nAjustaFat,536,296+nAjustaFat,603)

	nColuna := 002
	If Len(_parc) >0
		For nY := 1 To LEN(_parc)
			_data := substr(_parc[nY],7,2)+"/"+substr(_parc[nY],5,2)+"/"+substr(_parc[nY],1,4) 
			oprn:Say(273+nAjustaFat,nColuna,_data,oFont08:oFont)
			oprn:Say(281+nAjustaFat,nColuna,_data[nY],oFont08:oFont)
			oprn:Say(289+nAjustaFat,nColuna,Transform(_valor[nY],"@e 999,999.99"),oFont08:oFont)
			nColuna:= nColuna+67
		Next nY
	Endif
 	
	nAjustImp  := 80
	//Calculo do imposto
	oprn:Say(305+nAjustImp,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oprn:Box(307+nAjustImp,000,330+nAjustImp,121)
	oprn:Say(316+nAjustImp,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,002,Transform(TMP->F2_BASEICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,120,330+nAjustImp,200)
	oprn:Say(316+nAjustImp,125,"VALOR DO ICMS",oFont08N:oFont)
	oprn:Say(326+nAjustImp,125,Transform(TMP->F2_VALICM,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,199,330+nAjustImp,360)
	oprn:Say(316+nAjustImp,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,202,Transform(TMP->F2_BASIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,360,330+nAjustImp,490)
	oprn:Say(316+nAjustImp,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
	oprn:Say(326+nAjustImp,363,Transform(TMP->F2_VALIMP1,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(307+nAjustImp,490,330+nAjustImp,603)
	oprn:Say(316+nAjustImp,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	oprn:Say(327+nAjustImp,491,Transform(TMP->F2_VALMERC,"@e 999,999.99"),oFont08:oFont)
	
	oprn:Box(330+nAjustImp,000,353+nAjustImp,110)
	oprn:Say(339+nAjustImp,002,"VALOR DO FRETE",oFont08N:oFont)
	oprn:Say(349+nAjustImp,002,Transform(TMP->F2_FRETE,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,100,353+nAjustImp,190)
	oprn:Say(339+nAjustImp,102,"VALOR DO SEGURO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,102,Transform(TMP->F2_SEGURO,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,190,353+nAjustImp,290)
	oprn:Say(339+nAjustImp,194,"DESCONTO",oFont08N:oFont)
	oprn:Say(349+nAjustImp,194,Transform(TMP->F2_DESCONT,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,290,353+nAjustImp,415)
	oprn:Say(339+nAjustImp,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
	oprn:Say(349+nAjustImp,295,Transform(TMP->F2_DESPESA,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,414,353+nAjustImp,500)
	oprn:Say(339+nAjustImp,420,"VALOR DO IPI",oFont08N:oFont)
	oprn:Say(349+nAjustImp,420,Transform(TMP->F2_VALIPI,"@e 999,999.99"),oFont08:oFont)
	oprn:Box(330+nAjustImp,500,353+nAjustImp,603)
	oprn:Say(339+nAjustImp,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	oprn:Say(349+nAjustImp,506,Transform(TMP->F2_VALBRUT,"@e 999,999.99"),oFont08:oFont)

			nAjustaVt  := 80

	//Transportador/Volumes transportados
	_transp := GetAdvFVal( "SA4",{ "A4_NOME","A4_ANTT","A4_EST","A4_CGC","A4_END","A4_MUN","A4_EST","A4_INSEST" } , FwxFilial("SA4") +TMP->F2_TRANSP, 1, Array(05))

	oprn:Say(361+nAjustaVt,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oprn:Box(363+nAjustaVt,000,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,002,"RAZÃO SOCIAL",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,002,_transp[01],oFont08:oFont)
	oprn:Box(363+nAjustaVt,243,386+nAjustaVt,315)
	oprn:Say(372+nAjustaVt,245,"FRETE POR CONTA",oFont08N:oFont)
	If TMP->F2_TPFRETE =="C"
		oprn:Say(382+nAjustaVt,245,"C-CIF",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="F"
		oprn:Say(382+nAjustaVt,245,"F-FOB",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="T"
		oprn:Say(382+nAjustaVt,245,"T-POR CONTA TERCEIROS",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="R"
		oprn:Say(382+nAjustaVt,245,"R-POR CONTA REMETENTE",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="D"
		oprn:Say(382+nAjustaVt,245,"D-POR CONTA DESTINATARIO",oFont08:oFont)
	ElseIf TMP->F2_TPFRETE =="S"
		oprn:Say(382+nAjustaVt,245,"S-SEM FRETE",oFont08:oFont)
	Else
		oprn:Say(382+nAjustaVt,245,"",oFont08:oFont)
	Endif
	//oprn:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
	oprn:Box(363+nAjustaVt,315,386+nAjustaVt,370)
	oprn:Say(372+nAjustaVt,317,"CÓDIGO ANTT",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,319,_transp[02],oFont08:oFont)
	oprn:Box(363+nAjustaVt,370,386+nAjustaVt,490)
	oprn:Say(372+nAjustaVt,375,"PLACA DO VEÍCULO",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,375,TMP->F2_VEICUL1,oFont08:oFont)
	oprn:Box(363+nAjustaVt,450,386+nAjustaVt,510)
	oprn:Say(372+nAjustaVt,452,"UF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,452,_transp[03],oFont08:oFont)
	oprn:Box(363+nAjustaVt,510,386+nAjustaVt,603)
	oprn:Say(372+nAjustaVt,512,"CNPJ/CPF",oFont08N:oFont)
	oprn:Say(382+nAjustaVt,512,_transp[04],oFont08:oFont)

	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,603)
	oprn:Box(385+nAjustaVt,000,409+nAjustaVt,241)
	oprn:Say(393+nAjustaVt,002,"ENDEREÇO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,002,_transp[05],oFont08:oFont)
	oprn:Box(385+nAjustaVt,240,409+nAjustaVt,341)
	oprn:Say(393+nAjustaVt,242,"MUNICIPIO",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,242,_transp[06],oFont08:oFont)
	oprn:Box(385+nAjustaVt,340,409+nAjustaVt,440)
	oprn:Say(393+nAjustaVt,342,"UF",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,342,_transp[07],oFont08:oFont)
	oprn:Box(385+nAjustaVt,440,409+nAjustaVt,603)
	oprn:Say(393+nAjustaVt,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oprn:Say(404+nAjustaVt,442,_transp[08],oFont08:oFont)

	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,603)
	oprn:Box(408+nAjustaVt,000,432+nAjustaVt,101)
	oprn:Say(418+nAjustaVt,002,"QUANTIDADE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,002,Transform(TMP->F2_VOLUME1,"@e 99.99"),oFont08:oFont)
	oprn:Box(408+nAjustaVt,59,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,61,"ESPECIE",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,61,TMP->F2_ESPECI1,oFont08:oFont)
	//oprn:Say(428,102,aEspVol[1][1],oFont08:oFont)
	oprn:Box(408+nAjustaVt,285,432+nAjustaVt,285)
	oprn:Say(418+nAjustaVt,287,"MARCA",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,287,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,385,432+nAjustaVt,385)
	oprn:Say(418+nAjustaVt,387,"NUMERAÇÃO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,387,"",oFont08:oFont)
	oprn:Box(408+nAjustaVt,485,432+nAjustaVt,485)
	oprn:Say(418+nAjustaVt,487,"PESO BRUTO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,487,Transform(TMP->F2_PBRUTO,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
	oprn:Box(408+nAjustaVt,544,432+nAjustaVt,603)
	oprn:Say(418+nAjustaVt,546,"PESO LIQUIDO",oFont08N:oFont)
	oprn:Say(428+nAjustaVt,546,Transform(TMP->F2_PLIQUI,"@E 999999.9999"),oFont08:oFont)
	//oprn:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

	//Calculo do ISSQN
	oprn:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oprn:Box(688,000,711,151)
	oprn:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
	oprn:Say(706,002,"",oFont08:oFont)
	oprn:Box(688,150,711,301)
	oprn:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
	oprn:Say(706,152,"",oFont08:oFont)
	oprn:Box(688,300,711,451)
	oprn:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
	oprn:Say(706,302,"",oFont08:oFont)
	oprn:Box(688,450,711,603)
	oprn:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oprn:Say(706,452,"",oFont08:oFont)
	
	//Dados Adicionais
	oprn:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oprn:Box(721,000,865,351)
	oprn:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	aMensagem := TMP->F2_MENNOTA
	nLenMensagens:= Len(aMensagem)
	nLin:= 741
	nMensagem := 0
	oprn:Say( nLin, 002, SUBSTR(aMensagem,1,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,71,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,141,70), oFont08N:oFont )
	nLin:= nLin+10
	oprn:Say( nLin, 002, SUBSTR(aMensagem,212,38), oFont08N:oFont )
	nLin:= nLin+10

	oprn:Box(721,350,865,603)
	oprn:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

	//Logotipo Rodape
	/*if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oprn:SayBitmap(866,484,cLogoTotvs,120,20)
	endif*/

	//Dados do produto ou servico
	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0
	aAuxCabec := {}
	// Popula o array de cabeçalho das colunas de produtos/serviços.
	aAuxCabec := {;
		"COD. PROD",;
		"DESCRIÇÃO DO PROD./SERV.",;
		"NCM/SH",;
		"CST" ,;
		"CFOP",;
		"UN",;
		"QUANT.",;
		"V.UNITARIO",;
		"V.TOTAL",;
		"BC.ICMS",;
		"V.ICMS",;
		"V.IPI",;
		"A.ICMS",;
		"A.IPI";
	}

	// Retorna o tamanho das colunas baseado em seu conteudo
	//aTamCol := RetTamCol(aAuxCabec, aAux, oprn, oFont08:oFont, oFont08N:oFont)
	nAjustaPro := 80
		//Desenha os box dos itens
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//"COD. PROD"
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 100)//"DESCRIÇÃO DO PROD./SERV."
	nAuxH += 100
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 38)//"NCM/SH"
	nAuxH += 38
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//"CST"
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//CFOP
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 20)//UN
	nAuxH += 20
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 25)//QUANT
	nAuxH += 25
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.UNITARIO
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH +50)//V.TOTAL
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 50)//BC.ICMS
	nAuxH += 50
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 60)//V.ICMS
	nAuxH += 60
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 35)//V.IPI
	nAuxH += 35
	oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 40)//A.ICMS
	nAuxH += 40
	//oprn:Box(442+nAjustaPro, nAuxH, 678, nAuxH + 15 )
	nAuxH := 0	
	oprn:Say(450+nAjustaPro, nAuxH + 2, "COD. PROD",oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 52, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 152, "NCM/SH", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 190, "CST", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 210, "CFOP", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 230, "UN", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 250, "QUANT.", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 280, "V.UNITARIO", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 340, "V.TOTAL", oFont08N:oFont)
	oprn:Say(450+nAjustaPro, nAuxH + 390, "BC.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 435, "V.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 495, "V.IPI", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 535, "A.ICMS", oFont08N:oFont)	
	oprn:Say(450+nAjustaPro, nAuxH + 565, "A.IPI", oFont08N:oFont)
		TMP->(dbGoTop())
		_contit	:= 0
		nLinha := 1
		nAjustaPro := nAjustaPro + 10
		nAuxH := 0

		while !tmp->(eof())
			_contit := _contit + 1
			If _contit > 80 


				oprn:Say(450+nAjustaPro, nAuxH +2, alltrim(tmp->d2_cod),oFont08N:oFont)
				nAuxH += 25
				_infpro	:= GetAdvFVal("SB1",{"B1_DESC","B1_POSIPI"},XFilial("SB1")+alltrim(tmp->d2_cod),1,Array(02))			
				oprn:Say(450+nAjustaPro, nAuxH + 27, substr(_infpro[01],1,50), oFont08N:oFont)
				nAuxH += 120
				oprn:Say(450+nAjustaPro, nAuxH + 7, _infpro[02], oFont08N:oFont)
				nAuxH += 25
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CLASFIS, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_CF, oFont08N:oFont)
				nAuxH += 20
				oprn:Say(450+nAjustaPro, nAuxH + 20, TMP->D2_UM, oFont08N:oFont)
				nAuxH += 20
				
				oprn:Say(450+nAjustaPro, nAuxH + 20, Transform(TMP->D2_QUANT,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 23
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_PRCVEN,"@e 999,999.99") , oFont08N:oFont)
				nAuxH += 40
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_TOTAL,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 45, Transform(TMP->D2_BASEICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 45
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALICM,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50, Transform(TMP->D2_VALIPI,"@e 999,999.99"), oFont08N:oFont)
				nAuxH += 50
				oprn:Say(450+nAjustaPro, nAuxH + 50,Transform(TMP->D2_PICM,"@e 99.99") + " %", oFont08N:oFont)
				nAuxH += 35
				oprn:Say(450+nAjustaPro, nAuxH + 40, Transform(TMP->D2_IPI,"@e 99.99") + " %", oFont08N:oFont)
				nAjustaPro := nAjustaPro + 5
			EndIf 
			TMP->(dbSkip())       
		End
		TMP->(dbGoTop())
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If lPreview
	//	oprn:Preview()
//EndIf

oprn:EndPage()

RETURN()
static function _pergsx1()
local _i := 0

_agrpsx1:={}
aadd(_agrpsx1,{"RELNF","01","Nro Nota              ?","mv_ch1","C",9,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"SF2"})
/*aadd(_agrpsx1,{_cperg,"02","Ate o Bem             ?","mv_ch2","C",10,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"SN1"})
aadd(_agrpsx1,{_cperg,"03","A partir da data      ?","mv_ch3","D",08,0,0,"G",space(60),"mv_par03"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"   "})
aadd(_agrpsx1,{_cperg,"04","Ate a Data            ?","mv_ch4","D",08,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"   "})
aadd(_agrpsx1,{_cperg,"05","A partir da conta     ?","mv_ch5","C",20,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"CT1"})
aadd(_agrpsx1,{_cperg,"06","Ate a conta           ?","mv_ch6","C",20,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"CT1"})
aadd(_agrpsx1,{_cperg,"07","Qual a Moeda          ?","mv_ch7","N",01,0,2,"C",space(60),"mv_par07"       ,"Moeda 2"        ,space(30),space(15),"Moeda 3"        ,space(30),space(15),"Moeda 4"        ,space(30),space(15),"Moeda 5"        ,space(30),space(15),space(15)        ,space(30),"   "})
aadd(_agrpsx1,{_cperg,"08","Do Centro de Custo    ?","mv_ch8","C",09,0,0,"G",space(60),"mv_par08"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"CTT"})
aadd(_agrpsx1,{_cperg,"09","Ate o Centro de Custo ?","mv_ch9","C",09,0,0,"G",space(60),"mv_par09"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),"CTT"})
*/	
for _i:=1 to len(_agrpsx1)
	if ! sx1->(dbseek(_agrpsx1[_i,1]+_agrpsx1[_i,2]))
		sx1->(reclock("SX1",.t.))
		sx1->x1_grupo  :=_agrpsx1[_i,01]
		sx1->x1_ordem  :=_agrpsx1[_i,02]
		sx1->x1_pergunt:=_agrpsx1[_i,03]
		sx1->x1_variavl:=_agrpsx1[_i,04]
		sx1->x1_tipo   :=_agrpsx1[_i,05]
		sx1->x1_tamanho:=_agrpsx1[_i,06]
		sx1->x1_decimal:=_agrpsx1[_i,07]
		sx1->x1_presel :=_agrpsx1[_i,08]
		sx1->x1_gsc    :=_agrpsx1[_i,09]
		sx1->x1_valid  :=_agrpsx1[_i,10]
		sx1->x1_var01  :=_agrpsx1[_i,11]
		sx1->x1_def01  :=_agrpsx1[_i,12]
		sx1->x1_cnt01  :=_agrpsx1[_i,13]
		sx1->x1_var02  :=_agrpsx1[_i,14]
		sx1->x1_def02  :=_agrpsx1[_i,15]
		sx1->x1_cnt02  :=_agrpsx1[_i,16]
		sx1->x1_var03  :=_agrpsx1[_i,17]
		sx1->x1_def03  :=_agrpsx1[_i,18]
		sx1->x1_cnt03  :=_agrpsx1[_i,19]
		sx1->x1_var04  :=_agrpsx1[_i,20]
		sx1->x1_def04  :=_agrpsx1[_i,21]
		sx1->x1_cnt04  :=_agrpsx1[_i,22]
		sx1->x1_var05  :=_agrpsx1[_i,23]
		sx1->x1_def05  :=_agrpsx1[_i,24]
		sx1->x1_cnt05  :=_agrpsx1[_i,25]
		sx1->x1_f3     :=_agrpsx1[_i,26]
		sx1->(msunlock())
	endif
next
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InicPage  ºAutor  ³Daniel Peixoto      º Data ³  14/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicia uma nova pagina e impremi nro da pagina              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InicPage()
oPrn:EndPage()
oPrn:StartPage()
nLinI := 0
m_pag++
//oPrn:Say(nLinI+010, nColMax-47, "Pag.: " + STRZERO(m_pag, 2),oFont08:oFont)
Return
