#include 'protheus.ch'

//---------------------------------------------------------------\\
/*/{Protheus.doc} A120PIDF
//TODO Ponto de entrada usado no pedido de compras, para filtrar
  as solicitações de compras com base no código e loja do fornecedor
  informado no cabeçalho do pedido de compra.
@author Claudio
@since 12/05/2026
@version 1.0
@return nil
@type function
/*/
//---------------------------------------------------------------\\
User Function A120PIDF()

Local aFiltro  := {} // PARAMIXB // Recebe o filtro padrão do sistema
Local nCotacao := GETSX3CACHE('C1_COTACAO','X3_TAMANHO')  

If MsgYesNo('Deseja utilizar o filtro por fornecedor ?')
	aFiltro := {"C1_FILIAL = '"+xFilial('SC1')+"'"+;
				" .And. C1_FORNECE = '"+CA120FORN+"'"+;
				" .And. C1_LOJA = '"+CA120LOJ+"'" +;
				" .And. C1_TPOP <> 'P'" +;
				" .And. C1_QUJE < C1_QUANT"+;
				" .And. C1_FLAGGCT <> '1'"+;
				" .And. C1_ACCPROC <> '1'"+;
				" .And. C1_TPSC <> '2'"+;
				" .And. C1_RESIDUO <> 'S'"+;
				" .And. (C1_COTACAO = Space("+Alltrim(Str(nCotacao))+") .Or. C1_COTACAO = Replicate('X',"+Alltrim(Str(nCotacao))+"))"+;
				" .And. (C1_APROV = ' ' .Or. C1_APROV = 'L')"}

Else 
	aFiltro := {"C1_FILIAL = '"+xFilial('SC1')+"'"+;
				" .And. C1_TPOP <> 'P'" +;
				" .And. C1_QUJE < C1_QUANT"+;
				" .And. C1_FLAGGCT <> '1'"+;
				" .And. C1_ACCPROC <> '1'"+;
				" .And. C1_TPSC <> '2'"+;
				" .And. C1_RESIDUO <> 'S'"+;
				" .And. (C1_COTACAO = Space("+Alltrim(Str(nCotacao))+") .Or. C1_COTACAO = Replicate('X',"+Alltrim(Str(nCotacao))+"))"+;
				" .And. (C1_APROV = ' ' .Or. C1_APROV = 'L')"}
Endif 

Return aFiltro
