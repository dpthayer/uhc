%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Includes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifndef __RTS_H__
#define __RTS_H__
%%]

%%[8
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include <limits.h>
#include "config.h"
#include "sizes.h"
%%]

%%[98
#include <errno.h>
%%]

%%[97
#include "math.h"
#include "float.h"
%%]

%%[97
#ifndef FP_ZERO
#warning FP_ZERO not defined (assuming value 2). Using floating point numbers may give problems.
#define FP_ZERO 2
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Internal config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

For now, switch off Boehm GC, turn on own GC

%%[8
%%]
#undef USE_BOEHM_GC
#define USE_EHC_MM				1

%%[8
%%]
// not used
#define GB_IND_IN_HDR			1

%%[8.TRACE
#define TRACE 					1

#if TRACE
#define GB_COUNT_STEPS			1
#else
#define GB_COUNT_STEPS			0
#endif
%%]

%%[100 -8.TRACE
%%]

%%[8
#define INFO_EXITSTATE			1
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Very basic types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
typedef int Bool ;

#define True		1
#define False		0
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[97
%%]
// Hack around absence of FP_ZERO on some platforms.
// Assume IEEE-754, check zero-ness of IEEE-754 float/double using encoding (see e.g. http://babbage.cs.qc.edu/courses/cs341/IEEE-754references.html).
// Is zero when exp == 0 && mant == 0, so shift out sign (most sign bit) and rest must be all zero to be a FP zero.

#define fp_iszero(x)	( sizeof(x) == sizeof(float) ? ((x)&(1<<31)) == 0 : ((x)&(1<<63)) == 0 )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
// identity macro
#define ID(x)		x
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% More includes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#include "bits.h"
#include "mm/mmitf.h"

// extern GB_NodePtr gb_Unit ; // defined in grinbc/gbprim.h, but required here

#include "grinbc/grinbc.h"
#include "mm/mm.h"
#include "utils.h"
#include "priminline.h"
#include "grinbc/gbprimdecl.h"
%%[[99
#include "grinbc/gbprim-array.h"
#include "grinbc/gbprim-thread.h"
%%]]
#include "grinbc/gbprim.h"
%%[[97
#include "grinbc/gbprim-integer.h"
%%]]
%%[[98
#include "grinbc/gbprim-handle.h"
%%]]
%%[[99
#include "grinbc/gbprim-C.h"
%%]]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Basic types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
typedef SWord GrWord;
typedef GrWord* Pointer;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
/* the empty PRIM define is used to mark exported functions from prim.c,
   used to automatically generate prim.h
*/
#define PRIM

#include "prim.h"
%%]

Aliasing of primitives, as a preparation of removal of duplicates and not having two sets

%%[8
// include "primalias.h"
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stack, heap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#if USE_BOEHM_GC
#include "gc/gc.h"
#elif USE_EHC_MM
#else

#define HEAPSIZE 1000000

extern Pointer HP;
extern Pointer HeapAreaLow;
extern Pointer HeapAreaHigh;

#endif
%%]

%%[8
#if USE_BOEHM_GC
#	define heapalloc(sz)                Cast(GrWord,GC_MALLOC(sz*sizeof(GrWord)))
#	define heapalloc_uncollectable(sz)  Cast(GrWord,GC_MALLOC_UNCOLLECTABLE(sz*sizeof(GrWord)))
#elif USE_EHC_MM
#	define heapalloc(sz)                Cast(GrWord,mm_itf_alloc(sz*sizeof(GrWord)))
#	define heapalloc_uncollectable(sz)  Cast(GrWord,mm_itf_allocResident(sz*sizeof(GrWord)))
#else
	GrWord heapalloc(int);
#	define heapalloc_uncollectable(sz)  heapalloc(sz)
#endif
%%]

%%[8
#define STACKSIZE 800000
#define RETURNSIZE 100

extern Pointer SP, RP;
extern Pointer Stack, ReturnArea;

extern Pointer StackAreaHigh, StackAreaLow ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Globals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
extern GrWord global_False;
extern GrWord global_True;
%%]

%%[8
extern GrWord global_LT;
extern GrWord global_GT;
extern GrWord global_EQ;
%%]

%%[99
extern int rtsArgC ;
extern char** rtsArgV ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main entry points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
extern int main_Sil_Init1(int argc, char** argv) ;
extern int main_Sil_Run(int argc, char** argv) ;
extern int main_Sil_Exit(int argc, char** argv) ;

extern int main_GB_Init1(int argc, char** argv, int* nRtsOpt) ;
extern int main_GB_Run(int argc, char** argv, GB_BytePtr initPC, GB_Word initCAF) ;
extern int main_GB_Exit(int argc, char** argv) ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Dumping internal state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8.DUMP_INTERNALS
#define DUMP_INTERNALS	1
%%]

%%[100 -8.DUMP_INTERNALS
%%]

%%[8
#if DUMP_INTERNALS
#  define	IF_INFO_IS(info)				( gb_Opt_Info & info )
#  define	IF_INFO_ON(info,x)				if ( IF_INFO_IS( info ) ) { x ; } else {}
#else
#  define	IF_INFO_IS(info)				0
#  define	IF_INFO_ON(info,x)
#endif

#define	IF_INFO_EXITSTATE_ON(x)				IF_INFO_ON(INFO_EXITSTATE,x)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tracing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#define TRACE_LEV_DFLT 	3

#if TRACE
extern int traceLevel ;
#  define	IF_TR_ON(l,x)			if ( l <= traceLevel ) { x ; } else {}
#else
#  define	IF_TR_ON(l,x)
#endif

%%]

%%[8
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Postamble
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#endif /* __RTS_H__ */
%%]

