round_to_second_digit(Nr, Result) :-
    Result is round(Nr * 100) / 100.

afis_list([]).
afis_list([A|B]):-write(A), tab(2), afis_list(B).

vectorized_sum([[],[],[]],[]):- !.
vectorized_sum([[E1|L1], [E2|L2], [E3|L3]], [Efin|Lfin]):-
    Efin is E1+E2+E3, vectorized_sum([L1, L2, L3], Lfin).

young(Age, 1.0):- Age < 20, !.
young(Age, 0.9):- Age < 25, !.
young(Age, 0.7):- Age < 30, !.
young(Age, 0.5):- Age < 35, !.
young(Age, 0.2):- Age < 40, !.
young(Age, 0.1):- Age < 45, !.
young(_, 0):- !.

middle_aged(Age, 0.0) :- Age < 30, !.
middle_aged(Age, 0.2) :- Age < 35, !.
middle_aged(Age, 0.6) :- Age < 40, !.
middle_aged(Age, 1.0) :- Age < 45, !.
middle_aged(Age, 0.9) :- Age < 50, !.
middle_aged(Age, 0.6) :- Age < 55, !.
middle_aged(Age, 0.2) :- Age < 60, !.
middle_aged(_, 0) :- !.

senior(Age, 1.0):- Age > 65, !.
senior(Age, 0.9):- Age > 60, !.
senior(Age, 0.8):- Age > 55, !.
senior(Age, 0.6):- Age > 50, !.
senior(Age, 0.4):- Age > 45, !.
senior(Age, 0.2):- Age > 40, !.
senior(Age, 0.1):- Age > 35, !.
senior(_, 0):- !.

new(Age,  1.0):- Age < 2 , !.
new(Age,  0.9):- Age < 4 , !.
new(Age, 0.75):- Age < 6 , !.
new(Age,  0.6):- Age < 8 , !.
new(Age, 0.45):- Age < 10, !.
new(Age,  0.3):- Age < 12, !.
new(Age,  0.2):- Age < 14, !.
new(Age,  0.1):- Age < 16, !.
new(_, 0):- !.

old(Age, 1.0):- Age > 30, !.
old(Age, 0.9):- Age > 26, !.
old(Age, 0.7):- Age > 22, !.
old(Age, 0.5):- Age > 18, !.
old(Age, 0.3):- Age > 14, !.
old(Age, 0.1):- Age > 10, !.
old(_, 0):- !.

cheap(Price, 1.0) :- Price < 1000, !.
cheap(Price, 0.9) :- Price < 1100, !.
cheap(Price, 0.7) :- Price < 1200, !.
cheap(Price, 0.5) :- Price < 1300, !.
cheap(Price, 0.3) :- Price < 1400, !.
cheap(Price, 0.1) :- Price < 1500, !.
cheap(_, 0) :- !.

mid_range(Price, 0.0) :- Price < 1200, !.
mid_range(Price, 0.3) :- Price < 1300, !.
mid_range(Price, 0.6) :- Price < 1400, !.
mid_range(Price, 1.0) :- Price < 1500, !.
mid_range(Price, 0.6) :- Price < 1600, !.
mid_range(Price, 0.3) :- Price < 1700, !.
mid_range(_, 0) :- !.

expensive(Price, 0.1) :- Price < 1600, !.
expensive(Price, 0.3) :- Price < 1700, !.
expensive(Price, 0.5) :- Price < 1800, !.
expensive(Price, 0.7) :- Price < 1900, !.
expensive(Price, 0.9) :- Price < 2000, !.
expensive(Price, 1) :-   Price < 2300, !.

price_interval([800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200]).

weights_for_interval(_, _, [], []):- !.
weights_for_interval(PriceDegree, ReferenceWeight, [Price|RestPriceInterval], [Weight|RestWeight]):- 
    call(PriceDegree, Price, PriceWeight), PriceWeight =< ReferenceWeight, 
    Weight is PriceWeight,     weights_for_interval(PriceDegree, ReferenceWeight, RestPriceInterval, RestWeight);
    Weight is ReferenceWeight, weights_for_interval(PriceDegree, ReferenceWeight, RestPriceInterval, RestWeight).

and(WeightsList, Result):- min_list(WeightsList, Result).
or(WeightsList, Result):- max_list(WeightsList, Result).

compute_weights(_, [], []):- !.
compute_weights([Age|RestAges], [_/Degree|RestDegrees], [Weight|RestWeights]):-
    call(Degree, Age, Weight), compute_weights(RestAges, RestDegrees, RestWeights).

compute_area_under_curve(DriverAge, CarAge, [LogicalOperator, MembershipsList, PriceDegree], Area):- 
    compute_weights([DriverAge, CarAge], MembershipsList, WeightsList), 
    call(LogicalOperator, WeightsList, PriceWeight),
    price_interval(Interval),
    weights_for_interval(PriceDegree, PriceWeight, Interval, Area).


iter_rules(_,_,[],[]):- !.
iter_rules(DriverAge, CarAge, [Rule|RestRules], [Area|RestAreas]):- 
    compute_area_under_curve(DriverAge, CarAge, Rule, Area), iter_rules(DriverAge, CarAge, RestRules, RestAreas).

weighted_mean([], [], []):- !.
weighted_mean([Weight|BigArea], [Price|Interval], [Result|RestResult]):-
    Result is Weight * Price, weighted_mean(BigArea, Interval, RestResult).


main_func:- write("How old are you? (number between 16-100)"), nl, read(DriverAge), nl, 
       write("How old is your car? (number between 0-50)"), nl, read(CarAge), nl, 

       open('/home/edstan/Desktop/master_AI/krr/projects/project2/input2.txt', read, Stream), 
       read_line_to_codes(Stream, RulesCodes), RulesCodes \= at_end_of_stream(Stream), 
       read_term_from_codes(RulesCodes, Rules, []), close(Stream),
       %afis_list(Rules), 
       iter_rules(DriverAge, CarAge, Rules, Areas), 
       %afis_list(Areas),
       vectorized_sum(Areas, BigArea), price_interval(Interval),
       weighted_mean(BigArea, Interval, WeightedPrices), sum_list(BigArea, BigWeight),
       sum_list(WeightedPrices, BigPrice), FinalPrice is BigPrice / BigWeight,
       round_to_second_digit(FinalPrice, RoundedFinalPrice),
       write("The insurance cost is "), write(RoundedFinalPrice), write(" RON.").