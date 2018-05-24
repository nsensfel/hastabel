parser grammar LangParser;

options
{
   tokenVocab = LangLexer;
}

@header
{
   package hastabel;

   import hastabel.lang.Predicate;
   import hastabel.lang.Element;
   import hastabel.lang.Type;
}

@members
{
   World WORLD;
   /* of the class */
}

lang_file [World init_world]

   @init
   {
      WORLD = init_world;
   }:

   (lang_instr)*
   {
   }
;

lang_instr:
   (WS)* ADD_TYPE_KW (WS)* new_type (WS)*
   {
   }

   | (WS)* ADD_RELATION_KW (WS)* new_predicate (WS)*
   {
   }

   | (WS)* ADD_TEMPLATE_KW (WS)* new_template (WS)*
   {
   }

   | (WS)* ID (WS)* L_PAREN (WS)* ident_list (WS*) R_PAREN (WS)*
   {
      final Predicate predicate;
      final List<Element> params;
      final Iterator<String> param_names;

      predicate = WORLD.get_predicates_manager().get(($ID.text));

      if (predicate == null)
      {
         WORLD.invalidate();
      }
      else
      {
         params = new ArrayList<Element>();

         param_names = ($ident_list.list).iterator();

         while (param_names.hasNext())
         {
            params.add(WORLD.get_elements_manager().get(param_names.next()));
         }

         predicate.add_member(params);
      }
   }

   | (WS)* ID (WS)+ ident_list (WS)*
   {
      final Type type;
      final Iterator<String> elem_names;

      type = WORLD.get_types_manager().get(($ID.text));

      if (type == null)
      {
         WORLD.invalidate();
      }
      else
      {
         elem_names = ($ident_list.list).iterator();

         while (elem_names.hasNext())
         {
            WORLD.get_elements_manager().declare(type, elem_names.next());
         }
      }
   }

   | (WS)* STAR (WS)* ID (WS)+ ident_list (WS)*
   {
      final Template subtemplate;
      final Iterator<String> elem_names;

      subtemplate = WORLD.get_templates_manager().get(($ID.text));

      if (subtemplate == null)
      {
         WORLD.invalidate();
      }
      else
      {
         elem_names = ($ident_list.list).iterator();

         while (elem_names.hasNext())
         {
            final TemplateInstance ti;

            ti =
               WORLD.get_template_instances_manager().declare
               (
                  subtemplate,
                  elem_names.next()
               );

            ti.add_contents_to
            (
               WORLD.get_elements_manager(),
               WORLD.get_predicates_manager()
            );
         }
      }
   }
;

new_type:
   parent=ID (WS)* SUB_TYPE_OF (WS)* type=ID
   {
      final Type parent_type;

      parent_type = WORLD.get_types_manager().get(($parent.text));

      WORLD.get_types_manager().declare(parent_type, ($type.text));
   }

   | ID
   {
      WORLD.get_types_manager().declare(null, ($ID.text));
   }
;

new_predicate:
   ID (WS)* L_PAREN (WS)* ident_list (WS)* R_PAREN
   {
      final List<Type> signature;
      final Iterator<String> type_names;

      signature = new ArrayList<Type>();

      type_names = ($ident_list.list).iterator();

      while (type_names.hasNext())
      {
         signature.add(WORLD.get_types_manager().get(type_names.next()));
      }

      WORLD.get_predicates_manager().declare(signature, ($ID.text));
   }
;

new_template
   @init
   {
      Template template;
   }:

   ID { template = WORLD.get_templates_manager().declare(WORLD, ($ID.text)); }
   (WS)* L_BRAKT (WS)* (template_instr[template])* (WS)* R_BRAKT
   {
   }
;

template_instr [Template template]:
   (WS)* ID (WS)* L_PAREN (WS)* ident_list (WS*) R_PAREN (WS)*
   {
      final Predicate predicate;
      final List<Element> params;
      final Iterator<String> param_names;

      predicate =
         template.get_predicates_manager().get_or_duplicate(($ID.text));

      if (predicate == null)
      {
         WORLD.invalidate();
      }
      else
      {
         params = new ArrayList<Element>();

         param_names = ($ident_list.list).iterator();

         while (param_names.hasNext())
         {
            params.add(template.get_elements_manager().get(param_names.next()));
         }

         predicate.add_member(params);
      }
   }

   | (WS)* ID (WS)+ ident_list (WS)*
   {
      final Type type;
      final Iterator<String> elem_names;

      type = WORLD.get_types_manager().get(($ID.text));

      if (type == null)
      {
         WORLD.invalidate();
      }
      else
      {
         elem_names = ($ident_list.list).iterator();

         while (elem_names.hasNext())
         {
            template.get_elements_manager().declare(type, elem_names.next());
         }
      }
   }

   | (WS)* STAR (WS)* ID (WS)+ ident_list (WS)*
   {
      final Template subtemplate;
      final Iterator<String> elem_names;

      subtemplate = WORLD.get_templates_manager().get(($ID.text));

      if (subtemplate == null)
      {
         WORLD.invalidate();
      }
      else
      {
         elem_names = ($ident_list.list).iterator();

         while (elem_names.hasNext())
         {
            final TemplateInstance ti;

            ti = template.get_template_instances_manager().declare
               (
                  subtemplate,
                  elem_names.next()
               );

            ti.add_contents_to(template);
         }
      }
   }
;

ident_list returns [List<String> list]
   @init
   {
      final List<String> result = new ArrayList<String>();
   }

   :
   first_element=ID
   (
      (WS)* COMMA (WS)* next_element=ID
      {
         result.add(($next_element.text).replaceAll("\\.", "__"));
      }
   )*
   {
      result.add(0, ($first_element.text).replaceAll("\\.", "__"));

      $list = result;
   }
;
