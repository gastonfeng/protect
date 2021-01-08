/********************************/
/*	SolarVoltage power	*/
/*	limit load suite	*/
/*	program by:fengjiantao	*/
/*	2000.4.14		*/
/*	filename:protect.c	*/
/********************************/
#include "16C711.H"
#include "int16cxx.h"

#define MAX 250
#define MIN 190
#define settime 100
#define AMAX	1
#define	AMIN	2
#define	BMAX	3
#define BMIN	4
#define CMAX	5
#define CMIN	6

char voltage;
char Atime,Btime,Ctime;
bit intflag,pra,prb,prc;

#pragma bit protect @ 5.4
#pragma bit TX @ 6.0
#pragma bit SCK @ 6.1
#pragma bit RA	@ 6.6
#pragma bit GA  @ 6.7
#pragma bit RB	@ 6.4
#pragma bit GB 	@ 6.5
#pragma bit RC	@ 6.2
#pragma bit GC	@ 6.3

#pragma origin = 0x4

interrupt int_server( void)
{
    	int_save_registers    // W, STATUS (and PCLATH)
    	T0IF=0;
		intflag=1;
    	int_restore_registers // W, STATUS (and PCLATH)
}


char table(char W)
{
//	if(W>=10)return 0;
	#pragma computedgoto 1
	PCL+=W;
	return 0xfc;
	return 0x30;	//0xc;
	return 0xdc;	//0xd9;
	return 0xf2;	//0x9d;
	return 0x66;	//0x2d;
	return 0xb6;	//0xb5;
	return 0xbe;	//0xf5;
	return 0xe0;	//0x1c;
	return 0xfe;	//0xfd;
	return 0xf6;	//0xbd;
	#pragma computedgoto 0
}

void outchar(char cc)
{
	unsigned char i;
	for(i=0;i<8;i++){
		#asm
		rrf cc,f;
		#endasm
		if(Carry)TX=1;
		else TX=0;
		SCK=1;
		SCK=0;
	}
}


	
	
void display()
{
	char i,i1,i2,i3;
	i=voltage/100;
	i1=table(i);
	voltage%=100;
	i=voltage/10;
	i2=table(i);
	i=voltage%10;
	i3=table(i);
	outchar(i3);
	outchar(i2);
	outchar(i1);
}

	
char adc(char ch)
{
	union{
		unsigned long s16;
		char s8[2];
	}sum;
	char i;
	sum.s16=0;
	ADCON0=ch;
	clrwdt();
	clrwdt();
	clrwdt();
	clrwdt();
	i=0;
	do{
		clrwdt();
		clrwdt();
		clrwdt();
		clrwdt();
		GO=1;
		while(GO);
		sum.s16+=ADRES;
		i++;
	}while(i!=0);
	return sum.s8[1];
}

void wait(void)
{
	while(!intflag)clrwdt();
	intflag=0;
	while(!intflag)clrwdt();
	intflag=0;
}
	
void main(void)
{
	char i;
	unsigned long tmp;
	ADCON1=0;
	TRISA=0x1f;
	OPTION=0x87;
	INTCON=0b10100000;
	if(RA){
		wait();
		wait();
		if(RA){
			TRISB=0b11111100;
			while(1){
				voltage=adc(0x89);
				display();
				wait();
			}
		}
	}
	if(RB){
		wait();
		wait();
		if(RB){
			TRISB=0b11111100;
			while(1){
				voltage=adc(0x91);
				display();
				wait();
			}
		}
	}
	if(RC){
		wait();
		wait();
		if(RC){
			TRISB=0b11111100;
			while(1){
				voltage=adc(0x99);
				display();
				wait();
			}
		}
	}
	TRISB=0;
//	voltage=0;
//	display();
//	for(i=0;i<200;i++)wait();
	Atime=0;
	Btime=0;
	Ctime=0;
	RA=0;
	RB=0;
	RC=0;
	GA=1;
	GB=1;
	GC=1;
	pra=0;
	prb=0;
	prc=0;
	while(1){
		voltage=adc(0x81);
		tmp=voltage;
		tmp*=2;
		voltage=tmp/5;
		display();
		if(!pra){
		i=adc(0x89);
		if(i>MAX){
			if(Atime>settime){
				RA=1;GA=0;
				pra=1;
			}
			else Atime++;
		}
		else{
			if(i<MIN){
				if(Atime>settime){
					RA=1;GA=1;
					pra=1;
				}
				else Atime++;
			}
			else Atime=0;
		}
		}
		if(!prb){
		i=adc(0x91);
		if(i>MAX){
			if(Btime>settime){
				RB=1;GB=0;
				prb=1;
			}
			else Btime++;
		}
		else{
			if(i<MIN){
				if(Btime>settime){
					RB=1;GB=1;
					prb=1;
				}
				else Btime++;
			}
			else Btime=0;
		}
		}
		if(!prc){
		i=adc(0x99);
		if(i>MAX){
			if(Ctime>settime){
				RC=1;GC=0;
				prc=1;
			}
			else Ctime++;
		}
		else{
			if(i<MIN){
				if(Ctime>settime){
					RC=1;GC=1;
					prc=1;
				}
				else Ctime++;
			}
			else Ctime=0;
		}
		}
		if(protect){
			wait();
			wait();
			if(protect){
				pra=1;
				prb=1;
				prc=1;
			}
		}
		wait();
	}
}
