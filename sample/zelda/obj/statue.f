type: statue

( shoot shit at link )
: /shit  draw> 8 8 +at rndcolor 4 circlef ;
: (limit)  act> in-playfield? not ?end ;
: (snipe)  0 perform> 30 pauses p1 toward 1.5 dup 2* vx 2! ;
: snipe  spawn stage *actor { /shit (limit) (snipe) } ;

statue :to start  ['] snipe 30 every ;

