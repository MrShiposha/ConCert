open BasicAst
open Datatypes
open MCString
open PCUICAst
open String0
open Universes0

(** val string_of_term : term -> char list **)

let rec string_of_term = function
| Coq_tRel n ->
  append ('R'::('e'::('l'::('('::[])))) (append (string_of_nat n) (')'::[]))
| Coq_tVar n -> append ('V'::('a'::('r'::('('::[])))) (append n (')'::[]))
| Coq_tEvar (ev, args) ->
  append ('E'::('v'::('a'::('r'::('('::[])))))
    (append (string_of_nat ev)
      (append (','::[])
        (append (string_of_list string_of_term args) (')'::[]))))
| Coq_tSort s ->
  append ('S'::('o'::('r'::('t'::('('::[])))))
    (append (string_of_sort s) (')'::[]))
| Coq_tProd (na, b, t0) ->
  append ('P'::('r'::('o'::('d'::('('::[])))))
    (append (string_of_name na)
      (append (','::[])
        (append (string_of_term b)
          (append (','::[]) (append (string_of_term t0) (')'::[]))))))
| Coq_tLambda (na, b, t0) ->
  append ('L'::('a'::('m'::('b'::('d'::('a'::('('::[])))))))
    (append (string_of_name na)
      (append (','::[])
        (append (string_of_term b)
          (append (','::[]) (append (string_of_term t0) (')'::[]))))))
| Coq_tLetIn (na, b, t', t0) ->
  append ('L'::('e'::('t'::('I'::('n'::('('::[]))))))
    (append (string_of_name na)
      (append (','::[])
        (append (string_of_term b)
          (append (','::[])
            (append (string_of_term t')
              (append (','::[]) (append (string_of_term t0) (')'::[]))))))))
| Coq_tApp (f, l) ->
  append ('A'::('p'::('p'::('('::[]))))
    (append (string_of_term f)
      (append (','::[]) (append (string_of_term l) (')'::[]))))
| Coq_tConst (c, u) ->
  append ('C'::('o'::('n'::('s'::('t'::('('::[]))))))
    (append c
      (append (','::[]) (append (string_of_universe_instance u) (')'::[]))))
| Coq_tInd (i, u) ->
  append ('I'::('n'::('d'::('('::[]))))
    (append (string_of_inductive i)
      (append (','::[]) (append (string_of_universe_instance u) (')'::[]))))
| Coq_tConstruct (i, n, u) ->
  append
    ('C'::('o'::('n'::('s'::('t'::('r'::('u'::('c'::('t'::('('::[]))))))))))
    (append (string_of_inductive i)
      (append (','::[])
        (append (string_of_nat n)
          (append (','::[])
            (append (string_of_universe_instance u) (')'::[]))))))
| Coq_tCase (indn, t0, p, brs) ->
  let (ind, i) = indn in
  append ('C'::('a'::('s'::('e'::('('::[])))))
    (append (string_of_inductive ind)
      (append (','::[])
        (append (string_of_nat i)
          (append (','::[])
            (append (string_of_term t0)
              (append (','::[])
                (append (string_of_term p)
                  (append (','::[])
                    (append
                      (string_of_list (fun b -> string_of_term (snd b)) brs)
                      (')'::[]))))))))))
| Coq_tProj (p, c) ->
  let (p0, k) = p in
  let (ind, i) = p0 in
  append ('P'::('r'::('o'::('j'::('('::[])))))
    (append (string_of_inductive ind)
      (append (','::[])
        (append (string_of_nat i)
          (append (','::[])
            (append (string_of_nat k)
              (append (','::[]) (append (string_of_term c) (')'::[]))))))))
| Coq_tFix (l, n) ->
  append ('F'::('i'::('x'::('('::[]))))
    (append (string_of_list (string_of_def string_of_term) l)
      (append (','::[]) (append (string_of_nat n) (')'::[]))))
| Coq_tCoFix (l, n) ->
  append ('C'::('o'::('F'::('i'::('x'::('('::[]))))))
    (append (string_of_list (string_of_def string_of_term) l)
      (append (','::[]) (append (string_of_nat n) (')'::[]))))

(** val decompose_app_rec : term -> term list -> term * term list **)

let rec decompose_app_rec t l =
  match t with
  | Coq_tApp (f, a) -> decompose_app_rec f (a :: l)
  | _ -> (t, l)

(** val decompose_app : term -> term * term list **)

let decompose_app t =
  decompose_app_rec t []

(** val decompose_prod_assum : context -> term -> context * term **)

let rec decompose_prod_assum _UU0393_ t = match t with
| Coq_tProd (n, a, b) -> decompose_prod_assum (snoc _UU0393_ (vass n a)) b
| Coq_tLetIn (na, b, bty, b') ->
  decompose_prod_assum (snoc _UU0393_ (vdef na b bty)) b'
| _ -> (_UU0393_, t)

(** val decompose_prod_n_assum :
    context -> nat -> term -> (context * term) option **)

let rec decompose_prod_n_assum _UU0393_ n t =
  match n with
  | O -> Some (_UU0393_, t)
  | S n0 ->
    (match t with
     | Coq_tProd (na, a, b) ->
       decompose_prod_n_assum (snoc _UU0393_ (vass na a)) n0 b
     | Coq_tLetIn (na, b, bty, b') ->
       decompose_prod_n_assum (snoc _UU0393_ (vdef na b bty)) n0 b'
     | _ -> None)
