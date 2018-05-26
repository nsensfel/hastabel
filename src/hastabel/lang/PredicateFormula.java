package hastabel.lang;

import java.util.List;

class PredicateFormula extends Formula
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
}
