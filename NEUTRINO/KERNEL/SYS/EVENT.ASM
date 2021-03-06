; Copyright (C) 2011-2012 Alisson Linhares de Carvalho.
; All rights reserved.
;
; This file is part of the neutrino kernel.
;
; The neutrino kernel is free software: you can redistribute it and/or 
; modify it under the terms of the GNU General Public License as 
; published by the Free Software Foundation, either version 3 of the 
; License, or (at your option) any later version.
;
; The neutrino kernel is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with the neutrino kernel. If not, see <http://www.gnu.org/licenses/>.
;
;--------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------
;-----------------------------�rea reservada para constantes---------------------------------
EVENT_PTR              EQU 100Eh
EVENT_BUFFER_SIZE      EQU 5
EVENT_SIGNATURE        EQU 089ABCDEFh

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para registros---------------------------------
;@description: Organiza��o do sistema de eventos em mem�ria. O sistema de eventos � carregado na posi��o 100Eh "EVENT_PTR".
struc tEvent
	.status         RESB 1
	.buffer         RESD EVENT_BUFFER_SIZE
	.bufferSize     RESB 1
	.bufferBegin    RESD 1
	.bufferEnd      RESD 1
	.code           RESB 0
endstruc

;@description: Lista de eventos suportados.
struc tEventListener
	%macro RES_TEVENTLISTENER 0-1 .
		%1onKeyDown      RESD 1
		%1onKeyUp        RESD 1
		%1onMouseOver    RESD 1
		%1onMouseOut     RESD 1
		%1onFocus        RESD 1
		%1onMouseDownL   RESD 1
		%1onMouseDownR   RESD 1
		%1onMouseDownM   RESD 1
		%1onMouseUpL     RESD 1
		%1onMouseUpR     RESD 1
		%1onMouseUpM     RESD 1
	%endmacro
	
	RES_TEVENTLISTENER
endstruc

;--------------------------------------------------------------------------------------------	
;@description: Fun��o para agendar um tratador de eventos para um processo. A fun��o � inserida em um buffer e posteriormente executada.
;@input: EAX << base do processo, EDX << handler
;@output: -
;@author: alisson_linhares@hotmail.com
event_CallProcessHandler:
	;Verifica se ESI � uma base para um processo v�lido e se pode ser inserido um novo tratador no buffer.
	CMP EDX,STACK_SIZE
	JBE .abort 
	CMP DWORD[EAX + BCP_PTR + bcp.signature],BCP_SIGNATURE
	JNE .abort
	CMP BYTE[EAX + EVENT_PTR + tEvent.bufferSize],EVENT_BUFFER_SIZE
	JAE .abort
		PUSH EDI
		MOV EDI,DWORD[EAX + EVENT_PTR + tEvent.bufferEnd]

		;Verifica se o ponteiro para o final do buffer est� entre o espa�o reservado para o buffer
		CMP EDI,EVENT_PTR + tEvent.buffer
		JB .resetEventtem
		CMP EDI,EVENT_PTR + tEvent.buffer + EVENT_BUFFER_SIZE * 4
		JB .registerNewHandler
		.resetEventtem:
			;Reconfigurando o registro de eventos.
			MOV DWORD[EAX + EVENT_PTR + tEvent.bufferEnd  ],EVENT_PTR + tEvent.buffer	
			MOV DWORD[EAX + EVENT_PTR + tEvent.bufferBegin],EVENT_PTR + tEvent.buffer	
			MOV BYTE [EAX + EVENT_PTR + tEvent.bufferSize ],0
			MOV BYTE [EAX + EVENT_PTR + tEvent.status     ],0

			;Informando ao kernel sobre a falha
			error_Notification EVENT_BUFFER_VIOLATION
			JMP .eventSystemError
		.registerNewHandler:
			;Verifica se o buffer deve ser reiniciado
			CMP DWORD[EAX + EVENT_PTR + tEvent.bufferEnd],EVENT_PTR + tEvent.buffer + (EVENT_BUFFER_SIZE - 1) * 4
			JAE .resetPosition
				ADD DWORD[EAX + EVENT_PTR + tEvent.bufferEnd],4
				JMP .bufferConfigured
			.resetPosition:
				MOV DWORD[EAX + EVENT_PTR + tEvent.bufferEnd],EVENT_PTR + tEvent.buffer					
			.bufferConfigured:
			
			MOV DWORD[EAX + EDI],EDX ;Inserindo tratador 	   
			INC BYTE [EAX + EVENT_PTR + tEvent.bufferSize] ;Incremento o total de elementos do buffer		
		.eventSystemError:
		
		POP EDI
	.abort:
	RET

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando uma tecla � pressionada "Evento do teclado".
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnKeyDown 0
	gui_OnKeyDown
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando uma tecla � liberada "Evento do teclado".
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnKeyUp 0
	gui_OnKeyUp
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o mouse � movimentado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseMove 0
	gui_OnMouseMove
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o mouse � movimentado com o bot�o direito pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseDrag 0
	gui_OnMouseDrag
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � liberado ap�s um gui_OnMouseDrag.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseDrop 0 
	gui_OnMouseDrop
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o esquerdo do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseLeft 0
	gui_OnMouseLeft
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseRight 0
	gui_OnMouseRight
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o do meio do mouse � pressionado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseMiddle 0
	gui_OnMouseMiddle 
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o esquerdo do mouse � liberado
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseUpLeft 0
	gui_OnMouseUpLeft
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o direito do mouse � liberado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseUpRight 0
	gui_OnMouseUpRight
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro que � executada quando o bot�o do meio do mouse � liberado.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro event_OnMouseUpMiddle 0
	gui_OnMouseUpMiddle
%endmacro