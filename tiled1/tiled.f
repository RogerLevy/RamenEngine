[section] preamble
$10000 [version] tiled-ver
\ Tiled module for RAMEN

[undefined] draw-ver [if] $000100 include ramen/lib/draw [then]
[undefined] array2d-ver [if] $000100 include ramen/lib/array2d [then]
[undefined] xml-ver [if] $000100 include kit/lib/xml [then]
$10000 include ramen/tiled1/tilegame

\ -------------------------------------------------------------------------------------------------
[section] tilemap
\ Tilemap objects
\ A large singular 2D array is used for stability

var scrollx var scrolly  \ used to define starting column and row!
var w var h              \ width & height in pixels

4096 4096 array2d: tilebuf

: /tilemap
    displaywh w 2!
    draw>
        at@ w 2@ clip>
        scrollx 2@  20 20 scroll  tilebuf loc  tilebuf pitch@  draw-tilemap ;

: map@  ( col row -- tile )  tilebuf loc @ ;

: >gid  ( tile -- gid )  $0000fffc and 10 << ;

\ hex addressing
: htile@  ( #col #row -- tile ) 2p map@ ;

\ -------------------------------------------------------------------------------------------------
[section] tmx

$10000 include ramen/tiled1/tmx

\ Load tilemap and objects
\  2 arrays, one to store unique tile bitmaps and one for object initializers.
\  A hook lets you do extra stuff per tile

defer onloadtile  ( dom-nnn -- )  ' drop is onloadtile

5000 cellstack bitmaps
0 value ts                        \ dom-nnn
create tempimg  /image /allot
5000 cellstack initializers

var gid

\ Deferred words.
\ They can all assume ONE has just been called.
\ They can also assume the GID has already been set; same for HIDE (=0).

defer onmapload  ' execute is onmapload  ( initializer -- )  \ executes the initializer (or not)
defer obj  ' noop  is obj   ( -- )  \ default initializer when type isn't specified
defer box  ' 2drop is box  ( w h -- )

\ MAKE-INITIALIZERS
\ make array of initializer XT's.  if the object has a "type", it's
\ looked up in the dictionary and if it exists we get the XT and put it in the array.
\ if it doesn't exist or if the "type" is not defined we use ' *OBJ
\ no need to TRUNCATE INITIALIZERS since we'll be using GID's as indices.
\ if a tile element doesn't exist at all we of course use ' *OBJ then too.

: (defaults)
    ts tilecount@ for
        ['] obj  ts @firstgid i +  initializers [] !
    loop ; \ default all to OBJ

: make-initializers  ( -- )
    (defaults)
    ts tiles>  ( tile-node )  >r                                        \ process any tile nodes
        r@ ?type if  uncount find not if  drop bright cr ." ERROR evaluating tile type, continuing..." normal ['] obj  then
               else  ['] obj  then
        ts @firstgid  r@ @id +  initializers nth !
        r@ onloadtile
    r> drop
;

: get-image
    >r  tempimg ts r@ tile-image load-image
    tempimg bmp @ ts r> tile-gid tiles nth !
    tempimg bmp @ bitmaps push ;

: get-single-image
    tempimg ts single-image load-image
    tempimg ts tile-dims ts @firstgid change-tiles
    tempimg bmp @ bitmaps push ;

: load-tiles
    bitmaps scount for  @+ -bmp  loop drop  bitmaps 0 truncate
    clear-tiles
    #tilesets for
        i tileset[] to ts
        cr ts >el x.
        ts #images 1 > if
            ts @tilecount for  i get-image  loop
        else
            get-single-image
        then
        make-initializers
    loop ;

: load-objects  ( objgroup-node -- )
    dup cr x.
    \ get the destination objlist first
    dup @nameattr ['] evaluate catch if
        2drop objects  bright ." ERROR evaluating object group name (objlist), continuing..." normal
    then  in
    objects> >r
        cr r@ x.
        r@ @xy at
        r@ ?name if
            ['] evaluate catch if  bright ." ERROR evaluating object name, continuing..." normal then
        else
            r@ rectangle? not if
                ONE  r@ @gid gid !
                r@ @visible not hide !
                gid @ initializers [] @ ONMAPLOAD
            else
                r@ @wh ONE BOX
            then
        then
    r> drop ;


: convert-tile  ( n -- n )
    dup 2 << over $80000000 and 1 >> or swap $40000000 and 1 << or ;

: convert-tilemap  ( col row #cols #rows array2d -- )
    some2d> cells bounds do
        i @ convert-tile i ! cell
    +loop ;

: get  ( layernode destcol destrow -- )
    3dup tilebuf addr-pitch extract-tile-layer
    rot @wh tilebuf convert-tilemap ;

: load  ( map -- )  count opentmx  load-tiles ;

: map  ( -- <name> <filespec> )  ( -- map )  create <filespec> string, ;


\ -------------------------------------------------------------------------------------------------
[section] collision

include ramen/tiled1/collision

var onhitmap  \ XT;  ( info -- )  must be assigned to something to enable tilemap collision detection

\ map hitbox; exclusively for colliding with the TILEBUF; expressed in relative coords
var mbx  var mby  var mbw  var mbh

: onhitmap>  ( -- <code> ) r> code> onhitmap ! ;

: collide-objects-map  ( objlist tilesize -- )
    locals| tilesize |
    each>   x 2@  mbx 2@ x 2+!  onhitmap @ if  mbw 2@  tilesize  onhitmap @ collide-map  then
            x 2! ;
