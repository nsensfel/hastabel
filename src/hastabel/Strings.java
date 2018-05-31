package hastabel;

import hastabel.lang.Type;
import hastabel.lang.Element;
import hastabel.lang.Predicate;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import java.util.regex.Pattern;

public class Strings
{

   private final Map<String, Element> AS_ELEMENT;
   private final Map<String, String> FROM_ELEMENT_NAME;
   private final Collection<Pattern> regexes;

   private final Type string_type;
   private final LogicWorld world;

   private final String anon_string_prefix;
   private int anon_string_count;

   private static String cleanup_string (final String str)
   {
      return str.replaceAll("\\s","").toLowerCase();
   }

   public Strings (final Type string_type, final LogicWorld world)
   {
      AS_ELEMENT = new HashMap<String, Element>();
      FROM_ELEMENT_NAME = new HashMap<String, String>();
      regexes = new ArrayList<Pattern>();

      anon_string_prefix = "_string_"; /* TODO: use a program param. */
      anon_string_count = 0;

      this.string_type = string_type;
      this.world = world;
   }

   public Element get_string_as_element (final String str)
   {
      Element elem;

      elem = AS_ELEMENT.get(cleanup_string(str));

      if (elem == null)
      {
         elem =
            world.get_elements_manager().declare
            (
               string_type,
               (anon_string_prefix + anon_string_count)
            );

         anon_string_count += 1;

         AS_ELEMENT.put(str, elem);
         FROM_ELEMENT_NAME.put(elem.get_name(), str);
      }

      return elem;
   }

   public Element get_regex_as_element (String str)
   {
      str = str.toLowerCase();
      regexes.add(Pattern.compile(str.substring(1, (str.length() - 1))));

      return get_string_as_element(str);
   }

   public String get_string_from_element_name (final String e_name)
   {
      return FROM_ELEMENT_NAME.get(e_name);
   }

   public void populate_regex_predicate (final Predicate rp)
   {
      final Set<Map.Entry<String, Element>> candidates;

      candidates = AS_ELEMENT.entrySet();

      for (final Pattern p: regexes)
      {
         for (final Map.Entry<String, Element> c: candidates)
         {
            String word;

            word = c.getKey();
            /* Remove the surounding "" */
            word = word.substring(1, (word.length() - 1));

            if (p.matcher(word).matches())
            {
               rp.add_member
               (
                  Arrays.asList
                  (
                     new Element[]
                     {
                        c.getValue(),
                        AS_ELEMENT.get("\"" + p.pattern() + "\"")
                     }
                  )
               );
            }
         }
      }
   }
}
