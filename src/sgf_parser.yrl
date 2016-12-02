Nonterminals game elems elem.
Terminals '(' ')' atom.
Rootsymbol game.

game ->
    '(' ')' : [].
game ->
    '(' elems ')' : '%2'.

elems ->
    elem : ['%1'].

elem ->
    atom : extract_token('$1').

Erlang code.

extract_token({_Token, _Line, Value}) ->
    Value.
