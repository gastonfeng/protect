
; CC5X Version 3.0G, Copyright (c) B. Knudsen Data
; C compiler for the PICmicro family
; ************  17. Nov 2000   1:09  *************

	processor  16C711
	radix  DEC

OPTION_REG  EQU   0x81
PCL         EQU   0x02
STATUS      EQU   0x03
TRISA       EQU   0x85
TRISB       EQU   0x86
INTCON      EQU   0x0B
Carry       EQU   0
RP0         EQU   5
T0IF        EQU   2
ADCON0      EQU   0x08
ADRES       EQU   0x09
ADCON1      EQU   0x88
GO          EQU   2
voltage     EQU   0x18
Atime       EQU   0x19
Btime       EQU   0x1A
Ctime       EQU   0x1B
intflag     EQU   0
pra         EQU   1
prb         EQU   2
prc         EQU   3
protect     EQU   4
TX          EQU   0
SCK         EQU   1
RA          EQU   6
GA          EQU   7
RB          EQU   4
GB          EQU   5
RC          EQU   2
GC          EQU   3
s1          EQU   0x0C
s2          EQU   0x0D
cc          EQU   0x15
i           EQU   0x16
i_2         EQU   0x11
i1          EQU   0x12
i2          EQU   0x13
i3          EQU   0x14
C1cnt       EQU   0x15
C2tmp       EQU   0x16
C3rem       EQU   0x17
C4cnt       EQU   0x15
C5tmp       EQU   0x16
C6cnt       EQU   0x15
C7tmp       EQU   0x16
C8rem       EQU   0x17
C9cnt       EQU   0x15
C10tmp      EQU   0x16
ch          EQU   0x11
sum         EQU   0x12
i_3         EQU   0x14
i_4         EQU   0x0E
tmp         EQU   0x0F
C11cnt      EQU   0x11
C12tmp      EQU   0x12
C13rem      EQU   0x14

	GOTO main

  ; FILE D:\PRODUCT\PROTECT\PROGRAM\PROTECT.C
			;/********************************/
			;/*	SolarVoltage power	*/
			;/*	limit load suite	*/
			;/*	program by:fengjiantao	*/
			;/*	2000.4.14		*/
			;/*	filename:protect.c	*/
			;/********************************/
			;#include "16C711.H"
			;#include "int16cxx.h"
			;
			;#define MAX 250
			;#define MIN 190
			;#define settime 100
			;#define AMAX	1
			;#define	AMIN	2
			;#define	BMAX	3
			;#define BMIN	4
			;#define CMAX	5
			;#define CMIN	6
			;
			;char voltage;
			;char Atime,Btime,Ctime;
			;bit intflag,pra,prb,prc;
			;
			;#pragma bit protect @ 5.4
			;#pragma bit TX @ 6.0
			;#pragma bit SCK @ 6.1
			;#pragma bit RA	@ 6.6
			;#pragma bit GA  @ 6.7
			;#pragma bit RB	@ 6.4
			;#pragma bit GB 	@ 6.5
			;#pragma bit RC	@ 6.2
			;#pragma bit GC	@ 6.3
			;
			;#pragma origin = 0x4
	ORG 0x0004
			;
			;interrupt int_server( void)
			;{
int_server
			;    	int_save_registers    // W, STATUS (and PCLATH)
	MOVWF s1
	SWAPF STATUS,W
	MOVWF s2
			;    	T0IF=0;
	BCF   0x0B,T0IF
			;		intflag=1;
	BSF   0x1C,intflag
			;    	int_restore_registers // W, STATUS (and PCLATH)
	SWAPF s2,W
	MOVWF STATUS
	SWAPF s1,1
	SWAPF s1,W
			;}
	RETFIE
			;
			;
			;char table(char W)
			;{
table
			;//	if(W>=10)return 0;
			;	#pragma computedgoto 1
			;	PCL+=W;
	ADDWF PCL,1
			;	return 0xfc;
	RETLW .252
			;	return 0xc;
	RETLW .12
			;	return 0xd9;
	RETLW .217
			;	return 0x9d;
	RETLW .157
			;	return 0x2d;
	RETLW .45
			;	return 0xb5;
	RETLW .181
			;	return 0xf5;
	RETLW .245
			;	return 0x1c;
	RETLW .28
			;	return 0xfd;
	RETLW .253
			;	return 0xbd;
	RETLW .189
			;	#pragma computedgoto 0
			;}
			;
			;void outchar(char cc)
			;{
outchar
	MOVWF cc
			;	unsigned char i;
			;	for(i=0;i<8;i++){
	CLRF  i
m001	MOVLW .8
	SUBWF i,W
	BTFSC 0x03,Carry
	GOTO  m004
			;		#asm
			;		rrf cc,f;
	RRF   cc,1
			;		#endasm
			;		if(Carry)TX=1;
	BTFSS 0x03,Carry
	GOTO  m002
	BCF   0x03,RP0
	BSF   0x06,TX
			;		else TX=0;
	GOTO  m003
m002	BCF   0x03,RP0
	BCF   0x06,TX
			;		SCK=1;
m003	BCF   0x03,RP0
	BSF   0x06,SCK
			;		SCK=0;
	BCF   0x06,SCK
			;	}
	INCF  i,1
	GOTO  m001
			;}
m004	RETURN
			;
			;
			;	
			;	
			;void display()
			;{
display
			;	char i,i1,i2,i3;
			;	i=voltage/100;
	MOVF  voltage,W
	MOVWF C2tmp
	CLRF  C3rem
	MOVLW .8
	MOVWF C1cnt
m005	RLF   C2tmp,1
	RLF   C3rem,1
	MOVLW .100
	SUBWF C3rem,W
	BTFSS 0x03,Carry
	GOTO  m006
	MOVLW .100
	SUBWF C3rem,1
	BSF   0x03,Carry
m006	RLF   i_2,1
	DECFSZ C1cnt,1
	GOTO  m005
			;	i1=table(i);
	MOVF  i_2,W
	CALL  table
	MOVWF i1
			;	voltage%=100;
	MOVF  voltage,W
	MOVWF C5tmp
	CLRF  voltage
	MOVLW .8
	MOVWF C4cnt
m007	RLF   C5tmp,1
	RLF   voltage,1
	MOVLW .100
	SUBWF voltage,W
	BTFSS 0x03,Carry
	GOTO  m008
	MOVLW .100
	SUBWF voltage,1
m008	DECFSZ C4cnt,1
	GOTO  m007
			;	i=voltage/10;
	MOVF  voltage,W
	MOVWF C7tmp
	CLRF  C8rem
	MOVLW .8
	MOVWF C6cnt
m009	RLF   C7tmp,1
	RLF   C8rem,1
	MOVLW .10
	SUBWF C8rem,W
	BTFSS 0x03,Carry
	GOTO  m010
	MOVLW .10
	SUBWF C8rem,1
	BSF   0x03,Carry
m010	RLF   i_2,1
	DECFSZ C6cnt,1
	GOTO  m009
			;	i2=table(i);
	MOVF  i_2,W
	CALL  table
	MOVWF i2
			;	i=voltage%10;
	MOVF  voltage,W
	MOVWF C10tmp
	CLRF  i_2
	MOVLW .8
	MOVWF C9cnt
m011	RLF   C10tmp,1
	RLF   i_2,1
	MOVLW .10
	SUBWF i_2,W
	BTFSS 0x03,Carry
	GOTO  m012
	MOVLW .10
	SUBWF i_2,1
m012	DECFSZ C9cnt,1
	GOTO  m011
			;	i3=table(i);
	MOVF  i_2,W
	CALL  table
	MOVWF i3
			;	outchar(i3);
	MOVF  i3,W
	CALL  outchar
			;	outchar(i2);
	MOVF  i2,W
	CALL  outchar
			;	outchar(i1);
	MOVF  i1,W
	GOTO  outchar
			;}
			;
			;	
			;char adc(char ch)
			;{
adc
	MOVWF ch
			;	union{
			;		unsigned long s16;
			;		char s8[2];
			;	}sum;
			;	char i;
			;	sum.s16=0;
	CLRF  sum
	CLRF  sum+1
			;	ADCON0=ch;
	MOVF  ch,W
	BCF   0x03,RP0
	MOVWF ADCON0
			;	clrwdt();
	CLRWDT
			;	clrwdt();
	CLRWDT
			;	clrwdt();
	CLRWDT
			;	clrwdt();
	CLRWDT
			;	i=0;
	CLRF  i_3
			;	do{
			;		clrwdt();
m013	CLRWDT
			;		clrwdt();
	CLRWDT
			;		clrwdt();
	CLRWDT
			;		clrwdt();
	CLRWDT
			;		GO=1;
	BCF   0x03,RP0
	BSF   0x08,GO
			;		while(GO);
m014	BCF   0x03,RP0
	BTFSC 0x08,GO
	GOTO  m014
			;		sum.s16+=ADRES;
	MOVF  ADRES,W
	ADDWF sum,1
	BTFSC 0x03,Carry
	INCF  sum+1,1
			;		i++;
	INCFSZ i_3,1
			;	}while(i!=0);
	GOTO  m013
			;	return sum.s8[1];
	MOVF  sum+1,W
	RETURN
			;}
			;
			;void wait(void)
			;{
wait
			;	while(!intflag)clrwdt();
m015	BTFSC 0x1C,intflag
	GOTO  m016
	CLRWDT
	GOTO  m015
			;	intflag=0;
m016	BCF   0x1C,intflag
			;	while(!intflag)clrwdt();
m017	BTFSC 0x1C,intflag
	GOTO  m018
	CLRWDT
	GOTO  m017
			;	intflag=0;
m018	BCF   0x1C,intflag
			;}
	RETURN
			;	
			;void main(void)
			;{
main
			;	char i;
			;	unsigned long tmp;
			;	ADCON1=0;
	BSF   0x03,RP0
	CLRF  ADCON1
			;	TRISA=0x1f;
	MOVLW .31
	MOVWF TRISA
			;	OPTION=0x87;
	MOVLW .135
	MOVWF OPTION_REG
			;	INTCON=0b10100000;
	MOVLW .160
	MOVWF INTCON
			;	if(RA){
	BCF   0x03,RP0
	BTFSS 0x06,RA
	GOTO  m020
			;		wait();
	CALL  wait
			;		wait();
	CALL  wait
			;		if(RA){
	BTFSS 0x06,RA
	GOTO  m020
			;			TRISB=0b11111100;
	MOVLW .252
	BSF   0x03,RP0
	MOVWF TRISB
			;			while(1){
			;				voltage=adc(0x89);
m019	MOVLW .137
	CALL  adc
	MOVWF voltage
			;				display();
	CALL  display
			;				wait();
	CALL  wait
			;			}
	GOTO  m019
			;		}
			;	}
			;	if(RB){
m020	BCF   0x03,RP0
	BTFSS 0x06,RB
	GOTO  m022
			;		wait();
	CALL  wait
			;		wait();
	CALL  wait
			;		if(RB){
	BTFSS 0x06,RB
	GOTO  m022
			;			TRISB=0b11111100;
	MOVLW .252
	BSF   0x03,RP0
	MOVWF TRISB
			;			while(1){
			;				voltage=adc(0x91);
m021	MOVLW .145
	CALL  adc
	MOVWF voltage
			;				display();
	CALL  display
			;				wait();
	CALL  wait
			;			}
	GOTO  m021
			;		}
			;	}
			;	if(RC){
m022	BCF   0x03,RP0
	BTFSS 0x06,RC
	GOTO  m024
			;		wait();
	CALL  wait
			;		wait();
	CALL  wait
			;		if(RC){
	BTFSS 0x06,RC
	GOTO  m024
			;			TRISB=0b11111100;
	MOVLW .252
	BSF   0x03,RP0
	MOVWF TRISB
			;			while(1){
			;				voltage=adc(0x99);
m023	MOVLW .153
	CALL  adc
	MOVWF voltage
			;				display();
	CALL  display
			;				wait();
	CALL  wait
			;			}
	GOTO  m023
			;		}
			;	}
			;	TRISB=0;
m024	BSF   0x03,RP0
	CLRF  TRISB
			;//	voltage=0;
			;//	display();
			;//	for(i=0;i<200;i++)wait();
			;	Atime=0;
	CLRF  Atime
			;	Btime=0;
	CLRF  Btime
			;	Ctime=0;
	CLRF  Ctime
			;	RA=0;
	BCF   0x03,RP0
	BCF   0x06,RA
			;	RB=0;
	BCF   0x06,RB
			;	RC=0;
	BCF   0x06,RC
			;	GA=1;
	BSF   0x06,GA
			;	GB=1;
	BSF   0x06,GB
			;	GC=1;
	BSF   0x06,GC
			;	pra=0;
	BCF   0x1C,pra
			;	prb=0;
	BCF   0x1C,prb
			;	prc=0;
	BCF   0x1C,prc
			;	while(1){
			;		voltage=adc(0x81);
m025	MOVLW .129
	CALL  adc
	MOVWF voltage
			;		tmp=voltage;
	MOVF  voltage,W
	MOVWF tmp
	CLRF  tmp+1
			;		tmp*=2;
	BCF   0x03,Carry
	RLF   tmp,1
	RLF   tmp+1,1
			;		voltage=tmp/5;
	MOVF  tmp,W
	MOVWF C12tmp
	MOVF  tmp+1,W
	MOVWF C12tmp+1
	CLRF  C13rem
	MOVLW .16
	MOVWF C11cnt
m026	RLF   C12tmp,1
	RLF   C12tmp+1,1
	RLF   C13rem,1
	BTFSC 0x03,Carry
	GOTO  m027
	MOVLW .5
	SUBWF C13rem,W
	BTFSS 0x03,Carry
	GOTO  m028
m027	MOVLW .5
	SUBWF C13rem,1
	BSF   0x03,Carry
m028	RLF   voltage,1
	DECFSZ C11cnt,1
	GOTO  m026
			;		display();
	CALL  display
			;		if(!pra){
	BTFSC 0x1C,pra
	GOTO  m033
			;		i=adc(0x89);
	MOVLW .137
	CALL  adc
	MOVWF i_4
			;		if(i>MAX){
	MOVLW .251
	SUBWF i_4,W
	BTFSS 0x03,Carry
	GOTO  m030
			;			if(Atime>settime){
	MOVLW .101
	SUBWF Atime,W
	BTFSS 0x03,Carry
	GOTO  m029
			;				RA=1;GA=0;
	BCF   0x03,RP0
	BSF   0x06,RA
	BCF   0x06,GA
			;				pra=1;
	BSF   0x1C,pra
			;			}
			;			else Atime++;
	GOTO  m033
m029	INCF  Atime,1
			;		}
			;		else{
	GOTO  m033
			;			if(i<MIN){
m030	MOVLW .190
	SUBWF i_4,W
	BTFSC 0x03,Carry
	GOTO  m032
			;				if(Atime>settime){
	MOVLW .101
	SUBWF Atime,W
	BTFSS 0x03,Carry
	GOTO  m031
			;					RA=1;GA=1;
	BCF   0x03,RP0
	BSF   0x06,RA
	BSF   0x06,GA
			;					pra=1;
	BSF   0x1C,pra
			;				}
			;				else Atime++;
	GOTO  m033
m031	INCF  Atime,1
			;			}
			;			else Atime=0;
	GOTO  m033
m032	CLRF  Atime
			;		}
			;		}
			;		if(!prb){
m033	BTFSC 0x1C,prb
	GOTO  m038
			;		i=adc(0x91);
	MOVLW .145
	CALL  adc
	MOVWF i_4
			;		if(i>MAX){
	MOVLW .251
	SUBWF i_4,W
	BTFSS 0x03,Carry
	GOTO  m035
			;			if(Btime>settime){
	MOVLW .101
	SUBWF Btime,W
	BTFSS 0x03,Carry
	GOTO  m034
			;				RB=1;GB=0;
	BCF   0x03,RP0
	BSF   0x06,RB
	BCF   0x06,GB
			;				prb=1;
	BSF   0x1C,prb
			;			}
			;			else Btime++;
	GOTO  m038
m034	INCF  Btime,1
			;		}
			;		else{
	GOTO  m038
			;			if(i<MIN){
m035	MOVLW .190
	SUBWF i_4,W
	BTFSC 0x03,Carry
	GOTO  m037
			;				if(Btime>settime){
	MOVLW .101
	SUBWF Btime,W
	BTFSS 0x03,Carry
	GOTO  m036
			;					RB=1;GB=1;
	BCF   0x03,RP0
	BSF   0x06,RB
	BSF   0x06,GB
			;					prb=1;
	BSF   0x1C,prb
			;				}
			;				else Btime++;
	GOTO  m038
m036	INCF  Btime,1
			;			}
			;			else Btime=0;
	GOTO  m038
m037	CLRF  Btime
			;		}
			;		}
			;		if(!prc){
m038	BTFSC 0x1C,prc
	GOTO  m043
			;		i=adc(0x99);
	MOVLW .153
	CALL  adc
	MOVWF i_4
			;		if(i>MAX){
	MOVLW .251
	SUBWF i_4,W
	BTFSS 0x03,Carry
	GOTO  m040
			;			if(Ctime>settime){
	MOVLW .101
	SUBWF Ctime,W
	BTFSS 0x03,Carry
	GOTO  m039
			;				RC=1;GC=0;
	BCF   0x03,RP0
	BSF   0x06,RC
	BCF   0x06,GC
			;				prc=1;
	BSF   0x1C,prc
			;			}
			;			else Ctime++;
	GOTO  m043
m039	INCF  Ctime,1
			;		}
			;		else{
	GOTO  m043
			;			if(i<MIN){
m040	MOVLW .190
	SUBWF i_4,W
	BTFSC 0x03,Carry
	GOTO  m042
			;				if(Ctime>settime){
	MOVLW .101
	SUBWF Ctime,W
	BTFSS 0x03,Carry
	GOTO  m041
			;					RC=1;GC=1;
	BCF   0x03,RP0
	BSF   0x06,RC
	BSF   0x06,GC
			;					prc=1;
	BSF   0x1C,prc
			;				}
			;				else Ctime++;
	GOTO  m043
m041	INCF  Ctime,1
			;			}
			;			else Ctime=0;
	GOTO  m043
m042	CLRF  Ctime
			;		}
			;		}
			;		if(protect){
m043	BCF   0x03,RP0
	BTFSS 0x05,protect
	GOTO  m044
			;			wait();
	CALL  wait
			;			wait();
	CALL  wait
			;			if(protect){
	BTFSS 0x05,protect
	GOTO  m044
			;				pra=1;
	BSF   0x1C,pra
			;				prb=1;
	BSF   0x1C,prb
			;				prc=1;
	BSF   0x1C,prc
			;			}
			;		}
			;		wait();
m044	CALL  wait
			;	}
	GOTO  m025
			;}

	END
