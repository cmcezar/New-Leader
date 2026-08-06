User Function  MT120LOK()
Local nPosFor    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_FORNECE'})
Local nPosLj     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_LOJA'})
Local lValido := .T.
(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)) 
_nomFor := Posicione("SA2",1,xFilial("SA2")+nPosFor+nPosLj,"A2_NOME")
MsgAlert(_nomfor, "Antes")
aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NOMEFOR'}) := _nomFor 
           M->C7_NOMEFOR := _nomFor
            __READVAR := "C7_NOMEFOR"
MsgAlert(aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NOMEFOR'}) , "depois")            
Return(lValido) 
