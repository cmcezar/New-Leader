//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} zTstExc1
Função que cria um exemplo de FWMsExcel
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
    Local cCabec        := "Tipo;Data de Entrega;Data de Embarque;Unidade;Número da OC;Número da Linha da OC;CÓdigo de Material;Tipo de Commodity;Qte.;Qte. Prévia;Última Qte. ASN;Última Data ASN;Última Quantidade Recebida;Data do último Recebimento;Lista de Números de Embalagem;Embarcar para Local;Número da Doca;Código de Material Fornecedor;Número de Acionamento;Localização da Alimentação da Linha;Número do Departamento;Quantidade Cumulativa Recebida;Preço por Unidade;Data último envio;Última Data Atualizada;Revisão de Engenharia;Num. Ordem Cliente;Usuário;Registro Data/Hora;Nome do Destinatário;Embarcar para Endereço;Embarcar para Cidade;Embarcar para Região;Embarcar para Código Postal;Tipo de Ordem;Tipo de Embarque;Instrução de Embarque;Identificação do Caminhão;Ponto de Distribuição;Informação de Rota;Container Retornável;Lista de Identificação;Localização da Plataforma;Referência do Concessionário #;Data de lançamento atual;Número de lançamento atual;Num. Pedido"
    Local aCabec        := {}

    AADD(aCabec,Separa(cCabec,";",.T.))

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()

    //Aba 02 - Produtos
    oFWMsExcel:AddworkSheet("pedven")

    //Criando a Tabela
    oFWMsExcel:AddTable("pedven","pedven")

    //Cria colunas
    For nX := 1 to 47

        oFWMsExcel:AddColumn("pedven","pedven",ALLTRIM(aCabec[1][nX]),1)

    Next

    //Criando as Linhas... Enquanto não for fim do array
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
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    RestArea(aArea)
Return
