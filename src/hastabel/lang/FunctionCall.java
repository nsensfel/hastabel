package hastabel.lang;

import java.util.List;

class FunctionCall extends Expression
{
   private final Predicate parent;
   private final List<Expression> params;

   public FunctionCall
   (
      final Predicate parent,
      final List<Expression> params
   )
   {
      this.parent = parent;
      this.params = params;
   }
}
