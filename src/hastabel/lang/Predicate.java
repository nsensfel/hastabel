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
   private final Set<List<Element>> members;
   private final String name;

   public Predicate (final List<Type> signature, final String name)
   {
      signatures = new ArrayList<List<Type>>(1);
      signatures.add(signature);

      this.name = name;

      members = new HashSet<List<Element>>();
   }

   public Predicate (final Collection<List<Type>> signatures, final String name)
   {
      this.signatures = new ArrayList<List<Type>>();
      this.signatures.addAll(signatures);

      this.name = name;

      members = new HashSet<List<Element>>();
   }

   public void add_member (final List<Element> elements)
   {
      if (is_compatible_with(elements))
      {
         members.add(elements);
      }
   }

   public void add_member_ (final Element... elements)
   {
      final ArrayList<Element> params;

      params = new ArrayList<Element>();

      for (final Element e: elements)
      {
         params.add(e);
      }

      if (is_compatible_with(params))
      {
         members.add(params);
      }
   }

   private boolean is_compatible_with_signature
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

   public boolean is_compatible_with (final List<Element> elements)
   {
      for (final List<Type> signature: signatures)
      {
         if (is_compatible_with_signature(elements, signature))
         {
            return true;
         }
      }

      return false;
   }

   public String get_name ()
   {
      return name;
   }

   public Collection<List<Type>> get_signatures ()
   {
      return signatures;
   }

   public Set<List<Element>> get_members ()
   {
      return members;
   }

   public Predicate shallow_copy ()
   {
      return new Predicate(signatures, name);
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
      final Formula result;

      result = new PredicateFormula(this, params);

      return result;
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
