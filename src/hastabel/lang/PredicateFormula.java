package hastabel.lang;

import java.util.List;

class PredicateFormula extends Formula
{
   private final Predicate parent;
   private final List<Expression> params;

   public PredicateFormula
   (
      final Predicate parent,
      final List<Expression> params
   )
   {
      this.parent = parent;
      this.params = params;
   }
}
