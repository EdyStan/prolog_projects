input:- open('/home/edstan/Desktop/master_AI/krr/projects/reasoning_input.txt', read, Stream),
    iter_inputs(Stream),
    close(Stream).

iter_inputs(Stream):- read_line_to_codes(Stream, KBcodes), KBcodes \= at_end_of_stream(Stream), 
    read_term_from_codes(KBcodes, KB, []), main(KB), iter_inputs(Stream).
iter_inputs(_Stream):- !.

neg(n(X), X):- !.
neg(A, n(A)).

% optimizations

elim_element(_,[],[]):- !.
elim_element(E,[E|T],N):- elim_element(E,T,N).
elim_element(E,[H|T],[H|N]):- E\=H, elim_element(E,T,N).

concatenate([], L, L):- !.
concatenate([E|L1], L2, [E|L3]):- concatenate(L1, L2, L3).

find_pure_neg(_E, []):- !, fail.
find_pure_neg(E, [H|T]):- not(member(E, H)), find_pure_neg(E, T).
find_pure_neg(E, [H|_T]):- member(E, H), !.

iter_neg([], _T).
iter_neg([E1|L], T):- neg(E1, E2), copy_term(E2, X), find_pure_neg(X, T), iter_neg(L, T).

remove_pure(_R, [], []):- !.
remove_pure(R, [L|RestKB], [L|NKB]):- concatenate(R, RestKB, T), iter_neg(L, T), remove_pure([L|R], RestKB, NKB).
remove_pure(R, [L|RestKB], NKB):- concatenate(R, RestKB, T), not(iter_neg(L, T)), remove_pure(R, RestKB, NKB).

is_subsumed(_L, []):- !, fail.
is_subsumed(L, [H|T]):- not(subset(H, L)), is_subsumed(L, T).
is_subsumed(L, [H|_T]):- subset(H, L), !.

remove_subsumed(_R, [], []):- !.
remove_subsumed(R, [L|RestKB], NKB):- concatenate(R, RestKB, T), is_subsumed(L, T), remove_subsumed(R, RestKB, NKB).
remove_subsumed(R, [L|RestKB], [L|NKB]):- concatenate(R, RestKB, T), not(is_subsumed(L, T)), remove_subsumed([L|R], RestKB, NKB). 

remove_tautologies([], []):- !.
remove_tautologies([L|RestKB], [L|NKB]):- member(E1, L), neg(E1, E2), copy_term(E2, X), not(member(X, L)), remove_tautologies(RestKB, NKB).
remove_tautologies([L|RestKB], NKB):- member(E1, L), neg(E1, E2), copy_term(E2, X), member(X, L), remove_tautologies(RestKB, NKB).

% main implementation

sortKB([],[]).
sortKB([A|B], [A1|B1]):- sort(A, A1), sortKB(B, B1).

afis_list([]):- nl.
afis_list([A|B]):-write(A), tab(2), afis_list(B).

resolvent(L1, L2, R3):- member(E1, L1), neg(E1,E2), copy_term(E2, X), member(X, L2),
    elim_element(E1, L1, R1), elim_element(E2, L2, R2),
    concatenate(R1, R2, R3).

res(KB) :- member([], KB), write('UNSAT'), nl, nl.
res(KB) :- member(L1, KB), member(L2, KB), L1 \= L2,
    resolvent(L1, L2, R), sort(R, R1), not(member(R1, KB)), 
    res([R1|KB]).
res(_KB):- write('SAT'), nl, nl.

main(C):- write('Initial KB:          '), afis_list(C), remove_subsumed([], C, C1), 
    write('After subsumed:      '), afis_list(C1), remove_tautologies(C1, C2),
    write('After tautologies:   '), afis_list(C2), remove_pure([], C2, C3), 
    write('After pure:          '), afis_list(C3), sortKB(C3, KB), 
    write('After sort:          '), afis_list(KB), res(KB).
