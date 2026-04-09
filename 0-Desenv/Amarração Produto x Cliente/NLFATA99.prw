//Define as variáveis
lDeuCerto := .F.
cCliente  := "000001"
cLojaCli  := "01"
cProduto  := "PROD0001"
nPreco    := 10.99
dDataRef  := Date()
 
DbSelectArea('SA7')
SA7->(DbSetOrder(1)) //A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
 
//Somente se não encontrar Produto x Cliente irá cair dentro da condição
If ! SA7->(DbSeek(FWxFilial('SA7') + cCliente + cLojaCli + cProduto))
 
    //Instanciando a rotina MATA370, buscando o model dos campos da SA7MASTER e definindo a operação como inclusão
    oModel := FWLoadModel("MATA370")
    oSA7Mod:= oModel:GetModel("SA7MASTER")
    oModel:SetOperation(3)
    oModel:Activate()
 
    //Define as informações básicas da rotina
    oSA7Mod:setValue("A7_FILIAL",    FWxFilial("SA7") ) 
    oSA7Mod:setValue("A7_CLIENTE",   cCliente         ) 
    oSA7Mod:setValue("A7_LOJA",      cLojaCli         ) 
    oSA7Mod:setValue("A7_PRODUTO",   cProduto         ) 
    oSA7Mod:setValue("A7_PRECO01",   nPreco           ) 
    oSA7Mod:setValue("A7_DTREF01",   dDataRef         ) 
 
    //Tenta validar as informações e realizar o commit
    If oModel:VldData()
        If oModel:CommitData()
            lDeuCerto := .T.
        EndIf
    EndIf 
     
    //Se não deu certo a operação de inclusão
    If ! lDeuCerto
        //Busca o Erro do Modelo de Dados
        aErro := oModel:GetErrorMessage()
 
        //Monta o Texto que será mostrado na tela
        AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
        AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
        AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
        AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
        AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
        AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
        AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
        AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
        AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
 
        //Mostra a mensagem de Erro
        MostraErro()
    EndIf
 
    //Por fim, desativa o modelo de dados
    oModel:DeActivate()
EndIf
