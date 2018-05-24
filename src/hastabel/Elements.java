package hastabel;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

public class Elements
{
   private final boolean is_root_mgr;

   private final Map<String, Element> from_name;

   public Elements (final boolean is_root_mgr)
   {
      from_name = new HashMap<String, Element>();
      this.is_root_mgr = is_root_mgr;
   }

   public Element declare (final Type type, final String name)
   {
      final Element result, previous_instance;

      result = new Element(type, name);

      previous_instance = from_name.get(name);

      if (previous_instance == null)
      {
         from_name.put(name, result);

         if (is_root_mgr)
         {
            type.add_element(result);
         }

         return result;
      }

      if (type.equals(previous_instance.get_type()))
      {
         return previous_instance;
      }

      if (previous_instance.get_type().includes(type))
      {
         System.err.println
         (
            "[W] Element \""
            + name
            + "\" was declared as a \""
            + previous_instance.get_type().get_name()
            + "\", but is now declared as its \""
            + type.get_name()
            + "\" sub-type. \""
            + type.get_name()
            + "\" declaration ignored."
         );

         return previous_instance;
      }

      System.err.println
      (
         "[E] Conflicting types for element \""
         + name
         + "\": was \""
         + previous_instance.get_type().get_name()
         + "\", is now \""
         + type.get_name()
         + "\"."
      );

      return null;
   }

   public Element get (final String name)
   {
      final Element result;

      result = from_name.get(name);

      if (result == null)
      {
         System.err.println("[F] Undeclared element \"" + name + "\".");

         System.exit(-1);

         return null;
      }

      return result;
   }

   public Collection<Element> get_all ()
   {
      return from_name.values();
   }
}
