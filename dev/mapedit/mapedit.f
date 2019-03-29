include ramen/ramen.f
#2 #0 #0 [ws] [checkver]
#2 #0 #0 [ramen] [checkver]
empty
project: dev/mapedit
depend ramen/basic.f                    \ load the basic packet
depend ramen/lib/std/tilemap2.f         \ load tilemap support
nativewh resolution

ld apptools

create curMapFile  256 /allot   s" dev/mapedit/zelda.buf" curMapFile place
create curTilesetFile  256 /allot  s" dev/mapedit/overworld-tiles.png" curTilesetFile place
create curPaletteFile  256 /allot  s" dev/mapedit/NES_palette.png" curPaletteFile place
variable curTile  4 curtile !
create palette  %image sizeof /allot
create curColor 1e sf, 1e sf, 1e sf, 1e sf,
: !color  curColor fore 4 cells move ;

curPaletteFile count palette load-image

: mapedit:show  show> ramenbg unmount stage draws ;
mapedit:show

stage actor: map0   /tilemap  256 256 w 2!  2 2 sx 2!  0 0 x 2!
    :now draw>  me transform> tilemap ;

stage actor: tile0  524 0 x 2!  16 16 sx 2!
    :now  16 16 w 2!  draw>  me transform> 0 0 at curTile @ tile ;

stage actor: color0 524 270 x 2!  256 16 w 2!
    :now  draw>  !color  w 2@ rectf ;

stage actor: tileset0  524 300 x 2!  2 2 sx 2!  
    :now draw>  tb img !  img @ imagewh w 2!  0 0 tb imagewh 0 bsprite ;

stage actor: hilite0
    :noname draw>  tileset0 >{ curTile @ tb subxy sx 2@ 2*   x 2@ 2+  at  tile0 's w 2@
                sx 2@ 2*  2dup  white rect  -1 -1 +at  2 2 2+ black rect } ; execute

stage actor: palette0  796 0 x 2!  1.5 1.5 sx 2!  palette img ! 
    :now palette imagewh w 2! draw> sprite ;


: subcols  image.subcols @ ;

: box  x 2@ w 2@ sx 2@ 2* aabb 1 1 2- ;
: (tile)  map0 >{ curtile @ maus x 2@ 2- sx 2@ 2/ scrollx 2@ 2+ tb subwh 2/ tilebuf loc } ;
: that   (tile) @ curtile ! ;
: lay  (tile) ! ;
: mpos  maus x 2@ 2- sx 2@ 2/ ;
: pick   mpos tb subwh 2/ 2pfloor tb subcols * + 1 + curtile ! ;
: crayon  curColor  img @ >bmp  mpos 2i  al_get_pixel ;
: paint  curTile @ tile>rgn 2drop rot onto> mpos 2+ 2i curColor 4@ al_put_pixel ;
: eyedrop  curColor curTile @ tile>rgn 2drop mpos 2+ 2i al_get_pixel ;
: interact?  @ maus box within? and ;
: pan  mdelta globalscale dup 2/ sx 2@ 2/ 2negate scrollx 2+! ;

stage actor: ctl


:noname act>
    map0 as 
        <space> kstate lb @ and if  pan  ;then
        lb interact? if  lay  ;then
        rb interact? if  that   ;then
    tile0 as 
        lb interact? if  paint  then
        rb interact? if  eyedrop  then
    tileset0 as 
        lb interact? if  pick  then
    palette0 as 
        lb interact? if  crayon  then
        rb interact? if  crayon  then
; execute

: tilebankbmp ( n - bmp )
    tb >r  tilebank  tb >bmp   r> to tb ;

: save
    0 0 tilebuf loc 512 512 * cells curMapFile count file!
    0 tilebankbmp curTilesetFile count savebmp
;

: tw  tb subwh drop ;
: th  tb subwh nip ;

: sw  shift? if map0 's w @ else tw then ;
: sh  shift? if map0 's h @ else th then ;

: mapedit-events
    etype ALLEGRO_EVENT_KEY_CHAR = if
        keycode <e> = if  0 curtile !  ;then
        keycode <up> = if     sh negate map0 's scrolly +! ;then
        keycode <down> = if   sh map0 's scrolly +! ;then
        keycode <left> = if   sw negate map0 's scrollx +! ;then
        keycode <right> = if  sw map0 's scrollx +! ;then
    then
;

: mapedit:pump  pump> app-events mapedit-events ;
mapedit:pump

: (load-tilemap)  curMapFile count 0 0 tilebuf loc 512 512 * cells @file ;

: (load-tileset)  0 tilebank  curTilesetFile count 16 16 loadtileset ;

nr
option: load-tilemap  curMapFile s" *.buf" osopen if (load-tilemap) then ;
option: load-tileset  curTilesetFile s" *.png" osopen if (load-tileset) then ;
nr
option: wash
    curTile @ tile>rgn 2drop rot onto> at
    !color  16 16 rectf
;
option: revert
    (load-tilemap)  (load-tileset)
;

\ option: load-palette ;
\ option: load-project ;
\ option: new-project ;
s" save" button

(load-tileset)
(load-tilemap)
\ load-palette
: empty  save empty ;

page
repl off