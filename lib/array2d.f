$000100 [version] array2d-ver

: 2move  ( src /pitch dest /pitch #rows /bytes -- )
  locals| #bytes #rows destpitch dest srcpitch src |
  #rows 0 do
    src dest #bytes move
    srcpitch +to src  destpitch +to dest
  loop ;

: clip  ( col row #cols #rows #destcols #destrows -- col row #cols #rows )
  2>r  2over 2+  0 0 2r@ 2clamp  2swap  0 0 2r> 2clamp  2swap 2over 2- ;

: batch  ( ... addr #cells xt -- ... )  ( ... addr -- ... )
  >code -rot  cells bounds do  i swap dup >r call  r>  cell +loop  drop ;

: `batch  ( ... addr xt -- ... )  ( ... addr -- ... )  \ -1 is terminator
  >code begin  over @ 0 >=  while  2dup 2>r  call  r> r> cell+ swap repeat  2drop ;

struct array2d
    array2d int svar numcols
    array2d int svar numrows
    array2d 0 int sfield data

decimal
    : array2d:  ( numcols numrows -- <name> )
        2pfloor 2dup  create  2,  2i * cells /allot ;

    : count2d ( array2d -- data #cells )  dup data swap numcols 2@ 2i * ;
fixed

: dims  ( array2d -- numcols numrows )  numcols 2@ ;

: (clamp)  ( col row array2d -- same )
  >r  0 0 r@ numcols 2@ 2clamp  r> ;

\ TODO: this is incomplete!
\      if dest col/row are negative, we need to adjust the source start address!!

: (clip)   ( col row #cols #rows array2d -- same )
  dims 1 1 2- clip ;

decimal
    : loc  ( col row array2d -- addr )
      (clamp) >r  2i r@ numcols @ 1i * +  cells  r> data + ;
fixed

: pitch@  ( array2d -- /pitch strid)  numcols @ cells ;

: addr-pitch  ( col row array2d -- addr /pitch )  dup >r loc r> pitch@ ;

: write2d  ( src-addr pitch destcol destrow #cols #rows dest -- )
    locals| dest |
  dest (clip)  2swap dest addr-pitch  2swap  swap cells 2move ;

: move2d  ( srcrow srccol destcol destrow #cols #rows src -- )
  locals| src |
  2>r 2>r  src addr-pitch  2r> 2r> write2d ;

: some2d  ( ... col row #cols #rows array2d XT -- ... )  ( ... addr #cells -- ... )
  >r >r  r@ (clip)   2swap r> addr-pitch
  r> locals| xt pitch src #rows #cols |
  #rows 0 do  src #cols xt execute  pitch +to src  loop ;

: some2d>  r> code> some2d ;

:noname  third ifill ;
: fill2d  ( val col row #cols #rows array2d -- )  literal some2d  drop ;

: scan2d  ( ... array2d xt -- ... )  ( ... addr #cells -- ... )
  >r >r  0  0  r@ dims  r> r> some2d ;

: scan2d>  r> code> scan2d ;

\ : some2d>  r> code> some2d ;
\ : each2d>  r> code> each2d ;

:noname  cr  cells bounds do  i @ h.  cell +loop ;
: 2d.  >r 0 0 r@ dims 16 16 2min  r> literal some2d  ;


\ test
marker dispose
10 15 array2d: a
12 7 array2d: b
a count2d 5 ifill
b count2d 10 ifill

cr .( === ARRAY2D tests passed. === )
dispose
