#include "protheus.ch"
 
User Function impse1()
 
Local cArq    := "se1.csv"
Local cDir    := "c:\temp\"  
Local cEnd			:= "C:" //GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr			:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath			:= "\IMPORT\"
Local cTipoLog		:= "Import_"
Local cExtensao     := "_Log.txt"
Local cNomeLog		:=	cPath+cTipoLog+cDtHr
Local cArql			:=	cEnd+cNomeLog   
Local cCdAlias		:= "SE1"
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

	ProcRegua(Len(aDados))
	dbSelectArea("SE1")
	dbSetOrder(1)
	
	For _ni:=1 to Len(aDados)
        //dbSeek(xFilial("SE1")+alltrim(aDados[_ni,1]))
        //If Found ()
		Reclock("SE1",.T.)
 		dEmis	:= stod(substr(aDados[_ni,8],7,4) + substr(aDados[_ni,8],4,2) + substr(aDados[_ni,8],1,2))
 		dEmisa	:= stod(substr(aDados[_ni,9],7,4) + substr(aDados[_ni,9],4,2) + substr(aDados[_ni,9],1,2))
 		dVenc	:= stod(substr(aDados[_ni,10],7,4) + substr(aDados[_ni,10],4,2) + substr(aDados[_ni,10],1,2))
		dVencr	:= stod(substr(aDados[_ni,11],7,4) + substr(aDados[_ni,11],4,2) + substr(aDados[_ni,11],1,2))
		_codcli	:= aInfoDest := GetAdvFVal("SA1", { "A1_COD","A1_LOJA"}, xFilial("SA1")+aDados[_ni,7], 3, { "", ""})
		SE1->E1_FILIAL	:= aDados[_ni,1]
		SE1->E1_PREFIXO	:= aDados[_ni,2]	
		SE1->E1_NUM	    := aDados[_ni,3]
		SE1->E1_PARCELA	:= aDados[_ni,4]
		SE1->E1_TIPO	:= aDados[_ni,5]
		SE1->E1_NATUREZ	:= aDados[_ni,6]	
		SE1->E1_CLIENTE	:= _codcli[01]
		SE1->E1_LOJA	:= _codcli[02]
		SE1->E1_EMISSAO	:= dEmis    //aDados[_ni,9]
		SE1->E1_EMIS1	:= dEmisa   //aDados[_ni,10]	
		SE1->E1_VENCTO	:= dVenc    //aDados[_ni,11]
		SE1->E1_VENCREA	:= dVencr   //aDados[_ni,12]
		SE1->E1_VALOR	:= Val(aDados[_ni,12])
		SE1->E1_SALDO	:= Val(aDados[_ni,13])	
		SE1->E1_HIST	:= aDados[_ni,14]
		SE1->E1_MOEDA	:= Val(aDados[_ni,15])
		SE1->E1_VLCRUZ	:= Val(aDados[_ni,16])
		SE1->(MsUnlock())        
     
    Next _ni        
 
FT_FUSE()
	fClose(nHdl)
ApMsgInfo("Importacao SE1 Descricao de produtos concluida, consulte o log para mais informacoes!","[IMPAPROV] - SUCESSO")


cDirServ  := "\data\"
cDirLocal := "C:\temp\"
cArquivo  := "se1010.dtc"
 
//Copiando o arquivo via __CopyFile (nesse é possível alterar o nome do arquivo de destino, por exemplo, teste2.txt)
__CopyFile(cDirServ+cArquivo,cDirLocal+cArquivo)
 
//Copiando o arquivo via CpyT2S
//CpyT2S(cDirLocal+cArquivo, cDirServ)
Return
