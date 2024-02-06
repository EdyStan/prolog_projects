answer(yes).

afis_list([]):- nl.
afis_list([A|B]):-write(A), tab(2), afis_list(B).

concatenate([], L, L):- !.
concatenate([E|L1], L2, [E|L3]):- concatenate(L1, L2, L3).

create_clause([],[]).
create_clause([E1|L1], [E1/false|L2]):- create_clause(L1, L2).

questions(["Are you just a medic? (yes/no)" / is_medic, 
           "Are you a pediatrician? (yes/no)" / is_pediatrician,
           "Do you connect well with children? (yes/no)" / connects_well_with_children]).

create_KB([],[]).
create_KB([L1|RawKB], [L2|NewKB]):- create_clause(L1, L2), create_KB(RawKB, NewKB).

update_clause(_, [], []).
update_clause(Atom, [Atom/false|RestL1], [Atom/true|RestL2]):- update_clause(Atom, RestL1, RestL2).
update_clause(Atom, [n(Atom)/false|RestL1], [n(Atom)/true|RestL2]):- update_clause(Atom, RestL1, RestL2).
update_clause(Atom, [C/A|RestL1], [C/A|RestL2]):- update_clause(Atom, RestL1, RestL2).

update_KB(_, [],[]).
update_KB(Atom, [L1|KB], [L2|NewKB]):- update_clause(Atom, L1, L2), update_KB(Atom, KB, NewKB).

update_more_atoms([], NewKB, NewKB).
update_more_atoms([Atom|RestAtoms], KB, NewKB):- update_KB(Atom, KB, TempKB1), 
    update_KB(n(Atom), TempKB1, TempKB2), update_more_atoms(RestAtoms, TempKB2, NewKB).

make_all_true([], [], []).
make_all_true([n(E)/false|L1], [n(E)/true|L2], [E|RestChanged]):- make_all_true(L1, L2, RestChanged).
make_all_true([n(E)/true|L1], [n(E)/true|L2], RestChanged):- make_all_true(L1, L2, RestChanged).

check_for_relations_in_clause([E/false|L1], [E/false|L1], []):- !.
check_for_relations_in_clause([E/true|L1], [E/true|L2], Changed):- make_all_true(L1, L2, Changed).

check_for_relations([], [], []).
check_for_relations([L1|KB], [L2|NewKB], FutureChanged):- reverse(L1, RevL1), check_for_relations_in_clause(RevL1,RevL2,PresentChanged), 
        concatenate(PresentChanged, PastChanged, FutureChanged),
        reverse(RevL2, L2), check_for_relations(KB, NewKB, PastChanged).

all_relations(KB, NewKB):- check_for_relations(KB, TempKB, Changed), (Changed == [],
       NewKB = TempKB; update_more_atoms(Changed, TempKB, AlmostNewKB), all_relations(AlmostNewKB, NewKB)).

iter_negatives([]).
iter_negatives([n(E)/true|SortedKB]):- write("- "), write_term(E, []), nl, iter_negatives(SortedKB).
iter_negatives([_|SortedKB]):- iter_negatives(SortedKB).

afis_unique(KB):- flatten(KB, FlatKB), sort(FlatKB, SortedKB), iter_negatives(SortedKB).

bkw(KB, Question/Atom):- write(Question), nl, read(Answer1), nl, nl,
        (
            answer(Answer1), update_KB(Atom, KB, TempKB), all_relations(TempKB, NewKB),
            write("Final KB:"), nl, afis_list(NewKB), nl, nl,
            write("You have the following qualities:"), nl, 
            afis_unique(NewKB), nl, nl;
            write("Unsolved! Do you want to answer again to this question? (yes/no)"), nl, read(Answer2), nl,
            (
                answer(Answer2), 
                bkw(KB, Question/Atom); 
                nl, write("Okay. Your choice :D"), nl, nl
            )
        ).


main:- write("Based on your responses, I will determine what qualities you have."), nl,
       write("Press any key to continue."), nl, read(_), nl, nl,
       open('/home/edstan/Desktop/master_AI/krr/projects/project2/input1.txt', read, Stream), 
       read_line_to_codes(Stream, KBcodes), KBcodes \= at_end_of_stream(Stream), 
       read_term_from_codes(KBcodes, RawKB, []), close(Stream),
       create_KB(RawKB, KB), write("Initial KB:"), nl, afis_list(KB), nl, 
       questions([Q1, Q2, Q3]), bkw(KB, Q1), bkw(KB, Q2), bkw(KB, Q3).