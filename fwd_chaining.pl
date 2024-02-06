answer(yes).

afis_list([]):- nl.
afis_list([A|B]):-write(A), tab(2), afis_list(B).

create_clause([],[]).
create_clause([E1|L1], [E1/false|L2]):- create_clause(L1, L2).

create_KB([],[]).
create_KB([L1|RawKB], [L2|NewKB]):- create_clause(L1, L2), create_KB(RawKB, NewKB).

questions(["Are you a playful person? (yes/no)" / n(is_playful), 
           "Are you empathetic? (yes/no)" / n(is_empathetic),
           "Did you finish medical school? (yes/no)" / n(finished_medicine),
           "Do you usually help other people? (yes/no)" / n(helps_people)]).

update_clause(_, [], []).
update_clause(Atom, [Atom/false|RestL1], [Atom/true|RestL2]):- update_clause(Atom, RestL1, RestL2).
update_clause(Atom, [C/A|RestL1], [C/A|RestL2]):- update_clause(Atom, RestL1, RestL2).

update_KB(_, [],[]).
update_KB(Atom, [L1|KB], [L2|NewKB]):- update_clause(Atom, L1, L2), update_KB(Atom, KB, NewKB).


check_for_relations_in_clause([], [], _):- !.
check_for_relations_in_clause([E/true|L1], [E/true|L2], Changed):- check_for_relations_in_clause(L1, L2, Changed).
check_for_relations_in_clause([n(E)/false|L1], [n(E)/false|L1], _Changed):- !.
check_for_relations_in_clause([E/false], [E/true], E):- !.

check_for_relations([], [], _).
check_for_relations([L1|KB], [L2|NewKB], Changed):- check_for_relations_in_clause(L1,L2,Changed), 
       check_for_relations(KB, NewKB, Changed).

all_relations(KB, NewKB):- check_for_relations(KB, TempKB, Changed), (var(Changed),
       NewKB = TempKB; update_KB(n(Changed), TempKB, AlmostNewKB), all_relations(AlmostNewKB, NewKB)).

ask(NewKB, [], NewKB, NewQuestions, NewQuestions).
ask(KB, [Question/Atom|RestQuestions], LastKB, AddQuestion, LastQuestions):- 
       (
              write(Question), nl, read(Answer), nl, nl,
              answer(Answer), 
              update_KB(Atom, KB, TempKB), all_relations(TempKB, NewKB), 
              ask(NewKB, RestQuestions, LastKB, AddQuestion, LastQuestions);
              ask(KB, RestQuestions, LastKB, [Question/Atom|AddQuestion], LastQuestions)
       ).

all_true([]).
all_true([_/true|NewKB]):- all_true(NewKB).

fwd(KB, Questions):- ask(KB, Questions, NewKB, [], NewQuestions),
       (
              flatten(NewKB, NewKBflat), not(all_true(NewKBflat)),
              (
                     write("Current KB:"), nl, afis_list(NewKB), nl,
                     write("Unsolved! You are not a pediatrician yet. Do you want to continue answering questions? (yes/no)"), 
                     nl, read(Answer), nl,
                     answer(Answer), 
                     fwd(NewKB, NewQuestions); 
                     nl, write("Okay. Your choice :D")
              );
              write("Final KB:"), nl, afis_list(NewKB), nl,
              write("You are a pediatrician!!")
       ).

main:- write("Based on your responses, I will determine wether you are a pediatrician."), nl,
       write("Press any key to continue."), nl, read(_), nl, nl,
       open('/home/edstan/Desktop/master_AI/krr/projects/project2/input1.txt', read, Stream), 
       read_line_to_codes(Stream, KBcodes), KBcodes \= at_end_of_stream(Stream), 
       read_term_from_codes(KBcodes, RawKB, []), close(Stream),
       create_KB(RawKB, KB), write("Initial KB:"), nl, afis_list(KB), nl, questions(Questions), fwd(KB, Questions).