#type_narrowing = true

val (+) : (int, int) -> int
val (@) : (['a*], ['b*]) -> ['a* 'b*]

(* Code: *)
(* Example filter *)
(* success *)
val filter_success : ('a -> any) & ('b -> ~true) -> [('a|'b)*] -> [('a\'b)*]
let filter_success f l =
  match l with
  | [] -> []
  | e::l ->
    if f e is true then e::(filter_success f l) else filter_success f l
  end

(* failure *)
val filter_failure : ('a -> any) & ('b -> ~true) -> [('a|'b)*] -> [('a\'b)*]
let filter_failure f l =
  match l with
  | [] -> []
  | e::l ->
    if f e is true then e::(filter_failure f l) else e::(filter_failure f l)
  end

(* Example flatten *)
(* success *)
type int_tree_success = [ (int\[any*] | int_tree_success)* ]

val flatten_success : int_tree_success -> [int*]
let flatten_success l =
  match l with
  | [] -> []
  | (x & :list)::y -> (flatten_success x) @ (flatten_success y)
  | x::y -> x::(flatten_success y)
  end

(* failure *)
type int_tree_failure = [ (int\[any*] | int_tree_failure)* ]

val flatten_failure : int_tree_failure -> [int*]
let flatten_failure l =
  match l with
  | [] -> []
  | (x & :list)::y -> (flatten_failure x) @ (flatten_failure y)
  | x::y -> x
  end

(* Example tree_node *)
(* success *)
type tree_node_success = { value:int ; children:[tree_node_success*]? }

val is_tree_node_success : (tree_node_success -> true) & (~tree_node_success -> false)
let is_tree_node_success x =
  if x is tree_node_success then true else false

(* failure *)
type tree_node_failure = { value:int ; children:[tree_node_failure*]? }

val is_tree_node_failure : (tree_node_failure -> true) & (~tree_node_failure -> false)
let is_tree_node_failure x =
  if x is { value:int ..} then true else false

(* Example rainfall *)
(* success *)
type weather_report_success = { rainfall:any? ..}

val rainfall_success : [weather_report_success*] -> int
let rainfall_success reports =
  match reports with
  | [] -> 0
  | day::rest ->
    if day is { rainfall:(0..999) ..} then
      day.rainfall + (rainfall_success rest)
    else rainfall_success rest
  end

(* failure *)
type weather_report_failure = { rainfall:any? ..}

val rainfall_failure : [weather_report_failure*] -> int
let rainfall_failure reports =
  match reports with
  | [] -> 0
  | day::rest ->
    if day is { rainfall:any ..} then
      day.rainfall + (rainfall_failure rest)
    else rainfall_failure rest
  end

(* End: *)
