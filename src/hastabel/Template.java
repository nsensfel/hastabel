package hastabel;

import hastabel.lang.Element;
import hastabel.lang.Predicate;

import java.util.List;
import java.util.Collection;
import java.util.ArrayList;

public class Template extends LogicWorld
{
   private final static String INSTANCE_SEP = "__";

   private final TemplateInstances template_instances;
   private final String name;

   public Template (final LogicWorld parent, final String name)
   {
      super(parent);

      template_instances = new TemplateInstances();

      this.name = name;
   }

   public String get_name ()
   {
      return name;
   }

   public TemplateInstances get_template_instances_manager ()
   {
      return template_instances;
   }

   public void add_contents_to (final String prefix, final Template t)
   {
      add_contents_to(prefix, t.elements, t.predicates);
   }

   public void add_contents_to
   (
      final String prefix,
      final Elements dest_elements,
      final Predicates dest_predicates
   )
   {
      final String actual_prefix;

      actual_prefix = prefix + INSTANCE_SEP;

      for (final Element e: elements_mgr.get_all())
      {
         dest_elements.declare(e.get_type(), (actual_prefix + e.get_name()));
      }

      for (final Predicate orig_rel: predicates_mgr.get_all())
      {
         final Predicate dest_rel;

         dest_rel = dest_predicates.get_or_duplicate(orig_rel.get_name());

         for (final List<Element> orig_membs: orig_rel.get_members())
         {
            final List<Element> dest_membs;

            dest_membs = new ArrayList<Element>(orig_membs.size());

            for (final Element e: orig_membs)
            {
               dest_membs.add(dest_elements.get(actual_prefix + e.get_name()));
            }

            dest_rel.add_member(dest_membs);
         }
      }
   }

   @Override
   public boolean equals (Object o)
   {
      final Template t;

      if ((o == null) || !(o instanceof Template))
      {
         return false;
      }

      t = (Template) o;

      return (t.name.equals(name));
   }

   @Override
   public int hashCode ()
   {
      return name.hashCode();
   }

   @Override
   public String toString ()
   {
      return "Template " + name;
   }
}
