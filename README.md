# Spanning Tree Protocol 

## Description
The modified Prim's algorithm will be used to make a new STP graph with minimal distances between root and each node. The algorithm will keep the same method when choosing edges, but the condition that the total weigth of the graph to be minimal is replaced with the following: minimum distances between root and each node.
	
## Predicates
- predicates for lists: **tail** (returns the tail of the list), **member** (checks if element is in list), **rev** (revert the list).
- predicates for STP: **stp([V, E], Root, Edges)** (computes the root node and the list with the new graph's edges).
- auxiliary predicates (1): **root_stp** (finds the root of the graph), **edges_stp**(computes the list of the new graph's edges). 
- auxiliary predicates (2): **min_node** (returns the node with the lowest value from a list, compute_node -> helping predicate), **remove_node**(removes an element from a list depending of it's value, compute_erase -> helping predicate), **adj_nodes**(returns a list with the adiacent nodes for a a given parent, compute_adj -> helping predicate), **get_value**(returns the value of a given node from the list), **update_value** (updates the value of a given node in a list, compute_update -> helping predicate).

## Prim's algorithm (almost):
- prim - predicate that follows Prim's algorithm.
- prim_loop - computes the loop for priority queue. It picks the node with the minimal distance, and it founds it's parent. It computes the list with the adiacent nodes and each edge weight accordingly. The distance and parent lists are modified accordingly. The current node is erased from the distance and parent lists and it is added to the Visited list. The result is added in the accumulator.
- init_lists - initializes the distance and parent lists.
- update_lists - modifies the distance and parent lists; for each node that isn't in the Visited list, the values are updated in both of the lists.
- update_dist - updates a given value in the distance list. If the distances are equal for several edges, the node with the lowest priority is picked.
- update_parent - updates a given value in the parent list. If the distances are equal for several edges, the node with the lowest priority is picked.
- each_priority - returns a pair of priorities(the parent's priority from the parent list and the current parent's priority).

## Usage
For an easier time running the program, swipl will be used, where Network is a given graph, and Root and Edges are the variables that store the outputs of the predicate. 
- swipl -s main.pl
	- stp(Network, Root, Edges) 
		
### Example

Network - a list with nodes and their priorities and a list with edges and their weight;
####
Network = [[[1, 50], [2, 20], [3, 30], [4, 45], [5, 60]] ,[[1,2, 6],[2,3, 3], [3,4, 1], [4,5, 500], [2,4, 5], [1,4, 1]]] , 
> stp(Network, Root, Edges).
####
Output: Root = 2,			
####
Edges = [[2, 3], [3, 4], [4, 1], [4, 5]].
