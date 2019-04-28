.code32

SYSEXIT = 1
EXIT_SUCCESS = 0
STDOUT = 1
SYSWRITE = 4
SYSREAD = 3
STDIN = 0
SYSCALL32 = 0x80

.data
dzieleniePrzezZero: .ascii "Nie mozna dzielic przez zero"
dzieleniePrzezZero_dlugosc = . - dzieleniePrzezZero
.text

.type odejmij, @function  
odejmij:
	movl %esp, %ebp
	subl $16, %esp		#esp wskazuje na ostatni argument
	movl 4(%ebp), %edx      #wpisz adres arg1
	movl (%edx), %eax	#wpisz wartosc z pod arg1
	movl 8(%ebp), %edx	#wpisz adres arg2
	subl (%edx), %eax	#odejmij arg2 od arg1
	movl 12(%ebp), %edx	#wpisz adres wyniku
	movl %eax, (%edx)	#wpisz wartosc odejmowania do wyniku
	movl $1, %ecx		#licznik 1 
	odejmij_:	
	pushf			#zachowaj flagi
	cmpl 16(%ebp), %ecx	#dopoki rozne od dlugosci argumentow
	je koniec_odejmij
	popf			 #pobierz flagi ze stosu
	movl 4(%ebp), %edx	 #wez adres arg1
	movl (%edx,%ecx,4), %eax #wez i-ty wyraz arg1
	movl 8(%ebp), %edx	 #wez adres arg2
	movl (%edx,%ecx,4), %ebx #wez i-ty wyraz arg2
	sbbl %ebx, %eax 	 #odejmij i-ty wyraz arg2 od arg1
	pushf			 #zachowaj flagi
	movl 12(%ebp), %edx	 #wez adres wyniku
	movl %eax, (%edx,%ecx,4) #wpisz wartosc do i-tego elementu wyniku
	incl %ecx		 #zwieksz licznik
	jmp odejmij_
	koniec_odejmij:
	popf
	movl %ebp, %esp
	ret

.type porownaj2Liczby, @function
porownaj2Liczby:
    movl %esp, %ebp
    subl $12, %esp
    pushl %edx
    pushl %edi
    pushl %ecx
    movl 4(%ebp), %edx  #adres 1 liczby
    movl 8(%ebp), %edi  #adres 2 liczby
    movl 12(%ebp), %ecx #rozmiar argumentow
    decl %ecx      
    sprawdzaj_wszystkie:
    cmpl $0, %ecx  
    jl koniec_sprawdzaj_wszystkie
    movl (%edx,%ecx,4), %eax
    cmpl (%edi,%ecx,4), %eax
    ja pierwsza_wieksza
    jb druga_wieksza
    decl %ecx
    jmp sprawdzaj_wszystkie
    koniec_sprawdzaj_wszystkie:
    movl $0, %eax           #zwraca zero gdy liczby sa rowne
    jmp koniec_porownywania
    pierwsza_wieksza:
    movl $1, %eax           #zwraca 1 gdy pierwsza wieksza
    jmp koniec_porownywania    
    druga_wieksza:
    movl $2, %eax           #zwraca 2 gdy druga wieksza
    koniec_porownywania:
    popl %ecx
    popl %edi
    popl %edx
    movl %ebp, %esp
        ret
#(Arg1, Arg2, rozmiar)
.type kopiujArg1DoArg2, @function
kopiujArg1DoArg2:
    movl 4(%esp), %edi #arg1
    movl 8(%esp), %edx #arg2
    movl $0, %ecx
    kopiuj:
    cmpl 12(%esp), %ecx
    je koniec_kopiowania
    movl (%edi,%ecx,4), %eax
    movl %eax, (%edx,%ecx,4)
    incl %ecx
    jmp kopiuj
    koniec_kopiowania:
    ret
#(adres arg, arg_size)
.type przesunBityWLewo, @function
przesunBityWLewo:
    movl %esp, %ebp
    subl $8, %esp
    pushl %edi
    pushl %ecx
    movl 4(%ebp), %edi
    movl $1, %ecx
    shll $1, (%edi)
    przesunWLewo:
    pushf           #zachowaj przeniesienie
    cmpl 8(%ebp), %ecx
    je koniecPrzesunWLewo
    popf        #pobierz flage cf
    rcll $1, (%edi,%ecx,4) 
    incl %ecx
    jmp przesunWLewo
    koniecPrzesunWLewo:
    popf
    popl %ecx
    popl %edi
    movl %ebp, %esp
ret
#(arg1, arg1_size)
.type przesunBityWPrawo, @function
przesunBityWPrawo:
    movl %esp, %ebp
    subl $8, %esp
    pushl %edi
    pushl %ecx
    movl 4(%ebp), %edi  #adres argumentu
    movl 8(%ebp), %ecx  #rozmiar argumentow
    decl %ecx      
    shrl $1, (%edi,%ecx,4)
    decl %ecx
    przesunWPrawo:
    pushf           #zachowaj przeniesienie
    cmpl $0, %ecx
    jl koniecPrzesunWPrawo
    popf        #pobierz flage cf
    rcrl $1, (%edi,%ecx,4) 
    decl %ecx
    jmp przesunWPrawo
    koniecPrzesunWPrawo:
    popf
    popl %ecx
    popl %edi
    movl %ebp, %esp  
ret
 
 
.globl dziel 
.type dziel, @function
dziel:
      #arg1- dzielna, arg2- dzielnik, reszta_z_dzielenia,rozmiar, adr wyniku
movl %esp, %ebp
subl $20, %esp
    #sprawdz czy dzielnik = 0
    movl 8(%ebp), %edi  #adres dzielnika
    movl $0, %ecx       #licznik
    sprawdz_wszystkie_elementy:
    cmpl 16(%ebp), %ecx    
    je koniec_sprawdz_wszystkie_elementy
    cmpl $0, (%edi,%ecx,4) 
    jne nie_zero
    incl %ecx
    jmp sprawdz_wszystkie_elementy
    koniec_sprawdz_wszystkie_elementy:
    movl $SYSWRITE, %eax
    movl $STDOUT, %ebx
    movl $dzieleniePrzezZero, %ecx
    movl $dzieleniePrzezZero_dlugosc, %edx
    int $SYSCALL32
    movl %ebp, %esp
    ret
    nie_zero:
    #kopiuj dzielna do reszty_z_dzielenia
    pushl %ebp
    pushl 16(%ebp)  #rozmiar arg
    pushl 12(%ebp)  #reszta_z_dzielenia
    pushl 4(%ebp)   #dzielna
    call kopiujArg1DoArg2
    addl $12, %esp
    popl %ebp
    movl $0, %ecx   #licznik przesuniec
    #sprawdz czy najstarszy bit dzielnej =1
    movl 4(%ebp), %edi  #adres dzielnej
    movl 16(%ebp), %edx #rozmiar
    decl %edx       #rozmiar -1
    movl $2147483648, %eax  #10....0
    andl (%edi,%edx,4), %eax    #najstarszy bit =1
    jz skalowanie
    movl 8(%ebp), %edi  #adres dzielnika
    przeskaluj_maksymalnie_dzielnik:
    movl $2147483648, %eax 
    andl (%edi,%edx,4), %eax
    jnz koniec_skalowania
    pushl %ebp
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 8(%ebp)   #dzielnik
    call przesunBityWLewo
    addl $8, %esp
    popl %ebp
    incl %ecx
    jmp przeskaluj_maksymalnie_dzielnik
    #------
    #skalowanie dzielnej:
    #(adres 1 liczby, adres 2 liczby, rozmiar argumentow)
    skalowanie:
    pushl %ebp
    pushl 16(%ebp) #rozmiar argumentow
    pushl 8(%ebp)  #dzielnik
    pushl 12(%ebp) #reszta_z_dzielenia
    call porownaj2Liczby    #eax=0 rowne, eax=1 pierwsza wieksza, eax=2 druga wieksza
    addl $12, %esp
    popl %ebp
    cmpl $2, %eax
    je koniec_skalowania
    incl %ecx
    #(adres arg, arg_size)
    pushl %ebp
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 8(%ebp)   #dzielnik
    call przesunBityWLewo
    addl $8, %esp
    popl %ebp
    jmp skalowanie
    koniec_skalowania:
    #Dzielna przeskalowana
    #sprawdz i odejmij     ##########do tad dziala
    odejmuj_kolejne:
    cmpl $0, %ecx       #tyle samo sprawdzen co skalowac w lewo
    je koniec_odejmuj_kolejne
    #sprawdz czy mniejsze jezeli tak odejmij jezeli nie skaluj w prawo dzielnik
    #wynik przesun w lewo
    pushl %ebp
    pushl 16(%ebp)  #rozmiar
    pushl 20(%ebp)  #wynik dzielenia ###############break--------------
    call przesunBityWLewo  
    addl $8, %esp
    popl %ebp
    pushl %ebp
    pushl 16(%ebp) #rozmiar argumentow
    pushl 8(%ebp)  #dzielnik
    pushl 12(%ebp) #reszta_z_dzielenia      #BLAD !!!!!!!!!!!!!!!!!---------
call porownaj2Liczby#eax=0 rowne, eax=1 pierwsza wieksza, eax=2 druga wieksza
    addl $12, %esp
    popl %ebp
    cmpl $2, %eax
    je wiekszy#wiekszy dzielnik
    #dzielnik mniejszy -> odejmij,wynik+1, przeskaluj
    pushl %ebp
    pushl %ecx  #odejmowanie wykorzystuje ecx
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 12(%ebp)  #adres wyniku
    pushl 8(%ebp)   #adres 2 arg
    pushl 12(%ebp)  #adres 1 arg
    call odejmij    #arg1-arg2      #modyfikuje rejestry
    addl $16, %esp
    popl %ecx
    popl %ebp
    movl 20(%ebp), %edi
    addl $1, (%edi)
    decl %ecx
    pushl %ebp
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 8(%ebp)   #adres dzielnika
    call przesunBityWPrawo
    addl $8, %esp
    popl %ebp
    jmp odejmuj_kolejne
 
    wiekszy:
    pushl %ebp
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 8(%ebp)   #adres dzielnika
    call przesunBityWPrawo
    addl $8, %esp
    popl %ebp
    decl %ecx
    jmp odejmuj_kolejne
    koniec_odejmuj_kolejne:
 
 
 
    #Ostatni odejmowanie bez przesuwania dzielnika
    pushl %ebp
    pushl 16(%ebp)  #rozmiar
    pushl 20(%ebp)  #wynik dzielenia
    call przesunBityWLewo  
    addl $8, %esp
    popl %ebp
    pushl %ebp
    pushl 16(%ebp) #rozmiar argumentow
    pushl 8(%ebp)  #dzielnik
    pushl 12(%ebp) #reszta_z_dzielenia     
    call porownaj2Liczby#eax=0 rowne, eax=1 pierwsza wieksza, eax=2 druga wieksza
    addl $12, %esp
    popl %ebp
    cmpl $2, %eax
    je koniec_dzielenia #wiekszy dzielnik
    #dzielnik mniejszy -> odejmij,wynik+1
    pushl %ebp
    pushl %ecx  #odejmowanie wykorzystuje ecx
    pushl 16(%ebp)  #rozmiar argumentow
    pushl 12(%ebp)  #adres wyniku
    pushl 8(%ebp)   #adres 2 arg
    pushl 12(%ebp)  #adres 1 arg
    call odejmij    #arg1-arg2      #modyfikuje rejestry
    addl $16, %esp
    popl %ecx
    popl %ebp
    movl 20(%ebp), %edi
    addl $1, (%edi)
    decl %ecx
    koniec_dzielenia:
movl %ebp ,%esp
ret
