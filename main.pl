		% List predicates
tail(L, X) :- L = [_|X].

member(E, [E|_]).
member(E, [_|Tail]) :- member(E, Tail).

rev([], Acc, Acc).
rev([Head|Tail], Acc, R) :- rev(Tail, [Head|Acc], R).


		% STP predicates
stp([V, E], Root, Edges) :- root_stp(V, Root), edges_stp(V, E, Edges).

drum(Retea, Src, Dst, Root, Edges, Path) :- Path = [].


	% auxiliary
% smallest node
min_node([[Node, Value] | Tail], R) :-
	compute_min([[Node, Value] | Tail], Value, Node, R).

compute_min([], _, N, N).
compute_min([[Node, Value] | Tail], V, N, R) :- 
	Value >= V, compute_min(Tail, V, N, R).
compute_min([[Node, Value] | Tail], V, N, R) :-
	Value < V, compute_min(Tail, Value, Node, R).

% remove node
remove_node(V, Node, R) :- rev(V, [], RV), compute_erase(RV, Node, [], R). 

compute_erase([], _, Acc, Acc).
compute_erase([[Node, Value] | Tail], N, Acc, R) :-
	Node \= N, compute_erase(Tail, N, [[Node, Value] | Acc], R).
compute_erase([[Node, Value] | Tail], N, Acc, R) :-
	Node = N, compute_erase(Tail, N, Acc, R).

% adicent list for node
adj_nodes(E, Node, R) :- rev(E, [], RE), compute_adj(RE, Node, [], R).

compute_adj([], _, Acc, Acc).
compute_adj([[Node1, Node2, Cost] |Tail], N, Acc, R) :-
        (Node1 \= N, Node2 \= N), compute_adj(Tail, N, Acc, R).
compute_adj([[Node1, Node2, Cost] |Tail], N, Acc, R) :-
        (Node1 = N, Node2 = M; Node1 = M, Node2 = N), 
        compute_adj(Tail, N, [[M, Cost] | Acc], R).

% get value for a node from a list
get_value([[Node, Value] | Tail], N, R) :- Node = N, R = Value.
get_value([[Node, Value] | Tail], N, R) :- Node \= N, get_value(Tail, N, R).

% update value for a node in a list
update_value(L, Node, Value, R) :- 
	rev(L, [], RL), compute_update(RL, Node, Value, [], R).

compute_update([], _, _, Acc, Acc).
compute_update([[Node, Value] | Tail], N, V, Acc, R) :- 
	Node \= N, compute_update(Tail, N, V, [[Node, Value] | Acc], R).
compute_update([[Node, Value] | Tail], N, V, Acc, R) :- 
	Node = N, compute_update(Tail, N, N, [[Node, V] | Acc], R).


	% finding root of graph
root_stp([], R).
root_stp(V, R) :- min_node(V, R).


	% finding STP edges
edges_stp(V, [], Edges).
edges_stp(V, E, Edges) :- prim(V, E, Edges).


	% almost Prim algorithm
prim(V, E, Edges) :- init_lists(V, D, P), prim_loop(V, E, D, P, [], [], R1), 
                          rev(R1, [], R2), tail(R2, Edges).

% loop for pirority queue
prim_loop(V, E, [], P, Visited, Acc, Acc).
prim_loop(V, E, D, P, Visited, Acc, R) :-
	min_node(D, Node),
	get_value(P, Node, Parent),
	adj_nodes(E, Node, Adj), 
	update_lists(V, Adj, Node, D, P, Visited, [], [NewDaux, NewPaux]),
        remove_node(NewDaux, Node, NewD),
	remove_node(NewPaux, Node, NewP),
	prim_loop(V, E, NewD, NewP, [Node | Visited], [[Parent, Node] | Acc], R).

% make necessary lists for almost Prim's algorithm
make_list([], _, Acc, Acc).
make_list([[Node, Priority] | Tail], Value, Acc, R) :- 
	make_list(Tail, Value, [Pair | Acc], R), Pair = [Node, Value].

make_dist_list(V, Root, R) :- rev(V, [], RV), make_list(RV, 999999, [], RT),
                              update_value(RT, Root, 0, R).

make_parent_list(V, R) :- rev(V, [], RV), make_list(RV, 0, [], R).

% initialize necessary lists
init_lists(V, D, P) :- root_stp(V, Root), make_dist_list(V, Root, D), 
                       make_parent_list(V, P).

% update lists for each iteration
update_lists(V, [], Parent, D, P, Visited, Acc, Acc).
update_lists(V, [[Node, Cost] | Tail], Parent, D, P, Visited, Acc, R) :-
	member(Node, Visited),
        update_lists(V, Tail, Parent, D, P, Visited, [D, P], R).
update_lists(V, [[Node, Cost] | Tail], Parent, D, P, Visited, Acc, R) :-
	not(member(Node, Visited)), 
        get_value(D, Parent, Val), Val1 = X, X is Val + Cost,
	get_value(D, Node, Val2),
	update_dist(V, D, P, Node, Parent, Val1, Val2, NewD),
	update_parent(V, P, Node, Parent, Val1, Val2, NewP),
        update_lists(V, Tail, Parent, NewD, NewP, Visited, [NewD, NewP], R).

% update distance list
update_dist(V, D, P, Node, Parent, Val1, Val2, R) :- 
	((Val1 > Val2); (Val1 = Val2, each_priority(V, P, Node, Parent, [Pr1, Pr]),
	Pr1 < Pr)), R = D.
update_dist(V, D, P, Node, Parent, Val1, Val2, R) :- 
	((Val1 < Val2); (Val1 = Val2, each_priority(V, P, Node, Parent, [Pr1, Pr]),
	Pr1 > Pr)), update_value(D, Node, Val1, R).

% update parent list
update_parent(V, P, Node, Parent, Val1, Val2, R) :-
	((Val1 > Val2); (Val1 = Val2, each_priority(V, P, Node, Parent, [Pr1, Pr]),
	Pr1 < Pr)), R = P.
update_parent(V, P, Node, Parent, Val1, Val2, R) :- 
	((Val1 < Val2); (Val1 = Val2, each_priority(V, P, Node, Parent, [Pr1, Pr]),
	Pr1 > Pr)), update_value(P, Node, Parent, R).

% return a pair of priorities
each_priority(V, P, Node, Parent, R) :- 
	get_value(P, Node, Parent1), get_value(V, Parent1, Priority1), 
	get_value(V, Parent, Priority), R = [Priority1, Priority].

