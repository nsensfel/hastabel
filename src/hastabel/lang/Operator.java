package hastabel.lang;

import java.util.List;

public enum Operator
{
   NOT,
   AND,
   OR,
   IFF,
   IMPLIES,
   AX,
   EX,
   AG,
   EG,
   AF,
   EF,
   AU,
   EU,
   NPB,
   NDCB;

   public Formula as_formula (final List<Formula> params)
   {
      final OperatorFormula result;

      result = new OperatorFormula(this, params);

      return result;
   }
}
