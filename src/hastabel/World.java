package hastabel;

import java.io.IOException;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

public class World extends LogicWorld
{
   private final Templates templates_mgr;
   private final TemplateInstances template_inst_mgr;

   private final Types types_mgr;

   private boolean is_erroneous;

   public World ()
   {
      super();

      templates_mgr = new Templates();
      template_inst_mgr = new TemplateInstances();

      types_mgr = new Types();

      is_erroneous = false;
   }

   public boolean load (final String filename)
   throws IOException
   {
      final CommonTokenStream tokens;
      final LangLexer lexer;
      final LangParser parser;

      lexer = new LangLexer(CharStreams.fromFileName(filename));
      tokens = new CommonTokenStream(lexer);
      parser = new LangParser(tokens);

      parser.lang_file(this);

      return !is_erroneous;
   }

   public void invalidate ()
   {
      is_erroneous = true;
   }

   public boolean is_valid ()
   {
      return !is_erroneous;
   }

   public Templates get_templates_manager ()
   {
      return templates_mgr;
   }

   public TemplateInstances get_template_instances_manager ()
   {
      return template_inst_mgr;
   }

   public Types get_types_manager ()
   {
      return types_mgr;
   }
}
