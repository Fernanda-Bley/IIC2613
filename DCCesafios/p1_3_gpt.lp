student(S)        :- info(S, _, _, _, _, _).
section(S, Sec)   :- info(S, Sec, _, _, _, _).
gender(S, G)      :- info(S, _, G, _, _, _).
high_school(S, H) :- info(S, _, _, H, _, _).
region(S, R)      :- info(S, _, _, _, R, _).
admission(S, A)   :- info(S, _, _, _, _, A).
admission_type(A) :- admission(_, A).
team(T)           :- section_of_team(T, _).
team(T) :- assign(_, T).

{ assign(S, T) : section_of_team(T, Sec) } = 1 :- student(S), section(S, Sec).

:- team(T), #count { S : assign(S, T), gender(S, f) } = 1.

:- team(T), #count { S : assign(S, T), region(S, otra) } = 1.

:- team(T), #count { S : assign(S, T), region(S, otra) } >= 8.

:- team(T), #count { S : assign(S, T), admission(S, A) } = 1.

:- team(T), assign(S1, T), assign(S2, T), high_school(S1, H), high_school(S2, H), S1 != S2.

size_of_team(T , Size) :- team(T), #count {S : assign(S,T)} = Size.

:- team(T), #count { S : assign(S, T), gender(S, f) } >= 8.

:- team(T), size_of_team(T, Size), Size > 8. 
:- team(T), size_of_team(T, Size), Size < 7. 

% Restricción adicional para heterogeneidad de género
team_with_no_women(T) :- team(T), #count { S : assign(S, T), gender(S, f) } = 0.
team_with_many_women(T) :- team(T), #count { S : assign(S, T), gender(S, f) } >= 4.

:- team_with_no_women(T1), team_with_many_women(T2).

#show assign/2.
