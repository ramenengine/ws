\ really basic workspaces functionality; just buttons (and labels that are also buttons)

#2 #0 #0 [version] [ws]
#1 #5 #0 [ramen] [checkver]

only forth definitions


create figure _node static
create window  %rect sizeof /allot
create hovered  16 stack,
variable ui  ui on

define wsing
    include ws/rangetools.f
    
    
    ( attributes )
    #1 8 <<
    \ bit #deleted
    bit #boxed
    bit #newrow
    bit #click
    drop
    
    ( element class )
    _node sizeof 0 class _element
        var attr  
        %rect sizeof field span \ pos and dims
        var data <adr 
        var datasize <int 
    ;class
    :noname  me /node ; _element class.constructor !
    :noname  data @ -exit data @ free throw ; _element class.destructor !
    
        
    \ --- Low-level stuff ---
    : ??  attr @ and 0<> ;
    : pos@  span xy@ ;
    : pos!  span xy! ;
    : dims@  span wh@ ;
    : dims!  span wh! ;
    : ew@   dims@ drop ;
    : eh@   dims@ nip ;
    : *element  ( figure - me=new )  \ add an element
        _element dynamic  me swap push ;
    : data@  ( - adr n )
        data @ datasize @ ;
    : data!  ( adr n - )
        data @ 0= if  dup allocate throw data ! dup datasize !
                  else  data @ over resize throw data ! dup datasize ! then
        ( adr n ) data @ swap move ;
                  
    \ --- Display ---
    : newrow  fs @ if  displayw 0.67 *  else 200 then  peny @ fnt @ chrh + 30 + at ;
    : boxshadow  5 5 +at  dims@ black 0.5 alpha rectf  -5 -5 +at ;
    : printdata  data@ print ;
    : textoutline
        at@  black 1 alpha
            1 0 +at  printdata
            0 1 +at  printdata
            -1 0 +at printdata
            -1 0 +at printdata
            0 -1 +at printdata
            0 -1 +at printdata
            1 0 +at  printdata
            1 0 +at  printdata
        at
    ;
    : drawlabel  at@  0 13 +at  textoutline  white printdata  at  ew@ penx +! ;
    : drawbutton
        at@  
        #click ?? if
            2 2 +at
            dims@ dgrey rectf  dims@ lgrey rect 
        else
            boxshadow  dims@ grey rectf  dims@ white rect 
        then
        16 12 +at  printdata
        at
        ew@ 15 + penx +! ;
    
    : pos2@  pos@ dims@ 2+ ;
    : +window
        window xy@ pos@ 2min window xy!
        window xy2@ pos2@ 2max window xy2!
    ;
    : draw
        #newrow ?? if  newrow  exit  then
        data@ stringwh 32 16 2+ dims!
        penx @ ew@ + 15 + displayw >= if  newrow  then
        at@ pos!
        #boxed ?? if  drawbutton
                  else  drawlabel  then 
        +window
    ;
        
    : drawwindow
        window xy@ 10 10 2- at  window wh@ 20 20 2+ black 0.4 alpha rectf  ;
    : /window
        fs @ if displayw 0.67 * else 200 then 0 0 0 window xywh!
        fs @ if displayw 0.67 *  0 at  displayw 0.67 * margins w!
        else      200 0 at    displayw margins w!
        then
    ; 
    : (ui)  ( figure - )  drawwindow /window  each> as draw ;
    
    \ --- interaction ---
    : ?hover  ( figure - )
        hovered vacate
        each> as
            evt ALLEGRO_MOUSE_EVENT.x 2@ 2p pos@ dims@ area inside? if
                me hovered push  
            then
    ;
    : click
        hovered >top @ >{
            #boxed ?? if
                #click attr or!
                data@ } ['] evaluate catch ?.catch
            ;then
        } 
    ;
    : ?click  hovered length -exit  click ;
    : unclick  figure each> as  #click attr not! ;

\ --- Public stuff ---
only forth definitions also wsing

: ui-mouse
    etype ALLEGRO_EVENT_MOUSE_AXES = if figure ?hover then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_DOWN = if ?click then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_UP = if unclick then
;

: blank  ( figure )
    vacate
;
: button  ( text c )  { figure *element data! #boxed attr ! } ;
: label  ( text c )   { figure *element data! } ;
: nr  { figure *element #newrow attr ! } ;  \ new row
: drawui  consolas fnt !  unmount  figure (ui) ;
: toggle-ui  etype ALLEGRO_EVENT_KEY_DOWN = keycode <`> = and -exit  ui @ not ui ! ;

: (system)   ide-system  toggle-ui  ui @ if ui-mouse then ;

0 value ui:lasterr
:make ?system
    ['] (system) catch
    dup if ui:lasterr 0= if cr ." GUI error." dup to ui:lasterr throw ;then then
    to ui:lasterr
;

:make ?overlay  ide-overlay  ui @ if drawui then  unmount ;

: empty  figure blank  hovered vacate  empty ;

gild