#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������`���������������������������ͻ��
���Programa  �M460FIM   �Autor  �Sandro Delfino       � Data � 27/11/2022 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado ap�s o t�rmino do faturamento de ���
���          �Pedidos de Venda.                                           ���
�������������������������������������������������������������������������͹��
���Uso       � New Leader                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function M460FIM()

Local aArea		:= GetArea()
Local cRetorno  := space(250) 


cRetorno := FWInputBox("Digite os dados adicionais da NF", "")
 u_fGraDadosAdt(cRetorno)
RestArea(aArea)

Return

User Function fGraDadosAdt(cRetorno)
Local _msgori := ""
_msgori := alltrim(SF2->F2_MENNOTA) 

        If 	RecLock("SF2",.F.)
                SF2->F2_MENNOTA := _msgori + " " + Alltrim(cRetorno)
        
                
                SF2->(MsUnLock())
            else
                SF2->F2_MENNOTA := _msgori + Alltrim(cRetorno)
    

        EndIf

Return
User Function Tela()
/*cRetorno := FWInputBox("Digite os dados adicionais da NF", "")

MsgAlert(cRetorno, "Dados digitados")

Local wVeiculoa    := "" 
@ 000,000 to 200,250 dialog odlg9 title "Informe dados adicionais da NF"

	@ 001,001 say "Dados Adicionais"
	@ 002,001 get wVeiculoa 		Picture "@!" 			       size 060,050 

	@ 090,020 bmpbutton type 1 action fGraDadosAdt(wVeiculoa)
    @ 090,050 BmpButton Type 2 Action Close(odlg9)
	Activate Dialog odlg9 Centered*/
Return
