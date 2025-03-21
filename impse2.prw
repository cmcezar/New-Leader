#include "protheus.ch"
 
User Function impse2()
 
Local cArq    := "se2.csv"
Local cDir    := "c:\temp\"  
Local cEnd			:= "C:" //GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr			:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath			:= "\IMPORT\"
Local cTipoLog		:= "Import_"
Local cExtensao     := "_Log.txt"
Local cNomeLog		:=	cPath+cTipoLog+cDtHr
Local cArql			:=	cEnd+cNomeLog   
Local cCdAlias		:= "SE2"
Local cLinha  := ""
Local aDados  := {}

Local _ni     := 0 
Private aErro := {}





If !File(cDir+cArq)
	MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impaprov] - ATENCAO")
	Return
EndIf
 
FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 
	cLinha := FT_FREADLN()
 
	AADD(aDados,Separa(cLinha,";",.T.))

 
	FT_FSKIP()
EndDo
 	nHdl := fCreate(cArql+'-'+cCdAlias+cExtensao)
	If nHdl == -1
		MsgAlert("O arquivo  "+cArql+'-'+cCdAlias+cExtensao+" nao pode ser criado!","Atencao!")
		fClose(nHdl)
		fErase(cArql+'-'+cCdAlias+cExtensao)
		RestArea(aArea)
	 	Return()
	EndIf
	fWrite(nHdl, Replicate( '=', 80 ) 											+ CHR(13)+CHR(10))
	fWrite(nHdl, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S'		+ CHR(13)+CHR(10))
	fWrite(nHdl, Replicate( '-', 80 ) 											+ CHR(13)+CHR(10))
	fWrite(nHdl, 'Lista de itens não importados ' +   DtoC( dDataBase ) 			+ CHR(13)+CHR(10))	
    cBanco      := "SLD"
    cAgencia    := "SLD"
    cConta      := "SLD" 
	ProcRegua(Len(aDados))
	dbSelectArea("SE2")
	dbSetOrder(1)
	
	For _ni:=1 to Len(aDados)
        //dbSeek(xFilial("SE1")+alltrim(aDados[_ni,1]))
        //If Found ()
		Reclock("SE2",.T.)
 		dEmis	:= stod(substr(aDados[_ni,9],7,4) + substr(aDados[_ni,9],4,2) + substr(aDados[_ni,9],1,2))
 		dEmisa	:= stod(substr(aDados[_ni,10],7,4) + substr(aDados[_ni,10],4,2) + substr(aDados[_ni,10],1,2))
 		dVenc	:= stod(substr(aDados[_ni,11],7,4) + substr(aDados[_ni,11],4,2) + substr(aDados[_ni,11],1,2))
		dVencr	:= stod(substr(aDados[_ni,12],7,4) + substr(aDados[_ni,12],4,2) + substr(aDados[_ni,12],1,2))
        // Execauto que gera titulos a pagar incluindo PA 
        SE2->E2_FILIAL		:= xFilial("SE2")		
        SE2->E2_PREFIXO		:= aDados[_ni,2] 		
        SE2->E2_NUM			:= aDados[_ni,3]     	
        SE2->E2_PARCELA		:= aDados[_ni,4]     	
        SE2->E2_TIPO		:= aDados[_ni,5]     	
        SE2->E2_FORNECE		:= aDados[_ni,7]  	
        SE2->E2_LOJA		:= aDados[_ni,8]    	
        SE2->E2_VENCTO		:= dVenc          	
        SE2->E2_NATUREZ		:= aDados[_ni,6]	 	
        SE2->E2_EMISSAO		:= dEmis            	
        SE2->E2_EMIS1		:= dEmisa			   	
        SE2->E2_VENCREA		:= dVencr			   	
        SE2->E2_SALDO		:= Val(aDados[_ni,13])			   	
        SE2->E2_VALOR		:= Val(aDados[_ni,13])			   	
        SE2->E2_VLCRUZ		:= Val(aDados[_ni,16])			   	
        SE2->E2_HIST		:= aDados[_ni,14]			   	
        SE2->E2_MOEDA		:= Val(aDados[_ni,15])			   	
		SE2->(MsUnlock())
/*        If aDados[_ni,5] = "PA"
        	aAdd(aArray,{ "AUTBANCO" , cBanco , NIL })
		    aAdd(aArray,{ "AUTAGENCIA" , cAgencia , NIL })
		    aAdd(aArray,{ "AUTCONTA" , cConta , NIL })
		EndIf*/
    /*   pergunte("FIN050",.F.)
		MV_PAR05:=2
		MV_PAR09:=1
        lMsErroAuto := .F.
        MSExecAuto({|x,y,z| Fina050(x,y,z)},aTitulo,,3)

        If lMsErroAuto
            MostraErro()
            lRet := .f.
        Endif 
/*		SE2->E2_FILIAL	:= aDados[_ni,1]
		SE2->E2_PREFIXO	:= aDados[_ni,2]	
		SE2->E2_NUM	    := aDados[_ni,3]
		SE2->E2_PARCELA	:= aDados[_ni,4]
		SE2->E2_TIPO	:= aDados[_ni,5]
		SE2->E2_NATUREZ	:= aDados[_ni,6]	
		SE2->E2_FORNECE	:= aDados[_ni,7]
		SE2->E2_LOJA	:= aDados[_ni,8]
		SE2->E2_EMISSAO	:= dEmis    //aDados[_ni,9]
		SE2->E2_EMIS1	:= dEmisa   //aDados[_ni,10]	
		SE2->E2_VENCTO	:= dVenc    //aDados[_ni,11]
		SE2->E2_VENCREA	:= dVencr   //aDados[_ni,12]
		SE2->E2_VALOR	:= Val(aDados[_ni,13])
		SE2->E2_SALDO	:= Val(aDados[_ni,13])	
		//SE2->E2_HIST	:= aDados[_ni,14]
		SE2->E2_MOEDA	:= Val(aDados[_ni,15])
		SE2->E2_VLCRUZ	:= Val(aDados[_ni,16])
		SE2->E2_ISS	    := Val(aDados[_ni,17])
		SE2->E2_IRRF	:= Val(aDados[_ni,18])
		SE2->E2_INSS	:= Val(aDados[_ni,19])
		//SE2->E2_DIRF	:= aDados[_ni,20]
		//SE2->E2_CODRET	:= aDados[_ni,21]
		SE2->E2_COFINS	:= Val(aDados[_ni,22])
		SE2->E2_PIS	    := Val(aDados[_ni,23])
		SE2->E2_CSLL	:= Val(aDados[_ni,24])
		SE2->E2_CODINS	:= aDados[_ni,25]
        SE2->E2_CCUSTO	:= aDados[_ni,26]
		SE2->(MsUnlock()) */       
  
    Next _ni        


FT_FUSE()
	fClose(nHdl)
ApMsgInfo("Importacao SE2 titulos a pagar concluida, consulte o log para mais informacoes!","[IMPSE2] - SUCESSO")


cDirServ  := "\data\"
cDirLocal := "C:\temp\"
cArquivo  := "se2010.dtc"
 
//Copiando o arquivo via __CopyFile (nesse é possível alterar o nome do arquivo de destino, por exemplo, teste2.txt)
//__CopyFile(cDirServ+cArquivo,cDirLocal+cArquivo)
 
//Copiando o arquivo via CpyT2S
//CpyT2S(cDirLocal+cArquivo, cDirServ)
Return
