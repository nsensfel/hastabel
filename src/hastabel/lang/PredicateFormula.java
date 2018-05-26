package hastabel.lang;

import java.util.List;

public class PredicateFormula extends Formula
{
   private final Predicate parent;
   private final List<Expression> params;
   private final List<Type> signature;

   public PredicateFormula
   (
      final Predicate parent,
      final List<Type> signature,
      final List<Expression> params
   )
   {
      this.parent = parent;
      this.signature = signature;
      this.params = params;
   }

   public Predicate get_predicate ()
   {
      return parent;
   }

   public List<Expression> get_parameters ()
   {
      return params;
   }

   public List<Type> get_signature ()
   {
      return signature;
   }

   @Override
   public boolean equals (Object o)
   {
      final PredicateFormula e;

      if ((o == null) || !(o instanceof PredicateFormula))
      {
         return false;
      }

      e = (PredicateFormula) o;

      return
         (
            e.parent.equals(parent)
            && e.params.equals(params)
            && e.signature.equals(signature)
         );
   }

   @Override
   public String toString ()
   {
      final StringBuilder sb;

      sb = new StringBuilder();

      sb.append("(");
      sb.append(parent.toString());

      for (final Expression param: params)
      {
         sb.append(" ");
         if (param == null)
         {
            sb.append("_");
         }
         else
         {
            sb.append(param.toString());
         }
      }

      sb.append(")");

      return sb.toString();
   }
}
