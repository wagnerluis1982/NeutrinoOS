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
;@description: Conjunto de fun��es da int 30h.
struc isr0x30
	.prompt_PrintChar         RESD 1   ;EAX << 00; Fun��o para imprimir caracter no prompt de comando.
	.prompt_PrintString       RESD 1   ;EAX << 01; Fun��o para imprimir string no prompt de comando.
	.prompt_PrintInteger      RESD 1   ;EAX << 02; Fun��o para imprimir um valor num�rico no prompt de comando.
	.prompt_Clear             RESD 1   ;EAX << 03; Fun��o para limpar o prompt de comando.
	.prompt_Create            RESD 1   ;EAX << 04; Fun��o para criar um prompt de comando.
	.prompt_Reserved_0        RESD 1   ;EAX << 05; Reservado para uso futuro.
	.prompt_Reserved_1        RESD 1   ;EAX << 06; Reservado para uso futuro.
	.prompt_Reserved_2        RESD 1   ;EAX << 07; Reservado para uso futuro.
	
	.keyboard_ReadKey         RESD 1   ;EAX << 08; Fun��o para ler caracter do buffer de teclado.
	.keyboard_ReadString      RESD 1   ;EAX << 09; Fun��o para ler conjunto de caracteres do teclado.
	.keyboard_GetInfo         RESD 1   ;EAX << 10; Reservado para uso futuro.
	.keyboard_Reserved_0      RESD 1   ;EAX << 11; Reservado para uso futuro.
	.keyboard_Reserved_1      RESD 1   ;EAX << 12; Reservado para uso futuro.
	
	.video_CopyArea           RESD 1   ;EAX << 13; Fun��o para copiar �rea do v�deo para um buffer
	.video_ClearArea          RESD 1   ;EAX << 14; Fun��o para escrever conte�do do buffer de v�deo em na tela.
	.video_PaintArea          RESD 1   ;EAX << 15; Fun��o para pintar uma �rea do v�deo com um mapa de bits
	.video_Bgcolor            RESD 1   ;EAX << 16; Fun��o parar pintar o fundo com uma cor s�lida.
	.video_Reset              RESD 1   ;EAX << 17; Fun��o para copiar o buffer principal para o de v�deo.
	.video_DrawRectangle      RESD 1   ;EAX << 18; Fun��o para escrever um ret�ngulo.
	.video_PaintRectangle     RESD 1   ;EAX << 19; Fun��o para pintar �rea retangular.
	.video_DrawNIF            RESD 1   ;EAX << 20; Fun��o para escrever uma imagem nif na tela.
	.video_DrawNIF2           RESD 1   ;EAX << 21; Fun��o para escrever uma imagem nif na tela.
	.video_GetInfo            RESD 1   ;EAX << 22; Fun��o que retorna informa��es do v�deo.
	.video_DrawBitmap         RESD 1   ;EAX << 23; Fun��o para pintar um mapa de bits no v�deo.
	.video_Reserved_1         RESD 1   ;EAX << 24; Reservado para uso futuro.
	.video_Reserved_2         RESD 1   ;EAX << 25; Reservado para uso futuro.
	
	.panel_Open               RESD 1   ;EAX << 26; Fun��o para inserir um painel na lista de renderiza��o.
	.panel_Close              RESD 1   ;EAX << 27; Fun��o para remover o painel da lista de renderiza��o. 
	.panel_Add                RESD 1   ;EAX << 28; Fun��o para inserir um component no painel.
	.panel_Remove             RESD 1   ;EAX << 29; Fun��o para remover um component do painel.
	.panel_Draw               RESD 1   ;EAX << 30; Fun��o para pintar um painel em modo gr�fico.
	.panel_DrawComponent      RESD 1   ;EAX << 31; Fun��o para pintar um component do painel.
	.panel_DrawAll            RESD 1   ;EAX << 32; Fun��o para repintar todos os pain�is contidos na lista de renderiza��o.
	.panel_GetInfo            RESD 1   ;EAX << 33; Fun��o que retorna informa��es do sistema de paineis.
	.panel_Reserved_0         RESD 1   ;EAX << 34; Reservado para uso futuro.
	.panel_Reserved_1         RESD 1   ;EAX << 35; Reservado para uso futuro.
	
	.scheduler_StartProcess   RESD 1   ;EAX << 36; Fun��o para iniciar um processo.
	.scheduler_KillProcess    RESD 1   ;EAX << 37; Fun��o para matar um processo.
	.scheduler_GetInfo        RESD 1   ;EAX << 38; Fun��o para retornar informa�oes do scheduler.
	.scheduler_Reserved_0     RESD 1   ;EAX << 39; Reservado para uso futuro.
	.scheduler_Reserved_1     RESD 1   ;EAX << 40; Reservado para uso futuro.
	.scheduler_Reserved_2     RESD 1   ;EAX << 41; Reservado para uso futuro.
	
	.storage_AllocatePage     RESD 1   ;EAX << 42; Fun��o para alocar uma p�gina em disco.
	.storage_DeallocatePage   RESD 1   ;EAX << 43; Fun��o para desalocar uma p�gina em disco.
	.storage_GetInfo          RESD 1   ;EAX << 44; Fun��o para retornar informa��es dos discos.
	.storage_Reserved_0       RESD 1   ;EAX << 45; Reservado para uso futuro.
	.storage_Reserved_1       RESD 1   ;EAX << 46; Reservado para uso futuro.
	.storage_Reserved_2       RESD 1   ;EAX << 47; Reservado para uso futuro.
	
	.memory_Free              RESD 1   ;EAX << 48; Fun��o para desalocar mem�ria din�mica.
	.memory_Malloc            RESD 1   ;EAX << 49; Fun��o para alocar mem�ria din�mica.
	.memory_AllocatePage      RESD 1   ;EAX << 50; Fun��o para alocar uma p�gina de mem�ria.
	.memory_DeallocatePage    RESD 1   ;EAX << 51; Fun��o para desalocar uma p�gina de mem�ria.
	.memory_GetInfo           RESD 1   ;EAX << 52; Fun��o para retornar informa��es do gerente de mem�ria.
	.memory_Reserved_0        RESD 1   ;EAX << 53; Reservado para uso futuro.
	.memory_Reserved_1        RESD 1   ;EAX << 54; Reservado para uso futuro.
	.memory_Reserved_2        RESD 1   ;EAX << 55; Reservado para uso futuro.
	
	.nfs_OpenData             RESD 1   ;EAX << 56; Fun��o para abrir um arquivo para leitura.
	.nfs_ReadData             RESD 1   ;EAX << 57; Fun��o para ler o pr�ximo bloco de dados do disco.
	.nfs_WriteData            RESD 1   ;EAX << 58, Fun��o para escrever dados em disco.
	.nfs_CreateNode           RESD 1   ;EAX << 59; Fun��o para criar um arquivo em disco.
	.nfs_DeleteNode           RESD 1   ;EAX << 60; Fun��o para deletar um arquivo em disco.
	.nfs_Reserved_0           RESD 1   ;EAX << 61; Reservado para uso futuro.
	.nfs_Reserved_1           RESD 1   ;EAX << 62; Reservado para uso futuro.
	.nfs_Reserved_2           RESD 1   ;EAX << 63; Reservado para uso futuro.
	
	.system_Reboot            RESD 1   ;EAX << 64; Fun��o para resetar o sistema.
	.system_GetInfo           RESD 1   ;EAX << 65; Fun��o para ler informa��es dos gerentes do sistema.
	.system_Reserved_0        RESD 1   ;EAX << 66; Reservado para uso futuro.
	.system_Reserved_1        RESD 1   ;EAX << 67; Reservado para uso futuro.
	.system_Reserved_2        RESD 1   ;EAX << 68; Reservado para uso futuro.
	
	.cmos_GetTimer            RESD 1   ;EAX << 69; Fun��o que retorna data e hora do sistema.
	.mouse_GetInfo            RESD 1   ;EAX << 70; Fun��o que retorna informa��es do mouse.
	.utilities_Reserved_0     RESD 1   ;EAX << 71; Reservado para uso futuro.
	.utilities_Reserved_1     RESD 1   ;EAX << 72; Reservado para uso futuro.	
endstruc

;--------------------------------------------------------------------------------------------	
;@description: Macro respons�vel por remover todos os tratadores de interrup��o.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
%macro isr0x30_Clear 0
	MOV EAX,isr0x30_DefaultHandler
	MOV ECX,isr0x30_size/4
	XOR EDI,EDI
	CLD
	REP STOSD ;Movendo isr0x30_DefaultHandler para todas as posi��es da tabela de interrup��es 
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro respons�vel por instalar todas as fun��es na mem�ria.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
%macro isr0x30_Install 0

	;Limpando todos os tratadores reservados.
	isr0x30_Clear
	
	;Verifica qual o modo de v�deo.
	CMP BYTE[system.mode],GRAPHICS_MODE 
	JE %%graphicsMode
		MOV DWORD[isr0x30.keyboard_ReadKey],keyboard_ReadKey
		JMP %%textMode
	%%graphicsMode:
		;Instalando fun��es de v�deo
		MOV DWORD[isr0x30.video_GetInfo           ],video_GetInfo
		
		;Verifica qual drive deve ser instalado (16bpp ou 24bpp)
		CMP BYTE[video.bpp],2 
		JE %%vesa16 
			MOV DWORD[isr0x30.video_ClearArea     ],video_ClearArea_24
			MOV DWORD[isr0x30.video_PaintArea     ],video_PaintArea_24       
			MOV DWORD[isr0x30.video_Bgcolor       ],video_Bgcolor_24
			MOV DWORD[isr0x30.video_CopyArea      ],video_CopyArea_24
			MOV DWORD[isr0x30.video_Reset         ],video_Reset_24
			MOV DWORD[isr0x30.video_DrawRectangle ],video_DrawRectangle_24
			MOV DWORD[isr0x30.video_PaintRectangle],video_PaintRectangle_24
			MOV DWORD[isr0x30.video_DrawNIF       ],video_DrawNIF_24
			MOV DWORD[isr0x30.video_DrawNIF2      ],video_DrawNIF2_24
			MOV DWORD[isr0x30.video_DrawBitmap    ],video_DrawBitmap_24
			JMP %%continue
		%%vesa16:
			MOV DWORD[isr0x30.video_ClearArea     ],video_ClearArea_16
			MOV DWORD[isr0x30.video_PaintArea     ],video_PaintArea_16
			MOV DWORD[isr0x30.video_Bgcolor       ],video_Bgcolor_16
			MOV DWORD[isr0x30.video_CopyArea      ],video_CopyArea_16
			MOV DWORD[isr0x30.video_Reset         ],video_Reset_16
			MOV DWORD[isr0x30.video_DrawRectangle ],video_DrawRectangle_16
			MOV DWORD[isr0x30.video_PaintRectangle],video_PaintRectangle_16
			MOV DWORD[isr0x30.video_DrawNIF       ],video_DrawNIF_16
			MOV DWORD[isr0x30.video_DrawNIF2      ],video_DrawNIF2_16
			MOV DWORD[isr0x30.video_DrawBitmap    ],video_DrawBitmap_16
		%%continue:
		
		;Instalando fun��es do teclado
		MOV DWORD[isr0x30.keyboard_ReadKey        ],keyboard_GuiReadKey
	%%textMode:	
    
	MOV DWORD[isr0x30.keyboard_ReadString],keyboard_ReadString 
	MOV DWORD[isr0x30.keyboard_GetInfo   ],keyboard_GetInfo

	;Instalando fun��es do prompt de comando
	MOV DWORD[isr0x30.prompt_PrintChar   ],prompt_PrintChar
	MOV DWORD[isr0x30.prompt_PrintString ],prompt_PrintString
	MOV DWORD[isr0x30.prompt_PrintInteger],prompt_PrintInteger
	MOV DWORD[isr0x30.prompt_Clear       ],prompt_Clear
	MOV DWORD[isr0x30.prompt_Create      ],prompt_Create
	
	;Instalando fun��es da GUI	      
	MOV DWORD[isr0x30.panel_Open         ],panel_Open 
	MOV DWORD[isr0x30.panel_Close        ],panel_Close
	MOV DWORD[isr0x30.panel_Add          ],panel_Add
	MOV DWORD[isr0x30.panel_Remove       ],panel_Remove
	MOV DWORD[isr0x30.panel_Draw         ],panel_Draw 
	MOV DWORD[isr0x30.panel_DrawComponent],panel_DrawComponent    
	MOV DWORD[isr0x30.panel_DrawAll      ],panel_DrawAll
	MOV DWORD[isr0x30.panel_GetInfo      ],panel_GetInfo

	;Instalando fun��es do escalonador
	MOV DWORD[isr0x30.scheduler_StartProcess],scheduler_StartProcess
	MOV DWORD[isr0x30.scheduler_KillProcess ],scheduler_KillProcess
	MOV DWORD[isr0x30.scheduler_GetInfo     ],scheduler_GetInfo
	
	;Instalando fun��es do gerente de mem�ria
	MOV DWORD[isr0x30.memory_AllocatePage  ],memory_AllocatePage
	MOV DWORD[isr0x30.memory_DeallocatePage],memory_DeallocatePage
	MOV DWORD[isr0x30.memory_Malloc        ],memory_Malloc
	MOV DWORD[isr0x30.memory_Free          ],memory_Free
	MOV DWORD[isr0x30.memory_GetInfo       ],memory_GetInfo
	
	;Instalando fun��es do gerente de disco
	MOV DWORD[isr0x30.storage_AllocatePage  ],storage_AllocatePage
	MOV DWORD[isr0x30.storage_DeallocatePage],storage_DeallocatePage
	MOV DWORD[isr0x30.storage_GetInfo       ],storage_GetInfo
	
	;Instalando fun��es do gerente de arquivos
	MOV DWORD[isr0x30.nfs_OpenData  ],nfs_OpenData
	MOV DWORD[isr0x30.nfs_ReadData  ],nfs_ReadData
	MOV DWORD[isr0x30.nfs_WriteData ],nfs_WriteData
	MOV DWORD[isr0x30.nfs_CreateNode],nfs_CreateNode
	MOV DWORD[isr0x30.nfs_DeleteNode],nfs_DeleteNode
	
	;Instalando fun��es do sistema
	MOV DWORD[isr0x30.system_Reboot ],system_Reboot
	MOV DWORD[isr0x30.system_GetInfo],system_GetInfo
	MOV DWORD[isr0x30.cmos_GetTimer ],cmos_GetTimer
	MOV DWORD[isr0x30.mouse_GetInfo ],mouse_GetInfo
%endmacro  

;--------------------------------------------------------------------------------------------	
;@description: Tratador de interrup��es da int 30h.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
isr0x30_IrqHandler:
	CMP BYTE[CS:system.irqsEnabled],0              
	JA .abort
	CMP EAX,isr0x30_size / 4 ;Verifica se a chamada � v�lida
	JA .abort
		PUSH DS
		PUSH AX
		MOV AX,KERNEL_DATA
		MOV DS,AX
		MOV ES,AX 
		POP AX
		
		CALL DWORD[DS:EAX * 4] ;Chamando a fun��o
		
		MOV ES,WORD[ESP]
		POP DS
	.abort:
	IRET

;--------------------------------------------------------------------------------------------	
;@description: Tratador padr�o. Apenas retorna para o c�digo do chamador.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
isr0x30_DefaultHandler:
	RET