table sent/3, vp/3, sub/3, pred/3, obj/3.

% helper function.
takeAllButLast(List, Result):-removeLast(List, [], Result).
removeLast([_], R, R).
removeLast([H|T], Sol, Result):-append(Sol, [H], Sol2), removeLast(T, Sol2, Result).

% subject rule.
term0([X]) --> [[X, 'PROPN']].
term0([X, '.']) --> [[X, 'PROPN'], ['.', _]].
term0([X]) --> [[X, 'NOUN']].
term0([X]) --> [[X, 'NUM']].
term0([X]) --> [[X, 'ADJ']].
term0([X|S]) --> [[X, 'PROPN']], term0(S).
term0([X, '.'|S]) --> [[X, 'PROPN'], ['.',_]], term0(S).
term0([X|S]) --> [[X, 'NOUN']], term0(S).
term0([X|S]) --> [[X, 'NUM']], term0(S).
term0([X|S]) --> [[X, 'ADJ']], term0(S).

term1([X]) --> [[X, 'PRON']].
term1([X1, X2]) --> [[X1, 'SYM'], [X2, 'NUM']]. % currenc.
term1(S) --> term0(S).

term2([X|S]) --> [[X, 'ADJ']], term2(S).
term2([X|S]) --> [[X, 'VERB']], term2(S).
term2(S) --> term1(S).

term3([X|S]) --> [[X, 'ADV']], term2(S).
term3(S) --> term2(S).

term4([X]) --> [[X, 'DET']].
term4([X|S]) --> [[X, 'DET']], term3(S).
term4([X|S]) --> [[X, 'NUM']], term3(S).
term4(S) --> term3(S).

term5(S) --> term4(S1), [[X, 'CCONJ']], sub(S2), {append(S1, [X|S2], S)}.
term5(S) --> term4(S).

term6(S) --> term5(S1), [[X, 'ADP']], sub(S2), {append(S1, [X|S2], S)}.
term6(S) --> term5(S).

sub(S) --> term6(S1), [[X, 'PART']], sub(S2),
    {last(S1, L), atom_concat(L, X, Concat), takeAllButLast(S1, NewS1),
      append(NewS1, [Concat], UpdatedS1),
      append(UpdatedS1, S2, S)}.
sub(S) --> term6(S).
sub(S) --> [['"', 'PUNCT']], tokens(Sub), [['"', 'PUNCT']], {append(['"'|Sub], ['"'], S)}.

% object rule.
obj([X]) --> [[X, 'ADJ']].
obj(X) --> sub(X), [[_, 'ADP']], tokens(_).
obj(X) --> sub(X), [[_, 'DET']], tokens(_).
obj(X) --> sub(X), [[_, 'CCONJ']], tokens(_).
obj(X) --> sub(X), [[_, 'SCONJ']], tokens(_).
obj(X) --> sub(X), [[_, 'VERB']], tokens(_).
obj([X1, X2]) --> [[X1, 'ADV'], [X2, 'VERB']].
obj(X) --> sub(X).
obj(X) --> sub(S), [[V, 'VERB']], {append(S, [V], X)}.
obj([X1|S]) --> [[X1, 'ADP']], sub(S).
obj(X) --> sub(X1), [[XADP, 'ADP']], tokens(X2), {append(X1, [XADP|X2], X)}.

% predicate rule.
pred([X]) --> [[X, 'VERB']].
pred([X1, X2]) --> [[X1, 'ADV'] ,[X2, 'VERB']].
pred([X1, X2]) --> [[X1, 'VERB'], [X2, 'ADP']].
pred([X]) --> [[X, 'AUX']].

pred([X1|X2]) --> [[X1, 'VERB']], pred(X2).
pred([X1|X2]) --> [[X1, 'AUX']], pred(X2).
pred([X0, X1|X2]) --> [[X0, 'VERB'], [X1, 'PART']], pred(X2).
pred([X0, X1|X2]) --> [[X0, 'VERB'], [_, 'NOUN'] , [X1, 'PART']], pred(X2).
pred([X0, X1|X2]) --> [[X0, 'AUX'], [X1, 'PART']], pred(X2).

% n token.
tokens([X]) --> [[X, _]].
tokens([X|T]) --> [[X, _]], tokens(T).

% sentence rule.
vp([P,O]) --> pred(P), obj(O).
vp([P,O]) --> pred(P), obj(O), [['.', 'PUNCT']].
vp([P,O]) --> pred(P), obj(O), [[_, 'PUNCT']], tokens(_).
vp([P,O]) --> tokens(_), [[_, 'PUNCT']], vp([P,O]).

sent([S,P,O]) --> sub(S), pred(P), tokens(O), [[',', 'PUNCT']], tokens(_).
sent([S,P,O]) --> sub(S), pred(P), [[_, 'SCONJ']], tokens(O), [['.', 'PUNCT']].
sent([S,P,O]) --> sub(S), pred(P), [[_, 'NOUN'], [_, 'SCONJ']], tokens(O), [['.', 'PUNCT']].
sent([S,P,O]) --> sub(S), pred(P), tokens(O), [['.', 'PUNCT']].

sent([S,P,O]) --> sub(S), vp([P,O]).
sent([S,P,O]) --> sub(S), [[',', 'PUNCT']], sent([_,P,O]).
sent([S,P,O]) --> obj(O), [[',', 'PUNCT']], sent([S,P]).
sent([S,P,O]) --> sub(S), [[',', 'PUNCT']], vp([P,O]).
sent([S,P,O]) --> tokens(_), [[',', 'PUNCT']], sent([S,P,O]).
sent(X) --> [['"', 'PUNCT']], sent(X), [['"', 'PUNCT']]. 