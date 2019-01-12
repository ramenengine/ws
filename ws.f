\ really basic workspaces functionality; just buttons (and labels that are also buttons)

#2 #0 #0 [version] [ws]
#1 #5 #0 [ramen] [checkver]

only forth definitions

create figure  here cell+ ( current ) , 64 kbytes /allot
create window  %rect sizeof /allot
create hovered  16 stack,
variable ui  ui on

define wsing
    include ws/rangetools.f
    
    fields
        struct %element  %element to fields  redef on
        var a  
        %rect sizeof field span \ pos and dims
        var data <adr \ cell counted
        %element sizeof constant /head
    to fields  redef off
    
    #1 8 <<
    \ bit #deleted
    bit #boxed
    bit #active
    bit #newrow
    bit #click
    drop
    
    \ --- Low-level stuff ---
    : >first  cell+ ;
    : >current  ( fig - obj ) @ ;
    : current!  ( obj fig - ) ! ;
    : attr!  #active or a ! ;
    : attr@  a @ ;
    : ??  attr@ and 0<> ;
    : size@  #active ?? if /head data @ + else 0 then ;
    : pos@  span xy@ ;
    : pos!  span xy! ;
    : dims@  span wh@ ;
    : dims!  span wh! ;
    : ew@   dims@ drop ;
    : eh@   dims@ nip ;
    : next@  size@ me + ;
    : next  next@ as ;
    : add  ( figure )  \ really basic, and we currently can't insert stuff
        dup >current as   next  #active attr!  me swap current!  data off ;
    : data@  ( - adr n ) data dup cell+ swap @ ;
    : data!  ( adr n )   #1024 min dup data !  data cell+ swap move  ;
    
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
    
    : each> ( list - <code> )  ( me=obj - )
        r> swap >first >{
            begin  #active ?? while
                dup >r call r> next
            repeat  drop
        }
    ;
    
    : drawwindow
        window xy@ 10 10 2- at  window wh@ 20 20 2+ black 0.4 alpha rectf  ;
    : /window
        fs @ if displayw 0.67 * else 200 then 0 0 0 window xywh!
        fs @ if displayw 0.67 *  0 at  displayw 0.67 * margins w!
        else      200 0 at    displayw margins w!
        then
    ; 
    : (ui)  drawwindow /window figure each> draw ;
    
    \ --- interaction ---
    : ?hover
        hovered vacate
        figure each> 
            evt ALLEGRO_MOUSE_EVENT.x 2@ 2p pos@ dims@ area inside? if
                me hovered push  
            then
    ;
    : click
        hovered >top @ >{
            #boxed ?? if
                a @ #click or a !
                data@ } ['] evaluate catch ?.catch
            ;then
        } 
    ;
    : ?click  hovered length -exit  click ;
    : unclick  figure each> a @ #click invert and a ! ;

\ --- Public stuff ---
only forth definitions also wsing

: ui-mouse
    etype ALLEGRO_EVENT_MOUSE_AXES = if ?hover then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_DOWN = if ?click then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_UP = if unclick then
;

: blank  ( figure )
    dup >first dup >{
        begin #active ?? while
            me size@  next  erase
        repeat
    }
    swap current!
;
: button  ( text c )  { figure add data! #boxed attr! } ;
: label  ( text c )   { figure add data! } ;
: nr  { figure add #newrow attr! } ;  \ new row
: drawui  consolas fnt !  unmount  (ui) ;
: toggle-ui  etype ALLEGRO_EVENT_KEY_DOWN = keycode <`> = and -exit  ui @ not ui ! ;

:make ?system   ide-system  toggle-ui  ui @ if ui-mouse then ;
:make ?overlay  ide-overlay  ui @ if drawui then  unmount ;

: empty  figure blank empty ;