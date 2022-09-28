Require Import NatBin.

(*
 * This is another Shizhuo tutorial, building on NatBin.v.
 * This time we look at some other changes in shape like
 * the unary/binary example that form equivalences.
 *)

(* --- Equivalence 1: Unary and Ternary --- *)

(*
 * This will be a lot like our unary and binary examples,
 * but now we look at unary and ternary instead.
 * Ternary can be defined a lot like binary:
 *)
Inductive tern_pos : Set :=
| O1 : tern_pos              (* 01 *)
| O2 : tern_pos              (* 02 *)
| xO : tern_pos -> tern_pos  (* shift left and add 0 *)
| x1 : tern_pos -> tern_pos  (* shift left and add 1 *)
| x2 : tern_pos -> tern_pos. (* shift left and add 2 *)

Inductive tern : Set :=
| OO : tern                  (* 00 *)
| pos : tern_pos -> tern.    (* positive ternary numbers *)

(* --- Some related terms --- *)

(*
 * How are these related? Let's define corresponding points/terms.
 *)
Definition zeros : nat * tern :=
  (O, OO). (* 0, 00 *)

Definition ones : nat * tern :=
  (S O, pos O1). (* 1, 01 *)

Definition twos : nat * tern :=
  (S (S O), pos O2). (* 2, 02 *)

Definition threes : nat * tern :=
  (S (S (S O)), pos (xO O1)). (* 3, 10 *)

Definition fours : nat * tern :=
  (S (S (S (S O))), pos (x1 O1)). (* 4, 11 *)

Definition fives : nat * tern :=
  (S (S (S (S (S O)))), pos (x2 O1)). (* 5, 12 *)

Definition sixes : nat * tern :=
  (S (S (S (S (S (S O))))), pos (xO O2)). (* 6, 20 *)

Definition sevens : nat * tern :=
  (S (S (S (S (S (S (S O)))))), pos (x1 O2)). (* 7, 21 *)

Definition eights : nat * tern :=
  (S (S (S (S (S (S (S (S O))))))), pos (x2 O2)). (* 8, 22 *)

Definition nines : nat * tern :=
  (S (S (S (S (S (S (S (S (S O)))))))), pos (xO (xO O1))). (* 9, 100 *)

(*
 * We can similary define S over ternary:
 *)
Fixpoint S_tern_pos (t : tern_pos) : tern_pos :=
  match t with
  | O1 => O2
  | O2 => xO O1
  | xO t' => x1 t'
  | x1 t' => x2 t'
  | x2 t' => xO (S_tern_pos t')
  end.

Definition S_tern (t : tern) : tern :=
  match t with
  | OO => pos O1
  | pos t' => pos (S_tern_pos t')
  end.

(*
 * Likewise in the opposite direction:
 *)
Definition xO_nat (n : nat) :=
  add n (add n n).

Definition x1_nat (n : nat) :=
  S (add n (add n n)).

Definition x2_nat (n : nat) :=
  S (S (add n (add n n))).

(*
 * Our functions for the equivalence:
 *)
Fixpoint f (n : nat) : tern :=
  match n with
  | O => OO
  | S m => S_tern (f m)
  end.

Fixpoint g_pos (t : tern_pos) : nat :=
  match t with
  | O1 => S O
  | O2 => S (S O)
  | xO t' => xO_nat (g_pos t')
  | x1 t' => x1_nat (g_pos t')
  | x2 t' => x2_nat (g_pos t')
  end.

Definition g (t : tern) : nat :=
  match t with
  | OO => O
  | pos t' => g_pos t'
  end.

(*
 * Lemmas for equivalence proof:
 *)
Lemma S_OK :
  forall (t : tern), g (S_tern t) = S (g t).
Proof.
  induction t as [|t']; auto.
  induction t'; auto.
  simpl in *. rewrite IHt'. unfold xO_nat, x2_nat. simpl.
  f_equal. rewrite add_n_Sm.
  f_equal. rewrite add_n_Sm. 
  apply add_n_Sm.
Qed.

Definition xO_tern (t : tern) :=
  match t with
  | OO => OO
  | pos t' => pos (xO t')
  end.

Lemma xO_OK:
  forall (n : nat), f (xO_nat n) = xO_tern (f n).
Proof.
  intros n. induction n; auto.
  simpl. unfold xO_nat in IHn.
  rewrite add_n_Sm. simpl in *.
  rewrite add_n_Sm. simpl in *.
  rewrite add_n_Sm. simpl in *.
  rewrite IHn. destruct (f n); auto.
Qed.

Definition x1_tern (t : tern) :=
  match t with
  | OO => pos O1
  | pos t' => pos (x1 t')
  end.

Lemma x1_OK:
  forall (n : nat), f (x1_nat n) = x1_tern (f n).
Proof.
  intros n. induction n; auto.
  simpl. unfold x1_nat in IHn.
  rewrite add_n_Sm. simpl in *. 
  rewrite add_n_Sm. simpl in *. 
  rewrite add_n_Sm. simpl in *.
  rewrite IHn.
  destruct (f n); auto.
Qed.

Definition x2_tern (t : tern) :=
  match t with
  | OO => pos O2
  | pos t' => pos (x2 t')
  end.

Lemma x2_OK:
  forall (n : nat), f (x2_nat n) = x2_tern (f n).
Proof.
  intros n. induction n; auto.
  simpl. unfold x2_nat in IHn.
  rewrite add_n_Sm. simpl in *. 
  rewrite add_n_Sm. simpl in *. 
  rewrite add_n_Sm. simpl in *.
  rewrite IHn.
  destruct (f n); auto.
Qed.

Theorem section:
  forall (n : nat), g (f n) = n.
Proof.
  intros n. induction n.
  - reflexivity.
  - simpl. rewrite S_OK. rewrite IHn. reflexivity.
Qed.

Theorem retraction:
  forall (t : tern), f (g t) = t.
Proof.
  intros t. induction t as [|t']; auto.
  induction t'; auto; simpl in IHt'.
  + simpl. rewrite xO_OK. rewrite IHt'. reflexivity.
  + unfold g. replace (g_pos (x1 t')) with (x1_nat (g_pos t')) by reflexivity.
    rewrite x1_OK. rewrite IHt'. reflexivity.
  + unfold g. replace (g_pos (x2 t')) with (x2_nat (g_pos t')) by reflexivity.
    rewrite x2_OK. rewrite IHt'. reflexivity.
Qed.

