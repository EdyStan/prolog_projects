% read_from(KB, Lit):- open('/home/edstan/Desktop/master_AI/krr/labs/sat_input.txt', read, Stream),
%     read(Stream, KB), read(Stream, Lit).

afis_list([]).
afis_list([A|B]):-write(A), tab(2), afis_list(B).

input:- open('/home/edstan/Desktop/master_AI/krr/projects/sat_input.txt', read, Stream),
    iter_inputs(Stream),
    close(Stream).

iter_inputs(Stream):- read_line_to_codes(Stream, KBcodes), KBcodes \= at_end_of_stream(Stream), 
    read_term_from_codes(KBcodes, KB, []), afis_list(KB), main_short(KB), main_freq(KB), nl, nl, nl, iter_inputs(Stream).
iter_inputs(_Stream):- !.

% ----------------

select_most_frequent(KB, M):- flatten(KB, FlatKB), sort(FlatKB, SortedKB), create_count_list(SortedKB, FlatKB, CountList),
    max_member(_Count/M, CountList).
    
create_count_list([], _FlatKB, []).
create_count_list([M|SortedKB], FlatKB, [Count/M|Rest]):- count_occurrences_in_clause(M, FlatKB, Count), 
    create_count_list(SortedKB, FlatKB, Rest).

count_occurrences_in_clause(_, [], 0).
count_occurrences_in_clause(M, [M|T], Count) :-
    count_occurrences_in_clause(M, T, RestCount),
    Count is RestCount + 1.
count_occurrences_in_clause(M, [H|T], Count) :-
    M \= H,
    count_occurrences_in_clause(_M, T, Count).

% -------------

select_from_shortest_clause([], []).

select_from_shortest_clause([C|RestKB], P) :- \+ member([], [C|RestKB]),
    determine_shortest_clause(RestKB, C, [P|_CBest]).

determine_shortest_clause([], CB, CB) :- !.

determine_shortest_clause([C|RestKB], CSC, CBest) :-
    length(CSC, LenCSC),
    length(C, LenC),
    LenC < LenCSC, determine_shortest_clause(RestKB, C, CBest);
    determine_shortest_clause(RestKB, CSC, CBest).
    
 % -------------

neg(n(X), X):- !.
neg(A, n(A)).

remove_element(_, [], []).
remove_element(E, [E|T], N):-
    remove_element(E, T, N).
remove_element(E, [H|T], [H|N]):-
    E\=H,
    remove_element(E, T, N).

% --------------

dot([], _M, _Mc, []).
dot([C|KB1], M, Mc, [C|KB2]):- \+ member(M, C), \+ member(Mc, C), 
    dot(KB1, M, Mc, KB2).
dot([C|KB1], M, Mc, [Cr|KB2]):- \+ member(M, C), member(Mc, C), 
    remove_element(Mc, C, Cr), dot(KB1, M, Mc, KB2).
dot([C|KB1], M, Mc, KB2):- member(M, C), dot(KB1, M, Mc, KB2).

sat_most_frequent(KB):- dp_most_frequent(KB, R), write('YES'), nl, afis_list(R); write('NOT').

dp_most_frequent([], []).
dp_most_frequent(KB, _):- member([],KB), !, fail. 
dp_most_frequent(KB, [M/true|S]):- select_most_frequent(KB, M), neg(M, Mc), dot(KB, M, Mc, NKB), dp_most_frequent(NKB, S).
dp_most_frequent(KB, [M/false|S]):- select_most_frequent(KB, M), neg(M, Mc), dot(KB, Mc, M, NKB), dp_most_frequent(NKB, S).


sat_shortest_clause(KB):- dp_shortest_clause(KB, R), write('YES'), nl, afis_list(R); write('NOT').

dp_shortest_clause([], []).
dp_shortest_clause(KB, _):- member([],KB), !, fail. 
dp_shortest_clause(KB, [M/true|S]):- select_from_shortest_clause(KB, M), neg(M, Mc), dot(KB, M, Mc, NKB), dp_shortest_clause(NKB, S).
dp_shortest_clause(KB, [M/false|S]):- select_from_shortest_clause(KB, M), neg(M, Mc), dot(KB, Mc, M, NKB), dp_shortest_clause(NKB, S).

main_short(KB):- nl, nl, write('Literal from shortest clause: '), sat_shortest_clause(KB).
main_freq(KB):- nl, nl, write('Most frequent literal: '), sat_most_frequent(KB).