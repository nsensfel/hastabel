package hastabel;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

public class Templates
{
   private final Map<String, Template> from_name;

   public Templates ()
   {
      from_name = new HashMap<String, Template>();
   }

   public Template declare (final LogicWorld parent, final String name)
   {
      final Template previous_instance;

      previous_instance = from_name.get(name);

      if (previous_instance == null)
      {
         final Template result;

         result = new Template(parent, name);

         from_name.put(name, result);

         return result;
      }

      System.err.println
      (
         "[E] Multiple declarations for template \""
         + name
         + "\"."
      );

      return null;
   }

   public Template get (final String name)
   {
      final Template result;

      result = from_name.get(name);

      if (result == null)
      {
         System.err.println("[E] Undeclared template \"" + name + "\".");

         return null;
      }

      return result;
   }

   public Collection<Template> get_all ()
   {
      return from_name.values();
   }
}
