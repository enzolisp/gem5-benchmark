** Parâmetros fixos:

# cpu.py
fetchWidth    = 4      # 2 → 4 \\ 
issueWidth    = 4      # 2 → 4 \\ 
numROBEntries = 128    # 96 → 128 \\
MyIntALU count = 4     # 2 → 4 \\

# cache.py
L1D size = '64kB'     # 32kB → 64kB \\
L2 size  = '512kB'    # 256kB → 512kB \\ 

** Sugestão dos 3 parâmetros a variar (com boa justificativa acadêmica): 

L1D size — AES acessa S-box (256B) + tabelas Te (~4KB) repetidamente; L1D pequena vai causar evictions constantes. XOR não usa tabela nenhuma. Contraste claro entre os 3 programas. \\
issueWidth — XOR é quase que um loop puro com IntALU; aumentar issueWidth permite emitir mais XORs por ciclo. RC4 tem dependência de dados entre iterações (índice j depende de S[i]), então não escala tanto. Justificativa rica. \\ 
MyMemUnit count — RC4 e AES fazem acessos a arrays (S-box, tabelas) constantemente; XOR mal toca memória além do buffer linear. Aumentar de 1 para 2 unidades de memória deve impactar RC4/AES muito mais que XOR. \\ 
