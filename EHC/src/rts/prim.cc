%%[8
#include "rts.h"

/* Make sure these numbers are the same as generated by Grin/ToSilly.cag */

#define CFalse  1
#define CTrue   2
#define Ccolon  3
#define Csubbus 4
#define CEQ     5
#define CGT     6
#define CLT     7
#define Ccomma0 8

#define CEHC_Prelude_AppendBinaryMode     9
#define CEHC_Prelude_AppendMode          10
#define CEHC_Prelude_ReadBinaryMode      11
#define CEHC_Prelude_ReadMode            12
#define CEHC_Prelude_ReadWriteBinaryMode 13
#define CEHC_Prelude_ReadWriteMode       14
#define CEHC_Prelude_WriteBinaryMode     15
#define CEHC_Prelude_WriteMode           16

%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% System related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Integer related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8

PRIM GrWord packedStringToInteger(GrWord s)
{
	GrWord res;
    res = heapalloc(1);
    ((Pointer)res)[0] = atoi( (char*)s );
    return res;
}


PRIM GrWord primIntToInteger(GrWord n)
{
	GrWord res;
    res = heapalloc(1);
    ((Pointer)res)[0] = n;
    return res;
}

PRIM GrWord primIntegerToInt(GrWord p)
{
	GrWord res;
    res = ((Pointer)p)[0];
    return res;
}

PRIM GrWord primCmpInteger(GrWord x, GrWord y)
{   if (((Pointer)x)[0] > ((Pointer)y)[0])
        return CGT;
    if (((Pointer)x)[0] == ((Pointer)y)[0])
        return CEQ;
    return CLT;
}

PRIM GrWord primEqInteger(GrWord x, GrWord y)
{
    if (((Pointer)x)[0] == ((Pointer)y)[0])
        return CTrue;
    return CFalse;
}



%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8


PRIM GrWord primNegInt(GrWord x)
{
	return -x;	
}

PRIM GrWord primAddInt(GrWord x, GrWord y)
{   
	//printf("add %d %d\n", x, y );
	return x+y;
}

PRIM GrWord primSubInt(GrWord x, GrWord y)
{   
	//printf("sub %d %d\n", x, y );
	return x-y;
}

PRIM GrWord primMulInt(GrWord x, GrWord y)
{   
	//printf("mul %d %d\n", x, y );
	return x*y;
}

/* This should be the Quot function */
PRIM GrWord primDivInt(GrWord x, GrWord y)
{   
	//printf("div %d %d\n", x, y );
	return x/y;
}

/* This should be the Rem function */
PRIM GrWord primModInt(GrWord x, GrWord y)
{   
	//printf("mod %d %d\n", x, y );
	return x%y;
}

PRIM GrWord primRemInt(GrWord x, GrWord y)
{   
	return x%y;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Ord Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8

/* The Boolean functions below only return the constructor */


PRIM GrWord primGtInt(GrWord x, GrWord y)
{   if (x>y)
    { //  printf ("%d is groter dan %d\n", x, y );
        return CTrue;
    }
    //printf ("%d is niet groter dan %d\n", x, y );
    return CFalse;
}

PRIM GrWord primLtInt(GrWord x, GrWord y)
{   if (x<y)
        return CTrue;
    return CFalse;
}
%%]

%%[8
PRIM GrWord primCmpInt(GrWord x, GrWord y)
{   if (x>y)
        return CGT;
    if (x==y)
        return CEQ;
    return CLT;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Eq Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
PRIM GrWord primEqInt(GrWord x, GrWord y)
{
	 //printf("eq %d %d\n", x, y );
	
    if (x==y)
        return CTrue;
    return CFalse;
}
%%]

%%[8
PRIM GrWord primNeInt(GrWord x, GrWord y)
{
	 //printf("neq %d %d\n", x, y );
	
    if (x!=y)
        return CTrue;
    return CFalse;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Misc primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
PRIM GrWord primUnsafeId(GrWord x)
{   return x ;
}

PRIM void primPatternMatchFailure()
{
    printf("Pattern match failure\n");
    exit(1);
}

PRIM GrWord primOrd(GrWord x)
{
	return x;	
}

PRIM GrWord primChr(GrWord x)
{
	return x;	
}

PRIM GrWord primOdd(GrWord x)
{
    if (x&1)
        return CTrue;
    return CFalse;
}


PRIM GrWord primPackedStringNull(GrWord s)
{
	if (*  ((char*)s) )	
    	return CFalse;	
    return CTrue;
}

PRIM GrWord primPackedStringTail(GrWord s)
{
	return  (GrWord)(((char*)s)+1);
}

PRIM GrWord primPackedStringHead(GrWord s)
{
	return (GrWord)(*((char*)s));
}


PRIM GrWord primError(GrWord s)
{
	GrWord c;
	char x;

	printf("\nError function called from Haskell with message: ");
	fflush(stdout);
	
	while (  ((GrWord*)s)[0] == Ccolon )
	{
		c = ((GrWord*)s)[1];	
		x = ((GrWord*)c)[1];
		putc(x,stdout);
		s = ((GrWord*)s)[2];	
	}
	putc('\n', stdout);
	fflush(stdout);
	
	exit(1);
	return 0;	
}


PRIM GrWord primMinInt()
{
	return 0x10000000;
}
PRIM GrWord primMaxInt()
{
	return 0x0FFFFFFF;
}


%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% char related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[99
PRIM GrWord primCharIsUpper( GrWord x )
{
	if ( x >= 'A' && x <= 'Z' )
		return CTrue;
  	return CFalse;
}

PRIM GrWord primCharIsLower( GrWord x )
{
	if ( x >= 'a' && x <= 'z' )
		return CTrue;
  	return CFalse;
}

%%]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[96

PRIM GrWord primExitWith(GrWord n)
{
	exit(n);
  	return 0;
}

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[98

PRIM GrWord primStdin()
{
  	return (GrWord)stdin;
}

PRIM GrWord primStdout()
{
  	return (GrWord)stdout;
}

PRIM GrWord primStderr()
{
  	return (GrWord)stderr;
}

PRIM GrWord primHFileno(GrWord chan)
{
	return fileno((FILE*)chan);
}


PRIM GrWord primOpenFile(GrWord str, GrWord mode)
{
	char filename[1024];
	char *d, *modestring;
	GrWord c;
	char x;
	FILE *f;

	d = filename;
	while (  ((GrWord*)str)[0] == Ccolon )
	{
		c = ((GrWord*)str)[1];	
		x = ((GrWord*)c)[1];
		*d++ = x;
		str = ((GrWord*)str)[2];	
	}
	*d = 0;

	
	switch(mode - CEHC_Prelude_AppendBinaryMode)
	{
	case 0: modestring = "ab"; break;
	case 1: modestring = "a"; break;
	case 2: modestring = "rb"; break;
	case 3: modestring = "r"; break;
	case 4: modestring = "r+b"; break;
	case 5: modestring = "r+"; break;
	case 6: modestring = "wb"; break;
	case 7: modestring = "w"; break;
	default:  printf("primOpenFile: illegal mode %d\n", mode); fflush(stdout);
	          return 0;	
}

	//printf("try to open [%s] with mode [%s]\n", filename, modestring );  fflush(stdout);
	f = fopen(filename, modestring);
	return (GrWord) f;	
}

PRIM GrWord primHClose(GrWord chan)
{
	fclose( (FILE*)chan );
	return Ccomma0;	
}

PRIM GrWord primHFlush(GrWord chan)
{
	fflush( (FILE*)chan );
	return Ccomma0;	
}

PRIM GrWord primHGetChar(GrWord h)
{
	int c;
	c = getc( (FILE*)h );
	//printf ("character read: %c\n", c );
	return c;
}

PRIM GrWord primHPutChar(GrWord h, GrWord c)
{
	putc(c, (FILE*)h );
	return Ccomma0;
}

PRIM GrWord primHIsEOF(GrWord h)
{
	int c;
	c = getc( (FILE*)h );
	if (c==EOF)
		return CTrue;
	
	ungetc( c, (FILE*)h );
	return CFalse;
}


%%]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[103

   struct OracleEntry {
     struct OracleEntry *last,*next;
     int count;
   };


   struct OracleEntry *oracleStartnode, *oracleCurrent;


   static struct OracleEntry * newOracle(struct OracleEntry *l, struct OracleEntry *n) {
     struct OracleEntry * o = malloc(sizeof(struct OracleEntry));
     o -> last  = l;
     o -> next  = n;
     o -> count = 0;
     return o;
   }

   // ()
PRIM GrWord gb_primInitOracle()
{
  printf("init oracle list\n");
  oracleStartnode = newOracle(0, 0);
  oracleCurrent   = oracleStartnode;
  oracleStartnode -> next = oracleStartnode;
  oracleStartnode -> last = oracleStartnode;
  return (GrWord)gb_Unit;
}


   // Oracle -> Oracle
PRIM GrWord gb_primOracleEnter(GrWord o)
{
  struct OracleEntry *oldOracle = oracleCurrent;
  oracleCurrent = (struct OracleEntry *) o;

  oracleCurrent->last->count++;
  printf("oracle entered\n");
  return (GrWord) oldOracle;
}


   // Oracle -> a -> a
PRIM GrWord gb_primOracleLeave(GrWord o, GrWord x)
{
  oracleCurrent->last->count += oracleCurrent->count;
  oracleCurrent->last->next = oracleCurrent->next;
  oracleCurrent->next->last = oracleCurrent->last;
  free(oracleCurrent);
  printf("left oracle\n");
  oracleCurrent = (struct OracleEntry *) o;
  return x;
}




   // Oracle -> a -> a
PRIM GrWord gb_primOracleEnterandLeave(GrWord o, GrWord x)
{
  struct OracleEntry *oe = (struct OracleEntry *) o;
  oe->last->count += oe->count+1;
  oe->last->next = oe->next;
  oe->next->last = oe->last;
  free(oe);
  printf("oracle entered and left\n");
  return x;
}


   // Oracle
PRIM GrWord gb_primOracleNewEntry()
{
  struct OracleEntry * l = oracleCurrent->last;
  struct OracleEntry * o = newOracle(l, oracleCurrent);
  printf("new oracle entry\n");
  oracleCurrent->last = o;
  l->next = o;
  return (GrWord)o;
}


   // Int
PRIM GrWord gb_primWhatIsNextOracle()
{
  struct OracleEntry * n = oracleCurrent->next;
  if(n->count) {
    n->count--;
   printf("current is True(1)");
    return 1;
  } else {
    oracleCurrent->next=n->next;
    printf("current is False(0)");
    return 0;
  }
}

PRIM GrWord gb_primDumpOracle()
{
  int l = 0;
  struct OracleEntry * o = oracleStartnode->next;
  printf("[");
  while(1) {
    l++;
    printf("%i", o->count);
    if((o=o->next)==oracleStartnode)
      break;
    printf(",");
  }
  printf("]\n");
  return l;
}

PRIM GrWord gb_primIsEvaluated(GrWord x)
{
  if ( GB_Word_IsPtr(x)) {
    GB_NodePtr n = Cast(GB_NodePtr,x);
    GB_NodeHeader h = n->header;
    if(GB_NH_Fld_NdEv(h) ==  GB_NodeNdEv_Yes)
      return 0;
  }
  return 1;
}

PRIM GrWord gb_primRawShow(GrWord x)
{
  int i;
  //  printf("primRawShow %p\n", x);

  if(GB_Word_IsInt(x)) {
    // an Integer value
    printf("%d ", GB_GBInt2Int(x));
    return x;
  } 

  if(! GB_Word_IsPtr(x)) {
    // not a pointer and not an int: this should never happen
    printf("<internal_error> ");
    return x;
  }

  GB_NodePtr n = Cast(GB_NodePtr,x);
  GB_NodeHeader h = n->header;

  if(GB_NH_Fld_NdEv(h) ==  GB_NodeNdEv_Yes) {
    // unevaluated thunk
    printf("_");
    return x;
  }

  if(GB_NH_Fld_NdEv(h) == GB_NodeNdEv_BlH) {
    printf("<blackhole>");
    return x;
  }


  int numfields = GB_NH_NrFlds(h);
  printf("(#%d.%d ", GB_NH_Fld_TagCat(h),GB_NH_Fld_Tag(h));
  for(i = 0;;printf(" ")) {
    GrWord next = n->content.fields[i];
    if(next)
      gb_primRawShow(next);
    else printf("<nil>");

    if(++i >= numfields)
      break;
  }
  printf(")");

  
  return x;
}

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% System
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[99
PRIM GrWord primGetArgC()
{
	return (GrWord) rtsArgC ;
}

PRIM GrWord primGetArgVAt( GrWord argc )
{
	return (GrWord) rtsArgV[ argc ] ;
}

%%]

