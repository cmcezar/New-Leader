#include 'protheus.ch'

User Function A120PIDF()

Local aFiltro  := {} // PARAMIXB // Recebe o filtro padrão do sistema
Local nCotacao := GETSX3CACHE('C1_COTACAO','X3_TAMANHO')  

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
    
Return aFiltro
