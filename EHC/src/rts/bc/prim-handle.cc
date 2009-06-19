%%[8
#include "../rts.h"
#include "interpreter.h"
%%]

%%[8.dummyForLinker
int dummy_handle ;
%%]

%%[98 -8.dummyForLinker
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Primitives for grin bytecode interpreter: Handle related
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% I/O: auxiliary functions needed in the implementation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[98

GB_NodePtr gb_throwChanInteractionException( GB_NodePtr chan, char* strErr )
{
	GB_NodePtr ioe_handle ;
	GB_NodePtr ioe_filename ;
	GB_GC_SafeEnter ;
	GB_GC_Safe1(chan) ;
	GB_GC_Safe2_Zeroed(ioe_handle,ioe_filename) ;
	
	GB_MkMaybeJust( ioe_filename, chan->content.chan.name ) ;
	GB_MkMaybeJust( ioe_handle, chan ) ;

	GB_GC_SafeLeave ;
	return gb_intl_throwIOErrorFromPrim( ioe_handle, gb_EOF, ioe_filename, strErr ) ;
}

GB_NodePtr gb_getChanEOFOrThrowExc( GB_NodePtr chan, Bool throwExcForEOF, Bool* isEof )
{
	FILE *f = chan->content.chan.file ;
	if ( feof( f ) ) {
		if ( throwExcForEOF ) {
			return gb_throwChanInteractionException( chan, "EOF reached" ) ;
		}
		*isEof = True ;
		return NULL ;
	} else {
		*isEof = False ;
		return NULL ;
	}
}

/*
 * Read+return a char,
 * unless at EOF which:
 *   throws an exc if throwExcForEOF
 *   or otherwise returns EOF in *isEof
 */

GB_NodePtr gb_ChanGetChar( GB_NodePtr chan, Bool throwExcForEOF, Bool* isEof, int* pc )
{
	FILE *f = chan->content.chan.file ;
	int c ;
	GB_GC_SafeEnter ;
	GB_GC_Safe1(chan) ;
	
	// printf( "%d ", feof( f ) ) ;
	GB_PassExc_GCSafe( gb_getChanEOFOrThrowExc( chan, throwExcForEOF, isEof ) ) ;
	if ( *isEof ) {
		c == EOF ;
	} else {
		c = getc( f ) ;
		if ( c == EOF ) {
			GB_PassExc_GCSafe( gb_getChanEOFOrThrowExc( chan, throwExcForEOF, isEof ) ) ;
		} else if ( c == '\r' && chan->content.chan.isText ) {
			int c2 = getc( f ) ;
			if ( c2 != '\n' && c2 != EOF ) {
				ungetc( c2, f ) ;
			}
			c = '\n' ;
		}
	}
	// printf( "%d %d %d\n", feof( f ), *isEof, c ) ;
	*pc = c ;
	GB_GC_SafeLeave ;
	return NULL ;
}


GB_NodePtr gb_ThrowWriteChanError( GB_NodePtr chan )
{
	GB_NodePtr ioe_handle ;
	Word    ioe_type ;
	GB_NodePtr ioe_filename ;
	GB_GC_SafeEnter ;
	GB_GC_Safe1(chan) ;
	GB_GC_Safe2_Zeroed(ioe_handle,ioe_filename) ;

	GB_MkMaybeJust( ioe_handle, chan ) ;
	GB_MkMaybeJust( ioe_filename, chan->content.chan.name ) ;
	
	switch( errno ) {
		case ENOMEM :
		case ENOSPC :
			ioe_type = gb_FullError ;
			break ;
		case EFBIG :
		case EIO :
			ioe_type = gb_PermissionDenied ;
			break ;
		default :
			ioe_type = gb_PermissionDenied ;
			break ;
	}
	
	GB_GC_SafeLeave ;
	return gb_intl_throwIOErrorFromPrim( ioe_handle, ioe_type, ioe_filename, strerror( errno ) ) ;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% I/O: basic primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRIM GB_NodePtr primStdin()
{
  	return gb_chan_stdin ;
}

PRIM GB_NodePtr primStdout()
{
  	IF_GB_TR_ON(3,printf("primStdout\n" ););
  	return gb_chan_stdout ;
}

PRIM GB_NodePtr primStderr()
{
  	return gb_chan_stderr ;
}


%%[98

PRIM Word primGBHandleFileno( GB_NodePtr chan )
{
	return ( fileno(chan->content.chan.file) ) ;
}

PRIM Word primEqGBHandle( GB_NodePtr chan1, GB_NodePtr chan2 )
{
	return ( fileno(chan1->content.chan.file) == fileno(chan2->content.chan.file) ? gb_True : gb_False ) ;
}

PRIM Word primEqGBHandleFileno( GB_NodePtr chan, Word fno )
{
	return ( fno == fileno(chan->content.chan.file) ? gb_True : gb_False ) ;
}

PRIM GB_NodePtr primOpenFileOrStd( GB_NodePtr nmNd, Word modeEnum, GB_NodePtr mbHandleNr )   
{
    /* mbHandleNr to be used only for std{in,out,err}, ignoring the opening mode. */
	int nmSz = 0 ;
	Word mbHandleNrFromJust = 0 ;
	GB_GC_SafeEnter ;
	GB_GC_Safe4(mbHandleNrFromJust,nmNd,modeEnum,mbHandleNr) ;
	GB_PassExc_GCSafe( gb_listForceEval( &nmNd, &nmSz ) ) ;
	char* nm = alloca( nmSz + 1 ) ;
	GB_PassExc_GCSafe( gb_copyCStringFromEvalString( nm, nmNd, nmSz ) ) ;	
	nm[ nmSz ] = 0 ;

	GB_PassExc_GCSafe( mbHandleNr = Cast( GB_NodePtr, gb_eval( Cast(Word,mbHandleNr) ) ) ) ;
	Bool mbHandleNrIsJust = False ;
	if ( GB_NH_Fld_Tag(mbHandleNr->header) == GB_Tag_Maybe_Just ) {
		mbHandleNrIsJust = True ;
		GB_PassExc_GCSafe( mbHandleNrFromJust = gb_eval( mbHandleNr->content.fields[0] ) ) ;
	}
	
	char *mode ;
	Bool isText = True ;
	if ( GB_EnumIsEqual( modeEnum, gb_ReadMode ) ) {
		mode = "r" ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_ReadBinaryMode ) ) {
		mode = "rb" ;
		isText = False ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_WriteMode ) ) {
		mode = "w" ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_WriteBinaryMode ) ) {
		mode = "wb" ;
		isText = False ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_ReadWriteMode ) ) {
		mode = "r+" ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_ReadWriteBinaryMode ) ) {
		mode = "r+b" ;
		isText = False ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_AppendMode ) ) {
		mode = "a" ;
	} else if ( GB_EnumIsEqual( modeEnum, gb_AppendBinaryMode ) ) {
		mode = "ab" ;
		isText = False ;
	}
	
	FILE *f = NULL ;
	if ( mbHandleNrIsJust ) {
		switch( GB_GBInt2Int( mbHandleNrFromJust ) ) {
			case 0: f = stdin  ; break ;
			case 1: f = stdout ; break ;
			case 2: f = stderr ; break ;
		}
	} else {
		f = fopen( nm, mode ) ;
	}
	if ( f == NULL )
	{
		GB_NodePtr ioe_handle ;
		Word    ioe_type ;
		GB_NodePtr ioe_filename ;
		GB_GC_Safe2_Zeroed(ioe_handle,ioe_filename) ;

		GB_MkMaybeNothing( ioe_handle ) ;
		GB_MkMaybeJust( ioe_filename, nmNd ) ;
		
		switch ( errno ) {
			case ENODEV :
			case ENOENT :
				ioe_type = gb_NoSuchThing ;
				break ;
			case EPERM   :
			case EACCES  :
			case ENOTDIR :
			case EMFILE :
				ioe_type = gb_PermissionDenied ;
				break ;
			case EBUSY :
				ioe_type = gb_ResourceBusy ;
				break ;
			default :
				ioe_type = gb_PermissionDenied ;
				break ;
		}

		GB_GC_SafeLeave ;
		return gb_intl_throwIOErrorFromPrim( ioe_handle, ioe_type, ioe_filename, strerror( errno ) ) ;
	}
	
	GB_NodePtr chan ;
	GB_NodeAlloc_Chan_In(chan) ;
	chan->content.chan.file = f ;
	chan->content.chan.name = nmNd ;
	chan->content.chan.isText = isText ;
	
%%[[99
	GB_NodePtr handle ;
	GB_MkNode_Handle_GBHandle(handle,chan) ;
%%]]
	
	GB_GC_SafeLeave ;
%%[[98
	return chan ;
%%][99
	return handle ;
%%]]
}

PRIM GB_NodePtr primHClose( GB_NodePtr handle )
{
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
	fclose(chan->content.chan.file) ;
	return gb_Unit ;
}

PRIM GB_NodePtr primHFlush( GB_NodePtr handle )
{
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
	fflush( chan->content.chan.file ) ;
	return gb_Unit ;
}

PRIM Word primHGetChar( GB_NodePtr handle )
{
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
	Bool isEof ;
	int c ;
	GB_PassExc_CastAsWord( gb_ChanGetChar( chan, True, &isEof, &c ) ) ;
	// return Cast(GB_NodePtr,GB_Int2GBInt(c)) ;
	return Cast(Word,c) ;
}

PRIM GB_NodePtr primHPutChar( GB_NodePtr handle, Word c )
{	
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
	// int c2 = putc( GB_GBInt2Int(c), chan->content.chan.file ) ;
	int c2 = putc( (c), chan->content.chan.file ) ;
	if (c2 == EOF) {
		GB_PassExc( gb_ThrowWriteChanError( chan ) ) ;
	}
	return gb_Unit ;
}


%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% I/O: additional primitives for enhanced performance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[98

PRIM GB_NodePtr primHGetContents( GB_NodePtr handle )
{
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
	Bool isEof ;
	GB_NodePtr res, n ;
	GB_GC_SafeEnter ;
	GB_GC_Safe1(chan) ;
	GB_GC_Safe2_Zeroed(n,res) ;

	int c ;
	GB_PassExc_GCSafe( gb_ChanGetChar( chan, False, &isEof, &c ) ) ;
	if ( isEof ) {
		GB_MkListNil( res ) ;
	} else if ( c == EOF ) {
		GB_GC_SafeLeave ;
		return gb_throwChanInteractionException( chan, strerror( errno ) ) ;
	} else {
		GB_MkCFunNode1In(n,&primHGetContents
%%[[98
		                ,chan) ;
%%][99
		                ,handle) ;
%%]]
		GB_MkListCons(res,GB_Int2GBInt(c),n) ;
	}
	
	GB_GC_SafeLeave ;
	return res ;
}

PRIM GB_NodePtr primHPutByteArray( GB_NodePtr handle, GB_NodePtr a )
{
%%[[98
	GB_NodePtr chan = handle ;
%%][99
	GB_NodePtr chan = (GB_NodePtr)(handle->content.fields[0]) ;
%%]]
  	IF_GB_TR_ON(3,printf("primWriteChan sz %d\n", a->content.bytearray.size ););
  	size_t szWritten ;
	szWritten = fwrite( a->content.bytearray.ptr, 1, a->content.bytearray.size, chan->content.chan.file ) ;
	if (szWritten != a->content.bytearray.size) {
		GB_PassExc( gb_ThrowWriteChanError( chan ) ) ;
	}
	return gb_Unit ;
}


%%]

