( transformation stack )
create mstack 16 cells 32 * /allot
transform: t:m
variable (m)
: mcurrent  (m) @ 16 cells - [ 16 cells 32 * #1 - ]# and mstack + ;
: mtop  (m) @ [ 16 cells 32 * #1 - ]# and mstack + ;
: tpush ( - )  16 cells (m) +!  mcurrent al_use_transform  mcurrent mtop 16 cells move ; 
: tpop ( - )  -16 cells (m) +!  mcurrent al_use_transform  mcurrent mtop 16 cells move ;
: translate  ( x y - ) 2af mtop -rot al_translate_transform ;
: scale  ( sx sy - ) 2af mtop -rot al_scale_transform ;
: rotate  ( angle - ) 1af mtop swap al_rotate_transform ;
: hshear  ( n - ) 1af mtop swap al_horizontal_shear_transform ;
: vshear  ( n - ) 1af mtop swap al_vertical_shear_transform ;
: identity  mtop al_identity_transform ;
identity tpush

( draw relative )
: transform  ( - )
    sx 2@ scale
    ang @ rotate
    x 2@ [undefined] HD [if] 2pfloor [then] translate
;

: view  ( - )
    x 2@ [undefined] HD [if] 2pfloor [then] 2negate translate
    ang @ negate rotate
    1 1 sx 2@ 2/ scale
;

: view>  ( object - <code> )
    >{ view tpush } r> call tpop ;

: transform>  ( object - <code> )
    >{ transform tpush } r> call tpop ;
