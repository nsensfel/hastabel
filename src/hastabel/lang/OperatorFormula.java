package hastabel.lang;

import java.util.List;

class OperatorFormula extends Formula
{
   private final Operator parent;
   private final List<Formula> params;

   public OperatorFormula
   (
      final Operator parent,
      final List<Formula> params
   )
   {
      this.parent = parent;
      this.params = params;
   }
}
