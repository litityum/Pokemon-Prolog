% Ömer Yılmaz
% 2016400024
% compiling: yes
% complete: yes

:- [pokemon_data].

%takes first two items of a list
take_two(X, Y, [X|[Y|_]]).

%takes first item of a list
take_one(X,[X|_]).

%finds max of two numbers
find_max(X,Y,Z) :-
	X >= Y, Z is X,!;
	Y >= X, Z is Y.
	
%calculate the length
len([],0).
len([_|T],N) :- len(T,X), N is X+1.
%Check if the list is empty
is_empty(List):- not(member(_,List)).
%Add element to list
add_to_list(X,List,[X|List]).


%Evolving pokemon recursively
find_pokemon_evolution(Y, Pokemon, EvolvedPokemon) :- 
	(pokemon_evolution(Pokemon, NextEvolve, Z), Y>=Z),
	find_pokemon_evolution(Y, NextEvolve, EvolvedPokemon), ! ;
	EvolvedPokemon = Pokemon.
 %Finding the level stats of a Pokemon
 pokemon_level_stats(PokemonLevel, Pokemon, PokemonHp, PokemonAttack, PokemonDefense) :-
	pokemon_stats(Pokemon, _, HealthPoint, Attack, Defense),
	PokemonHp is HealthPoint + 2 * PokemonLevel,
	PokemonAttack is Attack + PokemonLevel,
	PokemonDefense is Defense + PokemonLevel.
 %Help to single_type_multiplier
 stm_help(DT, Mul, [PT | PTRest], [TC | TCRest]):- 
	DT = PT, Mul = TC, !; stm_help(DT, Mul, PTRest, TCRest).
 %Calculate Multiplier for only one DefenderType
 single_type_multiplier(AttackerType, DefenderType, Multiplier) :-
	type_chart_attack(AttackerType, ATList), pokemon_types(PTList), stm_help(DefenderType, Multiplier, PTList, ATList).
 %Calculate Multiplier for DefenderTypeList
 type_multiplier(AttackerType, DefenderTypeList, Multiplier) :-
	take_two(X, Y, DefenderTypeList),
	single_type_multiplier(AttackerType, X, Mul1),
	single_type_multiplier(AttackerType, Y, Mul2),
	Multiplier is Mul1 * Mul2, !;
	take_one(Z, DefenderTypeList),
	single_type_multiplier(AttackerType, Z, Multiplier).
%Help to pokemon_type_multiplier
ptm_help(ATList, DList, Multiplier) :-
	take_two(X, Y, ATList), type_multiplier(X, DList, Mul1), type_multiplier(Y, DList, Mul2), find_max(Mul1, Mul2, Multiplier), !;
	take_one(Z, ATList), type_multiplier(Z, DList, Multiplier).
%Calculate the Multiplier for two Pokemons
pokemon_type_multiplier(AttackerPokemon, DefenderPokemon, Multiplier) :-
	pokemon_stats(AttackerPokemon, ATList, _, _, _),
	pokemon_stats(DefenderPokemon, DList, _, _, _),
	ptm_help(ATList, DList, Multiplier).
%Calculate the Damage for two Pokemons
pokemon_attack(ATP, ATPLevel, DEFP, DEFPLevel, Damage) :-
	pokemon_level_stats(ATPLevel, ATP,  _, Attack, _),
	pokemon_level_stats(DEFPLevel, DEFP, _, _, Defense),
	pokemon_type_multiplier(ATP, DEFP, Mul),
	Damage is ((0.5 * ATPLevel * (Attack/Defense) * Mul) + 1).
%Check the X or Y smaller than 0 and help for pf_help
both_smaller(X, Y) :- (X =< 0; Y =< 0).
%Help to pokemon_fight
pf_help(P1Damage, P1Hp, P2Damage, P2Hp, Rounds, P1Son, P2Son) :-
	both_smaller(P1Hp, P2Hp), Rounds is 0, P1Son = P1Hp, P2Son = P2Hp, !;
	A is P1Hp - P2Damage,
	B is P2Hp - P1Damage,
	pf_help(P1Damage, A, P2Damage, B, X, P1Son, P2Son), Rounds is X + 1.
%Demonstrate the fight for two Pokemons
pokemon_fight(Pok1, Pok1Level, Pok2, Pok2Level, Pok1Hp, Pok2Hp, Rounds) :-
	pokemon_attack(Pok1, Pok1Level, Pok2, Pok2Level, Pok1Damage),
	pokemon_attack(Pok2, Pok2Level, Pok1, Pok1Level, Pok2Damage),
	pokemon_level_stats(Pok1Level, Pok1, XHp, _, _),
	pokemon_level_stats(Pok2Level, Pok2, YHp, _, _),
	pf_help(Pok1Damage, XHp, Pok2Damage, YHp, Rounds, Pok1Hp, Pok2Hp).

%Find the winning Trainer for fighting Pokemons to help pt_help
fight_winner(P1, Pok1Level, P2, Pok2Level, Winner, PT1, PT2) :-
	find_pokemon_evolution(Pok1Level, P1, Pok1Evolve),
	find_pokemon_evolution(Pok2Level, P2, Pok2Evolve),
	pokemon_fight(Pok1Evolve, Pok1Level, Pok2Evolve, Pok2Level, _, P2Hp, _),
	P2Hp =< 0, Winner = PT1, !; Winner = PT2.
%Help to pokemon_tournament
pt_help(PT1, PT2, [Pok1 | P1Rest], [Pok1Level | Pok1LevelRest], [Pok2 | P2Rest], [Pok2Level | Pok2LevelRest], WinnerList) :-
	fight_winner(Pok1, Pok1Level, Pok2, Pok2Level, Winner, PT1, PT2), (is_empty(P1Rest) -> WinnerList = [Winner];
	(pt_help(PT1, PT2, P1Rest,  Pok1LevelRest, P2Rest, Pok2LevelRest, WinList), add_to_list(Winner, WinList, WinnerList))).
	
%Find the WinnerList for tournament
pokemon_tournament(PT1, PT2, WinnerList) :-
	pokemon_trainer(PT1, Pok1, Pok1Level),
	pokemon_trainer(PT2, Pok2, Pok2Level),
	pt_help(PT1, PT2, Pok1, Pok1Level, Pok2, Pok2Level, WinnerList).
%Find Remaining HP for PokemonList for fight between EnemyPokemon to help best_pokemon
find_remainHP(EnemyPokemon, Level, RemHPList, [Pokemon | PokemonRest]) :-
	pokemon_fight(Pokemon, Level, EnemyPokemon, Level, PokemonHP, _, _), (is_empty(PokemonRest) -> RemHPList = [PokemonHP];
	(find_remainHP(EnemyPokemon, Level, RemHPRest, PokemonRest), add_to_list(PokemonHP, RemHPRest, RemHPList))).
%Find the pokemon with max remaining HP to help best_pokemon
find_max_in_list([RemHP| RemHPRest], [Pokemon|PokemonRest], Max, BestPokemon) :-
	Max = RemHP -> BestPokemon = Pokemon ; find_max_in_list(RemHPRest, PokemonRest, Max, BestPokemon).
	
%Find the best pokemon to EnemyPokemon
best_pokemon(EnemyPokemon, Level, RemHp, BestPokemon) :-
	findall(X, pokemon_stats(X, _, _, _, _), PokemonList),
	find_remainHP(EnemyPokemon, Level, RemHPList, PokemonList),
	max_list(RemHPList, RemHp),
	find_max_in_list(RemHPList, PokemonList, RemHp, BestPokemon).
%Help to best_pokemon_team
bpt_help([Pokemon|PokemonRest], [Level|LevelRest], BestTeam) :-
	best_pokemon(Pokemon, Level, _, Best), (is_empty(PokemonRest) -> BestTeam = [Best] ;
	(bpt_help(PokemonRest, LevelRest, Bestt), add_to_list(Best, Bestt, BestTeam))).
%Find BestPokemonTeam
best_pokemon_team(OpponentTrainer, BestTeam) :-
	pokemon_trainer(OpponentTrainer, PokemonList, LevelList),
	bpt_help(PokemonList, LevelList, BestTeam).
%Help to pokemon_types
pokemon_type_help([H|Rest], Pokemon) :-
	pokemon_stats(Pokemon, PokemonTypeList, _, _, _),
	((member(H, PokemonTypeList), !); pokemon_type_help(Rest, Pokemon)).
%Find Pokemon list among the TypeList
pokemon_types(TypeList, InitPokemonList, PokemonList) :-
	findall(X, (member(X, InitPokemonList), pokemon_type_help(TypeList, X)), PokemonList).
%Check if X or Y be member of List to help pokemon_liked
two_member(X, Y, List) :-
	member(X, List) ; member(Y, List).
%Check if the Pokemon Liked and not Disliked to help gpt_help
pokemon_liked(Pokemon, LikedTypes, DislikedTypes) :-
	pokemon_stats(Pokemon, TypeList, _, _, _),(
	(take_two(X, Y, TypeList), not(member(X, DislikedTypes) ; member(Y, DislikedTypes)),
	two_member(X, Y, LikedTypes), !);
	len(TypeList, N), N = 1, take_one(Z, TypeList), not(member(Z, DislikedTypes)), member(Z, LikedTypes)).
	
%Find the PokemonList that are Liked and not Disliked to help generate_pokemon_team
gpt_help([Pokemon|PokemonRest], LikedTypes, DislikedTypes, PokemonTeam):-
	(pokemon_liked(Pokemon, LikedTypes, DislikedTypes),
	(is_empty(PokemonRest) -> PokemonTeam = [Pokemon]; (gpt_help(PokemonRest, LikedTypes, DislikedTypes, PokemonT), add_to_list(Pokemon, PokemonT, PokemonTeam))), !);
	is_empty(PokemonRest) -> PokemonTeam = []; gpt_help(PokemonRest, LikedTypes, DislikedTypes, PokemonTeam).
%Make KeyList from a List according to Criterion
key_maker([Pokemon|PokemonRest], [Key|KeyRest], Criterion) :-
	pokemon_stats(Pokemon, _, HP, Attack, Defense),
	(Criterion = a, X is ((-1) * Attack), Key = X - [Pokemon, HP, Attack, Defense];
	Criterion = d, Y is ((-1) * Defense), Key = Y - [Pokemon, HP, Attack, Defense];
	Criterion = h, Z is ((-1) * HP), Key = Z - [Pokemon, HP, Attack, Defense]),
	(not(is_empty(PokemonRest))-> key_maker(PokemonRest, KeyRest, Criterion) ; KeyRest = []).
%Remove the Key
key_remover(_ - Y, Y).
%Get a List from KeyList
key_remover2([Key|KeyRest], [L|Rest]) :-
	key_remover(Key, L), (is_empty(KeyRest) -> Rest = []; key_remover2(KeyRest, Rest)).
%Take the first Count elements of a list
count_remover([L|Rest], Count, [Rem|RemRest]) :-
	Count > 1 -> (Rem = L, X is Count - 1, count_remover(Rest, X, RemRest)); take_one(A, Rest), [Rem|RemRest] = [A].
	 
	
%Generate a pokemon Team
generate_pokemon_team(LikedTypes, DislikedTypes, Criterion, Count, PokemonTeam) :-
	findall(X, pokemon_stats(X, _, _, _, _), PokemonList),
	gpt_help(PokemonList, LikedTypes, DislikedTypes, Team),
	key_maker(Team, KeyTeam, Criterion),
	keysort(KeyTeam, Sorted),
	key_remover2(Sorted, UnKey),
	count_remover(UnKey, Count, PokemonTeam).
	
	
	
	
	

	
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
