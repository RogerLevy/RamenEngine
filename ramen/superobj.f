( Super objects! )

\ [x] - Classed objects
\ [x] - Prototypes
\ [x] - Two kinds of allocation - dictionary (static) and heap (dynamic)
\ [x] - Smart fields - different classes' fields can reuse names and you can check for field ownership on a class basis.
\ [x] - Private words
\ [x] - Constructors and destructors
\ [x] - Inspection
\ [x] - Class extensions
\ [x] - Pool allocation (problem: objects aren't all nodes!!! what do?? maybe just custom build for actors)

\ TODO:
\ [x] - CLASS: copy all field instances and add them, plus the offset table
\ [x] - Make nodes compatible with this so we can subclass from them
\ [ ] - Implement arrays, stacks and strings, including dynamic ones.
\ [x] - Initialize offset tables with high offsets intended to cause segfaults
\ [x] - >{ { }
\ [x] - Implement ?ALREADY

\ MAYBE, MAYBE NOT:
\ [ ] - Automatic construction/destruction of embedded objects, such as collections  (downside: slow)


\ depends on structs.f and Venery


\ 0 value me  \ defined in piston.f

0 value cc \ current Class
0 value nextOffsetSlot \ next offset in offset table
0 value (superfield)  \ temporary variable
0 value (size)        \ temporary variable
0 value lastClass  \ last defined Class

: ?literal  state @ if postpone literal then ;

also venery
    
    struct %class
        %class %node sembed class>node   
        %class svar class.size           <int
        %class svar class.wordlist       <hex
        %class svar class.prototype      <adr
        %class svar class.prototypeSize  <adr
        %class svar class.maxSize        <int
        \ %class svar class.useHeap
        %class svar class.constructor    <word
        %class svar class.destructor     <word
        %class %node sembed class>pool 
        %class %node sembed class>fields
        %class 1024 cells sfield class>offsetTable  <int

    struct %superfield
        %superfield svar superfield.offset  <int
        %superfield svar superfield.magic
    
    struct %field 
        %field %node sembed superfield>node 
        %field svar field.size        <int   
        %field svar field.offset      <int      
        %field svar field.inspector   <word    
        %field svar field.class       <adr
        %field svar field.superfield  <adr
        %field svar field.attributes  <hex

    : old-sizeof  sizeof ;    

previous

( class utils )
: prototype  ( class - object )  class.prototype @ ;
: >wordlist  ( class - wordlist )  class.wordlist @ ;
: sizeof  ( class - n ) class.size @ ;
: >offsetTable  ( class - adr )  [ 0 class>offsetTable ]# ?literal s" +" evaluate ; immediate
: >fields  class>fields ; 
: >pool    class>pool ;


( object utils )
: >class  ( object - class )  s" @" evaluate ; immediate
: size  ( object - n )  >class sizeof ;
: class!  ( class object - ) ! ;
: is?  ( object class - flag ) swap >class = ;

( search order )
: converse  ( class - )
    >wordlist +order
;
: -converse  ( class - )
    >wordlist -order
;
: ?converse  me -exit state @ ?exit me >class converse  ;
: ?-converse me -exit state @ ?exit me >class -converse ;

: as  ( obj - )
    ( ?-converse )
    dup to me  >class >offsetTable to offsetTable
    ( ?converse )
;
create mestk  0 , 16 cells allot
: i{ ( - ) me mestk dup @ cells + cell+ !  mestk @ 1 + 15 and mestk ! ;  \ interpreter version, uses a circular stack
: i} ( - ) mestk @ 1 - 15 and mestk !  mestk dup @ cells + cell+ @ as ; 
: {  ( - ) state @ if s" me >r" evaluate else  i{  then ; immediate
: }  ( - ) state @ if s" r> as" evaluate else  i}  then ; immediate
: >{ ( object - )  s" { as " evaluate ; immediate  \ }


: add-field  ( field class - )  >fields push ;

: superfield.offset ; immediate


: 's  ( object - <field> adr )
    state @ if
        s" dup >class >offsetTable" evaluate
        ' >body superfield.offset @ postpone literal
        s" + @ +" evaluate
    else
        dup >class >offsetTable ' >body superfield.offset @ + @ +
    then
; immediate

: field-exists
    >in @ >r
    defined if
        >body cell+ @ $12345678 =
    else
        drop 0 then
    r> >in ! ;

: (.field)  ( adr size - )
    bounds ?do i @ dup if p. else i. then cell +loop ;


: superfield=  field.superfield @ (superfield) = ;

: ?already
    cc >fields 0 ['] superfield= rot which@ dup if
        r> drop
        ( found-field ) to lastField
        \ (Superfield) .name
    else
        drop
    then ;

: create-field-instance  ( size superfield - )
    to (superfield) to (size)
    
    ?already  \ early out if instance of superfield already in class
    
    cc sizeof
        cc class>offsetTable
            (superfield) superfield.offset @ ( the offset slot offset ) + !
    
    
    %field old-sizeof allotment >r
        r@ to lastfield  \ needed for defining inspectors
        r@ /node
        (superfield)  r@ field.superfield !
        (size) r@ field.size !
        cc class.size @ r@ field.offset !
        ['] (.field) r@ field.inspector !
        r@ cc add-field
    r> drop

    (size) cc class.size +!
;

: create-superfield  ( - <name> )  ( - adr )
    >in @ create >in !
    nextOffsetSlot , $12345678 ,
    nextOffsetSlot cell+ #4095 and to nextOffsetSlot
    does> superfield.offset @ offsetTable + @ me + 
;

: ?superfield  ( size - <name> flag )  ( - adr )    
    field-exists not if
        ( not defined; define the superfield word )
        create-superfield
        ( create the anonymous field instance, for great justice )
        ( size ) ' >body create-field-instance
        true
    else 
        ( size ) ' >body create-field-instance
        false
    then
;

: allocation  dup class.maxSize @ dup if nip else drop class.size @ then ;

: /object  ( class object - )
    >r 
        dup prototype r@ rot sizeof move
    r> as 
    me >class class.constructor @ execute
    ( initialize embedded objects )
\    me >class >fields each>
\        dup field.class @ dup if
\            ( field class )
\            swap  @ offsetTable + @ me +
\                >{ recurse }
\        else
\            drop drop
\        then
;

: static  dup allocation allotment /object ;

: dynamic  ( class - object )
\    dup class.useHeap @ if
\        dup allocation allocate throw
\    else
        dup class>pool length if
            dup class>pool pop
        else
            dup sizeof allotment 
        then
\    then
    /object
;

: destruct  ( object - )
    >{ me >class class.destructor @ execute } ;

: destroy  ( object - )
    dup destruct
\    dup >class class.useHeap @ if
\    free throw
\    else
        dup >class class>pool push
\    then
;


: class:  ( initialsize maxsize - <name> )  \ pass 0 for maxsize to not have one
    create
        %class old-sizeof allotment to cc
        cc to lastClass

    cc /node
    cc >fields /node
    cc >pool /node
    wordlist cc class.wordlist !
    ( maxsize ) cc class.maxSize !    
    ( initialsize ) cell max cc class.size !
    ['] noop cc class.constructor !
    ['] noop cc class.destructor !
    cc class>offsetTable  1024  $80000000  ifill
;

: !prototype
    cc class.prototype @ 0= if
        \ create a new prototype copied from superclass
        cc allocation allotment cc class.prototype !
        cc allocation cc class.prototypeSize !  \ support extensions
        cc dup prototype class!  \ set the prototype's class, v. important
    else
        cc class.maxSize @ 0= if
            \ create a new prototype copied from the current one.  (for when extending classes)
            cc prototype 
                cc allocation allotment cc class.prototype !
                ( prototype ) cc prototype cc class.prototypeSize @ move
            cc allocation cc class.prototypeSize !
        then
    then
;

: ;class
    !prototype
;

wordlist constant knowinging
knowinging +order definitions
    : ; postpone ; -converse set-current knowinging -order ; immediate
previous definitions

: (knowing)  ( class - current class )
    get-current swap dup converse ;

: :- ( class - <name> <code> current class ; )
    (knowing) definitions knowinging +order : ;

: :+ ( class - <name> <code> ; )
    (knowing) knowinging +order : ;

: field  ( size - <name> ) ( object - object+n )
    ?superfield drop ;
    
: var  ( - <name> ) ( object - object+n )
    cell field ;

: fields:  ( class - )
    to cc ;

\ superfield offset utility
: superfield>offset  ( superfield class - offset )
    >offsetTable swap superfield.offset @ + @ ;


( Inspection )

: (peek)  ( object class - ) 
    >fields each> ( adr object, field, - adr )
        cr normal space
        dup field.superfield @ body> >name ccount type ."  : " 
        bright
        2dup dup field.size @ swap field.inspector @ execute
        field.size @ +   \ go to next field in the passed instance
;

: peek  ( object - )
    dup >class .name 
    dup >class  dup >fields dup length if node.first @ field.offset @ u+ ( skip any collection stuff )
                                       else drop then
        (peek) drop normal ;

( Utils )
: .me   cr me peek ;
: .class  >fields each> dup field.superfield @ .name   field.offset @ i.  cr ;

: knowing ( - <class> )
    only forth definitions ' >body converse ;

: extend:  ( - <name> )
    ' >body to cc 
;

( Node class )

%node venery:sizeof dup class: _node
;class
: me/node  me /node ;
' me/node _node class.constructor !

( Dynamic classes - based on _node )

: node-class:  ( maxsize )
    _node sizeof swap class:
    ['] me/node lastClass class.constructor ! ;

: invalidate-pool  ( class )
    class>pool 0node ;


( TEST )

marker dispose
: test  not abort" Super Objects unit test fail" ;

dispose

