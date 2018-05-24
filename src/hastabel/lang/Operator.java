package hastabel.lang;

import java.util.List;
import java.util.ArrayList;

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

   public Formula as_formula_ (final Formula... e_params)
   {
      final ArrayList<Formula> params;

      params = new ArrayList<Formula>();

      for (final Formula f: e_params)
      {
         params.add(f);
      }

      return as_formula(params);
   }
}
