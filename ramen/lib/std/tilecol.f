( Simple tilemap collision )

( what sides the object collided )
0 value lwall?
0 value rwall?
0 value floor?
0 value ceiling?

[undefined] tstep@ [if] : tstep@ 16 16 ; [then]

extend: _actor
    var mbx  var mby   \ tilemap collision box x,y,relative to origin (0,0 local)
    var mbw  var mbh   \ tilemap collision box width,height
;class
_actor >prototype {
    -8 -8 mbx 2!
    16 16 mbw 2!
}


defer on-tilemap-collide  ' drop is on-tilemap-collide  ( tileval - )
defer tileprops@   :noname drop 0 ; is tileprops@  ( tileval - bitmask )  
[undefined] loc [if] defer loc [then]   ( col row array2d - adr )


#1
    bit BIT_CEL
    bit BIT_FLR
    bit BIT_WLT
    bit BIT_WRT
value tile-bits

define collisioning
    
    0 value map
    : map@  ( col row - tile )  map loc @ ;

    : cel? BIT_CEL and ; \ ' ceiling '
    : flr? BIT_FLR and ; \ ' floor '
    : wlt? BIT_WLT and ; \ ' wall left '
    : wrt? BIT_WRT and ; \ ' wall right '
    
    : vector   create 0 , here 0 , constant ;
    vector nx ny  \ new velocity
    
    : gap  ( - n ) tstep@ drop ;  \ just square tiles supported for now
    
    : px x @ mbx @ + ;
    : py y @ mby @ + ;

    variable t
    : xy>cr  ( x y tilesize - c r )
        dup  2/  2pfloor ;
        
    : pt  ( x y tilesize - n )  \ point
        gap xy>cr  map@ dup t !  tileprops@ ;          

    ( increment coordinates )
    : ve+  swap gap +  mbw @ #1 - px +  min  swap ;
    : he+  gap +  mbh @ #1 - ny @ +  min ;

    : +vy ny +! ny @ py - vy ! ;
    : +vx nx +! nx @ px - vx ! ;

    ( push up/down )
    : pu ( xy ) nip gap mod negate +vy  true to floor?  t @ on-tilemap-collide  ;
    : pd ( xy ) nip gap mod negate gap + +vy  true to ceiling?  t @ on-tilemap-collide ;

    ( check up/down )
    : cu mbw @ gap / 2 + for 2dup pt cel? if pd unloop exit then ve+ loop 2drop ;
    : cd mbw @ gap / 2 + for 2dup pt flr? if pu unloop exit then ve+ loop 2drop ;

    ( push left/right )
    : pl ( xy ) drop gap mod negate ( -1.0 + ) +vx  true to rwall?  t @ on-tilemap-collide ;
    : pr ( xy ) drop gap mod negate gap + +vx  true to lwall?  t @ on-tilemap-collide ;

    ( check left/right )
    : cl  mbh @ gap / 2 + for 2dup pt wrt? if pr unloop exit then he+ loop 2drop ;
    : crt mbh @ gap / 2 + for 2dup pt wlt? if pl unloop exit then he+ loop 2drop ;

    : ud vy @ -exit vy @ 0 < if px ny @ cu exit then px ny @ mbh @ + cd ;
    : lr vx @ -exit vx @ 0 < if nx 2@ cl exit then   nx @ mbw @ + ny @ crt ;

    : init   px py  vx 2@  2+  nx 2!  0 to lwall? 0 to rwall? 0 to floor? 0 to ceiling? ;

only forth definitions fixed 
also collisioning

: tilemap-physics ( array - ) to map  init ud lr ;

only forth definitions