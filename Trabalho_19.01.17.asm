;declaracao de variaveis
section .bss
	id_ArqIn resd 1 ;identificador do nomeArqIn
	nomeArqIn resb 50 ;nome do arquivo de entrada (recebido com argumento)
	info resb 4000 ;variavel que armazena o conteúdo do arquivo informado pelo usuário	
	info_aux resb 400; variável que armazena o conteúdo informado pelo usuário que ainda não foi salvo no arquivo
	tamanho_info resd 1; tamanho do conteudo do arquivo de entrada informado pelo usuário
	tamanho_info_aux resd 1;tamanho do conteudo digitado pelo usuário que ainda não foi salvo no arquivo de entrada
	cont resb 1;contador utizado na impressão do número de palavras aramazenado em info
	caractere resb 5 ;utilizado no rotulo que lê o conteúdo digitado pelo usuário
	opcao resb 1 ;utilizado para o usuário decidir se quer salvar ou não o arquivo ao sair do programa
	res resb 5 ;utilizado na impressao do número de palavras armazenado em info
	aux resb 1 ;utilizado na impressao do número de palavras armazenado em info

;declaracao de constantes
section .data
	msg db "Arquivo criado com sucesso!" ;mensagem inforvativa
	msg_L equ $-msg ;tamanho da mensagem
	msg1 db "Documento salvo com sucesso!" ;mensagem inforvativa
	msg1_L equ $-msg1 ;tamanho da mensagem
	pular db 10 ;constante para pular linha
	msg2 db "Digite 1 caso queira salvar ou 0 para sair direto: " ;mensagem inforvativa
	msg2_L equ $-msg2 ;tamanho da mensagem
	msg3 db "Número de palavras digitadas: " ;mensagem inforvativa
	msg3_L equ $-msg3 ;tamanho da mensagem
	msg4 db "Para acionar um comando ao final do texto: " ;mensagem inforvativa
	msg4_L equ $-msg4 ;tamanho da mensagem
	msg5 db "Comandos: " ;mensagem inforvativa
	msg5_L equ $-msg5 ;tamanho da mensagem
	msg6 db "/slvr: salvar o arquivo" ;mensagem inforvativa
	msg6_L equ $-msg6 ;tamanho da mensagem
	msg7 db "/cpal: imprime na tela o numero de palavras no arquivo" ;mensagem inforvativa
	msg7_L equ $-msg7 ;tamanho da mensagem
	msg8 db "/sair: sair do programa" ;mensagem inforvativa
	msg8_L equ $-msg8 ;tamanho da mensagem
	msg9 db "--------------------" ;mensagem inforvativa
	msg9_L equ $-msg9 ;tamanho da mensagem
	msg10 db "OBS: NUNCA ESQUECER DE PRESSIONAR ENTER OU ESPAÇO (APENAS UM DOS DOIS) ANTES DE DIGITAR UM COMANDO" ;mensagem inforvativa
	msg10_L equ $-msg10 ;tamanho da mensagem
	msg11 db "Pressione ENTER ou ESPAÇO (apenas um dos dois), digite o comando e pressione ENTER novamente" ;mensagem inforvativa
	msg11_L equ $-msg11 ;tamanho da mensagem
	msg12 db "INSTRUÇÕES DE USO:" ;mensagem inforvativa
	msg12_L equ $-msg12 ;tamanho da mensagem
	msg13 db "Nenhum argumento enviado." ;mensagem inforvativa
	msg13_L equ $-msg13 ;tamanho da mensagem

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO - MACROS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;escreve na tela a mensagem enviada como parâmetro
%macro escrever 2 ;inicia macro com dois parâmetros
	mov eax,4 ;SYS_WRITE
	mov ebx,1 ;STDOUT
	mov ecx,%1 ;primeiro parâmetro
	mov edx,%2 ;segundo parâmetro
	int 80h ;interrupção
%endmacro ;finaliza macro

;armazena o conteúdo fornecido pelo usuário na variável enviada como parâmetro
%macro ler 2 ;inicia macro com dois parâmetros
	mov eax,3 ;SYS_WRITE
	mov ebx,0 ;STDOUT
	mov ecx,%1 ;primeiro parâmetro
	mov edx,%2 ;segundo parâmetro
	int 80h ;interrupção
%endmacro ;finaliza macro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FIM - MACROS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;funcionalidade do linker
section .text
	global _start ;declaracao para o linker

;inicio start
_start:
	;recolhe o argumento (arquivo de entrada) na linha de comando, informado pelo usuário
	.pegar_argumento: 
		pop eax ;número de argumentos passados na linha de comando
		pop ecx ;nome do programa (./nome)
		pop ecx ;nome do arquivo passado pela linha de comando
		cmp ecx,0 ;compara para verificar existência do argumento
		jz exit ;caso nenhum argumento seja passado, acionar o rotulo exit (sair do programa)
		mov edx,0 ;contador
	.strlen: ;tamanho do nome do arquivo passado
		mov al,[ecx+edx] ;guarda em uma variável
		mov [nomeArqIn+edx],al ;guarda em uma variável
		cmp [ecx+edx], byte 0 ;se 0 (/0) então terminou a string
		jz home ;sai
		inc edx ;incrementa o contador
		jmp .strlen ;continua o laço	
	
	;label inicial
	home: 
		;mensagens iniciais para instruir o usuário ao bom uso do programa
		escrever pular, 1
		escrever msg12, msg12_L		
		escrever pular, 1
		escrever msg4, msg4_L
		escrever pular, 1
		escrever msg11, msg11_L
		escrever pular, 1
		escrever msg5, msg5_L
		escrever pular, 1
		escrever msg6, msg6_L
		escrever pular, 1
		escrever msg7, msg7_L
		escrever pular, 1
		escrever msg8, msg8_L
		escrever pular, 1
		escrever msg10, msg10_L
		escrever pular, 1		
		escrever msg9, msg9_L
		escrever pular, 1
		
		;abrindo arquivo para leitura
		mov eax,5;sys_open
		mov ebx,nomeArqIn;nome do arquivo de entrada
		mov ecx,2
		mov edx,0777q;permissao do arquivo
		int 80h
	
		;comparar se eax for menor que 0 (arquivo nao encontrado), se nao existir, cria o arquivo
		cmp eax, 0
		jle criar_arq ;caso eax seja menor ou igual a 0, acionar o rotulo criar_arq
		
		arquivo_existente:
			;depois que o arquivo foi aberto, move identificador do arquivo de entrada (eax) para id_ArqIn
			mov [id_ArqIn], eax
			
			;lendo conteudo do arquivo, armazenando em info
			ler_arquivo:
			mov eax,3 ;(sys_read)
			mov ebx,[id_ArqIn];identificador do arquivo
			mov ecx,info;armazena o conteudo do arquivo de entrada
			mov edx,4000;tamanho da variavel
			int 80h

			;move tamanho do conteudo do arquivo de entrada para tamanho_info		
			mov [tamanho_info], eax
			
			escrita:
				escrever info, [tamanho_info] ;exibir conteudo do arquivo para usuario	
				jmp leitura ;aqui para não criar o arquivo novamente, o código pula para a label de ler arquivo
		
		;caso o arquivo passado como argumento não exista, um arquivo com mesmo nome é criado
		criar_arq:
			;criando novo arquivo e abrindo
			mov eax,8;(sys_create)
			mov ebx,nomeArqIn;nome do arquivo informado pelo usuário
			mov ecx,0777q;permissao do arquivo
			int 80h
			
			;depois que o arquivo foi aberto, move identificador do arquivo de entrada (eax) para id_ArqIn
			mov [id_ArqIn], eax
			escrever msg,msg_L ;mensagem informativa
			escrever pular,1 ;pula linha
			mov [tamanho_info], dword 0 ;atribui a tamanho_info o seu tamanho inicial (zero)
		
		;recebe o conteúdo digitado pelo usuário, armazenando em info_aux
		leitura:
			mov ecx,0 ;inicia ecx com zero
			
			;lê o conteúdo informado pelo usuário, caractere por caractere 
			.ler_caractere:
				push ecx
				cmp ecx,399 ;compara ecx com 399
				jge .slvr ;caso ecx passe de 399, todo o conteúdo de info_aux é salvo no arquivo
				ler caractere, 1 ;lê o caractere digitado pelo usuário, armazenando em caractere
				cmp [caractere],  byte '/' ;compara o conteúdo de caractere com o caractere "/"
				je .comandos ;caso seja igual, um comando pode ser inserido pelo usuário, acionando o rótulo .comandos
				pop ecx
				mov al,[caractere] ;mover o caractere digitado para o registrador al
				mov [info_aux+ecx],al ;inserir o caractere armazenado em al para info_aux
				inc ecx ;incrementa o registrador ecx		
				jmp .ler_caractere ;rótulo .ler_caractere é acionado novamente
			
			;verifica qual comando o usuário deseja acionar verrificando os 4 caracteres digitados após "/"		
			.comandos:
				ler caractere, 5 ;efetua a leitura do comando desejado, armazenando em caractere
				cmp [caractere], dword "sair" ;caso o usuário queira sair do programa
				je .pre_exit
				cmp [caractere], dword "slvr" ;caso o usuário queira salvar o conteúdo digitado
				je .slvr
				cmp [caractere], dword "cpal" ;caso o usuário queira saber o número de palavras do arquivo
				je .cpal
				pop ecx
				mov eax,[caractere] ;move o conteúdo de caractere para eax
				mov [info_aux+ecx],eax ;move o conteúdo de eax para uma posição de info_aux determinada por ecx
				jmp .ler_caractere ;volta para o rótulo .ler_caractere
		
			.slvr:
				pop ecx
				mov [tamanho_info_aux],ecx ;tamanho_info_aux recebe o conteúdo de ecx
				
				;coloca o que está escrito em info_aux em info, desse modo pode-se contar as palavras de info
				.coloca_info:
					mov eax,[tamanho_info] ;move o conteúdo de tamamnho_info para eax
					add [tamanho_info], ecx ;aumenta o tamanho de info
					mov edx,0 ;edx recebe 0
					.for:
						cmp edx, ecx ;ver se acabou os bytes em info_aux
						je .escreve_arq ;se acabou, passa para escrever no arquivo
						mov bl, [info_aux+edx] ;senão passa o byte para info
						mov [info+eax], bl ;move o conteúdo de bl para uma posição de info determinada por eax
						inc eax ;incrementa eax
						inc edx ;incrementa edx
						jmp .for ;volta para o rótulo .for
				
				;escreve a variavel digitada pelo usuario, aarmazenada em info_aux, no arquivo
				.escreve_arq:
					mov eax,4 ;(sys_write)
					mov ebx,[id_ArqIn] ;(identificador do arquivo)
					mov ecx,info_aux ;(posição de memória)
					mov edx,[tamanho_info_aux] ;(tamanho)
					int 80h
					
				escrever msg1, msg1_L ;mensagem informativa
				escrever pular,1 ;pula linha
				mov ecx,0 ;ecx recebe 0 
				jmp .ler_caractere ;volta para o rótulo .ler_caractere
			
			;salva o conteúdo de info_aux no arquivo e sai do programa
			.slvr_sair:
				pop ecx
				mov [tamanho_info_aux],ecx ;tamanho_info_aux recebe ecx
				;escreve variável digitada pelo usuário no arquivo
				mov eax,4 ;(sys_write)
				mov ebx,[id_ArqIn] ;(identificador do arquivo)
				mov ecx,info_aux ;(posição de memória)
				mov edx,[tamanho_info_aux] ;(tamanho)
				int 80h
				jmp .exit ;aciona o rótulo .exit, saindo do programa		
			;verifica com o usuário se ele quer salvar ou não antes de sair do programa			
			.pre_exit:
				escrever msg2, msg2_L ;mensagem informativa
				ler opcao, 1 ;efutua a leitura do caractere que o usuário digitar
				cmp [opcao], byte '1' ;caso o caractere digitado seja 1
				je .slvr_sair ;se for igual, o conteúdo de info_aux é salvo no arquivo e o programa é encerrado
			;caso o usuário não queira salvar o conteúdo de info_aux no arquivo, o programa apenas é encerrado
			.exit:			
				mov eax,6 ;(sys_close)
				mov ebx,[id_ArqIn] ;(identificador do arquivo)
				int 80h
				mov eax, 1 ;SYS_EXIT
				mov ebx, 0 ;sem erros
				int 80h ;SYS_CALL
			
			;rótulo que conta o número de palavras do arquivo	
			.cpal:	
				mov edx, 0 ;edx recebe 0
				mov eax, 0 ;eax recebe 0
				mov ecx,[tamanho_info] ;ecx recebe o conteúdo de tamanho_info
				;rotulo que analisa os caracteres armmazenados em info
				.ler:
					cmp edx, ecx ;compara edx com ecx
					je .terminar ;caso sejam iguais (chegou ao fim de info), acionar o rótulo .terminar
					cmp [info+edx], byte 32 ;compara um caractere de info com o byte 32
					je .espaco ;caso sejam iguais, acionar o rótulo .espaço
					cmp [info+edx], byte 10 ;compara um caractere de info com o byte 10
					je .enter ;caso sejam iguais, acionar o rótulo .enter
					inc edx ;incrementa edx
					jmp .ler ;volta para o rótulo .ler
				.espaco:
					inc edx ;incrementa edx
					cmp [info+edx], byte 32 ;compara um caractere de info com o byte 32
					je .espaco ;caso sejam iguais, acionar o rótulo .espaço
					inc eax ;incrementa eax
					jmp .ler ;volta para o rótulo .ler
				.enter:
					inc edx ;incrementa edx
					cmp [info+edx], byte 10 ;compara um caractere de info com o byte 10
					je .enter ;caso sejam iguais, acionar o rótulo .enter
					inc eax ;incrementa eax
					jmp .ler ;volta para o rótulo .ler
				.terminar:
					push eax
					escrever msg3,msg3_L ;mensagem informativa
					pop eax
					mov ebx, 0 ;zera o contador
					mov ecx,10;divisor
					.transforma_caractere:
						mov edx,0;zerar o resto
						div ecx;dividir edx:eax por 10
						add dl,'0';transformar o resto em caractere
						mov [res+ebx],dl;colocar o resto em resultado
						inc ebx;incrementar contador
						cmp eax,0;compara o quociente com 0
						jne .transforma_caractere;se quociente for diferente de 0, continua dividindo		
					;imprimir resultado
					.imprimir_res:			
						dec ebx;decrementa contador
						mov al,[res+ebx];transfere caractere do resultado
						mov [aux],al;move para uma variavel auxiliar
						mov [cont],ebx;guarda no contador			
						mov eax,4;SYS_WRITE
						mov ebx,1;SYSOUT
						mov ecx,aux;posicao do resultado
						mov edx,1;1 byte do resultado
						int 80h;interrupcao
						mov ebx,[cont];retorna contador
						cmp ebx,0;comparar com 0 (primeiro caractere do resultado)
						jne .imprimir_res;se nao for igual a 0, continua imprimindo
					escrever pular,1; pula linha
					pop ecx
					jmp .ler_caractere ;volta para o rótulo .ler_caracter
exit:	
	escrever msg13,	msg13_L ;mensagem informativa
	escrever pular,1 ;pula linha
	mov eax, 1 ;SYS_EXIT
	mov ebx, 0 ;sem erros
	int 80h ;SYS_CALL



