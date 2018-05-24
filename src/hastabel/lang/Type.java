package hastabel.lang;

import java.util.Map;
import java.util.Set;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;

public class Type
{
   private final Set<Element> elements;
   private final Set<Type> sub_types;
   private final Type super_type;
   private final String name;

   public Type (final Type super_type, final String name)
   {
      this.name = name;
      this.elements = new HashSet<Element>();
      this.sub_types = new HashSet<Type>();
      this.super_type = super_type;
   }

   public void add_sub_type (final Type t)
   {
      sub_types.add(t);

      if (super_type != null)
      {
         super_type.add_sub_type(t);
      }
   }

   public String get_name ()
   {
      return name;
   }

   public void add_element (final Element e)
   {
      elements.add(e);
   }

   public Set<Element> get_elements ()
   {
      return elements;
   }

   public boolean includes (final Type t)
   {
      return (this.equals(t) || sub_types.contains(t));
   }

   @Override
   public boolean equals (Object o)
   {
      final Type t;

      if ((o == null) || !(o instanceof Type))
      {
         return false;
      }

      t = (Type) o;

      return
         (
            t.name.equals(name)
            &&
            (
               ((super_type == null) && (t.super_type == null))
               || super_type.equals(t.super_type)
            )
         );
   }

   @Override
   public int hashCode ()
   {
      return name.hashCode();
   }

   @Override
   public String toString ()
   {
      final StringBuilder sb;

      sb = new StringBuilder();

      if (super_type != null)
      {
         sb.append(super_type.get_name());
         sb.append("::");
      }

      sb.append(name);

      return sb.toString();
   }
}
