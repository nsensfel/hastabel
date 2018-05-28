package hastabel.lang;

public abstract class Formula
{
   public static Formula not (final Formula... p)
   {
      return Operator.NOT.as_formula_(p);
   }
   public static Formula and (final Formula... p)
   {
      return Operator.AND.as_formula_(p);
   }

   public static Formula or (final Formula... p)
   {
      return Operator.OR.as_formula_(p);
   }

   public static Formula implies (final Formula... p)
   {
      return Operator.IMPLIES.as_formula_(p);
   }

   public static Formula iff (final Formula... p)
   {
      return Operator.IFF.as_formula_(p);
   }

   public static Formula forall (final Variable v, final Formula f)
   {
      return new Quantifier(v, f, true);
   }

   public static Formula exists (final Variable v, final Formula f)
   {
      return new Quantifier(v, f, false);
   }

   public static Formula equals (final Expression a, final Expression b)
   {
      return new Equals(a, b);
   }
}
