% -- Definitions.

% -- Collection = GameTree { GameTree }
% -- GameTree   = "(" Sequence { GameTree } ")"
% -- Sequence   = Node { Node }
% -- Node       = ";" { Property }
% -- Property   = PropIdent PropValue { PropValue }
% -- PropIdent  = UcLetter { UcLetter }
% -- PropValue  = "[" CValueType "]"
% -- CValueType = (ValueType | Compose)
% -- ValueType  = (None | Number | Real | Double | Color | SimpleText |
% -- 		Text | Point  | Move | Stone)
%
% -- Rules.
%
% -- 'list of':    PropValue { PropValue }
% -- 'elist of':   ((PropValue { PropValue }) | None)

Definitions.

WHITESPACE = [\s\t\n\r]
PROPIDENT  = [A-Z]+
PROPVALUE  = (\[.+\])+

Rules.

\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
;             : {token, {';', TokenLine}}.
\[            : {token, {'[',  TokenLine}}.
\]            : {token, {']',  TokenLine}}.
{PROPIDENT}   : {token, {propident, TokenLine, TokenChars}}.
{PROPVALUE}   : {token, {provalue, TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.

