\ really basic workspaces functionality; just buttons (and labels that are also buttons)

#1 #2 0 [ramen] checkver

only forth definitions define wsing
require ramen/lib/draw.f

redef on
used @ 
    0 used !
    var a  
    %rect sizeof field span \ pos and dims
    var data  \ cell counted
    used @ constant /head
used !

\ #1 constant #deleted
#2 constant #boxed
#4 constant #active
#8 constant #newrow

create figure  here cell+ ( current ) , 64 kbytes /allot

: >first  cell+ ;
: >current  ( fig - obj ) @ ;
: current!  ( obj fig - )  ! ;
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

: next  size@ me + as ;
: add  ( figure )  \ really basic, we can't insert stuff so it's all going to be
                    \ generated with a script at startup
    dup >current as next  #active attr!  me swap current! ;
: clear  ( figure )
    dup cell+ dup off swap ! ;

: data@  data dup cell+ swap @ ;
: data!  dup data !  data cell+ swap move ;

: nextrow  0  peny @ fonth + 18 + at ;
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
: ren
    white  
    #newrow ?? if  nextrow  exit  then
    at@ pos!
    data@ strwh 16 8 2+ dims!
    penx @ ew@ + 10 + displayw >= if  nextrow  then
    #boxed ?? if  boxshadow  dims@ grey rectf  dims@ white rect
              else  textoutline  then 
    at@  8 6 +at  white printdata  at
    ew@ 10 + 0 +at
;
: (ui)  begin  #active ?? while  ren  next  repeat ;

only forth definitions also wsing

: button  ( text c )  { figure add data! #boxed attr! } ;
: label  ( text c )   { figure add data! } ;
: nr  { figure add #newrow attr! } ;  \ new row
: drawui  consolas fnt !  unmount  0 0 at  figure >first >{ (ui) } ;
variable ui  ui on
: toggle-ui  etype ALLEGRO_EVENT_KEY_DOWN = keycode <`> = and -exit  ui @ not ui ! ;
:is ?system  ide-system  toggle-ui ;
:is ?overlay   ide-overlay  ui @ if drawui then  unmount ;

only forth definitions


