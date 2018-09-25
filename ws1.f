\ really basic workspaces functionality; just buttons (and labels that are also buttons)

#1 #0 #2 [version] [ws1]
#1 #3 #5 [ramen] [checkver]

only forth definitions

create figure  here cell+ ( current ) , 64 kbytes /allot
create window  %rect sizeof /allot

define wsing
include ramen/lib/draw.f
include ramen/lib/rangetools.f

redef on
used @ 
    0 used !
    var a  
    %rect sizeof field span \ pos and dims
    var data  \ cell counted
    used @ constant /head
used !

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
: nextrow  fs @ if  displayw 2 /  else 200 then  peny @ fonth + 18 + at ;
: boxshadow  5 5 +at  dims@ black 0.5 alpha rectf  -5 -5 +at ;
: printdata  data@ print ;
: textoutline  at@  black 1 alpha
    9 6 +at  printdata
    0 1 +at  printdata
    -1 0 +at printdata
    -1 0 +at printdata
    0 -1 +at printdata
    0 -1 +at printdata
    1 0 +at  printdata
    1 0 +at  printdata
    at ;
: drawlabel  at@  8 6 +at  white printdata  at ;
: drawbutton
    at@  
    #click ?? if
        2 2 +at
        dims@ dgrey rectf  dims@ lgrey rect 
    else
        boxshadow  dims@ grey rectf  dims@ white rect 
    then
    8 6 +at  printdata
    at ;

: pos2@  pos@ dims@ 2+ ;
: +window  window xy@ pos@ 2min window xy!
           window xy2@ pos2@ 2max window xy2! ;
: ren
    #newrow ?? if  nextrow  exit  then
    data@ strwh 16 8 2+ dims!
    penx @ ew@ + 10 + displayw >= if  nextrow  then
    at@ pos!
    #boxed ?? if  drawbutton
              else  textoutline  drawlabel  then 
    ew@ 10 + 0 +at
    +window
;

: each>  r> swap >first >{
    begin #active ?? while  dup >r call r> next repeat  drop
} ;

: drawwindow
    window xy@ 10 10 2- at  window wh@ 20 20 2+ black 0.4 alpha rectf  ;
: /window  fs @ if displayw 2 / else 200 then 0 0 0 window xywh!
    fs @ if   displayw 2 /  0 at  displayw 2 / margins w!
    else      200 0 at    displayw margins w!
    then  ; 
: (ui)  drawwindow /window figure each> ren ;

\ --- Interaction ---
create hovered 12 stack
: ?hover
    hovered 0 truncate
    figure each> 
        evt ALLEGRO_MOUSE_EVENT.x 2@ 2p pos@ dims@ area inside? if
            me hovered push  
        then
;
: top@   dup #pushed 1 - [] @ ;
: click
    {
        hovered top@ as #boxed ?? if
            a @ #click or a !
            data@ } ['] evaluate catch ?.catch
        else } then 
    ;
: ?click  hovered #pushed -exit  click ;
: unclick  figure each> a @ #click invert and a ! ;

\ --- Public stuff ---
only forth definitions also wsing

: ui-mouse
    etype ALLEGRO_EVENT_MOUSE_AXES = if ?hover then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_DOWN = if ?click then
    etype ALLEGRO_EVENT_MOUSE_BUTTON_UP = if unclick then
;


: blank  ( figure )
    dup >first dup >{ begin #active ?? while  me size@  next  erase repeat }
    swap current! ;
: button  ( text c )  { figure add data! #boxed attr! } ;
: label  ( text c )   { figure add data! } ;
: nr  { figure add #newrow attr! } ;  \ new row
: drawui  consolas fnt !  unmount  (ui) ;
variable ui  ui on
: toggle-ui  etype ALLEGRO_EVENT_KEY_DOWN = keycode <`> = and -exit  ui @ not ui ! ;
:is ?system  ide-system  toggle-ui  ui @ if ui-mouse then ;
:is ?overlay   ide-overlay  ui @ if drawui then  unmount ;

only forth definitions marker (empty)