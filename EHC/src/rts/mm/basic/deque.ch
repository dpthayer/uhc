%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Memory management: Double Ended Queue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DEQue provides an efficient buffer based implementation for double ended
queues of Words. A dll of buffers is maintained, with offsets pointing
to the head and tail elements in the buffer. The use of a dll of buffers
avoids the necessity of reallocating one single buffer and allows for
flexible growth.

The API is split up in functions for
- finding out much headroom is available for reading/writing
- stepping through this headroom
- extending the headroom
This allows for fast pointer access by avoiding a per step check on available headroom.

The structure is biased towards addition at the tail and reading from
the head. This is part initialization, part lack of dual API.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEQue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#define MM_DEQue_BufSize		MM_Page_Size																	// including MM_DEQue_PageHeader part
#define MM_DEQue_BufMaxWords	((MM_Page_Size - sizeof(MM_DEQue_PageHeader)) >> Word_SizeInBytes_Log)			// excluding MM_DEQue_PageHeader part
%%]

%%[8
// the descriptor for a deque
typedef struct MM_DEQue {
	MM_DLL			dll ;		// dll of buffers
	Word			headOff ;	// offset into 1st buffer, pointing to 1st element
	Word			tailOff ;	// offset into last buffer, pointing to last element
	MM_Malloc*		memMgt ;
} MM_DEQue ;
%%]

The DLL embedded in MM_DEQue buffer pages is assumed to be at the
beginning, so as to be able to cast free between the DLL and the
MM_DEQue_PageHeader.

%%[8
// header for each buffer page
typedef struct MM_DEQue_PageHeader {
	MM_DLL			dll ;		// dll of buffers
	Word			tailOff ;	// == tailOff for tail pages, for internal pages it corresponds to the last global tailOff before extending
} MM_DEQue_PageHeader ;
%%]

%%[8
// are head and tail in same buffer?
static inline Bool mm_deque_HeadTailShareBuffer( MM_DEQue* deque ) {
	return deque->dll.next == deque->dll.prev ;
}

// address of the head
static inline WPtr mm_deque_Head( MM_DEQue* deque ) {
	return (WPtr)( (Word)deque->dll.next + deque->headOff ) ;
}

// address of the tail
static inline WPtr mm_deque_Tail( MM_DEQue* deque ) {
	return (WPtr)( (Word)deque->dll.prev + deque->tailOff ) ;
}

// set head offset
static inline void mm_deque_SetHeadOff( MM_DEQue* deque, Word off ) {
	deque->headOff = off ;
}

// set tail offset
static inline void mm_deque_SetTailOff( MM_DEQue* deque, Word off ) {
	deque->tailOff = off ;
	((MM_DEQue_PageHeader*)(deque->dll.prev))->tailOff = off ;
}

// incr head offset
static inline void mm_deque_IncHeadOff( MM_DEQue* deque, Word incWords ) {
	mm_deque_SetHeadOff( deque, deque->headOff + (incWords << Word_SizeInBytes_Log) ) ;
}

// incr tail offset
// assume: inc does not make tailOff point beyond buffer: inc <= mm_deque_TailAvailWrite
static inline void mm_deque_IncTailOff( MM_DEQue* deque, Word incWords ) {
	mm_deque_SetTailOff( deque, deque->tailOff + (incWords << Word_SizeInBytes_Log) ) ;
}

// nr of available words for writing at the head end
static inline Word mm_deque_HeadAvailWrite( MM_DEQue* deque ) {
	return (deque->headOff - sizeof(MM_DEQue_PageHeader)) >> Word_SizeInBytes_Log ;
}

// nr of available words for writing at the tail end
static inline Word mm_deque_TailAvailWrite( MM_DEQue* deque ) {
	return ((MM_Page_Size - Word_SizeInBytes) - deque->tailOff) >> Word_SizeInBytes_Log ;
}

// nr of available words for reading at the head end
static inline Word mm_deque_HeadAvailRead( MM_DEQue* deque ) {
	return
		( ( mm_deque_HeadTailShareBuffer( deque )
	      ? deque->tailOff + Word_SizeInBytes
	      : ((MM_DEQue_PageHeader*)(deque->dll.next))->tailOff + Word_SizeInBytes
	      )
	    - deque->headOff
	    ) >> Word_SizeInBytes_Log ;
}

// nr of available words for reading at the tail end
static inline Word mm_deque_TailAvailRead( MM_DEQue* deque ) {
	return
		( deque->tailOff + Word_SizeInBytes
	    - ( mm_deque_HeadTailShareBuffer( deque )
	      ? deque->headOff
	      : sizeof(MM_DEQue_PageHeader)
	      )
	    ) >> Word_SizeInBytes_Log ;
}
%%]

%%[8
extern Bool mm_deque_IsEmpty( MM_DEQue* deque ) ;

// init with one buffer, prepared for writing at the tail end
extern void mm_deque_Init( MM_DEQue* deque, MM_Malloc* memmgt ) ;

// reset to initial state, deallocating buffers
extern void mm_deque_Reset( MM_DEQue* deque ) ;

// extend with 1 buffer at the head
// assume: no write headroom left
extern void mm_deque_HeadExtend( MM_DEQue* deque ) ;

// extend with 1 buffer at the tail
// assume: no write headroom left
extern void mm_deque_TailExtend( MM_DEQue* deque ) ;

// shrink by 1 buffer at the head
// assume: no read headroom left
extern void mm_deque_HeadShrink( MM_DEQue* deque ) ;

// shrink by 1 buffer at the tail
// assume: no read headroom left
extern void mm_deque_TailShrink( MM_DEQue* deque ) ;

// push (write) words at the tail end
extern void mm_deque_TailPush( MM_DEQue* deque, Word* words, Word nrWords ) ;

// pop (read) words at the head end
// return: nr of words read
extern Word mm_deque_HeadPop( MM_DEQue* deque, Word* words, Word nrWords ) ;

// push (write) words at the head end
// extern void mm_deque_HeadPush( MM_DEQue* deque, Word* words, Word nrWords ) ;

// pop (read) words at the tail end
// return: nr of words read
// extern Word mm_deque_TailPop( MM_DEQue* deque, Word* words, Word nrWords ) ;

// ensure nrWords available for write
// assume: nrWords <= MM_DEQue_BufMaxWords
// post: from tail onwards nrWords can be written
extern void mm_deque_TailEnsure( MM_DEQue* deque, Word nrWords ) ;

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEQue dump/debug
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifdef TRACE
extern void mm_deque_Dump( MM_DEQue* deque ) ;
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEQue test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifdef TRACE
extern void mm_deque_Test() ;
#endif
%%]
