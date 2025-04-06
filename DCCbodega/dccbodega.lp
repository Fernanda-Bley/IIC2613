% Existirá un máximo de instantes de tiempo, denotado por la constante bound
time(1..bound).

% Los robots cuentan con varias acciones posibles, moverse en las 4 direcciones, no hacer nada o
% recoger/soltar una caja
action(up).
action(down).
action(left).
action(right).
action(wait).
action(liftShelf).
action(dropShelf).


% Para cada instante de tiempo T, cada robot R puede ejecutar una única acción de las 7/11 posibles:
1 {exec(R, A, T) : action(A)} 1 :- robot(R), time(T+1).

%% Como completamos objetivos
shelfHas(IDShelf, ObjectID) :- shelf(IDShelf), object(ObjectID).
goalWants(IDRobot, ObjectID) :- robot(IDRobot), object(ObjectID).

%% Se movera bajo estas condiciones

% Definimos como se mueve un robot

robotMoves(R, NewX, NewY) :- 
    exec(R, up, T), 
    robotOn(R, X, Y, T),
    shelfHeld(S, R, T),
    NewX = X, 
    NewY = Y + 1, 
    NewY < alto,  
    shelfMoves(S, NewX, NewY),
    not wallOn(NewX, NewY),  
    not robotOn(_, NewX, NewY, T).  

robotMoves(R, NewX, NewY) :- 
    exec(R, down, T), 
    robotOn(R, X, Y, T),
    shelfHeld(S, R, T), 
    NewX = X, 
    NewY = Y - 1, 
    NewY >= 0,  
    not wallOn(NewX, NewY),  
    not robotOn(_, NewX, NewY, T).   

robotMoves(R, NewX, NewY) :- 
    exec(R, right, T), 
    robotOn(R, X, Y, T),
    shelfHeld(S, R, T), 
    NewX = X + 1, 
    NewY = Y, 
    NewX < ancho,  
    not wallOn(NewX, NewY),  
    not robotOn(_, NewX, NewY, T).   

robotMoves(R, NewX, NewY) :- 
    exec(R, left, T), 
    robotOn(R, X, Y, T),
    shelfHeld(S, R, T), 
    NewX = X - 1, 
    NewY = Y, 
    NewX >= 0,  
    not wallOn(NewX, NewY),  
    not robotOn(_, NewX, NewY, T).   


% Definimos como se mueve un estante

shelfMoves(S, NewX, NewY) :- 
    exec(S, up, T), 
    shelfOn(S, X, Y, T), 
    NewX = X, 
    NewY = Y + 1, 
    NewY < alto,  
    not wallOn(NewX, NewY),
    not tableOn(NewX,NewY).

shelfMoves(S, NewX, NewY) :- 
    exec(S, down, T), 
    shelfOn(S, X, Y, T), 
    NewX = X, 
    NewY = Y - 1, 
    NewY >= 0,  
    not wallOn(NewX, NewY),
    not tableOn(NewX,NewY).  

shelfMoves(S, NewX, NewY) :- 
    exec(S, right, T), 
    shelfOn(S, X, Y, T), 
    NewX = X + 1, 
    NewY = Y, 
    NewX < ancho,  
    not wallOn(NewX, NewY),
    not tableOn(NewX,NewY).  

shelfMoves(S, NewX, NewY) :- 
    exec(S, left, T), 
    shelfOn(S, X, Y, T), 
    NewX = X - 1, 
    NewY = Y, 
    NewX >= 0,  
    not wallOn(NewX, NewY),
    not tableOn(NewX,NewY).  

% Definimos que hace un movimiento
shelfOn(S,X,Y,T) :- shelfMoves(S,X,Y), time(T), T < bound.
robotOn(R,X,Y,T) :- robotMoves(R,X,Y), time(T), T < bound.


%% Agarrar estanterias

% Agarrar un estante
shelfHeld(S, R, T) :- exec(R, liftShelf, T), shelfOn(S, X, Y, T), shelfContains(S, ObjectID), robotOn(R, X, Y, T).

% Si una estantería es botada, ya no estará tomada.
notShelfHeld(S, T) :- exec(R, dropShelf, T), shelfHeld(S, R, T).

% Una estantería estará ocupada si fue tomada
isShelfTaken(S, T) :- shelfHeld(S, R, T).

% Si un robot se mueve su estanteria se mueve
shelfMoves(S, X, Y) :- robot(R, X, Y), shelfHeld(S, R, T).

%% Objetivos

% Si es que el robot tiene el shelf sujetado que contiene el objeto y se encuentra en el goal
% hacemos drop al shelf y lo marcamos como delivered.
dropAndDeliver(R, S, ObjectID, T) :- 
    exec(R, dropShelf, T), 
    shelfHeld(S, R, T), 
    shelfContains(S, ObjectID), 
    robotOn(R, X, Y, T), 
    goalOn(X, Y).

% Será entregado cuando sea dropped y delivered.
delivered(ObjectID, T) :- dropAndDeliver(R, S, ObjectID, T).

% Nos aseguramos que todos los objetivos sean cumplidos.
:- goalWants(IDRobot, ObjectID), not delivered(ObjectID, T), time(T), T < bound.