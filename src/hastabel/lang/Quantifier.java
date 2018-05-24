package hastabel.lang;

import java.util.List;

public class Quantifier extends Formula
{
   private final boolean is_forall;
   private final Variable parent;
   private final Formula formula;

   public Quantifier
   (
      final Variable parent,
      final Formula formula,
      final boolean is_forall
   )
   {
      this.parent = parent;
      this.formula = formula;
      this.is_forall = is_forall;
   }
}
