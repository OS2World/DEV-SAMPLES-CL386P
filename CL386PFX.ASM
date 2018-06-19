              PAGE     80, 120
              TITLE    CL386PFX - CL386 prefix replacement
	SUBTTL	Copyright (c) 1991  Stephen Best
;
;
;  CL386PFX
;
;  Version 1.1
;
;
;  CL386PFX is a replacement for the runtime prefix code used with MS CL386.
;  It was developed primarily for use with re-entrant multi-threaded 32 bit
;  applications for OS/2 2.X, using the MS 386 C compiler (currently named
;  CL386). The use of this prefix enables full use of the facilities of the
;  OS/2 2.X API (with no MS specific extensions) to enable such applications
;  to be readily ported to future OS/2 platforms, such as RISC machines. No
;  changes need be made to headers or C code used with this prefix as the
;  modifications are invoked when the module is linked.
;
;  This version 1.1 has been modified to work with the _syscall declarative
;  used for malloc and free runtime functions, as introduced with the MS OS/2
;  2.0 SDK Pre-release 3.
;
;  This modification to the supplied prefix offers the following advantages:
;
;     1. Smaller EXE file size.
;
;     2. A re-entrant heap manager (used by malloc/free calls) which allows for
;        replacement of _beginthread with DosCreateThread. The heap manager
;        in this prefix allocates a 1MB heap which is sub-allocated by OS/2
;        calls and dynamically committed as required. Also the DosSuspendThread
;        and DosResumeThread can now be used without risk of a deadlock
;        situation. Use of _beginthread and _endthread with this prefix is not
;        supported.
;
;     3. A new stack replaces that defined in the DEF file. This new stack is
;        allocated 64Kb and uses the guard page feature of OS/2 2.X to
;        dynamically commit pages to the maximum above. As the stack is
;        allocated in a separate memory object, an exception will occur on an
;        overflow condition (generally an indication of looping in recursive
;        routines). It is suggested that all programs using this prefix be
;        linked with STACKSIZE 1024 in the DEF file. The HEAPSIZE parameter
;        can be omitted.
;
;     4. General protection exceptions for stack overflows and bad heap frees
;        with an indication of the cause and program address.
;
;
;  Restrictions:
;
;     1. To make use of such functions as DosCreateThread, all runtime functions
;        called by more than one thread must be re-entrant as this prefix does
;        not provide serialization to a shared resource (other than that
;        provided by the system for malloc/free calls). To this aim, a pair of
;        LIB response files have been provided to enable migration of selected
;        object files from the standard LIBC.LIB runtime library, to a new
;        re-entrant library, BITWARE.LIB which initially only contains this
;        prefix code.
;
;        This new library should be specified instead of LIBC.LIB when linking,
;        for example:
;
;          link386 /NOD test, test,, bitware os2386, test.def
;
;        The MS 're-entrant' library LIBCMT.LIB must NOT be used with this
;        replacement prefix, nor should the /MT option be specified when
;        compiling. An alternate approach is to specify the initial BITWARE.LIB
;        before LIBC.LIB when linking to pick up the appropriate object files
;        but this carries the risk of including objects that have not be tested
;        to be truly re-entrant.
;
;        Note that the list of objects provided in the LIB response files have
;        not, as yet, been fully tested for the re-entrancy requirements above
;        and it is expected that additions/subtractions will occur over the
;        life of this product.
;
;     2. As yet, no support for a number of useful runtime objects (such as the
;        printf/scanf family) has been provided, nor can these routines be used
;        with this prefix. Expect this shortcoming to change in a future
;        packaging of these CL386 runtime modifications. Volunteers wanted!
;
;     3. Care with memory allocations is required. Memory can be allocated
;        to automatic variables, by malloc and lastly by DosAllocMem. All three
;        methods should be used as appropriate. As there is only a single guard
;        page set up for stack growth, the total size of automatic variables
;        for a function call should not exceed 4096 bytes. This is not likely
;        to be a problem but can be checked by examining the maximum negative
;        offset in the stack frame from the CL386 local symbol listing, and
;        making sure that it is less than 0x1000. Malloc (and free) should be
;        used for temporary allocations of intermediate size. As there is no
;        heap cleanup logic provided by the system (that I know of), unused but
;        committed pages can remain after a free. Lastly, DosAllocMem should be
;        used for all permanent (or large temporary) allocations. These
;        allocations will be rounded up to the next 4Kb page size.
;
;     4. The command line arguments are parsed and available in the argc and
;        argv parameters as per normal. A maximum of 100 arguments will be
;        parsed. No support has been provided for the environment as this is
;        satisfied by OS/2 2.X API calls.
;
;
;  Exception codes:
;
;  This prefix will generate an exception during operation for various
;  conditions. Exceptions from the prefix will have zeros in the EIP register
;  and 0xdead in the EDX register. Any others you get are either unintentional
;  or the cause of problems external to this code. The following is an
;  explanation of the meaning of the code (in the EAX register):
;
;
;     1 - Bad API return code from initial heap allocation request
;     2 - Bad API return code from initial heap sub-allocation request
;
;     3 - Bad API return code from heap request (malloc)
;     4 - Bad API return code from heap request (free)
;
;  In both the above, EBX contains the caller's address. Code 4 is the most
;  likely one to be seen, and represents either a bad address given to a free
;  or a second free for the same address or, worse still, a corruption of the
;  heap management chain due to an out-of-bounds condition. In any event, the
;  location of the malloc or free can be worked out with a combination of the
;  COD and MAP listings.
;
;     5 - Bad API return code from initial stack allocation request
;     6 - Bad API return code from initial stack guard page setup
;
;     7 - Insufficient remaining stack for stack probe
;
;
;  Files:
;
;     CL386PFX.DOC - cover letter
;
;     CL386PFX.ASM - source for the new CL386 prefix
;     CL386PFX.MAK - NMAKE file for above
;
;     BITWARE.LIB  - object library containing CL386PFX.OBJ only
;     BITWARE.H    - header file for migrated objects
;     EXPORT.RSP   - LIB response file for exporting objects from LIBC.LIB
;     IMPORT.RSP   - LIB response file for importing objects to BITWARE.LIB
;
;  The BITWARE.LIB object library can be built from the re-entrant portions of
;  the MS LIBC.LIB library with the following commands:
;
;     LIB @EXPORT.RSP
;     LIB @IMPORT.RSP
;
;  Note that you may have to change to path name for the LIBC library on the
;  first line of EXPORT.RSP. Check the output BITWARE.LST file to see which
;  runtime functions are currently usable. ALSO note that at no time should
;  the completed BITWARE.LIB be distributed containing anything other than the
;  the replacement prefix. Objects imported from LIBC.LIB remain the
;  property of Microsoft and are subject to normal distribution regulations.
;
;  
;  Note that when using CV386 to debug modules including this prefix, you may
;  see a number of segment violation messages. These are spurious and result
;  from the initial page being validated for new program stack, as part of the
;  guard page mechanism. Just hit the GO key until these are cleared.
;
;
;  These modifications are distributed free of charge (and with no implied
;  liability or guarantee of functionality) for use as the recipient chooses,
;  excluding resale for profit. Please feel free to distribute this set of
;  files intact, together with any modifications you or others may make.
;
;  If you have any suggestions/criticisms/comments please direct them to me at
;  the below address or the Fidonet address given.
;
;
;     Stephen Best
;     July 21, 1991
;
;
;  FidoNet:    3:620/243.4
;  CompuServe: 100033,340
;
;  Bitware, Software & Services
;  P.O. Box 3097
;  Manuka  A.C.T.  2603
;  Australia
;
;
              PAGE
              .386P

;  Kernel routines

              EXTRN    DOS32ALLOCMEM: PROC
              EXTRN    DOS32FREEMEM: PROC
              EXTRN    DOS32SUBSET: PROC
              EXTRN    DOS32SUBUNSET: PROC
              EXTRN    DOS32SUBALLOC: PROC
              EXTRN    DOS32SUBFREE: PROC
              EXTRN    DOS32SETMEM: PROC
              EXTRN    DOS32EXIT: PROC

;  Variables

PAGE_SIZE     EQU      4096
STACK_SIZE    EQU      PAGE_SIZE * 16
HEAP_SIZE     EQU      PAGE_SIZE * 256
MAX_ARGS      EQU      100

;  Constants

PAG_READ      EQU      00000001h              ; read access
PAG_WRITE     EQU      00000002h              ; write access
PAG_GUARD     EQU      00000008h              ; guard page attributes
PAG_COMMIT    EQU      00000010h              ; commit storage

DOSSUB_INIT            EQU  00000001h
DOSSUB_SPARSE_OBJ      EQU  00000004h
DOSSUB_SERIALIZE       EQU  00000008h

EXIT_PROCESS  EQU      00000001h              ; exit process
              PAGE
              ASSUME   cs:FLAT, ds:FLAT, es:FLAT, ss:FLAT

DGROUP        GROUP    _DATA, CONST, _BSS, STACK


_DATA         SEGMENT  DWORD USE32 PUBLIC 'DATA'

              PUBLIC   __acrtused
__acrtused    EQU      0                      ; link hook

__stacksave   DD       0                      ; original stack pointer
__stackbase   DD       0                      ; new stack base
__heapbase    DD       0                      ; heap memory base

___argc       DD       0                      ; argument count
___argv       DD       0                      ; argument vector table address

_DATA         ENDS


CONST         SEGMENT  DWORD USE32 PUBLIC 'CONST'
CONST         ENDS


_BSS          SEGMENT  DWORD USE32 PUBLIC 'BSS'
_BSS          ENDS


STACK         SEGMENT  DWORD USE32 STACK 'STACK'
STACK         ENDS
              PAGE
_TEXT         SEGMENT  DWORD USE32 PUBLIC 'CODE'

              EXTRN    _main: PROC

;  Entry point for module

              PUBLIC   __entry
__entry       PROC


              mov      ebp, esp               ; copy caller's ebp

;  Save command line address

              mov      esi, [ebp + 16]        ; get command line address

;  Set scan/copy direction

              cld                             ; set scan/copy forward

;  Allocate stack and heap

              call     __stackinit            ; initialize stack
              call     __heapinit             ; initialize heap

;  Build command line argument array and count

              push     esi                    ; set command line address
              call     __setargv              ; parse command arguments

;  Prefix code all done, now do some work

              push     ___argv                ; argument vector array address
              push     ___argc                ; argument count
              call     _main                  ; call program
              mov      esp, ebp               ; restore stack pointer
              xchg     eax, esi               ; save return code

;  Free heap and stack

              call     __heapfree             ; free heap
              call     __stackfree            ; free stack

;  Set return code and exit

              push     esi                    ; set return code
              push     EXIT_PROCESS           ; set exit condition
              call     DOS32EXIT              ; exit


__entry       ENDP
              PAGE
__stackinit   PROC

;  New stack creation

              pop      edi                    ; return address
              mov      ebp, esp               ; copy stack pointer

              mov      __stacksave, esp       ; save stack pointer

              push     PAG_READ OR PAG_WRITE  ; attributes
              push     STACK_SIZE             ; total stack size
              push     OFFSET FLAT:__stackbase ; field for stack address
              call     DOS32ALLOCMEM          ; allocate it
              mov      esp, ebp               ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     5                      ; error code 5
              push     0                      ; no program address
              call     __error                ; call error logic

@@:           push     PAG_READ OR PAG_WRITE OR PAG_GUARD OR PAG_COMMIT
              push     PAGE_SIZE              ; page size
              mov      eax, __stackbase       ; stack base
              add      eax, STACK_SIZE - PAGE_SIZE
              push     eax                    ; last page address
              call     DOS32SETMEM            ; set attributes
              mov      esp, ebp               ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     6                      ; error code 6
              push     0                      ; no program address
              call     __error                ; call error logic

@@:           mov      esp, __stackbase       ; get new stack base
              add      esp, STACK_SIZE        ; stack end
              mov      ebp, esp               ; copy stack end address

              jmp      edi                    ; return


__stackinit   ENDP



__stackfree   PROC

;  New stack deallocation

              pop      edi                    ; return address

              mov      esp, __stacksave       ; original stack address
              mov      ebp, esp               ; copy stack end address

              push     __stackbase            ; address of stack
              call     DOS32FREEMEM           ; free heap
              mov      esp, ebp               ; restore stack pointer

              jmp      edi                    ; return


__stackfree   ENDP
              PAGE
__heapinit    PROC

;  Allocate heap

              enter    0, 0                   ; set stack frame

              push     PAG_READ OR PAG_WRITE  ; read/write allocation
              push     HEAP_SIZE              ; total heap size
              push     OFFSET FLAT:__heapbase ; field for heap address
              call     DOS32ALLOCMEM          ; allocate it
              mov      esp, ebp               ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     1                      ; error code 1
              push     0                      ; no program address
              call     __error                ; call error logic

@@:           push     HEAP_SIZE              ; suballocation size
              push     DOSSUB_INIT OR DOSSUB_SPARSE_OBJ OR DOSSUB_SERIALIZE
              push     __heapbase             ; address of heap
              call     DOS32SUBSET            ; set for initial suballocation
              mov      esp, ebp               ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     2                      ; error code 2
              push     0                      ; no program address
              call     __error                ; call error logic

@@:           leave                           ; restore ebp

              ret                             ; return


__heapinit    ENDP



__heapfree    PROC

;  Free heap

              enter    0, 0                   ; set stack frame

              push     __heapbase             ; address of heap
              call     DOS32SUBUNSET          ; free sub allocation
              mov      esp, ebp               ; restore stack pointer

              push     __heapbase             ; address of heap
              call     DOS32FREEMEM           ; free heap
              mov      esp, ebp               ; restore stack pointer

              leave                           ; restore ebp

              ret                             ; return


__heapfree    ENDP
              PAGE
__setargv     PROC

;  Parse command line arguments

              enter    0, 0                   ; set stack frame

              mov      esi, [ebp + 8]         ; command line start address
              mov      edi, esi               ; copy it
              xor      eax, eax               ; scan terminator (null)
              cmp      al, [esi]              ; do we have command line?
              je       SHORT __setargv_3      ; no, skip

              mov      ecx, -1                ; scan length
              repne    scasb                  ; scan for terminator
              repne    scasb                  ; scan for terminator

              sub      edi, esi               ; command line length
              lea      eax, MAX_ARGS * 4 [edi] ; add vector table length
              push     eax                    ; set as combined length
              call     _malloc                ; let's test our malloc routine

              mov      ___argv, eax           ; save vector array address
              lea      edi, MAX_ARGS * 4 [eax] ; copy area start
              xchg     eax, ebx               ; copy array address
              mov      ecx, 2                 ; null counter

__setargv_1:
              lodsb                           ; get next character
__setargv_2:
              or       al, al                 ; null?
              jne      SHORT @f               ; no, skip
              loop     __setargv_1            ; decrement null counter

              jmp      SHORT __setargv_3      ; end of command line

@@:           cmp      al, ' '                ; blank?
              je       __setargv_1            ; yes, skip it
              cmp      al, 09h                ; tab?
              je       __setargv_1            ; yes, skip it

              mov      [ebx], edi             ; set parameter address
              add      ebx, 4                 ; update slot address

              xor      edx, edx               ; zero quote indicator

__setargv_6:
              cmp      al, '"'                ; quote?
              jne      SHORT __setargv_7      ; no, skip

              not      edx                    ; toggle quote sequence flag

              jmp      SHORT __setargv_8      ; continue

__setargv_7:
              stosb                           ; set last character
__setargv_8:
              lodsb                           ; get next character
              or       al, al                 ; null?
              je       SHORT __setargv_5      ; yes, end of parameter

              or       edx, edx               ; in quote sequence
              jnz      __setargv_6            ; yes, skip blank/tab check

              cmp      al, ' '                ; blank?
              je       SHORT __setargv_5      ; yes, end of parameter
              cmp      al, 09h                ; tab?
              jne      __setargv_6            ; no, continue

__setargv_5:
              mov      BYTE PTR [edi], 0      ; set null
              inc      edi                    ; update address

              inc      ___argc                ; update counter
              cmp      ___argc, MAX_ARGS      ; reached maximum?
              jne      __setargv_2            ; no, continue

__setargv_3:
              leave                           ; restore ebp

              ret      4                      ; return


__setargv     ENDP
              PAGE
              PUBLIC   _malloc
_malloc       PROC

;  Runtime malloc function

              enter    4, 0                   ; set stack frame

              push     edi                    ; save edi

              mov      eax, [ebp + 8]         ; request size
              or       eax, eax               ; check if zero
              jz       SHORT _malloc_1        ; is, use it as return code

              xchg     eax, edi               ; copy request size
              add      edi, 4                 ; allow for header
              push     edi                    ; set length
              lea      eax, [ebp - 4]         ; local variable
              push     eax                    ; set output address
              push     __heapbase             ; set heap base
              call     DOS32SUBALLOC          ; call allocation routine
              lea      esp, [ebp - 8]         ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     3                      ; error code 3
              push     [ebp + 4]              ; caller's address
              call     __error                ; call error logic

@@:           mov      eax, [ebp - 4]         ; block address
              mov      [eax], edi             ; set block length as header

              add      eax, 4                 ; skip header

_malloc_1:
              pop      edi                    ; restore edi

              leave                           ; restore ebp

              ret	4	; return


_malloc       ENDP



              PUBLIC   _free
_free         PROC

;  Runtime free function

              enter    0, 0                   ; set stack frame

              mov      eax, [ebp + 8]         ; input pointer
              sub      eax, 4                 ; backspace to header

              push     [eax]                  ; set length
              push     eax                    ; set address
              push     __heapbase             ; set heap base
              call     DOS32SUBFREE           ; free block
              mov      esp, ebp               ; restore stack pointer

              or       eax, eax               ; check return code
              jz       SHORT @f               ; ok, skip

              push     4                      ; error code 4
              push     [ebp + 4]              ; caller's address
              call     __error                ; call error logic

@@:           leave                           ; restore ebp

              ret	4	; return


_free         ENDP
              PAGE
              PUBLIC   _stackavail
_stackavail   PROC

;  Runtime stackavail function, returns EXACT amount of stack remaining

              pop      ecx                    ; return address

              mov      eax, __stackbase       ; base address of stack
              sub      eax, esp               ; remaining length (negated)
              jb       SHORT @f               ; some, skip

              xor      eax, eax               ; set zero

@@:           neg      eax                    ; make amount positive

              jmp      ecx                    ; return


_stackavail   ENDP



              PUBLIC   __chkstk
__chkstk      PROC

;  Stack probe logic required for runtimes such as qsort

              pop      ecx                    ; return address

              cmp      eax, PAGE_SIZE         ; check stack adjustment
              ja       SHORT @f               ; exceed page size, error
              mov      edx, esp               ; copy current stack pointer
              sub      edx, eax               ; adjust by requested amount
              jb       SHORT @f               ; gone negative, error
              cmp      edx, __stackbase       ; compare with stack base address
              jb       SHORT @f               ; below, error

              mov      esp, edx               ; set new stack address

              jmp      ecx                    ; return

@@:           push     7                      ; error code 7
              push     ecx                    ; caller's address
              call     __error                ; call error logic


__chkstk      ENDP
              PAGE
__error       PROC

;  Error exception

              mov      eax, [esp + 8]         ; error code
              mov      ebx, [esp + 4]         ; program address (or null)
              mov      edx, 0000deadh         ; set eyecatcher

              xor      ecx, ecx               ; zero address
              jmp      ecx                    ; zap program counter


__error       ENDP
              PAGE
_TEXT         ENDS


              END      __entry
