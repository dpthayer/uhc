%%[8
#include "rts.h"
%%]

%%[8
void error( char* msg )
{
	fprintf( stderr, "error: %s\n", msg ) ;
	exit( 1 ) ;
}

void panic( char* msg )
{
	fprintf( stderr, "grinbc: panic: %s\n", msg ) ;
	exit( 1 ) ;
}

void panic1_1( char* msg, int i )
{
	fprintf( stderr, "grinbc: panic: %s: 0x%x\n", msg, i ) ;
	exit( 1 ) ;
}

void panic2_1( char* msg1, char* msg2, int i )
{
	fprintf( stderr, "grinbc: %s panic: %s: 0x%x\n", msg1, msg2, i ) ;
	exit( 1 ) ;
}

void panic2_2( char* msg1, char* msg2, int i1, int i2 )
{
	fprintf( stderr, "grinbc: %s panic: %s: 0x%x: 0x%x\n", msg1, msg2, i1, i2 ) ;
	exit( 1 ) ;
}
%%]
