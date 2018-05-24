package hastabel;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

public class TemplateInstances
{
   private final Map<String, TemplateInstance> from_name;

   public TemplateInstances ()
   {
      from_name = new HashMap<String, TemplateInstance>();
   }

   public TemplateInstance declare (final Template template, final String name)
   {
      final TemplateInstance result, previous_instance;

      result = new TemplateInstance(template, name);

      previous_instance = from_name.get(name);

      if (previous_instance == null)
      {
         from_name.put(name, result);

         return result;
      }

      System.err.println
      (
         "[E] Multiple declarations for template instance \""
         + name
         + "\"."
      );

      return null;
   }

   public TemplateInstance get (final String name)
   {
      final TemplateInstance result;

      result = from_name.get(name);

      if (result == null)
      {
         System.err.println("[F] Undeclared template \"" + name + "\".");

         return null;
      }

      return result;
   }

   public Collection<TemplateInstance> get_all ()
   {
      return from_name.values();
   }
}
