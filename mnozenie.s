.code32

.global mnoz
.text
.data
.type mnoz, @function
mnoz:
    #argumenty (adres mnoznej, adres mnoznika, rozmiar arg, adr wynik (size*2)
    #ecx - licznik petli wewnetrznej
    #ebx - licznik petli zewnetrznej
    movl %esp, %ebp
    subl $16, %esp	#esp wskazuje na ostatni element 
    movl $0, %ebx 
    petla_zewnetrzna:
    cmpl 12(%ebp), %ebx # sprawdz warunek
    je koniec_petla_zewnetrzna
        #---------------------------petla wewnetrzna-------------------
        movl $0, %ecx # wyzerowanie licznika petli wewnetrznej
        petla_wewnetrzna:
        cmpl 12(%ebp), %ecx # sprawdzenie warunku petli
        je koniec_petla_wewnetrzna 
        movl 4(%ebp), %edi      # adres mnoznej
        movl (%edi,%ecx,4), %eax # 4 bajty mnoznej do eax
        xor %edx, %edx          #wyzerowanie edx
        movl 8(%ebp), %edi      #adres mnoznika
        mull (%edi,%ebx,4) # 4 bajty mnoznika do ebx
        # eax mlodsza czesc , edx starsza 
        pushl %ecx # zachowaj licznik petli
        # dodaj do wyniku
        movl 16(%ebp), %edi     #adres wyniku
        addl %ebx, %ecx         #ustaw wage w ecx ecx=ecx+ebx
        addl %eax, (%edi,%ecx,4)
        incl %ecx               #kolejna waga
        adcl %edx, (%edi,%ecx,4)
        #dodaj przeniesienie jezeli wystapilo
	dodawaj_przeniesienie:
	jnc koniec_dodawaj_przeniesienie 	
        incl %ecx               #kolejna waga
        adcl $0, (%edi,%ecx,4) 
	jmp dodawaj_przeniesienie
	koniec_dodawaj_przeniesienie:
        popl %ecx               #pobierz licznik
        incl %ecx              
        jmp petla_wewnetrzna
        koniec_petla_wewnetrzna:
        #---------------------------koniec petla wewnetrzna-------------------
    incl %ebx           #zwieksz licznik petli zewnetrznej
    jmp petla_zewnetrzna
    koniec_petla_zewnetrzna:
    movl %ebp, %esp
    ret
