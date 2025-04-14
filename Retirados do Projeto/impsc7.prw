#include "protheus.ch"
 
User Function impsc7()
 
Local cArq    := "sc7.csv"
Local cDir    := "c:\temp\"  
Local cEnd			:= "C:" //GetPvProfString(cEnvServ,"StartPath","",cIniFile )   
Local cDtHr			:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath			:= "\IMPORT\"
Local cTipoLog		:= "Import_"
Local cExtensao     := "_Log.txt"
Local cNomeLog		:=	cPath+cTipoLog+cDtHr
Local cArql			:=	cEnd+cNomeLog   
Local cCdAlias		:= "SC7"
Local cLinha  := ""
Local lPrim   := .T.
Local aCab2   := {}
Local aDados  := {}
Local aItem3  :={}
Local aItem2  :={}
Local _ni     := 0 
Local _codped := ""
Local nOpc    :=3
Private aErro := {}

lMsErroAuto := .F.



If !File(cDir+cArq)
	MsgStop("O arquivo " +cDir+cArq + " nao foi encontrado. A importacao sera abortada!","[impaprov] - ATENCAO")
	Return
EndIf
 
FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 lPrim := .F.
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
	dbSelectArea("SC7")
	dbSetOrder(1)
	MsgAlert("VAI EXECUTAR A INCLUSAO")
    //STRZERO(val(aDados[_ni,1]),6)

        _codped := aDados[1,1]
                    aCab2:={{"C7_NUM",STRZERO(val(aDados[1,1]),6),Nil},;
                {"C7_ITEM" ,,Nil},;
                {"C7_EMISSAO" ,dDataBase,Nil},;                
                {"C7_FORNECE" ,STRZERO(val(aDados[1,8]),6),Nil},;
                {"C7_LOJA"    ,STRZERO(val(aDados[1,9]),2),Nil},;
                {"C7_COND"    ,"000",Nil},;
                {"C7_FILENT"  ,xFilial("SC7"),Nil}}
	    For _ni:=1 to Len(aDados)
            //dbSeek(xFilial("SA5")+alltrim(aDados[_ni,1])+alltrim(aDados[_ni,2])+alltrim(aDados[_ni,4]))
            //If Found () 
            If _codped <> aDados[_ni,1]
                MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
                IF lMsErroAuto //SE HOUVE ERRO
			        MostraErro()
		        EndIf
                aCab2 := {}
                aItem2  :={}
                    aCab2:={{"C7_NUM",STRZERO(val(aDados[_ni,1]),6),Nil},;
                {"C7_EMISSAO" ,dDataBase,Nil},;                
                {"C7_FORNECE" ,STRZERO(val(aDados[_ni,8]),6),Nil},;
                {"C7_LOJA"    ,STRZERO(val(aDados[_ni,9]),2),Nil},;
                {"C7_COND"    ,"000",Nil},;
                {"C7_FILENT"  ,xFilial("SC7"),Nil}}
            EndIf 
            _codped := aDados[_ni,1]
    
            aItem3:={}
            aItem3:={{"C7_ITEM",STRZERO(val(aDados[_ni,2]),4),Nil},;
            {"C7_PRODUTO",aDados[_ni,3],Nil},;
            {"C7_QUANT"  ,val(aDados[_ni,5]),Nil},;
            {"C7_PRECO"  ,val(aDados[_ni,6]),Nil},;
            {"C7_TOTAL"  ,val(aDados[_ni,7]),Nil},;
            {"C7_DATPRF" ,dDataBase,Nil},;
            {"C7_TES"    ,"1A1",Nil},;
            {"C7_FLUXO"  ,"S",Nil},;
            {"C7_USER"   ,__CUSERID,Nil},;
            {"C7_OBS"    ,"",Nil},;
            {"C7_LOCAL"  ,"01",Nil}}
        
            aadd(aItem2,aItem3)
            
        Next _ni        


FT_FUSE()
	fClose(nHdl)
ApMsgInfo("Importacao SC7 pedidos de compra concluida, consulte o log para mais informacoes!","[IMPAPROV] - SUCESSO")


cDirServ  := "\data\"
cDirLocal := "C:\temp\"
cArquivo  := "SB1010.dtc"
 
//Copiando o arquivo via __CopyFile (nesse é possível alterar o nome do arquivo de destino, por exemplo, teste2.txt)
__CopyFile(cDirServ+cArquivo,cDirLocal+cArquivo)
 
//Copiando o arquivo via CpyT2S
//CpyT2S(cDirLocal+cArquivo, cDirServ)+*/

Return
User Function ajusc7()
	dbSelectArea("SC7")
	dbSetOrder(1)
				While SC7->(!EOF()) 
					Reclock('SC7',.F.)
					SC7->C7_NOMEFOR := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")
					SC7->(MsUnLock())
					SC7->(dbSkip())
				EndDo    

RETURN 
//Posicione("SA2",1,xFilial("SA2")+CA120FORN+CA120LOJ,"A2_NOME")
