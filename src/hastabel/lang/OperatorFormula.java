package hastabel.lang;

import java.util.List;

public class OperatorFormula extends Formula
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

   public Operator get_operator ()
   {
      return parent;
   }

   public List<Formula> get_operands ()
   {
      return params;
   }

   @Override
   public boolean equals (Object o)
   {
      final OperatorFormula e;

      if ((o == null) || !(o instanceof OperatorFormula))
      {
         return false;
      }

      e = (OperatorFormula) o;

      return (e.parent.equals(parent) && e.params.equals(params));
   }

   @Override
   public String toString ()
   {
      final StringBuilder sb;

      sb = new StringBuilder();

      sb.append("(");
      sb.append(parent.toString());

      for (final Formula param: params)
      {
         sb.append(" ");
         sb.append(param.toString());
      }

      sb.append(")");

      return sb.toString();
   }
}
