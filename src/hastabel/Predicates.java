package hastabel;

import hastabel.lang.Predicate;
import hastabel.lang.Type;

import java.util.Collection;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;
import java.util.ArrayList;

public class Predicates
{
   private final Map<String, Predicate> from_name;
   private final Predicates parent_mgr;

   public Predicates (final Predicates parent_mgr)
   {
      from_name = new HashMap<String, Predicate>();
      this.parent_mgr = parent_mgr;
   }

   public Predicate declare (final List<Type> signature, final String name)
   {
      final Predicate result, previous_instance;

      result = new Predicate(signature, name);

      previous_instance = from_name.get(name);

      if (previous_instance == null)
      {
         from_name.put(name, result);

         return result;
      }

      if (previous_instance.get_signatures().contains(signature))
      {
         return previous_instance;
      }

      previous_instance.add_signature(signature);

      return null;
   }

   public Predicate get_or_duplicate (final String name)
   {
      Predicate result;

      result = from_name.get(name);

      if (result == null)
      {
         final Predicate main_predicate;

         main_predicate = parent_mgr.get(name);

         if (main_predicate == null)
         {
            return null;
         }

         result = main_predicate.shallow_copy();

         from_name.put(name, result);
      }

      return result;
   }

   public Predicate get (final String name)
   {
      final Predicate result;

      result = from_name.get(name);

      if (result == null)
      {
         System.err.println("[E] Undeclared predicate \"" + name + "\".");

         return null;
      }

      return result;
   }

   public Collection<Predicate> get_all ()
   {
      return from_name.values();
   }
}
