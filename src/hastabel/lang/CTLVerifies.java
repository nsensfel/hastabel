package hastabel.lang;

import java.util.List;

public class CTLVerifies extends Formula
{
   private final Variable root_node;
   private final Expression parent;
   private final Formula formula;

   public CTLVerifies
   (
      final Variable root_node,
      final Expression parent,
      final Formula formula
   )
   {
      this.root_node = root_node;
      this.parent = parent;
      this.formula = formula;
   }
}
