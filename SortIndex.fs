: Check-Environment ( Check we have the required wordlists )
    S" CORE-EXT"
    S" FACILITY-EXT"
    S" FILE"
    S" STRING"
    S" SEARCH-ORDER"
    
    BEGIN
        DEPTH
        0 >
    WHILE
        2DUP
        ENVIRONMENT? IF
            DROP 2DROP
        ELSE
            CR ." Required wordset missing: " TYPE
            ABORT
        THEN
    REPEAT
;
Check-Environment


: input-filename     S" forth.wrd" ;    ( Unsorted - definition order )
: output-filename    S" forth.wds" ;    ( Sorted - alphabetical order )

\ The input line has the following format:
\
\ \indexentry{10.6.2}{1306}{40}{EKEY>FKEY}{facility}{ EXT}{X:ekeys}{EKEYtoFKEY}{e-key-to-f-key}
\
\ \indexentry    - The LaTeX command that generates the index entry
\ {10.6.2}       - The Section the definition appears it
\                  (Chapter 10, section 6, subsection 2)
\                  Note: There is no subsection for Core words
\ {1306}         - The Word number, a four digit number,
\                  or {-} if a number has not yet been assigned
\ {40}           - The Word sub-number (or {} if undefined)
\ {EKEY>FKEY}    - The LaTeX frendly version of the word name
\ {facility}     - The name of the wordset
\ { EXT}         - If the word is part of the extended wordset or {}
\                  if it is part of the core wordset
\ {X:ekeys}      - The proposal that introduced the word (or {})
\ {EKEYtoFKEY}   - A fendly cross-reference lable given to the word
\                  (must not contain URL or PDF specail characters)
\ {e-key-to-f-key} - The "english" produnciation for the word
\                    (or {} if none given)

\ ==== String handling ====

: $. ( c-addr -- )
    DUP 0 = IF
        ." (null)" DROP
    ELSE
        COUNT TYPE
    THEN
;

: $, ( c-addr len -- addr )
    ALIGN HERE >R
    DUP C,                    ( Store string len )
    HERE OVER CHARS ALLOT     ( Reserve space for len characters )
    SWAP CMOVE                ( Copy string into dictionary )
    R>                        ( Return address of count )
;

( Find the first occurance of the character /char/ in the string    )
( identified by /c-addr/ /len/ starting at character position /n1/. )
( If the chatacter is found, /flag/ will be true and /n2/ is the    )
( position of the found chatacter.  Otherwise /flag/ is false and   )
( the value of /n2/ is unknown.  Should /n1/ be equal to or larger  )
( than /len/, /flag/ will be false.                                 )

: indexOf ( c-addr len char n1 -- n2 flag )
    ROT 2DUP < IF
        FALSE SWAP ROT DO
            DROP
            OVER I CHARS + C@
            OVER = IF
                2DROP I TRUE LEAVE
            THEN
            FALSE
        LOOP
        DUP 0= IF
            ROT DROP
        THEN
    ELSE
        ROT 2DROP NIP FALSE
    THEN
;    

\ ==== Character handling ====

0 CHAR+ CONSTANT /CHAR

( Convert the character /char/ into upper case )
: C>UPPER ( char -- char' )
    DUP [CHAR] a [ CHAR z 1+ ] LITERAL WITHIN IF
        [ CHAR a CHAR A - ] LITERAL -
    THEN
;

( Determin if /char/ is an ASCII alphebetic character )
: ?ALPHA ( char -- flag )
    C>UPPER [CHAR] A [ CHAR Z 1+ ] LITERAL WITHIN
;

( Convert the ASCII chatacter to its hexadecimal value )
: C>HEX ( char -- n )
    C>UPPER [CHAR] 0 - DUP 9 > IF 7 - THEN
    DUP $F > ABORT" Invalid Hex character"
;

\ ==== Data node ====

( n' = n + len; addr' = addr + n )
: +FIELD: ( n len "<name>" -- n'; addr -- addr' )
    CREATE OVER , + DOES> @ +
;

: node, ( len -- addr )
    ALIGN HERE SWAP DUP ALLOT 2DUP ERASE DROP
;

0
    1 CELLS +FIELD: Node.Next
    1 CELLS +FIELD: Node.Line
    1 CELLS +FIELD: Node.Name
    1 CELLS +FIELD: Node.Number
CONSTANT IndexNode

VARIABLE FirstNode
0 VALUE CurrentNode

: .Node ( addr -- )
    BASE @ >R CR
    ." Node: " DUP HEX U. CR
    ."   Next: " DUP Node.Next   @ U. CR
    ."   Line: " DUP Node.Line   @ $. CR
    ."   Name: " DUP Node.Name   @ $. CR
    ."    Key: " DUP Node.Number @ $. CR
    DROP
    R> BASE !
;

: .n ( node -- )
    DUP Node.Number @ $.
    SPACE
    DUP Node.Name @ DUP $.
    C@ $20 SWAP - SPACES
    Node.Line @ $.
;

( Add to next on stack, n4 = n1 + n3 )
: N+ ( n1 n2 n3 -- n4 n2 )
    ROT + SWAP
;

\ ==== Line buffer ====

128 CHARS CONSTANT /line-buffer
/line-buffer 2 CHARS + BUFFER: line-buffer
0 VALUE /line

: nth-brace ( n1 -- n2 )
    0 SWAP 0 DO
        line-buffer /line ROT [CHAR] { SWAP indexOf
        DROP 1+
    LOOP
;

\ ==== Source index file ====

0 VALUE Index-File-ID

( Open the unsorted index file and place the file ID in             )
( Index-File-ID or abort if the file can not be opened for some     )
( reason                                                            )
: open-index ( -- )
    input-filename R/O OPEN-FILE
    ABORT" Can't find index file: Forth.wrd"
    TO Index-File-ID
;

\ ==== Copy the input line into the current node ====

: line>node ( -- )
    line-buffer /line $, CurrentNode Node.Line !
;

\ ==== Copy word index number into number field of current node ====

: >NUM ( c-addr n -- d )
    0 S>D 2SWAP >NUMBER 2DROP
;

( Read subsection number from line, "1" for Core or "2" for EXT     )
: line>subsection ( -- d )
    line-buffer /line [CHAR] } 0 indexOf DROP
    1- CHARS line-buffer + C@ [CHAR] 0 - S>D
;

( Read Chapter number from line )
: line>chapter ( -- d )
    line-buffer 12 CHARS + 2 >NUM
;

( Read Sub-Word number from line )
: line>subword ( -- d )
    3 nth-brace CHARS line-buffer + 2 >NUM
;

( Read Word number from line )
: line>number ( -- d )
    2 nth-brace CHARS line-buffer + 4 >NUM
;

( Use the word number, word sub-number, chapter and sub section to  )
( generate what should be a unique key for the word.  Unfortunatly, )
( during the development of a wordset this is frequently 000000xx2  )
( I.e., not unique, we therefor have to use the words name to help  )
( identify the correct location in the ordered index.               )

: numb>node ( -- )
    line>number
    line>subword
    line>chapter
    line>subsection
    <# # 2DROP # # 2DROP # # 2DROP # # # # #>
    $, CurrentNode Node.Number !
;

\ ==== Copy word name into the current node ====
\ WARNING: TeX commands are case sensative

WORDLIST CONSTANT TeX-Wordlist
GET-ORDER TeX-Wordlist SWAP 1+ SET-ORDER DEFINITIONS

: \& ( dest src -- dest' src' )
    OVER [CHAR] & SWAP C!
;

: \char ( dest src -- dest' src' ) ( \char "xx )
    BEGIN DUP C@ BL = WHILE CHAR+ REPEAT
    DUP C@ [CHAR] " <> ABORT" Invalid TeX"
    CHAR+ DUP C@ C>HEX 
    SWAP CHAR+ DUP C@ C>HEX
    ROT $10 * +
    ROT 2DUP C!
    NIP SWAP
;

GET-ORDER NIP 1- SET-ORDER DEFINITIONS

: TeXCommand ( dest src -- dest' src' )
    DUP
    CHAR+ C@ ?ALPHA IF
        1 BEGIN
            1+
            2DUP CHARS + C@ ?ALPHA 0=
        UNTIL
    ELSE
        2
    THEN
    2DUP TeX-Wordlist SEARCH-WORDLIST IF
        >R CHARS + R> EXECUTE
    ELSE
        CR ." Unknown TeX command: " TYPE ABORT
    THEN
;

\ Unfortunately the name is in a TeX friendly format, which is not
\ sort-order friendly.  We must evaluate any TeX commands before
\ copying the name into the node.  The only TeX commands we need
\ to worry about are:
\
\ \char "xx   Replace with chatacter code xx (in hex)
\ \&          Replaced with &
\ {xx}        Remove braces from text given just "xx"
\
\ As these all replace the original text with something smaller we
\ can do it in-line before copying the name into the node.
\ Remember the name is sourounded by braces.

: name>node ( -- )
    line-buffer DUP 4 nth-brace CHARS +  ( dest src )
    0 >R                                 ( brace count )
    BEGIN
        DUP C@
        CASE
        [CHAR] \ OF TeXCommand           ( Run TeX command )
                    /CHAR N+             ( Increment dest )
                    TRUE
                ENDOF
        [CHAR] { OF R> 1+ >R             ( Increment brace count )
                    TRUE
                ENDOF
        [CHAR] } OF R@ IF
                        R> 1- >R         ( Decrement brace count )
                        TRUE
                    ELSE
                        FALSE            ( Finish on brace count = 0 )
                    THEN
                ENDOF
        ( Default - Copy character )
            ROT 2DUP C!                  ( Copy character )
            NIP CHAR+ SWAP               ( Increment dest )
            TRUE 0
        ENDCASE
    WHILE
        CHAR+                            ( Increment src )
    REPEAT
    R> DROP                              ( Drop brace count )
    DROP                                 ( Drop src )
    line-buffer - /CHAR /                ( Calculate length of name )
    line-buffer SWAP $, CurrentNode Node.Name !
;

\ ==== Read the index file into memory ====

( Read a single line of the unsorted index file into an IndexNode   )
: read-index-line ( -- flag )
    line-buffer /line-buffer Index-File-ID READ-LINE THROW
    SWAP TO /line DUP IF
        /line /line-buffer = ABORT" line-buffer too short"
        IndexNode node,
        DUP CurrentNode Node.Next !
        TO CurrentNode
    THEN
;

: build-index-node ( -- )
    line>node        ( Copy line from buffer into node )
    numb>node        ( Create number string for node )
    name>node        ( Copy word name into node )
;

: init-list
    IndexNode node, DUP FirstNode ! TO CurrentNode
;

: read-index
    init-list
    open-index
    BEGIN
        read-index-line
    WHILE
        build-index-node
    REPEAT
    Index-File-ID CLOSE-FILE THROW
;

\ ==== Debug ====

: show-nodes
    CR FirstNode @
    BEGIN
        Node.Next @
        DUP
    WHILE
        DUP .n CR
    REPEAT
    DROP
;

\ If we can regenerate the original unsorted file without any changes
\ we know we heve read it in correctly.

: write-unsorted-index
    S" unsorted.out" W/O CREATE-FILE THROW
    TO Index-File-ID
    FirstNode @
    BEGIN
        Node.Next @ DUP
    WHILE
        DUP Node.Line @ COUNT
        Index-File-ID WRITE-LINE THROW
    REPEAT
    DROP
    Index-File-ID CLOSE-FILE THROW
;

\ ==== Compare index noces ====

\ We are going to use an insersion sort to build an index of the
\ nodes.  First we need to be able to compaire nodes.

: Node= ( node1 node2 -- n )
    \ n = 1  when node2 > node1
    \ n = 0  when node2 = node1
    \ n = -1 when node2 < node1

    ( During the development of a wordlist the word numbers are     )
    ( likely to be 0000, so we must compare on the word names       )
    2DUP Node.Name @ COUNT
    ROT  Node.Name @ COUNT
    COMPARE DUP 0= IF
        ( Where the same word appears in multiple wordsets we place )
        ( them in order of chapter, so use the calculated key to    )
        ( order them                                                )
        DROP
        2DUP Node.Number @ COUNT
        ROT  Node.Number @ COUNT
        COMPARE
    THEN
    NIP NIP
;

\ ==== Sort Index ====

: Count-Nodes
    0 FirstNode @
    BEGIN
        Node.Next @ DUP
    WHILE
        1 N+
    REPEAT
    DROP
;

0 VALUE #Nodes
0 VALUE Index

: build-index
    Count-Nodes DUP TO #Nodes
    1+ CELLS node, TO Index
;

: show-index
    Index
    CR
    BEGIN
        DUP @ DUP
    WHILE
        .n CR
        CELL+
    REPEAT
    2DROP
;

: insert-node ( node -- )
    >R
    Index
    BEGIN
        DUP @ DUP IF
            R@ Node= 0< IF
                \ Open space for new node
                DUP DUP CELL+
                Index #nodes CELLS +
                OVER - MOVE
                FALSE
            ELSE
                DUP
            THEN
        THEN
    WHILE
        CELL+
    REPEAT
    ( addr - Location in index to place node )
    R> SWAP !
;

: sort-index
    build-index
    FirstNode @
    BEGIN
        Node.Next @ DUP
    WHILE
        DUP insert-node
    REPEAT
    DROP
;

\ ==== Write sorted index out to file ====

: write-index
    output-filename W/O CREATE-FILE THROW
    TO Index-File-ID
    Index
    BEGIN
        DUP @ DUP
    WHILE
        Node.Line @ COUNT
        Index-File-ID WRITE-LINE THROW
        CELL+
    REPEAT
    2DROP
    Index-File-ID CLOSE-FILE THROW
;

\ ==== Run the program ====

read-index
sort-index
write-index
bye
