parser grammar PropertyParser;

options
{
   tokenVocab = PropertyLexer;
}

@header
{
   package hastabel;

   import hastabel.World;
   import hastabel.lang.*;

   import java.util.Arrays;
   import java.util.ArrayList;
   import java.util.List;
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

      t.mark_as_used();

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
         System.err.println
         (
            "[E] The use of an joker is not allowed here (l."
            + ($ID.getLine())
            + " c."
            + ($ID.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }
      else
      {
         $value = WORLD.get_variables_manager().get(($ID.text));

         if (($value) == null)
         {
            WORLD.invalidate();
         }
      }
   }

   |
   STRING
   {
      final Type string_type;

      $value =
         WORLD.get_strings_manager().get_string_as_element(($STRING.text));

      string_type = WORLD.get_types_manager().get("string");

      if ((($value) == null) || (string_type == null))
      {
         WORLD.invalidate();
      }

      string_type.mark_as_used();
   }

   |
   function[current_node]
   {
      $value = ($function.result);
   }
;

id_or_string_or_fun_or_joker [Variable current_node]
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
         $value = WORLD.get_variables_manager().get(($ID.text));

         if (($value) == null)
         {
            WORLD.invalidate();
         }
      }
   }

   |
   STRING
   {
      final Type string_type;

      $value =
         WORLD.get_strings_manager().get_string_as_element(($STRING.text));

      string_type = WORLD.get_types_manager().get("string");

      if ((($value) == null) || (string_type == null))
      {
         WORLD.invalidate();
      }

      string_type.mark_as_used();
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

id_or_joker_list [Variable current_node]
   returns [List<Expression> list]

   @init
   {
      final List<Expression> result = new ArrayList<Expression>();
   }

   :
   (
      (WS)+
      id_or_string_or_fun_or_joker[current_node]
      {
         result.add(($id_or_string_or_fun_or_joker.value));
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
      id_or_joker_list[current_node]
   (WS)* R_PAREN

   {
      final Expression expression;
      final List<Expression> ids;
      final hastabel.lang.Predicate predicate;

      predicate = WORLD.get_predicates_manager().get(($ID.text));

      if (predicate == (hastabel.lang.Predicate) null)
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

      ids = ($id_or_joker_list.list);

      if (current_node != null)
      {
         ids.add(0, current_node);
      }

      predicate.mark_as_used();

      $result = predicate.as_partial_formula(ids);
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
      final hastabel.lang.Predicate predicate;

      predicate = WORLD.get_predicates_manager().get(($ID.text));

      if (predicate == (hastabel.lang.Predicate) null)
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

      predicate.mark_as_used_as_function();

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
      final Type string_type;
      final Expression[] params;
      final hastabel.lang.Predicate string_matches;

      params = new Expression[2];
      string_type = WORLD.get_types_manager().get("string");
      string_matches =
         WORLD.get_predicates_manager().get("string_matches");

      if ((string_type == null) || (string_matches == null))
      {
         WORLD.invalidate();
      }

      string_type.mark_as_used();
      string_matches.mark_as_used();

      params[0] = ($id_or_string_or_fun.value);
      params[1] =
         WORLD.get_strings_manager().get_regex_as_element(($STRING.text));

      if (params[1] == null)
      {
         WORLD.invalidate();
      }


      $result = string_matches.as_formula(Arrays.asList(params));
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
      $result = Operator.NOT.as_formula_(($formula.result));
   }
;

implies_operator [Variable current_node]
   returns [Formula result]:

   (WS)* IMPLIES_OPERATOR_KW
      a=formula[current_node]
      b=formula[current_node]
   (WS)* R_PAREN

   {
      $result = Operator.IMPLIES.as_formula_(($a.result), ($b.result));
   }
;

iff_operator [Variable current_node]
   returns [Formula result]:

   (WS)* IFF_OPERATOR_KW
      a=formula[current_node]
      b=formula[current_node]
   (WS)* R_PAREN

   {
      $result = Operator.IFF.as_formula_(($a.result), ($b.result));
   }
;

/** Quantified Expressions ****************************************************/
variable_declaration
   returns [Variable variable]:

   var=ID (WS)+ type=ID

   {
      final Type t;

      t = WORLD.get_types_manager().get(($type.text));

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

      t.mark_as_used();
      $variable = WORLD.get_variables_manager().add_variable(t, ($var.text));

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
            + ($FORALL_OPERATOR_KW.getLine())
            + " c."
            + ($FORALL_OPERATOR_KW.getCharPositionInLine())
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
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      root_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

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
      final hastabel.lang.Predicate is_start_node;
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

      is_start_node = WORLD.get_predicates_manager().get("is_start_node");

      if (is_start_node == null)
      {
         WORLD.invalidate();
      }

      is_start_node.mark_as_used();

      process = WORLD.get_variables_manager().get(($ps.text));

      $result =
         Formula.exists
         (
            root_node,
            Formula.and
            (
               is_start_node.as_formula_(root_node, process),
               ($f.result)
            )
         );
   }
;

/**** Computation Tree Logic Expressions **************************************/
ax_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

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
      final hastabel.lang.Predicate node_connect;

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

      node_connect.mark_as_used();

      $result =
         Formula.forall
         (
            next_node,
            Formula.and
            (
               node_connect.as_formula_(current_node, next_node),
               ($formula.result)
            )
         );
   }
;

ex_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

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
      final hastabel.lang.Predicate node_connect;

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($EX_OPERATOR_KW.getLine())
            + " c."
            + ($EX_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      node_connect = WORLD.get_predicates_manager().get("node_connect");

      if (node_connect == null)
      {
         WORLD.invalidate();
      }

      node_connect.mark_as_used();

      $result =
         Formula.exists
         (
            next_node,
            Formula.and
            (
               node_connect.as_formula_(current_node, next_node),
               ($formula.result)
            )
         );
   }
;

ag_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }:

   (WS)* AG_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate contains_node, is_path_of;

      if (current_node == null)
      {
         System.err.println
         (
            "[F] The property uses a CTL operator outside of a \"CTL_verifies\""
            + " (l."
            + ($AG_OPERATOR_KW.getLine())
            + " c."
            + ($AG_OPERATOR_KW.getCharPositionInLine())
            + ")."
         );

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");

      if ((path_type == null) || (is_path_of == null) || (contains_node == null))
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.forall
         (
            next_path,
            Formula.implies
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.forall
               (
                  next_node,
                  Formula.implies
                  (
                     contains_node.as_formula_(next_path, next_node),
                     ($formula.result)
                  )
               )
            )
         );
   }
;

eg_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* EG_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate contains_node, is_path_of;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");

      if ((path_type == null) || (is_path_of == null) || (contains_node == null))
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.exists
         (
            next_path,
            Formula.and
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.forall
               (
                  next_node,
                  Formula.implies
                  (
                     contains_node.as_formula_(next_path, next_node),
                     ($formula.result)
                  )
               )
            )
         );
   }
;

af_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* AF_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate contains_node, is_path_of;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");

      if ((path_type == null) || (is_path_of == null) || (contains_node == null))
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();


      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.forall
         (
            next_path,
            Formula.implies
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  next_node,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, next_node),
                     ($formula.result)
                  )
               )
            )
         );
   }
;

ef_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable next_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      next_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (next_node == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* EF_OPERATOR_KW
      formula[next_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate contains_node, is_path_of;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");

      if ((path_type == null) || (is_path_of == null) || (contains_node == null))
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.exists
         (
            next_path,
            Formula.and
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  next_node,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, next_node),
                     ($formula.result)
                  )
               )
            )
         );
   }
;

au_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable f1_node, f2_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      f1_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      f2_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if ((f1_node == null) || (f2_node == null))
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* AU_OPERATOR_KW
      f1=formula[f1_node]
      f2=formula[f2_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate is_path_of, contains_node, is_before;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_before = WORLD.get_predicates_manager().get("is_before");

      if
      (
         (path_type == null)
         || (is_path_of == null)
         || (contains_node == null)
         || (is_before == null)
      )
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();
      is_before.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.forall
         (
            next_path,
            Formula.implies
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  f2_node,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, f2_node),
                     ($f2.result),
                     Formula.forall
                     (
                        f1_node,
                        Formula.implies
                        (
                           is_before.as_formula_(next_path, f1_node, f2_node),
                           ($f1.result)
                        )
                     )
                  )
               )
            )
         );
   }
;

eu_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable f1_node, f2_node;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      f1_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      f2_node =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if ((f1_node == null) || (f2_node == null))
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* EU_OPERATOR_KW
      f1=formula[f1_node]
      f2=formula[f2_node]
   (WS)* R_PAREN

   {
      final Type path_type;
      final Variable next_path;
      final hastabel.lang.Predicate is_path_of, contains_node, is_before;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_before = WORLD.get_predicates_manager().get("is_before");

      if
      (
         (path_type == null)
         || (is_path_of == null)
         || (contains_node == null)
         || (is_before == null)
      )
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();
      is_before.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      if (next_path == null)
      {
         WORLD.invalidate();
      }

      $result =
         Formula.exists
         (
            next_path,
            Formula.and
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  f2_node,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, f2_node),
                     ($f2.result),
                     Formula.forall
                     (
                        f1_node,
                        Formula.implies
                        (
                           is_before.as_formula_(next_path, f1_node, f2_node),
                           ($f1.result)
                        )
                     )
                  )
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
      final Variable node_for_f;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_type.mark_as_used();

      node_for_f =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (node_for_f == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* DEPTH_NO_PARENT_OPERATOR_KW
      formula[node_for_f]
   (WS)* R_PAREN

   {
      final Type path_type, depth_type;
      final Variable next_path, node_of_path;
      final hastabel.lang.Predicate depth, is_path_of, is_lower_than, contains_node, is_before;

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

         WORLD.invalidate();
      }

      path_type = WORLD.get_types_manager().get("path");
      depth_type = WORLD.get_types_manager().get("depth");
      depth = WORLD.get_predicates_manager().get("depth");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_before = WORLD.get_predicates_manager().get("is_before");
      is_lower_than = WORLD.get_predicates_manager().get("is_lower_than");

      if
      (
         (path_type == null)
         || (is_path_of == null)
         || (contains_node == null)
         || (is_lower_than == null)
         || (is_before == null)
         || (depth == null)
      )
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      depth_type.mark_as_used();
      depth.mark_as_used_as_function();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();
      is_before.mark_as_used();
      is_lower_than.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      node_of_path =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if ((next_path == null) || (node_of_path == null))
      {
         WORLD.invalidate();
      }

      $result =
         Formula.forall
         (
            next_path,
            Formula.implies
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  node_for_f,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, node_for_f),
                     ($formula.result),
                     Formula.not
                     (
                        is_lower_than.as_formula_
                        (
                           depth.as_function_(node_for_f),
                           depth.as_function_(current_node)
                        )
                     ),
                     Formula.forall
                     (
                        node_of_path,
                        Formula.implies
                        (
                           is_before.as_formula_
                           (
                              next_path,
                              node_of_path,
                              node_for_f
                           ),
                           Formula.not
                           (
                              is_lower_than.as_formula_
                              (
                                 depth.as_function_(node_of_path),
                                 depth.as_function_(current_node)
                              )
                           )
                        )
                     )
                  )
               )
            )
         );
   }
;

depth_no_change_operator [Variable current_node]
   returns [Formula result]

   @init
   {
      final Variable node_for_f;
      final Type node_type;

      node_type = WORLD.get_types_manager().get("node");

      if (node_type == null)
      {
         WORLD.invalidate();
      }

      node_for_f =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if (node_for_f == null)
      {
         WORLD.invalidate();
      }
   }

   :
   (WS)* DEPTH_NO_CHANGE_OPERATOR_KW
      formula[node_for_f]
   (WS)* R_PAREN

   {
      final Type path_type, depth_type;
      final Variable next_path, node_of_path;
      final hastabel.lang.Predicate depth, is_path_of, contains_node, is_before;

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

      path_type = WORLD.get_types_manager().get("path");
      depth_type = WORLD.get_types_manager().get("path");
      depth = WORLD.get_predicates_manager().get("depth");
      is_path_of = WORLD.get_predicates_manager().get("is_path_of");
      contains_node = WORLD.get_predicates_manager().get("contains_node");
      is_before = WORLD.get_predicates_manager().get("is_before");

      if
      (
         (path_type == null)
         || (is_path_of == null)
         || (contains_node == null)
         || (is_before == null)
         || (depth == null)
      )
      {
         WORLD.invalidate();
      }

      path_type.mark_as_used();
      depth_type.mark_as_used();
      depth.mark_as_used_as_function();
      contains_node.mark_as_used();
      is_path_of.mark_as_used();
      is_before.mark_as_used();

      next_path =
         WORLD.get_variables_manager().new_anonymous_variable(path_type);

      node_of_path =
         WORLD.get_variables_manager().new_anonymous_variable(node_type);

      if ((next_path == null) || (node_of_path == null))
      {
         WORLD.invalidate();
      }

      $result =
         Formula.forall
         (
            next_path,
            Formula.implies
            (
               is_path_of.as_formula_(next_path, current_node),
               Formula.exists
               (
                  node_for_f,
                  Formula.and
                  (
                     contains_node.as_formula_(next_path, node_for_f),
                     ($formula.result),
                     Formula.equals
                     (
                        depth.as_function_(node_for_f),
                        depth.as_function_(current_node)
                     ),
                     Formula.forall
                     (
                        node_of_path,
                        Formula.implies
                        (
                           is_before.as_formula_
                           (
                              next_path,
                              node_of_path,
                              node_for_f
                           ),
                           Formula.equals
                           (
                              depth.as_function_(node_of_path),
                              depth.as_function_(current_node)
                           )
                        )
                     )
                  )
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
