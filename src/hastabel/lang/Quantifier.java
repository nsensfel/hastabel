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
      if (parent == null)
      {
         System.out.println("Ooops f:" + formula.toString() + ", forall:" + is_forall);
      }
      if (formula == null)
      {
         System.out.println("p:" + parent.toString() + ", forall:" + is_forall);
      }
      this.parent = parent;
      this.formula = formula;
      this.is_forall = is_forall;
   }

   public boolean is_forall ()
   {
      return is_forall;
   }

   public Variable get_variable ()
   {
      return parent;
   }

   public Formula get_formula ()
   {
      return formula;
   }

   @Override
   public boolean equals (Object o)
   {
      final Quantifier e;

      if ((o == null) || !(o instanceof Quantifier))
      {
         return false;
      }

      e = (Quantifier) o;

      return
         (
            e.parent.equals(parent)
            && e.formula.equals(formula)
            && (e.is_forall == is_forall)
         );
   }

   @Override
   public String toString ()
   {
      final StringBuilder sb;

      sb = new StringBuilder();

      sb.append("(");
      sb.append(is_forall ? "forall" : "exists");
      sb.append(" ");
      sb.append(parent.get_name());
      sb.append(" ");
      sb.append(parent.get_type().get_name());
      sb.append(" ");
      sb.append(formula.toString());
      sb.append(")");

      return sb.toString();
   }
}
