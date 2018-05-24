package hastabel;

import java.io.IOException;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

class LogicWorld
{
   protected final Elements elements_mgr;
   protected final Predicates predicates_mgr;

   public LogicWorld ()
   {
      elements_mgr = new Elements();
      predicates_mgr = new Predicates(null);
   }

   public LogicWorld (final LogicWorld parent)
   {
      elements_mgr = new Elements();
      predicates_mgr = new Predicates(parent.get_predicates_manager());
   }

   public Elements get_elements_manager ()
   {
      return elements_mgr;
   }

   public Predicates get_predicates_manager ()
   {
      return predicates_mgr;
   }
}
