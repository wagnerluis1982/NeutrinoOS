; Copyright (C) 2011-2012 Alisson Linhares de Carvalho.
; All rights reserved.
;
; This file is part of the neutrino kernel.
;
; The neutrino kernel is free software: you can redistribute it and/or 
; modify it under the terms of the GNU General Public License as 
; published by the Free Software Foundation, either version 3 of the 
; License, or (at your option) any later version.

; The neutrino kernel is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with the neutrino kernel. If not, see <http://www.gnu.org/licenses/>.
;
;--------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para registros---------------------------------
struc tNifButton
	.component          RESB tComponent_size
	.nifPtr             RESD 1 ;Ponteiro para imagem nif.
endstruc

;--------------------------------------------------------------------------------------------
;@description: Procedimento para pintar um bot�o feito com uma imagem NIF
;@input: ESP << X, ESP + 2 << Y, ESP + 4 << W, ESP + 6 << H, ESP + 8 << base
;@output: ALL
;@author: alisson_linhares@hotmail.com
nifButton_Draw:
	.Y EQU 4
	.X EQU 6
	.H EQU 8
	.W EQU 10
	.BASE EQU 12
	
	;Verifica se o componente possui um ponteiro para uma nif.
	CMP DWORD[EDI + tNifButton.nifPtr],0
	JE .abort
		MOV ESI,DWORD[EDI + tNifButton.nifPtr]
		ADD ESI,DWORD[ESP + .BASE] ;Colocando o ponteiro na �rea de dados do kernel

.PRINT_NIF__:   ;Label global usada para desenhar um nifbutton.

		;Verifica o tipo de pintura 
		TEST AL,AL 
		JNZ .setColor1
			MOV EBP,DWORD[EDI + tComponent.bgColor]                           
			MOV EBX,DWORD[EDI + tComponent.textColor]
			JMP .setColor2
		.setColor1: ;Pintura invertida
			MOV EBX,DWORD[EDI + tComponent.bgColor]      
			MOV EBP,DWORD[EDI + tComponent.textColor]
		.setColor2:
		
		;Pintando a imagem nif na tela
		MOV CX,WORD[ESP + .X]
		MOV DX,WORD[ESP + .Y]
		CALL DWORD[isr0x30.video_DrawNIF]
	.abort:
	RET 12 ;Desalocando os 12bytes passados na pilha.