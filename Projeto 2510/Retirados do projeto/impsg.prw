#include "protheus.ch"
 
User Function impsg()
 
Local cArq    := "sg1.csv"
Local cDir    := "c:\temp\"  
Local cEnd			:= "C:" //GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr			:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath			:= "\IMPORT\"
Local cTipoLog		:= "Import_"
Local cExtensao     := "_Log.txt"
Local cNomeLog		:=	cPath+cTipoLog+cDtHr
Local cArql			:=	cEnd+cNomeLog   
Local cCdAlias		:= "SG1"
Local cLinha  := ""
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {}
Local _ni     := 0 

    Local aArea := GetArea()
    Local aCab := {}
    Local aItens := {}

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
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
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
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
	DbSelectArea("SG1")
	SG1->(DbSetOrder(3))
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))							 
		aCab := {{"G1_COD","AKK42239",NIL},;
						{"G1_QUANT",1,NIL},;
						{"NIVALT","S",NIL},;
						{"ATUREVSB1","N",NIL}} 		 
		 		   	  
	   


	For _ni:=1 to Len(aDados)
    	nOption := 3//oParseJSON:OPERACAO // 3 - Inclusão <-> 4 - Alteração <-> 5 - Exclusão (Recomendo não usar exclusão)
        SB1->(dbSeek(xFilial("SB1")+alltrim(aDados[_ni,2])))
        If !Found ()
				Reclock("SB1",.T.)
				SB1->B1_FILIAL	:= "01"
				SB1->B1_COD		:= aDados[_ni,2]
				SB1->B1_DESC	:= aDados[_ni,16]
				SB1->B1_TIPO	:= "PA"
				SB1->B1_UM		:= "UN"
				SB1->B1_LOCPAD  := "01"
				SB1->B1_GRUPO	:= "0007"
				
				SB1->(MsUnlock())		
		EndIf 	
        If alltrim(aDados[_ni,7]) = "1"
                _fantasm := "1"
            Else 
                _fantasm := "2"
        EndIf     
	      aLinha := {}
		
	      aadd(aLinha,{"G1_COD",    aDados[_ni,3]	  		, Nil})
	      aadd(aLinha,{"G1_COMP",   aDados[_ni,2] 	  		, Nil})
	      aadd(aLinha,{"G1_QUANT",  val(aDados[_ni,4])     	, Nil}) 
	      aadd(aLinha,{"G1_TRT",	Space(3)			  	, NIL})
	      aadd(aLinha,{"G1_PERDA",	0					  	, NIL})     
	      aadd(aLinha,{"G1_FANTASM", _fantasm  				, NIL}) 
		  aadd(aLinha,{"G1_FIXVAR",	"V"						, NIL})
		  aadd(aLinha,{"G1_REVINI",	"001"					, NIL})
		  aadd(aLinha,{"G1_REVFIM",	"001" 					, NIL})
		  aadd(aLinha,{"G1_NIV",	"0" + aDados[_ni,1] 	, NIL})
		  aadd(aLinha,{"G1_NIVINV",STR(100-VAL(aDados[_ni,1])), NIL})
	      aadd(aItens, aLinha)

	   Next nX
	      
	
	//Begin Transaction
		//MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,aItens,nOption)					
				
		If lMsErroAuto
			//DisarmTransaction()	
			//cArqLog := "AKK42239 - " + SubStr( Time(),1,5 ) + ".log"
			MostraErro()
			
		EndIf
	//End Transaction
/*	For _ni:=1 to Len(aDados)
        If alltrim(aDados[_ni,7]) = "1"
                _fantasm := "1"
            Else 
                _fantasm := "2"
        EndIf  

				Reclock("SG1",.T.)

				SG1->G1_COD		:= aDados[_ni,3]
				SG1->G1_COMP	:= aDados[_ni,2]
				SG1->G1_QUANT	:= val(aDados[_ni,4]) 
				SG1->G1_TRT		:= Space(3)
				SG1->G1_PERDA	:= 0     
				SG1->G1_FANTASM := _fantasm   				
				SG1->G1_FIXVAR	:= "V"
				SG1->G1_REVINI	:= "001"	
				SG1->G1_REVFIM	:= "001" 
				SG1->G1_NIV		:= "0" + aDados[_ni,1]
				SG1->G1_NIVINV	:= STR(100-VAL(aDados[_ni,1]))

				SG1->(MsUnlock())
	   Next nX
*/

FT_FUSE()
	fClose(nHdl)
ApMsgInfo("Importacao SNG Estrutura de produtos concluida, consulte o log para mais informacoes!","[IMPAPROV] - SUCESSO")
/*
cDirServ  := "\data\"
cDirLocal := "C:\temp\"
cArquivo  := "sn4010.dtc"
__CopyFile(cDirServ+cArquivo,cDirLocal+cArquivo) 
//Copiando o arquivo via __CopyFile (nesse é possível alterar o nome do arquivo de destino, por exemplo, teste2.txt)
//__CopyFile(cDirServ+cArquivo,cDirLocal+cArquivo)
 
//Copiando o arquivo via CpyT2S
//CpyT2S(cDirLocal+cArquivo, cDirServ)*/

Return
