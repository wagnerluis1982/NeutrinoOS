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
STORAGE_INVALID        EQU 0h ;8Bits identificadores de dispositivos
STORAGE_PATA           EQU 1h    
STORAGE_PATAPI         EQU 2h
STORAGE_SATA           EQU 3h
STORAGE_SATAPI         EQU 4h
STORAGE_SCSI           EQU 5h

STORAGE_IDE0_MASTER    EQU 1h ;8Bits complementares         
STORAGE_IDE0_SLAVE     EQU 2h             
STORAGE_IDE1_MASTER    EQU 3h             
STORAGE_IDE1_SLAVE     EQU 4h 

STORAGE_BITS_PER_PAGE  EQU 9
STORAGE_PAGE_SIZE      EQU 1 << STORAGE_BITS_PER_PAGE

STORAGE_SIGNATURE      EQU 0x89ABCDEF
STORAGE_NUM_OF_DISKS   EQU 6

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para registros---------------------------------
;@description: Registro usado para gerenciar as unidades de armazenamento encontradas.
struc tStorage 
	.id            RESW 1
	.reserved      RESW 1
	.semaphore     RESD 1
	.buffer        RESD 1
	.size          RESD 1
endstruc

;@description: Registro usado dentro de tStorageInfo para montar um array de unidades.
struc tDisk
	.type          RESB 1
	.channel       RESB 1
	.size          RESD 1
endstruc

;@description: Modelo do registro usado para troca de informa��es entre a nlib e o kernel.
struc tStorageInfo
	.signature     RESD 1
	.numberOfDisks RESB 1
	.buffer        RESB tDisk_size * STORAGE_NUM_OF_DISKS
endstruc

;--------------------------------------------------------------------------------------------
;------------------------------�rea reservada para vari�veis---------------------------------                    
storage:
.lastStorageIndex      DD 0
.diskList              TIMES tStorage_size * STORAGE_NUM_OF_DISKS DB 0

;--------------------------------------------------------------------------------------------
;@description: Macro para configurar as unidades de disco.
;@input: -
;@output: ALL
;@author: alisson_linhares@hotmail.com
%macro storage_Config 0
	;Carregando informa��es do disco 0
	MOV DX,ATA_0
	MOV AL,0A0h
	MOV BH,STORAGE_IDE0_MASTER
	CALL storage_Identify

	;Carregando informa��es do disco 1
	MOV AL,0B0h
	MOV BH,STORAGE_IDE0_SLAVE
	CALL storage_Identify

	;Carregando informa��es do disco 2 
	MOV DX,ATA_1
	MOV AL,0A0h
	MOV BH,STORAGE_IDE1_MASTER
	CALL storage_Identify

	;Carregando informa��es do disco 3
	MOV AL,0B0h
	MOV BH,STORAGE_IDE1_SLAVE
	CALL storage_Identify

	;Verifica se a unidade de boot foi configurada como master. Caso contr�rio, seta como master a primeira unidade boot�vel no vetor de discos.
	XOR ESI,ESI

	%%nextDisk:
		MOV EDI,DWORD[ESI + storage.diskList + tStorage.buffer] 

		CMP DWORD[EDI + tBootSector.signature],NFS_BOOTSECTOR_SIGNATURE ;Procura pela assinatura do NFS
		JNE %%continue
		CMP BYTE[EDI + tBootSector.bootIndicator],80h ;Verifica se a unidade foi configurada como master.
		JE %%changePosition
		%%continue:
		  
		ADD ESI,tStorage_size
		CMP ESI,DWORD[storage.lastStorageIndex]
		JB %%nextDisk
	%%changePosition:
		;Se a unidade master for a primeira, o disco j� estava configurado corretamente.
		TEST ESI,ESI
		JZ %%done
			storage_XCHGDisk 0,ESI ;Trocando as unidades.
	%%done:
%endmacro

;--------------------------------------------------------------------------------------------
;@description: Macro projetada para trocar a posi��o l�gica dos discos.
;@input: %1 << Disco1, %2 << Disco2
;@output: EAX << Lixo
;@author: alisson_linhares@hotmail.com
%macro storage_XCHGDisk 2
	MOV EAX,DWORD[%2 + storage.diskList + tStorage.id]
	XCHG EAX,DWORD[%1 + storage.diskList + tStorage.id]
	MOV DWORD[%2 + storage.diskList + tStorage.id],EAX

	MOV EAX,DWORD[%2 + storage.diskList + tStorage.semaphore]
	XCHG EAX,DWORD[%1 + storage.diskList + tStorage.semaphore]
	MOV DWORD[%2 + storage.diskList + tStorage.semaphore],EAX

	MOV EAX,DWORD[%2 + storage.diskList + tStorage.buffer]
	XCHG EAX,DWORD[%1 + storage.diskList + tStorage.buffer]
	MOV DWORD[%2 + storage.diskList + tStorage.buffer],EAX

	MOV EAX,DWORD[%2 + storage.diskList + tStorage.size]
	XCHG EAX,DWORD[%1 + storage.diskList + tStorage.size]
	MOV DWORD[%2 + storage.diskList + tStorage.size],EAX
%endmacro

;--------------------------------------------------------------------------------------------
;@description: Procedimento para retornar informa��es das unidades de armazenamento detectadas.
;@remarks: No momento o sistema s� � capaz de detectar unidades IDE.
;@input: EDI << tStorageInfo
;@output: -
;@author: alisson_linhares@hotmail.com
storage_GetInfo:
	CMP DWORD[SS:EDI + tStorageInfo.signature],STORAGE_SIGNATURE
	JNE .abort
		PUSHAD

		ADD EDI,DWORD[SS:BCP_PTR + bcp.base]
		ADD EDI,tStorageInfo.numberOfDisks
		CLD

		;Retornando o total de unidades encontradas.
		MOV EAX,DWORD[storage.lastStorageIndex]
		SHR EAX,4
		STOSB
		
		;Copiando dados importantes do storage.diskList para o buffer do usu�rio.
		MOV EBX,storage.diskList
		JMP .startLoop

		.nextStorage:
			LEA ESI,[EBX + tStorage.id  ]
			MOVSW

			LEA ESI,[EBX + tStorage.size]
			MOVSD

			ADD EBX,tStorage_size
		.startLoop:
			DEC EAX
		JGE .nextStorage

		POPAD
	.abort:
	RET

;--------------------------------------------------------------------------------------------	
;@description: Macro para identificar e configurar as unidades de disco.
;@input: DX << ATA_1 || ATA_0, AL << 0A0h || 0B0h, BH << STORAGE_IDE0_MASTER || STORAGE_IDE0_SLAVE || STORAGE_IDE1_MASTER || STORAGE_IDE1_SLAVE
;@output: -
;@author: alisson_linhares@hotmail.com
storage_Identify:   
	PUSHAD

	;Escolhendo o drive Master "0A0h" ou Slave "0B0h"
	OR DX,6
	OUT DX,AL   

	;Limpando portas "1F2h/172h, 1F3h/173h, 1F4h/174h, 1F5h/175h" da controladora 
	XOR AL,AL
	DEC DX
	OUT DX,AL
	
	DEC DX
	OUT DX,AL

	DEC DX
	OUT DX,AL

	DEC DX
	OUT DX,AL

	;Enviado o comando de identifica��o para controladora "1F7h/177h"
	ADD DX,5
	MOV AL,ATA_IDENTIFY
	OUT DX,AL
	
	;Espera a controladora ficar pronta
	MOV CX,0FFFFh
	.ataIsBusy:
		IN AL,DX
	
		;Verifica se deu time out
		DEC CX
		JZ .invalidDisk
	TEST AL,AL
	JZ  .invalidDisk
	TEST AL,10000000b
	JNZ .ataIsBusy
	
	;Lendo portas 1F4/174 e 1F5/175 da controladora
	SUB DX,2
	IN AL,DX
	MOV AH,AL
	DEC DX
	IN AL,DX
	
	;Verifica o tipo do dispositivo conectado a controladora "Sata, Pata, Satapi, Patapi ou inv�lido"
	TEST AX,AX
	JZ .pata
	CMP AX,0C33Ch
	JE .sata
	CMP AX,0EB14h
	JE .patapi
	CMP AX,09669h
	JNE .invalidDisk
	
	.satapi:
		MOV BL,STORAGE_SATAPI
		JMP .atapi_config
	.patapi:
		MOV BL,STORAGE_PATAPI
		JMP .atapi_config
	.sata:
		MOV BL,STORAGE_SATA
		JMP .ata_config
	.pata:
		MOV BL,STORAGE_PATA
		JMP .ata_config
	.atapi_config:
		XOR EAX,EAX
		JMP .continue
	.ata_config:
		ADD DX,3
		
		;Verifica se o drive est� pronto para enviar informa��es sobre o disco
		.ataIsReady:
			IN AL,DX
		TEST AL,00000001b
		JNZ  .invalidDisk
		TEST AL,00001000b 
		JZ .ataIsReady

		;Carregando informa��es para o buffer de sistema
		CLD
		SUB DX,7
		MOV ECX,256
		MOV EDI,kernel_Buffer
		REP INSW
		
		;Configurando registro de controle do disco
		MOV EAX,DWORD[kernel_Buffer + 120]
	.continue:
		;Alocando um buffer para gerenciar as p�ginas em disco.
		MOV ECX,(STORAGE_PAGE_SIZE * 2) / MEMORY_PAGE_SIZE
		CALL memory_AllocatePage
		JC .invalidDisk
			MOV EDX,DWORD[storage.lastStorageIndex]
			MOV DWORD[EDX + storage.diskList + tStorage.semaphore],0
			MOV DWORD[EDX + storage.diskList + tStorage.buffer   ],EDI
			MOV DWORD[EDX + storage.diskList + tStorage.size     ],EAX
			MOV WORD [EDX + storage.diskList + tStorage.id       ],BX
			ADD DWORD[storage.lastStorageIndex],tStorage_size

			;Carregando o cabe�alho de boot para mem�ria.
			MOV ECX,1
			XOR EBX,EBX ;Cabe�alho do sistema de arquivo
			CALL storage_ReadPage
	.invalidDisk:
	
	POPAD
	RET

;--------------------------------------------------------------------------------------------	
;@description: Procedimento para detectar a configura��o de uma unidade com base no ID.
;@input: DX << tStorage.id
;@output: EDX >> ATA_0 | ATA_1, AL >> ATA_MASTER | ATA_SLAVE, AH >>  ATAPI_MASTER | ATAPI_SLAVE 
;@author: alisson_linhares@hotmail.com
storage_DetectAtaConfig:
	CMP DH,STORAGE_IDE0_MASTER
	JE .pata0Master
	CMP DH,STORAGE_IDE0_SLAVE
	JE .pata0Slave
	CMP DH,STORAGE_IDE1_MASTER
	JE .pata1Master
	CMP DH,STORAGE_IDE1_SLAVE
	JNE .done

	.pata1Slave:
		MOV EDX,ATA_1  
		MOV AX,ATA_SLAVE  + (ATAPI_SLAVE  << 8)
		JMP .done
	.pata0Master:
		MOV EDX,ATA_0 
		MOV AX,ATA_MASTER + (ATAPI_MASTER << 8)
		JMP .done
	.pata0Slave:
		MOV EDX,ATA_0  
		MOV AX,ATA_SLAVE  + (ATAPI_SLAVE  << 8)
		JMP .done
	.pata1Master:
		MOV EDX,ATA_1  
		MOV AX,ATA_MASTER + (ATAPI_MASTER << 8)
	.done:
	RET

;--------------------------------------------------------------------------------------------
;@description: Procedimento para ler p�ginas de um dispositivo de armazenamento secund�rio.
;@input: EDX << diskList index, EBX << page, EDI << buffer, ECX << total de p�ginas
;@output: -
;@author: alisson_linhares@hotmail.com
storage_ReadPage:
	PUSHAD
	
	;Verificando se a unidade � v�lida.
	CMP EDX,DWORD[storage.lastStorageIndex]               
	JAE .abort
		MOV DX,WORD[EDX + storage.diskList + tStorage.id]
		
		CMP DL,STORAGE_PATA
		JE .pata
		CMP DL,STORAGE_PATAPI
		JE .patapi
		CMP DL,STORAGE_SATA
		JE .sata
		CMP DL,STORAGE_SATAPI
		JNE .abort

		.satapi:
			;Reservado para dispositivos satapi
			JMP .done
		.sata:
			;Reservado para dispositivos sata
			JMP .done
		.patapi:
			CALL storage_DetectAtaConfig
                      
			ADD EBX,108 ;Pulando os dados de alinhamento
			SHR EBX,2
			SHR ECX,2 ;Convertendo para p�ginas de 2048
			INC ECX   ;
			SHL ECX,2 ;
			CALL memory_AllocatePage ;Alocando um novo buffer
			JC .abort

			PUSHAD
			SHR ECX,2 ;Dividindo por 4
			atapi_Read EBX,DX,AH,EDI,ECX
			POPAD

			MOV EDX,ECX
			MOV ESI,EDI
			MOV EAX,EDI

			MOV EDI,DWORD[ESP + STACK_EDI]
			MOV EBX,DWORD[ESP + STACK_EBX]
			
			;Calculando a posi��o da p�gina no buffer.
			AND EBX,3 
			SHL EBX,STORAGE_BITS_PER_PAGE
			ADD ESI,EBX

			MOV ECX,DWORD[ESP + STACK_ECX]
			SHL ECX,STORAGE_BITS_PER_PAGE - 2 ;(-2) Serve para dividir por 4, para tornar o MOVSD mais r�pido!
			REP MOVSD

			MOV EDI,EAX
			MOV ECX,EDX
			CALL memory_DeallocatePage ;Desalocando o buffer
			JMP .done
		.pata:
			CALL storage_DetectAtaConfig
			ata_Read EBX,DX,AL,EDI,ECX
			JMP .done
	.abort:
		PUSH DWORD STORAGE_INVALID_ID
		CALL error_ThrowException ;Informando ao n�cleo sobre o erro.
	.done:

	POPAD
	RET

;--------------------------------------------------------------------------------------------
;@description: Procedimento para escrever dados em um dispositivos de armazenamento secund�rio.
;@input: EDX << diskList index, EBX << page, EDI << buffer, ECX << total de p�ginas
;@output: -
;@author: alisson_linhares@hotmail.com
storage_WritePage:
	PUSHAD
	
	;Verificando se a unidade � v�lida.
	CMP EDX,DWORD[storage.lastStorageIndex]               
	JAE .abort
		MOV DX,WORD[EDX + storage.diskList + tStorage.id]
		
		CMP DL,STORAGE_PATA
		JE .pata
		CMP DL,STORAGE_PATAPI
		JE .patapi
		CMP DL,STORAGE_SATA
		JE .sata
		CMP DL,STORAGE_SATAPI
		JNE .abort

		.satapi:
			;Reservado para dispositivos satapi
			JMP .done
		.sata:
			;Reservado para dispositivos sata
			JMP .done
		.patapi:
			;Resevado para dispositivos patapi
			JMP .done
		.pata:
			CALL storage_DetectAtaConfig
			ata_Write EBX,DX,AL,EDI,ECX ;PAGE_ADDRESS, ATA_0 || ATA_1, ATA_MASTER || ATA_SLAVE,tATA_LBA28.buffer,tATA_LBA28.totalOfBlocks
			JMP .done
	.abort:
		PUSH DWORD STORAGE_INVALID_ID
		CALL error_ThrowException ;Informando ao n�cleo sobre o erro.
	.done:

	POPAD
	RET

;--------------------------------------------------------------------------------------------
;@description: Fun��o para desalocar p�ginas em disco.
;@remarks: N�o � permitida a desaloca��o de p�ginas em unidades de CD e DVD.
;@input: EDX << tStorage, EBX << p�gina inicial, ECX << total de p�ginas
;@output: -
;@author: alisson_linhares@hotmail.com
storage_DeallocatePage:
	PUSHAD
	
	;Verificando se a unidade � v�lida.
	CMP EDX,DWORD[storage.lastStorageIndex]       
	JAE .invalidId
		MOV EDI,DWORD[EDX + storage.diskList + tStorage.buffer]
		CMP DWORD[EDI + tBootSector.signature],NFS_BOOTSECTOR_SIGNATURE
		JNE .invalidDiskFormat
			;Travando o sem�foro para essa unidade.
			LEA EBP,[EDX + storage.diskList + tStorage.semaphore]
			CALL system_SemaphoreLock

			;Salvando em EBP o total de p�ginas.
			MOV EBP,ECX
			MOV ECX,1 ;ECX tem a unidade de aloca��o para storage_WritePage e storage_ReadPage.
			
			;Fazendo EDI apontar para o buffer em mem�ria.
			ADD EDI,MEMORY_PAGE_SIZE
			
			;Verifica se existe espa�o dispon�vel em disco.
			CMP DWORD[EDI - MEMORY_PAGE_SIZE + tBootSector.pageList],0
			JNE .findSpace
				;Liberando o bloco de p�ginas
				MOV DWORD[EDI + tMemoryPage.next],0 
				MOV DWORD[EDI + tMemoryPage.size],EBP
				CALL storage_WritePage
				
				;Salvando a p�gina, que cont�m o cabe�alho de boot, no disco.
				MOV DWORD[EDI - MEMORY_PAGE_SIZE + tBootSector.pageList],EBX
				JMP .updateBootSector
			.findSpace:
				MOV EBX,DWORD[EDI - MEMORY_PAGE_SIZE + tBootSector.pageList] 
			
				MOV EAX,EBX ;EAX � um ponteiro para o bloco anterior.
				JMP .startFindLoop
				
				;Procurando o local onde deve ser inserido o bloco de p�ginas
				.findLoop:
					MOV EAX,EBX
					MOV EBX,DWORD[EDI + tMemoryPage.next] ;Move para a pr�xima p�gina
					
				;Verifica se o bloco de p�ginas atual � menor que o passado por par�metro
				.startFindLoop:
				CMP DWORD[ESP + STACK_EBX],EBX 
				JB .insertMiddle
					CALL storage_ReadPage ;Lendo a pr�xima p�gina
					JC .done
				CMP DWORD[EDI + tMemoryPage.next],0
				JA .findLoop

				.insertFront: ;Inserindo bloco de p�ginas na frente do bloco atual
					MOV EBX,EAX
					CALL storage_ReadPage
					
					ADD EAX,DWORD[EDI + tMemoryPage.size] ;Ponteiro para o final do bloco anterior

			
					;Verifica se o final do bloco anterior � igual ao in�cio do bloco desalocado
					CMP EAX,DWORD[ESP + STACK_EBX]
					JE .addPages
						;O anterior aponta para o in�cio do bloco inserido.
						MOV EAX,DWORD[ESP + STACK_EBX]
						MOV DWORD[EDI + tMemoryPage.next],EAX
						CALL storage_WritePage ;Salvando o bloco anterior.
						
						MOV DWORD[EDI + tMemoryPage.next],0 ;Marcando como �ltima p�gina.
						MOV DWORD[EDI + tMemoryPage.size],EBP
						MOV EBX,EAX
						CALL storage_WritePage ;Salvando o bloco atual
						JMP .updateBootSector
					.addPages:
						;Inserindo o total de p�ginas do bloco e salvando o bloco anterior
						ADD DWORD[EDI + tMemoryPage.size],EBP
						CALL storage_WritePage
						JMP .updateBootSector
				.insertMiddle:
					MOV ESI,DWORD[ESP + STACK_EBX]
					ADD ESI,EBP
					
					;Verifica se o final do bloco anterior � igual ao in�cio do pr�ximo bloco
					CMP ESI,EBX 
					JNE .addNext
						CALL storage_ReadPage
						ADD DWORD[EDI + tMemoryPage.size],EBP ;Somando as duas p�ginas
						JMP .continue
					.addNext:
						MOV DWORD[EDI + tMemoryPage.next],EBX ;Ponteiro para p�gina seguinte
						MOV DWORD[EDI + tMemoryPage.size],EBP ;Inserindo o total de p�ginas do bloco
					.continue:
					
					MOV EBX,DWORD[ESP + STACK_EBX]
					CALL storage_WritePage
					
					;Verifica se existe algum bloco de p�ginas abaixo do bloco atual.
					CMP EBX,DWORD[EDI - MEMORY_PAGE_SIZE + tBootSector.pageList]
					JB .newFirstPage
						MOV EBX,EAX
						MOV EAX,DWORD[EDI + tMemoryPage.next] ;Salvando em EAX o ponteiro para a pr�xima p�gina.
						MOV EBP,DWORD[EDI + tMemoryPage.size] ;Salvando em EBP o total de p�ginas do bloco. 
						CALL storage_ReadPage
						
						MOV ESI,DWORD[EDI + tMemoryPage.size]
						ADD ESI,EBX
						
						;Verifica se o final do bloco � igual ao in�cio do bloco desalocado
						CMP ESI,DWORD[ESP + STACK_EBX]
						JNE .addPrior
							ADD DWORD[EDI + tMemoryPage.size],EBP
							MOV DWORD[EDI + tMemoryPage.next],EAX ;Inserindo o ponteiro para depois desse bloco
							CALL storage_WritePage
							JMP .updateBootSector
						.addPrior:
							MOV EAX,DWORD[ESP + STACK_EBX] 
							MOV DWORD[EDI + tMemoryPage.next],EAX  ;Ponteiro para p�gina desalocada
							CALL storage_WritePage
							JMP .updateBootSector
					.newFirstPage:
						MOV DWORD[EDI - MEMORY_PAGE_SIZE + tBootSector.pageList],EBX
	.updateBootSector:
		;EDI agora aponta para a c�pia em mem�ria da primeira p�gina da unidade.
		SUB EDI,MEMORY_PAGE_SIZE
		
		;Retirando o total de p�ginas desalocadas.
		MOV EAX,DWORD[ESP + STACK_ECX]
		SUB DWORD[EDI + tBootSector.usedPages],EAX
		
		XOR EBX,EBX
		CALL storage_WritePage
	.done:
		;Destravando o sem�foro
		system_SemaphoreUnlock EDX + storage.diskList + tStorage.semaphore
		JMP .abort
	.invalidDiskFormat:
		PUSH DWORD NFS_INVALID_DISK
		JMP .sendNotification
	.invalidId:
		PUSH DWORD STORAGE_INVALID_ID
	.sendNotification:
		CALL error_ThrowException
	.abort:

	POPAD
	RET

;--------------------------------------------------------------------------------------------
;@description: Fun��o para alocar blocos de p�ginas em disco.
;@remarks: N�o � permitida a aloca��o de p�ginas em unidades de CD e DVD.
;@input: EDX << tStorage, ECX << total de p�ginas
;@output: EBX >> bloco de p�ginas
;@author: alisson_linhares@hotmail.com
storage_AllocatePage:
	XOR EBX,EBX ;EBX retorna 0 em caso de erro.
	PUSHAD

	;Verificando se a unidade � v�lida.
	CMP EDX,DWORD[storage.lastStorageIndex]               
	JAE .invalidId
		MOV EDI,DWORD[EDX + storage.diskList + tStorage.buffer]
		CMP DWORD[EDI + tBootSector.signature],NFS_BOOTSECTOR_SIGNATURE
		JNE .invalidDiskFormat
			LEA EBP,[EDX + storage.diskList + tStorage.semaphore]
			CALL system_SemaphoreLock
			
			MOV EBX,DWORD[EDI + tBootSector.pageList]
			
			;EDI � o Ponteiro para o buffer depois do cabe�alho de boot.
			LEA EDI,[EDI + STORAGE_PAGE_SIZE]
			
			MOV EBP,ECX ;Salvando em EBP o total de p�ginas
			MOV ECX,1   ;Total de p�ginas lidas e escritas pelas fun��es storage_ReadPage e storage_WritePage
			
			XOR EAX,EAX
			JMP .startFindLoop
			
			.findLoop:
				MOV EAX,EBX
				MOV EBX,DWORD[EDI + tMemoryPage.next]
			.startFindLoop:
				TEST EBX,EBX 
				JZ .pageFaultError
				CALL storage_ReadPage
				JC .pageFaultError
			CMP DWORD[EDI + tMemoryPage.size],EBP
			JB .findLoop
			
			.spaceFound:
				;Retornando o bloco de p�ginas encontrado.
				MOV DWORD[ESP + STACK_EBX],EBX 
				
				;Verifica se o bloco de p�ginas � maior que a necessidade de aloca��o.
				JA .removePage
					;Removendo bloco inteiro se igual "Anterior aponta para o pr�ximo".
					MOV EBX,DWORD[EDI + tMemoryPage.next]
					JMP .removeBlock
				.removePage:
					;Alocando parte das p�ginas.
					SUB DWORD[EDI + tMemoryPage.size],EBP
					ADD EBX,EBP
					CALL storage_WritePage ;Salvando nova p�gina em disco.
				.removeBlock:
				
				;Verifica se o bloco removido � o primeiro.
				TEST EAX,EAX
				JZ .firstBlock ;Remove o bloco atual
					;Salvando em EBX o ponteiro para o bloco de p�ginas anterior e em EAX o ponteiro para o pr�ximo bloco. 
					XCHG EAX,EBX
					CALL storage_ReadPage ;Carregando o bloco anterior.

					;O bloco anterior aponta para o depois das p�ginas removidas.
					MOV DWORD[EDI + tMemoryPage.next],EAX 
					CALL storage_WritePage ;Salvando p�gina em disco
					JMP .continueRemove
				.firstBlock:
					MOV DWORD[EDI - STORAGE_PAGE_SIZE + tBootSector.pageList],EBX
				.continueRemove:
				
				;Atualizando o cabe�alho de boot
				XOR EBX,EBX
				SUB EDI,MEMORY_PAGE_SIZE
				ADD DWORD[EDI + tBootSector.usedPages],EBP ;Total de p�ginas usadas
				CALL storage_WritePage
				
				;Desativando sem�foro.
				system_SemaphoreUnlock EDX + storage.diskList + tStorage.semaphore
				JMP .done
	.pageFaultError:
		system_SemaphoreUnlock EDX + storage.diskList + tStorage.semaphore
		PUSH DWORD STORAGE_PAGE_FAULT
		JMP .sendNotification
	.invalidDiskFormat:
		PUSH DWORD NFS_INVALID_DISK
		JMP .sendNotification
	.invalidId:
		PUSH DWORD STORAGE_INVALID_ID
	.sendNotification:
		CALL error_ThrowException
	.done:

	POPAD
	RET