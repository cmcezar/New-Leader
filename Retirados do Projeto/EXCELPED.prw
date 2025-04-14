//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} zTstExc1
Fun��o que cria um exemplo de FWMsExcel
@author Atilio
@since 06/08/2016
@version 1.0
    @example
    u_zTstExc1()
/*/
 
User Function EXCELPED(aExcel)
    Local aArea         := GetArea()
    Local oFWMsExcel
    Local oExcel
    Local cArquivo      := GetTempPath()+'PEDIDOS.xml'
    Local nX            := 1  
    Local cCabec        := "Tipo;Data de Entrega;Data de Embarque;Unidade;N�mero da OC;N�mero da Linha da OC;C�digo de Material;Tipo de Commodity;Qte.;Qte. Pr�via;�ltima Qte. ASN;�ltima Data ASN;�ltima Quantidade Recebida;Data do �ltimo Recebimento;Lista de N�meros de Embalagem;Embarcar para Local;N�mero da Doca;C�digo de Material Fornecedor;N�mero de Acionamento;Localiza��o da Alimenta��o da Linha;N�mero do Departamento;Quantidade Cumulativa Recebida;Pre�o por Unidade;Data �ltimo envio;�ltima Data Atualizada;Revis�o de Engenharia;Num. Ordem Cliente;Usu�rio;Registro Data/Hora;Nome do Destinat�rio;Embarcar para Endere�o;Embarcar para Cidade;Embarcar para Regi�o;Embarcar para C�digo Postal;Tipo de Ordem;Tipo de Embarque;Instru��o de Embarque;Identifica��o do Caminh�o;Ponto de Distribui��o;Informa��o de Rota;Container Retorn�vel;Lista de Identifica��o;Localiza��o da Plataforma;Refer�ncia do Concession�rio #;Data de lan�amento atual;N�mero de lan�amento atual;Num. Pedido"
    Local aCabec        := {}

    AADD(aCabec,Separa(cCabec,";",.T.))

    //Criando o objeto que ir� gerar o conte�do do Excel
    oFWMsExcel := FWMSExcel():New()

    //Aba 02 - Produtos
    oFWMsExcel:AddworkSheet("pedven")

    //Criando a Tabela
    oFWMsExcel:AddTable("pedven","pedven")

    //Cria colunas
    For nX := 1 to 47

        oFWMsExcel:AddColumn("pedven","pedven",ALLTRIM(aCabec[1][nX]),1)

    Next

    //Criando as Linhas... Enquanto n�o for fim do array
    For nX := 1 to len(aExcel)

        oFWMsExcel:AddRow("pedven","pedven",{;
                                            aExcel[nX][1],aExcel[nX][2],aExcel[nX][3],aExcel[nX][4],aExcel[nX][5],aExcel[nX][6],aExcel[nX][7],aExcel[nX][8],;
                                            aExcel[nX][9],aExcel[nX][10],aExcel[nX][11],aExcel[nX][12],aExcel[nX][13],aExcel[nX][14],aExcel[nX][15],aExcel[nX][16],;
                                            aExcel[nX][17],aExcel[nX][18],aExcel[nX][19],aExcel[nX][20],aExcel[nX][21],aExcel[nX][22],aExcel[nX][23],aExcel[nX][24],;
                                            aExcel[nX][25],aExcel[nX][26],aExcel[nX][27],aExcel[nX][28],aExcel[nX][29],aExcel[nX][30],aExcel[nX][31],aExcel[nX][32],;
                                            aExcel[nX][33],aExcel[nX][34],aExcel[nX][35],aExcel[nX][36],aExcel[nX][37],aExcel[nX][38],aExcel[nX][39],aExcel[nX][40],;
                                            aExcel[nX][41],aExcel[nX][42],aExcel[nX][43],aExcel[nX][44],aExcel[nX][45],aExcel[nX][46],aExcel[nX][47];
                                            })

    Next
    
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conex�o com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    RestArea(aArea)
Return
