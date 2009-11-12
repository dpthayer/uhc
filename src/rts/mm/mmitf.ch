%%[8
#ifndef __MM_MMITF_H__
#define __MM_MMITF_H__
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Memory management: interface to outside MM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The design is inspired by:
- http://jikesrvm.org/MMTk,
  see the (somewhat sketchy) guide for an overview, otherwise the code in the jikes distribution itself
- http://cs.anu.edu.au/people/Steve.Blackburn/,
  the main creator of MMTk, with a lot of relevant papers

However, it deviates sufficiently to warrant a sketch of the overall design:


Layering
--------
from bottom to top layer:
(0) memory mgt provided by OS, currently malloc is used, as it is most widely available
(1) Pages, groupwise aligned/sized of 2^k, abstracting from malloc, multiple mallocs allowed,
    currently buddy system
(2) arbitrary sized allocation, managed by some policy: GC, free list, fixed, ...
    Uses areas of contiguously allocated pages.
    
Layer (2) is further subdivided into sublayers, each with a particular responsibility:
(2.a) Fragment, directly based on pages, offering identification based on its start address a:
      a >> fragment size.
      This is to be used for 'remembered sets' required for generational GC.
(2.b) Space, a set of Fragments, offering flexibility in size, granularity.
      Each Space is treated as a unit for the GC wrt tracing & collection
(2.c) Increment, a set of ordered Spaces, each following the same GC policy.
      The ordering provides generations, within the one policy.
(2.d) Belt, a set of ordered Increments, each with a (possibly) different GC policy.
      This is the toplevel.


Efficiency
----------
Fragment, Space, Increment and Belt offer the same interface
'Allocator'. The implementation is OO like organized in that an
interface type exists, with multiple implementations and private data.
As this conflicts with efficiency each implementation provides fast path
access by means of inlining, macros or a combination of these. The
consequence is that for the system as a whole only one combination of
policies etc is configured. Non inlined access always remains possible,
but globally one combination must be configured.


Current implementations
-----------------------
as of 20080819.

Pages:
- Buddy pages, on top of system malloc/free

Fragment:
- Implicitly as Pages part of a Space

Space:
- A multiple Fragment (discontiguous Pages) implementation, offering growing+shrinking only
- CopySpace

Increment:

Belt:

Other Allocators:
- List of Free (LOF), on top of Pages


Flexibility
-----------
The design allows for a fair degree of flexibility. All building blocks
are accessible by means of structures, in almost OO alike style.
Replacement with different implementations (for a given interface) is
therefore easy.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Imports for interfacing to MM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Order of imports is important because of usage dependencies between types.

%%[8
#include "config.h"
#include "common.h"
#include "basic/iterator.h"
#include "basic/flexarray.h"
#include "basic/freelistarray.h"
#include "basic/dll.h"
#include "basic/deque.h"
#include "basic/rangemap.h"
#include "pages.h"
#include "space.h"
#include "allocator.h"
#include "collector.h"
#include "trace.h"
#include "roots.h"
#include "tracesupply.h"
#include "module.h"
#include "mutator.h"
#include "weakptr.h"
#include "plan.h"
%%]

%%[8
#if MM_BYPASS_PLAN
#	if (MM_Cfg_Plan == MM_Cfg_Plan_SS)
#		include "allocator/bump.h"
#	endif
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bypass to internals of MM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#if MM_BYPASS_PLAN
extern MM_Allocator* mm_bypass_allocator ;
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Interface: allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
// Allocate sz bytes, to be managed by GC
// Pre: sz >= size required to admin forwarding pointers. This depends on the node encoding. For GBM: sz >= sizeof(header) + sizeof(word).
// If gcInfo == 0 means no gcInfo
static inline Ptr mm_itf_alloc( size_t sz, Word gcInfo ) {
#	if MM_BYPASS_PLAN
#		if (MM_Cfg_Plan == MM_Cfg_Plan_SS)
			return mm_allocator_Bump_Alloc( mm_bypass_allocator, sz, gcInfo ) ;
#		endif
#	else
		return mm_mutator.allocator->alloc( mm_mutator.allocator, sz, gcInfo ) ;
#	endif
}

static inline Ptr mm_itf_allocResident( size_t sz ) {
	return mm_mutator.residentAllocator->alloc( mm_mutator.residentAllocator, sz, 0 ) ;
}

static inline void mm_itf_deallocResident( Ptr p ) {
	mm_mutator.residentAllocator->dealloc( mm_mutator.residentAllocator, p ) ;
}
%%]

%%[8
// malloc equivalent interface to lower level MM routines
static inline Ptr mm_itf_malloc( size_t sz ) {
	return mm_mutator.malloc->malloc( sz ) ;
}

static inline void mm_itf_free( Ptr p ) {
	mm_mutator.malloc->free( p ) ;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Interface: root registration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
// registration of location of GC root
static inline void mm_itf_registerGCRoot( WPtr p ) {
	mm_Roots_Register1( p ) ;
}

%%]
static inline void mm_itf_registerGCRoots( WPtr p, Word n ) {
	mm_Roots_Register1( (WPtr)(&n) ) ;
}

%%[8
static inline int mm_itf_registerModule( Ptr m ) {
	return mm_mutator.module->registerModule( mm_mutator.module, m ) ;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Interface: finalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[94
// register for finalization only
static inline void mm_itf_registerFinalization( Word x, MM_WeakPtr_Finalizer finalizer ) {
	mm_weakPtr.newWeakPtr( &mm_weakPtr, x, 0, finalizer ) ;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tracing, debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#if TRACE
// check (and panic) if n is pointing (dangling) to fresh mem
static inline void mm_assert_IsNotDangling( Word x, char* msg ) {
	// printf("mm_assert_IsNotDangling x=%x space(x)=%p\n",x,mm_Spaces_GetSpaceForAddress( x )) ;
	if ( mm_plan.mutator->isMaintainedByGC( mm_plan.mutator, x ) && *((Word*)x) == MM_GC_FreshMem_Pattern_Word ) {
		rts_panic2_1( "dangling pointer", msg, x ) ;
	}
}
#else
#define mm_assert_IsNotDangling(n,msg)
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
extern void mm_init() ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#endif /* __MM_MMITF_H__ */
%%]
