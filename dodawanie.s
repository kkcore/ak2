.type dodaj, @function
dodaj:
	movl %esp, %ebp
	subl $16, %esp		#esp wskazuje na ostatni argument
	movl 4(%ebp), %edx      #wpisz adres arg1
	movl (%edx), %eax	#wpisz wartosc z pod arg1
	movl 8(%ebp), %edx	#wpisz adres arg2
	addl (%edx), %eax	#dodaj arg2 od arg1
	movl 12(%ebp), %edx	#wpisz adres wyniku
	movl %eax, (%edx)	#wpisz wartosc dodawania do wyniku
	movl $1, %ecx		#licznik 1 
	dodaj_:	
	pushf			#zachowaj flagi
	cmpl 16(%ebp), %ecx	#dopoki rozne od dlugosci argumentow
	je koniec_dodaj
	popf			 #pobierz flagi ze stosu
	movl 4(%ebp), %edx	 #wez adres arg1
	movl (%edx,%ecx,4), %eax #wez i-ty wyraz arg1
	movl 8(%ebp), %edx	 #wez adres arg2
	movl (%edx,%ecx,4), %ebx #wez i-ty wyraz arg2
	adcl %ebx, %eax 	 #dodaj i-ty wyraz arg2 do arg1
	pushf			 #zachowaj flagi
	movl 12(%ebp), %edx	 #wez adres wyniku
	movl %eax, (%edx,%ecx,4) #wpisz wartosc do i-tego elementu wyniku
	incl %ecx		 #zwieksz licznik
	jmp dodaj_
	koniec_dodaj:
	popf
	movl %ebp, %esp
	ret

