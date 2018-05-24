parser grammar PropertyParser;

options
{
   tokenVocab = PropertyLexer;
}

@header
{
   import hastabel.World;
   import hastabel.lang.*;
}

@members
{
   /* of the class */
   World WORLD;
}

tag_existing [World start_world]
   returns [Formula result]

   @init
   {
      WORLD = start_world;
   }:

   (WS)* TAG_EXISTING_KW
      L_PAREN
      (tag_item)+
      R_PAREN
   (WS)* formula[null]
   (WS)* R_PAREN

   {
      $result = ($formula.result);
   }
;

tag_item:

   (WS)* L_PAREN
   (WS)* var=ID
   (WS)+ type=ID
   (WS)* R_PAREN
   (WS)*

   {
      final Type t;

      t = WORLD.get_types_manager().get(($type.text));

      if (t == null)
      {
         System.err.println
         (
            "[F] The following exception was raised during the parsing of the"
            + " property (l."
            + ($var.getLine())
            + " c."
            + ($var.getCharPositionInLine())
            + "):\n[F] No such type \""
            + ($type.text)
            + "\"."
         );

         WORLD.invalidate();
      }

      if (WORLD.get_variables_manager().seek(t, ($var.text)) == null)
      {
         WORLD.invalidate();
      }
   }
;

id_or_string_or_fun [Variable current_node]
   returns [Expression value]

   :
   ID
   {
      if (($ID.text).equals("_"))
      {
         $value = null;
      }
      else
      {
         $value = WORLD.get_variables_manager().get_variable(($ID.text));

         if (($value) == null)
         {
            WORLD.invalidate();
         }
      }
   }

   |
   STRING
   {
      $value =
         WORLD.get_strings_manager().get_string_as_element(($STRING.text));

      if (($value) == null)
      {
         WORLD.invalidate();
      }
   }

   |
   function[current_node]
   {
      $value = ($function.result);
   }
;

id_list [Variable current_node]
   returns [List<Expression> list]

   @init
   {
      final List<Expression> result = new ArrayList<Expression>();
   }

   :
   (
      (WS)+
      id_or_string_or_fun[current_node]
      {
         result.add(($id_or_string_or_fun.value));
      }
   )*

   {
      $list = result;
   }
;

predicate [Variable current_node]
   returns [Formula result]:

   (WS)* L_PAREN
      ID
      id_list[current_node]
   (WS)* R_PAREN

   {
      final Expression expression;
      final List<Expression> ids;
      final Predicate predicate;

      predicate = WORLD.get_predicates_manager().get_predicate(($ID.text));

      if (predicate == (Predicate) null)
      {
         System.err.println
         (
            "[F] The property uses an unknown predicate: \""
            + ($ID.text)
            + "\" (l."
            + ($ID.getLine())
            + " c."
            + ($ID.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      ids = ($id_list.list);

      if (current_node != null)
      {
         ids.add(0, current_node);
      }

      $result = predicate.as_formula(ids);
   }
;

function [Variable current_node]
   returns [Expression result]:

   (WS)* L_BRAKT
      ID
      id_list[current_node]
   (WS)* R_BRAKT

   {
      final Expression function_call;
      final List<Expression> ids;
      final Predicate predicate;

      predicate = WORLD.get_predicates_manager().get_predicate(($ID.text));

      if (predicate == (Predicate) null)
      {
         System.err.println
         (
            "[F] The property uses an unknown function: \""
            + ($ID.text)
            + "\" (l."
            + ($ID.getLine())
            + " c."
            + ($ID.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      ids = ($id_list.list);

      if (current_node != null)
      {
         ids.add(0, current_node);
      }

      $result = predicate.as_function(ids);
   }
;

eq_special_predicate [Variable current_node]
   returns [Formula result]:

   (WS)* EQ_SPECIAL_PREDICATE_KW
      a=id_or_string_or_fun[current_node]
      (WS)+ b=id_or_string_or_fun[current_node]
   (WS)* R_PAREN

   {
      $result = new Equals(($a.value), ($b.value));
   }
;

regex_special_predicate [Variable current_node]
   returns [Formula result]:

   (WS)* REGEX_SPECIAL_PREDICATE_KW
      id_or_string_or_fun[current_node]
   (WS)+ STRING
   (WS)* R_PAREN

   {
      final Expression[] params;
      final Predicate string_matches;

      params = new Expression[2];
      string_matches =
         WORLD.get_predicates_manager().get_predicate("string_matches");

      if (string_matches == null)
      {
         WORLD.invalidate();
      }

      params[0] = ($id_or_string_or_fun.value);
      params[1] =
         WORLD.get_strings_manager().get_regex_as_element(($STRING.text));

      if (params[1] == null)
      {
         WORLD.invalidate();
      }

      $result = string_matches.as_formula(params);
   }
;

non_empty_formula_list [Variable current_node]
   returns [List<Formula> list]

   @init
   {
      final List<Formula> result = new ArrayList<Formula>();
   }

   :
   (
      formula[current_node]

      {
         result.add(($formula.result));
      }
   )+

   {
      $list = result;
   }
;

/**** First Order Expressions *************************************************/
and_operator [Variable current_node]
   returns [Formula result]:

   (WS)* AND_OPERATOR_KW
      formula[current_node]
      non_empty_formula_list[current_node]
   (WS)* R_PAREN

   {
      final List<Formula> list;

      list = ($non_empty_formula_list.list);

      list.add(0, ($formula.result));

      $result = Operator.AND.as_formula(list);
   }
;

or_operator [Variable current_node]
   returns [Formula result]:

   (WS)* OR_OPERATOR_KW
      formula[current_node]
      non_empty_formula_list[current_node]
   (WS)* R_PAREN

   {
      final List<Formula> list;

      list = ($non_empty_formula_list.list);

      list.add(0, ($formula.result));

      $result = Operator.OR.as_formula(list);
   }
;

not_operator [Variable current_node]
   returns [Formula result]:

   (WS)* NOT_OPERATOR_KW
      formula[current_node]
   (WS)* R_PAREN

   {
      final List<Formula> list;

      list = new ArrayList<Formula>();

      list.add(($formula.result));

      $result = Operator.NOT.as_formula(list);
   }
;

implies_operator [Variable current_node]
   returns [Formula result]:

   (WS)* IMPLIES_OPERATOR_KW
      a=formula[current_node]
      b=formula[current_node]
   (WS)* R_PAREN

   {
      final List<Formula> list;

      list = new ArrayList<Formula>();

      list.add(($a.result));
      list.add(($b.result));

      $result = Operator.IMPLIES.as_formula(list);
   }
;

iff_operator [Variable current_node]
   returns [Formula result]:

   (WS)* IFF_OPERATOR_KW
      a=formula[current_node]
      b=formula[current_node]
   (WS)* R_PAREN

   {
      final List<Formula> list;

      list = new ArrayList<Formula>();

      list.add(($a.result));
      list.add(($b.result));

      $result = Operator.IFF.as_formula(list);
   }
;

/** Quantified Expressions ****************************************************/
variable_declaration
   returns [Variable variable]:

   var=ID (WS)+ type=ID

   {
      final Type t;

      t = WORLD.get_types_manager().get_type(($type.value));

      if (t == (Type) null)
      {
         System.err.println
         (
            "[F] The property uses an unknown type: \""
            + ($type.text)
            + "\" at (l."
            + ($type.getLine())
            + " c."
            + ($type.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      $variable = WORLD.get_variables_manager().add_variable(t, ($var.value));

      if (($variable) == null)
      {
         WORLD.invalidate();
      }
   }
;

exists_operator [Variable current_node]
   returns [Formula result]:

   (WS)* EXISTS_OPERATOR_KW
      variable_declaration
      formula[current_node]
   (WS*) R_PAREN

   {
      if (current_node != null)
      {
         System.err.println
         (
            "[W] Use of the existential operator inside a \"CTL_verifies\""
            + " operator is not part of HaStABeL's semantics and may not be"
            + " available on some solving platforms. As a result, its use is"
            + " discouraged (from l."
            + ($EXISTS_OPERATOR_KW.getLine())
            + " c."
            + ($EXISTS_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );
      }

      $result =
         new Quantifier
         (
            ($variable_declaration.variable),
            ($formula.result),
            false
         );
   }
;

forall_operator [Variable current_node]
   returns [Formula result]:

   (WS)* FORALL_OPERATOR_KW
      variable_declaration
      formula[current_node]
   (WS*) R_PAREN

   {
      if (current_node != null)
      {
         System.err.println
         (
            "[W] Use of the universal operator inside a \"CTL_verifies\""
            + " operator is not part of HaStABeL's semantics and may not be"
            + " available on some solving platforms. As a result, its use is"
            + " discouraged (from l."
            + ($EXISTS_OPERATOR_KW.getLine())
            + " c."
            + ($EXISTS_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );
      }

      $result =
         new Quantifier
         (
            ($variable_declaration.variable),
            ($formula.result),
            true
         );
   }
;

/** Special Expressions *******************************************************/
ctl_verifies_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable root_node;

      root_node =
         WORLD.get_variables_manager().generate_new_anonymous_variable();

      if (root_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* CTL_VERIFIES_OPERATOR_KW
         ps=ID
         f=formula[root_node]
   (WS)* R_PAREN

   {
      final Variable process;

      if (current_node != null)
      {
         System.err.println
         (
            "[F] The property uses a \"CTL_verifies\" inside a \"CTL_verifies\""
            + " and we have not heard anything about you liking"
            + " \"CTL_verifies\", so you can't CTL_verify while you CTL_verify"
            + " (l."
            + ($CTL_VERIFIES_OPERATOR_KW.getLine())
            + " c."
            + ($CTL_VERIFIES_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      process = WORLD.get_variables_manager().get(($ps.text));

      $result = new CTLVerifies(root_node, process, ($f.result));
   }
;

/**** Computation Tree Logic Expressions **************************************/
ax_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;

      next_node =
         WORLD.get_variables_manager().generate_new_anonymous_variable();

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* AX_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Predicate node_connect;
      final List<Expression> node_connect_params;
      final List<Formula> and_params;

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AX_OPERATOR_KW.getLine())
            + " c."
            + ($AX_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      node_connect = WORLD.get_predicates_manager().get("node_connect");

      if (node_connect == null)
      {
         WORLD.invalidate();
      }

      node_connect_params = new ArrayList<Expression>(2);
      node_connect_params.add(current_node);
      node_connect_params.add(next_node);

      and_params = new ArrayList<Formula>(2);
      and_params.add(node_connect.as_formula(node_connect_params));
      and_params.add(($formula.result));

      $result =
         new Quantifier
         (
            next_node,
            Operator.AND.as_formula(internal),
            true
         );
   }
;

ex_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;

      next_node =
         WORLD.get_variables_manager().generate_new_anonymous_variable();

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* EX_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Predicate node_connect;
      final List<Expression> node_connect_params;
      final List<Formula> and_params;

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AX_OPERATOR_KW.getLine())
            + " c."
            + ($AX_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      node_connect = WORLD.get_predicates_manager().get("node_connect");

      if (node_connect == null)
      {
         WORLD.invalidate();
      }

      node_connect_params = new ArrayList<Expression>(2);
      node_connect_params.add(current_node);
      node_connect_params.add(next_node);

      and_params = new ArrayList<Formula>(2);
      and_params.add(node_connect.as_formula(node_connect_params));
      and_params.add(($formula.result));

      $result =
         new Quantifier
         (
            next_node,
            Operator.AND.as_formula(internal),
            false
         );
   }
;

ag_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;

      next_node =
         WORLD.get_variables_manager().generate_new_anonymous_variable();

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }:

   (WS)* AG_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Predicate node_connect;
      final List<Expression> node_connect_params;
      final List<Formula> and_params;

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AX_OPERATOR_KW.getLine())
            + " c."
            + ($AX_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      node_connect = WORLD.get_predicates_manager().get("contains_node");

      if (node_connect == null)
      {
         WORLD.invalidate();
      }

      node_connect_params = new ArrayList<Expression>(2);
      node_connect_params.add(current_node);
      node_connect_params.add(next_node);

      and_params = new ArrayList<Formula>(2);
      and_params.add(node_connect.as_formula(node_connect_params));
      and_params.add(($formula.result));

      $result =
         new Quantifier
         (
            next_node,
            Operator.AND.as_formula(internal),
            true
         );

      //////////////////////////////////////////////////////////////////////////
      $result =
         ($formula.result).forAll
         (
            next_node.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose() /* (is_path_of path node), we want the path. */
               ).join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         );
   }
;

eg_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node, chosen_path;

      next_node = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* EG_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($EG_OPERATOR_KW.getLine())
            + " c."
            + ($EG_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         ($formula.result).forAll
         (
            next_node.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forSome
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose() /* (is_path_of path node), we want the path. */
               )
            )
         );
   }
;

af_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node, chosen_path;

      next_node = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* AF_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AF_OPERATOR_KW.getLine())
            + " c."
            + ($AF_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         ($formula.result).forSome
         (
            next_node.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forAll
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose() /* (is_path_of path node), we want the path. */
               )
            )
         );
   }
;

ef_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node, chosen_path;

      next_node = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* EF_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($EF_OPERATOR_KW.getLine())
            + " c."
            + ($EF_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         ($formula.result).forSome
         (
            next_node.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forSome
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose() /* (is_path_of path node), we want the path. */
               )
            )
         );
   }
;

au_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable f1_node, f2_node, chosen_path;

      f1_node = Main.get_variable_manager().generate_new_anonymous_variable();
      f2_node = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* AU_OPERATOR_KW
      f1=formula[f1_node]
      f2=formula[f2_node]
   (WS)* R_PAREN

   {
      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AU_OPERATOR_KW.getLine())
            + " c."
            + ($AU_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         ($f1.result).forAll
         (
            f1_node.oneOf
            (
               f2_node.join
               (
                  chosen_path.join
                  (
                     Main.get_model().get_predicate_as_relation("is_before")
                  ).transpose()
               )
            )
         ).and
         (
            ($f2.result)
         ).forSome
         (
            f2_node.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forAll
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose()
               )
            )
         );
   }
;

eu_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable f1_node, f2_node, chosen_path;

      f1_node = Main.get_variable_manager().generate_new_anonymous_variable();
      f2_node = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* EU_OPERATOR_KW
      f1=formula[f1_node]
      f2=formula[f2_node]
   (WS)* R_PAREN

   {
      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($EU_OPERATOR_KW.getLine())
            + " c."
            + ($EU_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         ($f1.result).forAll
         (
            f1_node.oneOf
            (
               f2_node.join
               (
                  chosen_path.join
                  (
                     Main.get_model().get_predicate_as_relation("is_before")
                  ).transpose()
               )
            )
         ).and(
            ($f2.result)
         ).forSome
         (
            f2_node.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forSome
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose()
               )
            )
         );
   }
;

/**** Depth Operators *********************************************************/
depth_no_parent_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable node_of_path, node_for_f, chosen_path;

      node_of_path = Main.get_variable_manager().generate_new_anonymous_variable();
      node_for_f = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* DEPTH_NO_PARENT_OPERATOR_KW
      formula[node_for_f]
   (WS)* R_PAREN

   {
      final Predicate depth_relation, lower_than_relation;

      depth_relation = Main.get_model().get_predicate_as_relation("depth");
      lower_than_relation = Main.get_model().get_predicate_as_relation("depth");

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($DEPTH_NO_PARENT_OPERATOR_KW.getLine())
            + " c."
            + ($DEPTH_NO_PARENT_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         node_of_path.join
         (
            depth_relation
         ).product
         (
            current_node.join(depth_relation)
         ).in
         (
            lower_than_relation
         ).not
         (
            /* (not (is_lower_than [depth node_of_path] [depth current_node])) */
         ).forAll
         (
            node_of_path.oneOf
            (
               node_for_f.join
               (
                  chosen_path.join
                  (
                     Main.get_model().get_predicate_as_relation("is_before")
                  ).transpose()
               )
            )
         ).and
         (
            ($formula.result).and
            (
               current_node.join
               (
                  depth_relation
               ).product
               (
                  node_for_f
               ).in
               (
                  lower_than_relation
               ).not()
            )
         ).forSome
         (
            node_for_f.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forAll
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose()
               )
            )
         );
   }
;

depth_no_change_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable node_of_path, node_for_f, chosen_path;

      node_of_path = Main.get_variable_manager().generate_new_anonymous_variable();
      node_for_f = Main.get_variable_manager().generate_new_anonymous_variable();
      chosen_path = Main.get_variable_manager().generate_new_anonymous_variable();
   }

   :
   (WS)* DEPTH_NO_CHANGE_OPERATOR_KW
      formula[node_for_f]
   (WS)* R_PAREN

   {
      final Predicate depth_relation;

      depth_relation = Main.get_model().get_predicate_as_relation("depth");

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($DEPTH_NO_CHANGE_OPERATOR_KW.getLine())
            + " c."
            + ($DEPTH_NO_CHANGE_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         System.exit(-1);
      }

      $result =
         node_of_path.join
         (
            depth_relation
         ).eq
         (
            node_for_f.join(depth_relation)
         /* (eq? [depth node_of_path] [depth node_for_f]) */
         ).forAll
         (
            node_of_path.oneOf
            (
               node_for_f.join
               (
                  chosen_path.join
                  (
                     Main.get_model().get_predicate_as_relation("is_before")
                  ).transpose()
               )
            )
         ).and
         (
            ($formula.result)
         ).forSome
         (
            node_for_f.oneOf
            (
               chosen_path.join
               (
                  Main.get_model().get_predicate_as_relation("contains_node")
               )
            )
         ).forAll
         (
            chosen_path.oneOf
            (
               current_node.join
               (
                  Main.get_model().get_predicate_as_relation
                  (
                     "is_path_of"
                  ).transpose()
               )
            )
         );
   }
;

/**** Formula Definition ******************************************************/
formula [Variable current_node]
   returns [Formula result]:

   predicate[current_node]
   {
      $result = ($predicate.result);
   }

   | eq_special_predicate[current_node]
   {
      $result = ($eq_special_predicate.result);
   }

   | regex_special_predicate[current_node]
   {
      $result = ($regex_special_predicate.result);
   }

   | and_operator[current_node]
   {
      $result = ($and_operator.result);
   }

   | or_operator[current_node]
   {
      $result = ($or_operator.result);
   }

   | not_operator[current_node]
   {
      $result = ($not_operator.result);
   }

   | iff_operator[current_node]
   {
      $result = ($iff_operator.result);
   }

   | implies_operator[current_node]
   {
      $result = ($implies_operator.result);
   }

   | exists_operator[current_node]
   {
      $result = ($exists_operator.result);
   }

   | forall_operator[current_node]
   {
      $result = ($forall_operator.result);
   }

   | ctl_verifies_operator[current_node]
   {
      $result = ($ctl_verifies_operator.result);
   }

   | ax_operator[current_node]
   {
      $result = ($ax_operator.result);
   }

   | ex_operator[current_node]
   {
      $result = ($ex_operator.result);
   }

   | ag_operator[current_node]
   {
      $result = ($ag_operator.result);
   }

   | eg_operator[current_node]
   {
      $result = ($eg_operator.result);
   }

   | af_operator[current_node]
   {
      $result = ($af_operator.result);
   }

   | ef_operator[current_node]
   {
      $result = ($ef_operator.result);
   }

   | au_operator[current_node]
   {
      $result = ($au_operator.result);
   }

   | eu_operator[current_node]
   {
      $result = ($eu_operator.result);
   }

   | depth_no_parent_operator[current_node]
   {
      $result = ($depth_no_parent_operator.result);
   }

   | depth_no_change_operator[current_node]
   {
      $result = ($depth_no_change_operator.result);
   }
;
