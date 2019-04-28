#include <stdio.h>
#include <stdlib.h>

extern void dziel(unsigned long* dzielna, unsigned long* dzielnik, 
		unsigned long* reszta_z_dzielenia, unsigned long rozmiar, unsigned long* wynik);
//void mnoz(unsigned long* mnozna, unsigned long* mnoznik, unsigned long rozmiar, unsigned long* wynik);

int main() {
    unsigned long dzielna[3] = {21000,39000,3000};
    unsigned long dzielnik[3] = {13000,3900,2500};
    unsigned long reszta_z_dzielenia[3] = {0,0,0};
    unsigned long rozmiar = 3;
    unsigned long wynik[6] = {0,0,0,0,0,0};
    dziel(dzielna, dzielnik,reszta_z_dzielenia, rozmiar, wynik);
return 0;
}



