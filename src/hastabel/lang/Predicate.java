package hastabel.lang;

import java.util.Collection;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;
import java.util.ArrayList;

public class Predicate
{
   private final Collection<List<Type>> signatures;
   private final Collection<List<Type>> partial_signatures;
   private final Type function_type;
   private final Set<List<Element>> members;
   private final String name;
   private List<String> naming;
   private boolean can_be_used_as_function;
   private boolean is_used_as_predicate, is_used_as_function;

   public Predicate
   (
      final List<Type> signature,
      final String name,
      final boolean can_be_used_as_function
   )
   {
      partial_signatures = new ArrayList<List<Type>>(0);
      signatures = new ArrayList<List<Type>>(1);
      signatures.add(signature);

      this.function_type = signature.get(signature.size() - 1);
      this.name = name;
      this.can_be_used_as_function = can_be_used_as_function;

      members = new HashSet<List<Element>>();

      is_used_as_predicate = false;
      is_used_as_function = false;
   }

   public Predicate
   (
      final Predicate source
   )
   {
      signatures = new ArrayList<List<Type>>();
      signatures.addAll(source.signatures);

      partial_signatures = new ArrayList<List<Type>>(0);
      partial_signatures.addAll(source.partial_signatures);

      name = source.name;
      function_type = source.function_type;

      members = new HashSet<List<Element>>();

      can_be_used_as_function = source.can_be_used_as_function;
      is_used_as_predicate = source.is_used_as_predicate;
      is_used_as_function = source.is_used_as_function;
   }

   public void add_member (final List<Element> elements)
   {
      if (is_compatible_with2(elements) != null)
      {
         members.add(elements);
      }
      else
      {
         System.err.print
         (
            "[E] The predicate "
            + name
            + " has no signatures accepting ("
         );

         for (final Element elt: elements)
         {
            System.err.print(" " + elt.get_name());
         }

         System.err.println(").");
      }
   }

   public Type get_function_type ()
   {
      return function_type;
   }

   public void add_member_ (final Element... elements)
   {
      final ArrayList<Element> params;

      params = new ArrayList<Element>();

      for (final Element e: elements)
      {
         params.add(e);
      }

      add_member(params);
   }

   public void set_naming (final List<String> naming)
   {
      this.naming = naming;
   }

   public List<String> get_naming ()
   {
      return naming;
   }

   private boolean add_partial_signature
   (
      final List<Type> partial_signature
   )
   {
      boolean can_be_added;

      can_be_added = false;

      for (final List<Type> signature: signatures)
      {
         if (is_compatible_with_partial_signature(signature, partial_signature))
         {
            can_be_added = true;

            break;
         }
      }

      if (can_be_added)
      {
         partial_signatures.add(partial_signature);
      }

      return can_be_added;
   }

   private boolean is_compatible_with_partial_signature
   (
      final List<Type> signature,
      final List<Type> partial_signature
   )
   {
      final Iterator<Type> e_iter;
      final Iterator<Type> s_iter;

      if (partial_signature.size() != signature.size())
      {
         return false;
      }

      e_iter = partial_signature.iterator();
      s_iter = signature.iterator();

      while (e_iter.hasNext())
      {
         final Type e_next, s_next;

         e_next = e_iter.next();
         s_next = s_iter.next();

         if (e_next == null)
         {
            continue;
         }
         else if (!s_next.includes(e_next))
         {
            return false;
         }
      }

      return true;
   }

   private boolean is_compatible_with_signature
   (
      final List<Expression> elements,
      final List<Type> signature
   )
   {
      final Iterator<Expression> e_iter;
      final Iterator<Type> s_iter;

      if (elements.size() != signature.size())
      {
         return false;
      }

      e_iter = elements.iterator();
      s_iter = signature.iterator();

      while (e_iter.hasNext())
      {
         if (!s_iter.next().includes(e_iter.next().get_type()))
         {
            return false;
         }
      }

      return true;
   }

   private boolean is_compatible_with_fun_signature
   (
      final List<Expression> elements,
      final List<Type> signature
   )
   {
      final Iterator<Expression> e_iter;
      final Iterator<Type> s_iter;

      if (elements.size() != (signature.size() - 1))
      {
         return false;
      }

      e_iter = elements.iterator();
      s_iter = signature.iterator();

      while (e_iter.hasNext())
      {
         if (!s_iter.next().includes(e_iter.next().get_type()))
         {
            return false;
         }
      }

      return true;
   }

   // "incompatible types: List<Element> cannot be converted to List<Expression>"
   private boolean is_compatible_with_signature2
   (
      final List<Element> elements,
      final List<Type> signature
   )
   {
      final Iterator<Element> e_iter;
      final Iterator<Type> s_iter;

      if (elements.size() != signature.size())
      {
         return false;
      }

      e_iter = elements.iterator();
      s_iter = signature.iterator();

      while (e_iter.hasNext())
      {
         if (!s_iter.next().includes(e_iter.next().get_type()))
         {
            return false;
         }
      }

      return true;
   }

   private List<Element> mask_through_partial_signature
   (
      final List<Element> elements,
      final List<Type> signature
   )
   {
      final List<Element> result;
      final Iterator<Element> e_iter;
      final Iterator<Type> s_iter;

      if (elements.size() != signature.size())
      {
         return null;
      }

      result = new ArrayList<Element>();
      e_iter = elements.iterator();
      s_iter = signature.iterator();

      while (e_iter.hasNext())
      {
         final Type s_next;
         final Element e_next;

         e_next = e_iter.next();
         s_next = s_iter.next();

         if (s_next == null)
         {
            continue;
         }
         else if (!s_next.includes(e_next.get_type()))
         {
            return null;
         }
         else
         {
            result.add(e_next);
         }
      }

      return result;
   }

   public List<Type> is_compatible_with (final List<Expression> elements)
   {
      for (final List<Type> signature: signatures)
      {
         if (is_compatible_with_signature(elements, signature))
         {
            return signature;
         }
      }

      return null;
   }

   // "incompatible types: List<Element> cannot be converted to List<Expression>"
   public List<Type> is_compatible_with2 (final List<Element> elements)
   {
      for (final List<Type> signature: signatures)
      {
         if (is_compatible_with_signature2(elements, signature))
         {
            return signature;
         }
      }

      return null;
   }

   public String get_name ()
   {
      return name;
   }

   public Collection<List<Type>> get_signatures ()
   {
      return signatures;
   }

   public Collection<List<Type>> get_partial_signatures ()
   {
      return partial_signatures;
   }

   public Set<List<Element>> get_members ()
   {
      return members;
   }

   public Set<List<Type>> get_relevant_signatures ()
   {
      final Set<List<Type>> result;

      result = new HashSet<List<Type>>();

      for (final List<Type> signature: signatures)
      {
         boolean relevant_signature;

         relevant_signature = true;

         for (final Type sig_type: signature)
         {
            if (!sig_type.is_used())
            {
               relevant_signature = false;

               break;
            }
         }

         if (relevant_signature)
         {
            result.add(signature);
         }
      }

      return result;
   }

   public Set<List<Element>> get_relevant_members
   (
      final List<Type> signature
   )
   {
      final Set<List<Element>> result;

      result = new HashSet<List<Element>>();

      for (final List<Element> member: members)
      {
         if (is_compatible_with_signature2(member, signature))
         {
            result.add(member);
         }
      }

      return result;
   }
   public Set<List<Element>> get_relevant_members
   (
      final Set<List<Type>> relevant_signatures
   )
   {
      final Set<List<Element>> result;

      Set<List<Element>> current_members, next_members;

      next_members = members;

      result = new HashSet<List<Element>>();

      for (final List<Type> signature: relevant_signatures)
      {
         current_members = next_members;

         next_members = new HashSet<List<Element>>();

         for (final List<Element> member: current_members)
         {
            if (is_compatible_with_signature2(member, signature))
            {
               result.add(member);
            }
            else
            {
               next_members.add(member);
            }
         }
      }

      return result;
   }

   public Set<List<Element>> get_relevant_partial_members
   (
      final Set<List<Type>> relevant_signatures
   )
   {
      final Set<List<Element>> result;

      result = new HashSet<List<Element>>();

      for (final List<Type> signature: relevant_signatures)
      {
         for (final List<Element> member: members)
         {
            final List<Element> potential_member;

            potential_member =
               mask_through_partial_signature(member, signature);

            if (potential_member != null)
            {
               result.add(potential_member);
            }
         }
      }

      return result;
   }

   public Set<List<Element>> get_relevant_partial_members
   (
      final List<Type> signature
   )
   {
      final Set<List<Element>> result;

      result = new HashSet<List<Element>>();

      for (final List<Element> member: members)
      {
         final List<Element> potential_member;

         potential_member =
            mask_through_partial_signature(member, signature);

         if (potential_member != null)
         {
            result.add(potential_member);
         }
      }

      return result;
   }

   public Predicate shallow_copy ()
   {
      return new Predicate(this);
   }

   @Override
   public boolean equals (Object o)
   {
      final Predicate e;

      if ((o == null) || !(o instanceof Predicate))
      {
         return false;
      }

      e = (Predicate) o;

      return (e.name.equals(name));
   }

   @Override
   public int hashCode ()
   {
      return name.hashCode();
   }

   public void add_signature (final List<Type> signature)
   {
      signatures.add(signature);
   }

   public String get_definition ()
   {
      final StringBuilder sb;

      sb = new StringBuilder();

      sb.append(toString());
      sb.append("\n");

      for (final List<Element> params: members)
      {
         sb.append(name);
         sb.append("(");

         for (final Element param: params)
         {
            sb.append(param.get_name());
            sb.append(", ");
         }

         sb.append(")\n");
      }

      return sb.toString();
   }

   public Formula as_partial_formula (final List<Expression> params)
   {
      final List<Type> partial_signature;
      boolean is_partial;

      is_partial = false;

      partial_signature = new ArrayList<Type>();

      for (final Expression param: params)
      {
         if (param == null)
         {
            partial_signature.add(null);

            is_partial = true;
         }
         else
         {
            partial_signature.add(param.get_type());
         }
      }

      if (is_partial)
      {
         if (!add_partial_signature(partial_signature))
         {
            System.err.println
            (
               "[E][FIXME] Can't report that no signature was found that could"
               + " support partial signature."
            );
         }

         return new PredicateFormula(this, partial_signature, params);
      }

      return as_formula(params);
   }

   public void mark_as_used ()
   {
      is_used_as_predicate = true;
   }

   public void mark_as_used_as_function ()
   {
      for (final List<Type> signature: signatures)
      {
         signature.get(signature.size() - 1).mark_as_used();
      }

      is_used_as_function = true;
   }

   public void mark_as_function ()
   {
      can_be_used_as_function = true;
   }

   public boolean is_used ()
   {
      return (is_used_as_predicate || is_used_as_function);
   }

   public boolean is_used_as_predicate ()
   {
      return is_used_as_predicate;
   }

   public boolean is_used_as_function ()
   {
      return is_used_as_function;
   }

   @Override
   public String toString ()
   {
      final StringBuilder sb;
      final Iterator<Type> s_iter;

      sb = new StringBuilder();
      s_iter = ((List<Type>) signatures.toArray()[0]).iterator();

      sb.append(name);
      sb.append(": ");

      if (!s_iter.hasNext())
      {
         sb.append("(no params)");

         return sb.toString();
     }

      sb.append(s_iter.next().get_name());
      sb.append(" ");

      while (s_iter.hasNext())
      {
         sb.append("x ");
         sb.append(s_iter.next().get_name());
      }

      return sb.toString();
   }

   public Formula as_formula (final List<Expression> params)
   {
      final List<Type> signature;

      signature = is_compatible_with(params);

      if (signature == null)
      {
         System.err.print
         (
            "[E] No compatible signature for ("
            + name
         );

         for (final Expression expr: params)
         {
            System.err.print(" " + expr + "/" + expr.get_type().get_name());
         }

         System.err.println(").");

         return null;
      }

      return new PredicateFormula(this, signature, params);
   }

   public Formula as_formula_ (final Expression... e_params)
   {
      final ArrayList<Expression> params;

      params = new ArrayList<Expression>();

      for (final Expression e: e_params)
      {
         params.add(e);
      }

      return as_formula(params);
   }

   public Expression as_function (final List<Expression> params)
   {
      final Expression result;

      result = new FunctionCall(this, params);

      return result;
   }

   public Expression as_function_ (final Expression... e_params)
   {
      final ArrayList<Expression> params;

      params = new ArrayList<Expression>();

      for (final Expression e: e_params)
      {
         params.add(e);
      }

      return as_function(params);
   }
}
