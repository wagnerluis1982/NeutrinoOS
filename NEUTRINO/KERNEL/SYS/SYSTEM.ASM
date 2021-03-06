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
;-----------------------------�rea reservada para constantes---------------------------------
STACK_EDI          EQU 0
STACK_ESI          EQU 4
STACK_EBP          EQU 8
STACK_ESP          EQU 12
STACK_EBX          EQU 16
STACK_EDX          EQU 20
STACK_ECX          EQU 24
STACK_EAX          EQU 28

SYSTEM_SIGNATURE   EQU 0x89ABCDEF

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para registros---------------------------------
;@description: Modelo do registro usado para troca de informa��es entre a nlib e o kernel.
struc tSystemInfo
	.signature     RESD 1
	.status        RESD 1
	.version       RESW 1
	.mode          RESB 1 ;Modo de opera��o do sistema [DEBUG_MODE: 2, TEXT_MODE: 1, GRAPHICS_MODE: 0]
endstruc

;--------------------------------------------------------------------------------------------	
;@description: Tabelas de descritores do sistema [GDT e IDT].
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
GDT  DB 0,0,0,0,0,0,0,0                    ;GDT do modo real
KERNEL_CODE  EQU $ - GDT                   ;Segmento de c�digo [CS 08h]             "Kernel Ring0" 
	DW 0FFFFh,0
	DB 0,09Ah,0CFh,0
KERNEL_DATA  EQU $ - GDT                   ;Segmento de dados  [DS,ES,SS,FS,GS 10h] "Users Ring0"
	DW 0FFFFh,0
	DB 0,092h,0CFh,0
USER_CODE    EQU $ - GDT                   ;Segmento de c�digo [CS 08h]             "Users Ring0" 
	DW 0FFFFh,0
	DB 0,09Ah,0CFh,0
USER_DATA    EQU $ - GDT                   ;Segmento de dados  [DS,ES,SS,FS,GS 10h] "Users Ring0"                
	DW 0FFFFh,0h
	DB 0,092h,0CFh,0
PGDT    DW $ - GDT - 1                        ;Tamanho da GDT
	DD GDT                                ;OffSet da GDT
IDT     DW error_Isr0           ,08h,08F00h,0 ;Divide error     
	DW error_Isr1           ,08h,08F00h,0 ;Debug exceptions 
	DW error_Isr2           ,08h,08F00h,0 ;Nonmaskable interrupt exception
	DW error_Isr3           ,08h,08F00h,0 ;Breakpoint exception
	DW error_Isr4           ,08h,08F00h,0 ;Overflow exception
	DW error_Isr5           ,08h,08F00h,0 ;Bounds check exception
	DW error_Isr6           ,08h,08F00h,0 ;Invalid opcode exception
	DW error_Isr7           ,08h,08F00h,0 ;Coprocessor not available exception
	DW error_Isr8           ,08h,08F00h,0 ;Double fault exception
	DW error_Isr9           ,08h,08F00h,0 ;Coprocessor segment overrun exception
	DW error_IsrA           ,08h,08F00h,0 ;Invalid TSS exception
	DW error_IsrB           ,08h,08F00h,0 ;Segment not present
	DW error_IsrC           ,08h,08F00h,0 ;Stack exception
	DW error_IsrD           ,08h,08F00h,0 ;General protection exception
	DW error_IsrE           ,08h,08F00h,0 ;Page fault exception
	DW error_IsrF           ,08h,08F00h,0 ;Intel reserved
	DW error_Isr10          ,08h,08F00h,0 ;Coprecessor error
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW scheduler_IrqHandler ,08h,08F00h,0 ;System Timer
	DW keyboard_IrqHandler  ,08h,08F00h,0 ;Keyboard
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;COM2
	DW system_DefaultHandler,08h,08F00h,0 ;COM1
	DW system_DefaultHandler,08h,08F00h,0 ;LPT2
	DW system_DefaultHandler,08h,08F00h,0 ;Floppy disk drive
	DW system_DefaultHandler,08h,08F00h,0 ;LPT1
	DW system_DefaultHandler,08h,08F00h,0 ;CMOS Real Time Clock
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW system_DefaultHandler,08h,08F00h,0 ;Intel reserved
	DW mouse_IrqHandler     ,08h,08F00h,0 ;PS/2 Mouse  
	DW system_DefaultHandler,08h,08F00h,0 ;Numeric coprocessor
	DW ata_MasterIrqHandler ,08h,08F00h,0 ;Hard disk drive IDE1
	DW ata_SlaveIrqHandler  ,08h,08F00h,0 ;Hard disk drive IDE2
	DW isr0x30_IrqHandler   ,08h,08E00h,0 ;Neutrino System Calls
PIDT    DW $ - IDT - 1   
	DD IDT  

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para vari�veis--------------------------------- 
system:
.status                DD 0
.irqsEnabled           DB 1 ;Vari�vel de controle das irqs.
.mode                  DB OPERATION_MODE ;Se o debug estiver desativado o sistema tentar� iniciar em modo gr�fico. Em caso de erro na configura��o, est� vari�vel ser� setado com 1 e o sistema entrar� em modo texto.
.bootPath              DB 'a\boot\',0 ;Local da pasta de boot

;--------------------------------------------------------------------------------------------	
;@description: Macros para iniciar todos os programas de boot do sistema e configurar os principais dispositivos.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro system_Start 0
	memory_Check           ;Carregando informa��es da Mem�ria.
   
	video_Install          ;Configurando o V�deo.
	system_PMInstall       ;Configurando o modo protegido.
	system_IsrInstall      ;Configurando o PIC 8259a e instalando as ISRs.
	mouse_Install          ;Instalando o mouse.
	
	memory_Config          ;Configurando o gerente de mem�ria.
	storage_Config         ;Configurando o gerente de disco.

	;Procurando pela pasta de boot. Em caso de falha aborta o procedimento.
	MOV ESI,system.bootPath
	CALL nfs_Find
	JC %%abort
		MOV EBP,DWORD[EDI + tSubNode.size   ]
		MOV EBX,DWORD[EDI + tSubNode.dataPtr]
		
		%%nextSector:
			;Lendo dados da pasta a\boot\0, em caso de erro aborta o procedimento.
			MOV ECX,1
			MOV EDI,kernel_Buffer
			CALL storage_ReadPage ;Lendo uma p�gina do disco.
			JC %%abort
			
			MOV EAX,EDI

			%%startLoop:
				;Se o buffer estiver vazio aborta o procedimento.
				CMP DWORD[EAX],0                        
				JE %%abort
				
				;S� pode iniciar arquivos bin�rios.
				TEST BYTE[EAX + tSubNode.type],NFS_SUBNODETYPE_BINARY
				JZ %%invalidType
					PUSH EBX
					
					LEA ESI,[EAX + tSubNode.name]             ;Ponteiro para o nome do processo.
					MOV EBX,DWORD[EAX + tSubNode.dataPtr]     ;Setor do programa.
					MOV ECX,DWORD[EAX + tSubNode.size]        ;Total de p�ginas que devem ser alocada.

					;Reservando o espa�o para pilha e mem�ria din�mica.
					ADD ECX,(STACK_SIZE + DYNAMIC_MEM_SIZE)/MEMORY_PAGE_SIZE

					;Alocando mem�ria para o processo. Caso n�o exista memoria livre o sistema pula a inicializa��o deste processo.
					CALL memory_AllocatePage                        
					JC %%continue
						ADD EDI,STACK_SIZE
						SUB ECX,(STACK_SIZE + DYNAMIC_MEM_SIZE)/MEMORY_PAGE_SIZE
						
						;Carregando dados para depois da pilha
						CALL storage_ReadPage
						JC %%storageError
							SUB EDI,STACK_SIZE
							ADD ECX,(STACK_SIZE + DYNAMIC_MEM_SIZE)/MEMORY_PAGE_SIZE
							;Configurando o processo
							CALL scheduler_ConfigProcess
							JMP %%continue
						%%storageError:
						
						;Desalocando mem�ria do processo
						SUB EDI,STACK_SIZE
						ADD ECX,(STACK_SIZE + DYNAMIC_MEM_SIZE)/MEMORY_PAGE_SIZE
						CALL memory_DeallocatePage
					%%continue:
					
					POP EBX
				%%invalidType:
				
				;Vai para o pr�ximo arquivo e verifica se a p�gina terminou.
				ADD EAX,tSubNode_size
			CMP EAX,kernel_Buffer + MEMORY_PAGE_SIZE
			JB %%startLoop                                      
			
			;Vai para a p�xima p�gina. Se n�o tiver mais nenhuma, o procedimento termina.
			INC EBX
		DEC EBP
		JNZ %%nextSector
	%%abort:
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro respons�vel por ativar e entrar no modo protegido.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro system_PMInstall 0
	[BITS 16]

	;Mascarando IRQ "Destativando o APIC"
	MOV AL,255
	OUT 0A1h,AL             
	OUT 021h,AL

	;Verificando se a porta 64h est� liberada para escrita.
	CALL system_WritePort60
	MOV AL,0D1h                       
	OUT 64h,AL
	
	;1 - Ativando a linha A20 para obter mais de 1mb de mem�ria.
	CALL system_WritePort60                
	MOV AL,0DFh                            
	OUT 60h,AL
	CALL system_WritePort60

	;2 - Carregando GDT
	LGDT [PGDT]

	;3 - Carregando IDT
	LIDT [PIDT]

	;4 - Setando o bit PE para que o sistema possa trabalhar em modo protegido.
	MOV EAX,CR0
	OR  EAX,1
	MOV CR0,EAX

	;Configurando CS para usar a base de endere�amento do kernel.
	JMP KERNEL_CODE:CS_PM_CONFIG
		[bits 32] ;Informando ao nasm para trabalhar em modo 32bits.
	CS_PM_CONFIG:

	;Configurando os registradores de dados para usar a base de endere�amento do kernel.
	MOV AX,KERNEL_DATA
	MOV DS,AX
	MOV ES,AX
	MOV FS,AX
	MOV GS,AX
	MOV SS,AX 
	
	;Configurando a pilha.
	MOV ESP,kernel_Stack
%endmacro
  
;--------------------------------------------------------------------------------------------
;@description: Macro respons�vel por configurar o sistema de interrup��es.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro system_IsrInstall 0 
	;Instalando todas as fun�oes do kernel.
	isr0x30_Install

	;Configurando IRQ 0...15 [Reprogramando o PIC 8259A]
	CLI
	MOV AL,011h             
	OUT 0A0h,AL              
	OUT 020h,AL
	
	;Configurando as IRQs 0h...7h para 20h...27h
	MOV AL,020h    
	OUT 021h,AL
	
	;Configurando as IRQs 8h...15h para 28h...2Fh
	MOV AL,028h
	OUT 0A1h,AL

	MOV AL,04h            
	OUT 021h,AL
	MOV AL,02h
	OUT 0A1h,AL

	MOV AL,01h 
	OUT 021h,AL
	OUT 0A1h,AL
	
	;Em alguns PCs as interrup��es ficam desativadas. Limpando a porta 21h e A1h para ativar as interrup��es.
	XOR AL,AL
	OUT 021h,AL
	OUT 0A1h,AL
	STI
%endmacro

;--------------------------------------------------------------------------------------------
;@description: Macros para controle de concorr�ncia. 
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
%macro system_Lock 0
	INC BYTE[system.irqsEnabled] ;Desativa o escalonamento de processos e todas as interrup��es de software. 
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macros para controle de concorr�ncia.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
%macro system_Unlock 0
	DEC BYTE[system.irqsEnabled] ;Ativando o escalonamento de processos e todas as interrup��es de software. 
%endmacro     

;--------------------------------------------------------------------------------------------	
;@description: Macros para desativar um sem�foro.
;@input: %1 << endere�o do sem�foro
;@output: -
;@author: alisson_linhares@hotmail.com
%macro system_SemaphoreUnlock 1
	MOV DWORD[%1],0
%endmacro

;--------------------------------------------------------------------------------------------	
;@description: Macro para trocar o contexto de execu��o.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
%macro system_Sleep 0
	CLI 
	INT 20h ;Escalonador do sistema
	STI
%endmacro	

;--------------------------------------------------------------------------------------------	
;@description: Procedimento para ativar um sem�foro do sistema.
;@input: EBP << ponteiro para o sem�foro  
;@output: -
;@author: alisson_linhares@hotmail.com
system_SemaphoreLock:
	PUSH EAX
		
	.checkSemaphore:
		;Trava o escalonador 
		system_Lock

		MOV EAX,DWORD[scheduler.currentProcess]

		;Continua se o sem�foro estiver desarmado ou em uso pelo mesmo processo   
		CMP DWORD[DS:EBP],0
		JE .done
		CMP DWORD[DS:EBP],EAX
		JE .done

		;Destrava o escalonador e troca o contexto  
		system_Unlock
		system_Sleep
	JMP .checkSemaphore           
	.done:
	
	;Seta o sem�foro com a base do processo
	MOV DWORD[DS:EBP],EAX               
	system_Unlock

	POP EAX
	RET
	
;--------------------------------------------------------------------------------------------
;@description: Procedimento para desarmar todos os sem�foros do sistema.
;@input: EDI << bcp do processo, EAX << valor do sem�foro
;@output: -
;@author: alisson_linhares@hotmail.com
system_SemaphoresDisarm:
	PUSH EBX
	system_Lock
	
	;Desarmando sem�foros dos paineis
	CMP EDI,DWORD[panel.semaphore]
	JNE .disarmPanelSemaphore
		MOV DWORD[panel.semaphore],EAX
	.disarmPanelSemaphore:
	
	;Desarmando sem�foros dos dispositivos ATA
	CMP EDI,DWORD[ata.channel0 + tATAController.semaphore]
	JNE .disarmATA0Semaphore
		MOV DWORD[ata.channel0 + tATAController.semaphore],EAX
	.disarmATA0Semaphore:

	CMP EDI,DWORD[ata.channel1 + tATAController.semaphore]
	JNE .disarmATA1Semaphore
		MOV DWORD[ata.channel1 + tATAController.semaphore],EAX
	.disarmATA1Semaphore:

	;Desarmando sem�foros do gerente de disco
	XOR EBX,EBX
	JMP .startLoop

	.loop:
		CMP EDI,DWORD[EBX + storage.diskList + tStorage.semaphore]
		JNE .continue
			MOV DWORD[EBX + storage.diskList + tStorage.semaphore],EAX
		.continue:

		ADD EBX,tStorage_size
	.startLoop:
	CMP EBX,DWORD[storage.lastStorageIndex]
	JLE .loop

	;Desarmando sem�foros do gerente de mem�ria
	CMP EDI,DWORD[memory.semaphore]
	JNE .disarmMemorySemaphore
		MOV DWORD[memory.semaphore],EAX
	.disarmMemorySemaphore:
	
	system_Unlock
	POP EBX
	RET	

;--------------------------------------------------------------------------------------------	
;@description: Procedimento projetado para resetar o sistema.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
system_Reboot:
	system_Lock
	
	;Desalocando recursos do sistema.
	MOV EDI,KILL_ALL_PROCESS
	CALL scheduler_KillProcess
	XOR EDI,EDI
	CALL scheduler_KillProcess
	
	;For�ando o reset do sistema. Usando em caso de falhas.
.REBOOT_NOW__:

	;Preparando para escrever na porta 60h
	CALL system_WritePort60
	
	;Mandando FEh para controladora de teclado
	MOV AL,0FEh
	OUT 064h,AL                            
	
	PUSH DWORD SYSTEM_REBOOT_ERROR
	CALL error_ThrowException
	JMP $

;--------------------------------------------------------------------------------------------	
;@description: Procedimento projetado para retornar informa��es do sistema.
;@input: EDI << tSystemInfo
;@output: -
;@author: alisson_linhares@hotmail.com
system_GetInfo:
	;Verifica se o registro enviado � v�lido.
	CMP DWORD[SS:EDI + tSystemInfo.signature],SYSTEM_SIGNATURE
	JNE .abort
		PUSH EAX

		;Inserindo valores no registro.
		MOV EAX,DWORD[system.status]
		MOV DWORD[SS:EDI + tSystemInfo.status],EAX
		
		MOV WORD[SS:EDI + tSystemInfo.version],KERNEL_VERSION
		
		MOV AL,BYTE[system.mode]
		MOV BYTE[SS:EDI + tSystemInfo.mode],AL

		POP EAX
	.abort:
	RET

;--------------------------------------------------------------------------------------------	
;@description: Tratador padr�o para irqs. Apenas retorna ao programa.
;@input: -
;@output: -
;@author: alisson_linhares@hotmail.com
system_DefaultHandler:
	PUSH AX
	MOV AL,020h
	OUT 020h,AL
	POP AX	
	IRETD ;Retorna para o programa
	
[BITS 16] 

;--------------------------------------------------------------------------------------------	
;@description: Fun��o que espera a controladora de teclado ficar pronta para escrita. 
;@remarks: Toda entrada na porta 60h deve ser precedida de espera.
;@input: -
;@output: AL >> status
;@author: alisson_linhares@hotmail.com
system_WritePort60:                 
	.writeLoop: 
		;Esperando a controlador ficar pronta para escrita
		IN AL,064h                  
	AND AL,2           
	JNZ .writeLoop
	RET
	
;--------------------------------------------------------------------------------------------	
;@description: Fun��o que espera a controladora de teclado ficar pronta para leitura. 
;@remarks: Toda entrada na porta 60h deve ser precedida de espera.
;@input: -
;@output: AL >> status
;@author: alisson_linhares@hotmail.com
system_ReadPort60:
	.readLoop:
		IN AL,064h
	AND AL,1           
	JZ .readLoop
	RET

[BITS 32]