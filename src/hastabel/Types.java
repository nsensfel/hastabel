package hastabel;

import hastabel.lang.Type;

import java.util.Map;
import java.util.Set;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;

public class Types
{
   private final Map<String, Type> from_name;

   public Types ()
   {
      from_name = new HashMap<String, Type>();
   }

   public Type declare (final Type super_type, final String name)
   {
      final Type result, previous_instance;

      result = new Type(super_type, name);

      previous_instance = from_name.get(name);

      if (previous_instance == null)
      {
         from_name.put(name, result);

         if (super_type != null)
         {
            super_type.add_sub_type(result);
         }

         return result;
      }

      if (result.equals(previous_instance))
      {
         return previous_instance;
      }

      System.err.println
      (
         "[F] Conflicting declarations for type \""
         + name
         + "\"."
      );

      return null;
   }

   public Type get (final String name)
   {
      final Type result;

      result = from_name.get(name);

      if (result == null)
      {
         System.err.println("[F] Undeclared type \"" + name + "\".");

         return null;
      }

      return result;
   }

   public Collection<Type> get_all ()
   {
      return from_name.values();
   }
}
