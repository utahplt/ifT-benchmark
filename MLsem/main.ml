#type_narrowing = true

val strlen : string -> int
val add : int -> int -> int
val add1 : int -> int
val positive_int : int -> bool
val strcat : (string, string) -> string
val (+) : (int, int) -> int

let not_ x = if x is true then false else true

let and_ (x,y) =
  match x,y with
  | true,true -> true
  | _ -> false
  end

let or_ (x,y) = not_ (and_ (not_ x, not_ y))

val is_string : (string -> true) & (~string -> false)
let is_string x = if x is string then true else false

val is_int : (int -> true) & (~int -> false)
let is_int x = if x is int then true else false

val is_bool : (bool -> true) & (~bool -> false)
let is_bool x = if x is bool then true else false

(* Code: *)
(* Example positive *)
(* success *)
val positive_success_f : any -> any
let positive_success_f x =
  if x is string then strlen x else x

(* failure *)
val positive_failure_f : any -> any
let positive_failure_f x =
  if x is string then add1 x else x

(* Example negative *)
(* success *)
val negative_success_f : (string|int) -> int
let negative_success_f x =
  if x is string then strlen x else add1 x

(* failure *)
val negative_failure_f : (string|int|bool) -> int
let negative_failure_f x =
  if x is string then strlen x else add1 x

(* Example connectives *)
(* success *)
val connectives_success_f : (string|int) -> int
let connectives_success_f x =
  if is_int x is false then strlen x else 0

val connectives_success_g : any -> int
let connectives_success_g x =
  if or_ (is_string x, is_int x) is true then connectives_success_f x else 0

val connectives_success_h : (string|int|bool) -> int
let connectives_success_h x =
  if and_ (not_ (is_bool x), not_ (is_int x)) is true then strlen x else 0

(* failure *)
val connectives_failure_f : (string|int) -> int
let connectives_failure_f x =
  if is_int x is false then add1 x else 0

val connectives_failure_g : any -> int
let connectives_failure_g x =
  if or_ (is_string x, is_int x) is true then add1 x else 0

val connectives_failure_h : (string|int|bool) -> int
let connectives_failure_h x =
  if and_ (not_ (is_bool x), not_ (is_int x)) is true then add1 x else 0

(* Example nesting_body *)
(* success *)
val nesting_body_success_f : (string|int|bool) -> int
let nesting_body_success_f x =
  if x is ~string then
    if x is ~bool then add1 x else 0
  else 0

(* failure *)
val nesting_body_failure_f : (string|int|bool) -> int
let nesting_body_failure_f x =
  if x is (string|int) then
    if x is (int|bool) then strlen x else 0
  else 0

(* Example struct_fields *)
(* success *)
val struct_fields_success_f : { a:any } -> int
let struct_fields_success_f x =
  if x.a is int then x.a else 0

(* failure *)
val struct_fields_failure_f : { a:any } -> int
let struct_fields_failure_f x =
  if x.a is string then x.a else 0

(* Example tuple_elements *)
(* success *)
val tuple_elements_success_f : (any, any) -> int
let tuple_elements_success_f x =
  if fst x is int then fst x else 0

(* failure *)
val tuple_elements_failure_f : (any, any) -> int
let tuple_elements_failure_f x =
  if fst x is int then (fst x) + (snd x) else 0

(* Example tuple_length *)
(* success *)
val tuple_length_success_f : ([int int] | [string string string]) -> int
let tuple_length_success_f x =
  if x is [any any] then (hd x) + (hd (tl x)) else strlen (hd x)

(* failure *)
val tuple_length_failure_f : ([int int] | [string string string]) -> int
let tuple_length_failure_f x =
  if x is [any any] then (hd x) + (hd (tl x)) else (hd x) + (hd (tl x))

(* Example alias *)
(* success *)
val alias_success_f : any -> any
let alias_success_f x =
  let y = is_string x in
  if y is true then strlen x else x

(* failure *)
val alias_failure_f : any -> any
let alias_failure_f x =
  let y = is_string x in
  if y is true then add1 x else x

(* Example nesting_condition *)
(* success *)
val nesting_condition_success_f : any -> any -> int
let nesting_condition_success_f x y =
  if (if is_int x is true then is_string y else false) is true then
    add x (strlen y)
  else 0

(* failure *)
val nesting_condition_failure_f : any -> any -> int
let nesting_condition_failure_f x y =
  if (if is_int x is true then is_string y else is_string y) is true then
    add x (strlen y)
  else 0

(* Example merge_with_union *)
(* success *)
val merge_with_union_success_f : any -> (string|int)
let merge_with_union_success_f x =
  let y =
    if x is string then strcat (x, "hello")
    else if x is int then add1 x
    else 0
  in y

(* failure *)
val merge_with_union_failure_f : any -> (string|int)
let merge_with_union_failure_f x =
  let y =
    if x is string then strcat (x, "hello")
    else if x is int then add1 x
    else 0
  in add1 y

(* Example predicate_2way *)
(* success *)
val predicate_2way_success_helper : (string -> true) & (int -> false)
let predicate_2way_success_helper x =
  if x is string then true else false

val predicate_2way_success_g : (string|int) -> int
let predicate_2way_success_g x =
  if predicate_2way_success_helper x is true then strlen x else x

(* failure *)
val predicate_2way_failure_helper : (string -> true) & (int -> false)
let predicate_2way_failure_helper x =
  if x is string then true else false

val predicate_2way_failure_g : (string|int) -> int
let predicate_2way_failure_g x =
  if predicate_2way_failure_helper x is true then add1 x else x

(* Example predicate_1way *)
(* success *)
val predicate_1way_success_helper : (int -> bool) & (string -> false)
let predicate_1way_success_helper x =
  if x is int then positive_int x else false

val predicate_1way_success_g : (string|int) -> int
let predicate_1way_success_g x =
  if predicate_1way_success_helper x is true then add1 x else 0

(* failure *)
val predicate_1way_failure_helper : (int -> bool) & (string -> false)
let predicate_1way_failure_helper x =
  if x is int then positive_int x else false

val predicate_1way_failure_g : (string|int) -> int
let predicate_1way_failure_g x =
  if predicate_1way_failure_helper x is true then add1 x else strlen x

(* Example predicate_checked *)
(* success *)
val predicate_checked_success_helper : (string -> true) & ((int|bool) -> false)
let predicate_checked_success_helper x =
  if x is string then true else false

val predicate_checked_success_g : (string -> false) & ((int|bool) -> true)
let predicate_checked_success_g x =
  if predicate_checked_success_helper x is true then false else true

(* failure *)
val predicate_checked_failure_f : (string -> true) & ((int|bool) -> false)
let predicate_checked_failure_f x =
  if x is (string|int) then true else false

val predicate_checked_failure_g : (string -> false) & ((int|bool) -> true)
let predicate_checked_failure_g x =
  if x is int then true else false

(* End: *)
