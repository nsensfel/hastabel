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
   private final List<Type> signature;
   private final Set<List<Element>> members;
   private final String name;

   public Predicate (final List<Type> signature, final String name)
   {
      this.signature = signature;
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

   public boolean is_compatible_with (final List<Element> elements)
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

   public String get_name ()
   {
      return name;
   }

   public List<Type> get_signature ()
   {
      return signature;
   }

   public Set<List<Element>> get_members ()
   {
      return members;
   }

   public Predicate shallow_copy ()
   {
      return new Predicate(signature, name);
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
      s_iter = signature.iterator();

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
}
