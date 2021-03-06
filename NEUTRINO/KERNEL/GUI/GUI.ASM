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
;-------------------------Importando macros, procedimentos e dados---------------------------
%include "KERNEL/GUI/COMPONENT.ASM"
%include "KERNEL/GUI/PANEL.ASM" 

;--------------------------------------------------------------------------------------------
;-----------------------------�rea reservada para constantes---------------------------------
MOUSE_WIDTH         EQU 10   
MOUSE_HEIGHT        EQU 14

CLOSE_BUTTON_WIDTH  EQU 13
CLOSE_BUTTON_HEIGHT EQU 13

MAX_BUTTON_WIDTH    EQU 13
MAX_BUTTON_HEIGHT   EQU 13

MIN_BUTTON_WIDTH    EQU 13
MIN_BUTTON_HEIGHT   EQU 13

CHAR_WIDTH          EQU 7
CHAR_HEIGHT         EQU 13

TOTAL_OF_NIFS       EQU 260

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para vari�veis--------------------------------- 
gui:
.asciiListPtr       DD 0
.closeButtonPtr     DD 0
.minButtonPtr       DD 0
.maxButtonPtr       DD 0
.resizeButtonPtr    DD 0
.mousePtr           DD 0
.dataPath           DB 'a\data\nif.img',0 ;Caminho do arquivo de nifs

;--------------------------------------------------------------------------------------------	
;@description: Macro para carregar dados gr�ficos do disco para mem�ria.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_LoadData 0
	;Carregando dados do disco para mem�ria
	MOV ESI,gui.dataPath 
	CALL nfs_LoadFile
	
	;Configurando o ponteiro para as nifs    
	MOV DWORD[gui.asciiListPtr],EDI
	
	;Configurando os ponteiros internos do arquivo de nifs
	LEA ESI,[EDI + TOTAL_OF_NIFS * 4]           
	%%configNifs:
		ADD DWORD[ESI],EDI
		SUB ESI,4
	CMP ESI,EDI
	JAE %%configNifs 
  
	;Movendo os ponteiros internos do arquivo de imagens para vari�veis "Melhora o desempenho do v�deo" 
	CLD
	ADD ESI,256 * 4  + 4
	MOV EDI,gui.closeButtonPtr	
	MOV ECX,5
	REP MOVSD 
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro para iniciar o sistema gr�fico e carregar dados relativos ao v�deo.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_Start 0
	CMP BYTE[system.mode],GRAPHICS_MODE
	JNE %%skipConfig		
		;Alocando mem�ria para mouse e buffer de v�deo
		MOV ECX,((VIDEO_BUFFER_SIZE + PANEL_BUFFER_SIZE + MOUSE_BUFFER_SIZE)/MEMORY_PAGE_SIZE) + 1		
		CALL memory_AllocatePage
		
		;Salvando ponteiro para o buffer dos pain�is		
		MOV DWORD[panel.bufferPtr],EDI
		ADD EDI,PANEL_BUFFER_SIZE
		
		;Ponteiro para o buffer do mouse
		MOV DWORD[mouse.buffer],EDI
		ADD EDI,MOUSE_BUFFER_SIZE   
		
		;Salvando ponteiro para o buffer de v�deo
		MOV DWORD[video.buffer],EDI
		
		;Carregando nifs para mem�ria
		gui_LoadData
		
		;Configurando o prompt para trabalhar em modo gr�fico
		prompt_Config
	%%skipConfig:	
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando uma tecla � pressionada "Evento do teclado".
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnKeyDown 0
	panel_OnKeyDown
%endmacro	

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando uma tecla � liberada "Evento do teclado".
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnKeyUp 0
	panel_OnKeyUp
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o mouse � movimentado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseMove 0
	panel_OnMouseMove
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o mouse � movimentado com o bot�o direito pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseDrag 0
	panel_OnMouseDrag
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � liberado ap�s um gui_OnMouseDrag.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseDrop 0
	panel_OnMouseDrop
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o esquerdo do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseLeft 0	
	panel_OnMouseLeft
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseRight 0
	panel_OnMouseRight
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o do meio do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseMiddle 0
	panel_OnMouseMiddle
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o esquerdo do mouse � liberado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseUpLeft 0
	panel_OnMouseUpLeft	
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � liberado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseUpRight 0
	panel_OnMouseUpRight
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o do meio do mouse � liberado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro gui_OnMouseUpMiddle 0
	panel_OnMouseUpMiddle
%endmacro