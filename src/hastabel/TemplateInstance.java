package hastabel;

public class TemplateInstance
{
   private final Template template;
   private final String name;

   public TemplateInstance
   (
      final Template template,
      final String name
   )
   {
      this.template = template;
      this.name = name;
   }

   public String get_name ()
   {
      return name;
   }

   public Template get_template ()
   {
      return template;
   }

   public void add_contents_to (final Template t)
   {
      template.add_contents_to(name, t);
   }

   public void add_contents_to (final Elements e, final Predicates r)
   {
      template.add_contents_to(name, e, r);
   }
}
