% $Id: functions.pl,v 1.3 2016-11-08 15:04:13-08 - - $

/*
* Arya Kashani
* akashani
* 1474098
* CMPS 112
* Assignment 4
*/

not( X ) :- X, !, fail.
not( _ ).

mathfns( X, List ) :-
   S is sin( X ),
   C is cos( X ),
   Q is sqrt( X ),
   List = [S, C, Q].

constants( List ) :-
   Pi is pi,
   E is e,
   Epsilon is epsilon,
   List = [Pi, E, Epsilon].

sincos( X, Y ) :-
   Y is sin( X ) ** 2 + cos( X ) ** 2.

haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
   Dlon is Lon2 - Lon1,
   Dlat is Lat2 - Lat1,
   A is sin( Dlat / 2 ) ** 2
      + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3961.

degmin_to_radians( degmin( Degrees, Minutes ), Radians ) :-
   Deg_rees is Degrees + Minutes / 60,
   Radians is Deg_rees * pi / 180. 

distance( Airport1, Airport2, Distance ) :-
   airport( Airport1, _, Lat1, Lon1 ),
   airport( Airpotrt2, _, Lat2, Lon2 ),
   degmin_to_radians( Lat1, Lat1_r ),
   degmin_to_radians( Lon1, Lon1_r ),
   degmin_to_radians( Lat2, Lat2_r ),
   degmin_to_radians( Lon2, Lon2_r ),
   haversine_radians( Lat1_r, Lon1_r, Lat2_r, Lon2_r, Distance ).

miles_to_hours( Miles, Hours ) :-
   Hours is Miles / 500.

totalHours( time(Hours, Mins ), TotalHours ) :-
   TotalHours is Hours + Mins / 60.

printh( Time ) :-
   Time < 10, print( 0 ), print( Time ).
printh( Time ) :-
   Time >= 10, print( Time ).
printTime( TotalHours ) :-
   Mins is floor( TotalHours * 60 ),
   Hours is Mins // 60,
   Minutes is Mins mod 60,
   printh( Hours ), print( ':' ), printh( Minutes ).

isPath( Final, Final, _, [Final], _ ).
isPath( Start, Final, Vistited, [[Start, DepTime, ArrTime] | List], 
      DepTimeInHM ) :-
   flight( Start, Final, DepTimeInHM ),
   not( member( Final, Visited ) ),
   totalHours( DepTimeInHM, DepTime ),
   distance( Start, Final, DistanceInMi ),
   miles_to_hours( DistanceInMi, TravelTime ),
   ArrTime is DepTime + TravelTime,
   ArrTime < 24.0,
   isPath( Final, Final, [Final | Visited], List, _ ).
isPath( Start, Final, Visited, [[Start, DepTime, ArrTime] | List], 
      DepTimeInHM ) :-
   flight( Start, Next, DepTimeInHM ),
   not( member( Next, Visited ) ),
   totalHours( DepTimeInHM, DepTime ),
   distance( Start, Next, DistanceInMi ),
   miles_to_hours( DistanceInMi, TravelTime ),
   ArrTime is DepTime + TravelTime,
   ArrTime < 24.0,
   flight( Next, _, NextDepTimeInHM ),
   totalHours( NextDepTimeInHM, NextDepTime ),
   TransferFlightIF is NextDepTime - ArrTime - 0.5,
   TransferFlightIF >= 0,
   isPath( Next, Final, [Next | Visited], List, NextDepTimeInHM ).

writePath( [] ) :-
   nl.
writePath( [[Dep, DepTime, ArrTime], Arr | []] ) :-
   airport( Dep, DepName , _, _ ),
   airport( Arr, ArrName , _, _ ),
   write( '     ' ), 
   write( 'depart  ' ),
   write( Dep ), 
   write( '  ' ),
   write( DepName ),
   printTime( DepTime ), nl,
   write( '     ' ), 
   write( 'arrive  ' ),
   write( Arr ), 
   write( '  ' ),
   write( ArrName ),
   printTime( ArrTime ), nl, !, true.
writePath( [[Dep, DDepTime, DArrTime], 
      [Arr, ADepTime, AArrTime] | Rest] ) :-
   airport( Dep, DepName, _, _),
   airport( Arr, ArrName, _, _),
   write( '     ' ), 
   write( 'depart  ' ),
   write( Dep ), 
   write( '  ' ),
   write( DepName ),
   printTime( DDepTime ), nl,
   write( '     ' ), 
   write( 'arrive  ' ),
   write( Arr ), 
   write( '  ' ),
   write( ArrName ),
   printTime( DArrTime ), nl, !, 
   writePath( [[Arr, ADepTime, AArrTime] | Rest] ).

fly( Depart, Depart ) :-
   write( 'Error: the departure and the destination are the same.' ),
   nl, !, fail.

fly( Depart, Arrive ) :-
   airport( Depart, _, _, _ ),
   airport( Arrive, _, _, _ ),
   isPath( Depart, Arrive, [Depart], List, _ ),
   !, nl,
   writePath( List ),
   true.

fly( Depart, Arrive ) :-
   airport( Depart, _, _, _ ),
   airport( Arrive, _, _, _ ),
   write( 'Error: your flight isnt possible in the twilight zone.' ),
   nl, !, fail.

fly( _, _ ) :-
   write( 'Error: non-existent airport(s).' ),
   nl, !, fail.



