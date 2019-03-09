depend ramen/lib/array2d.f

decimal  \ necessary because tilemaps can be quite large
: init-buffer2d  ( array2d - )
    >r  r@ array2d.cols 2@ 2i i* cells allocate throw  r> array2d.data ! ;
fixed

: recreate-buffer2d  ( asset - )
    /assetheader + init-buffer2d ;

: unload-buffer2d
    /assetheader + array2d.data @ free throw ;

: init-buffer2d  ( cols rows buffer2d - )
    >r udup r@ array2d.cols 2!
    cells r@ array2d.pitch !
    ['] recreate-buffer2d ['] unload-buffer2d r@  /assetheader - register
    r> init-buffer2d ;

: buffer2d:   ( cols rows - <name> )  ( - array2d )
    create  /assetheader /allot  %array2d sizeof allotment  init-buffer2d
    does>  /assetheader + ; 