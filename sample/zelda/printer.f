s" nes.ttf" >data 8 ALLEGRO_TTF_NO_KERNING font: nes.ttf
create printer object
variable dialog  \ code

: draw>dialog  draw>  dialog @ -exit  nes.ttf font>  dialog @ call ;
: dialog>  r> dialog ! printer >{ draw>dialog } ; 