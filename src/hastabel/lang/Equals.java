package hastabel.lang;

import java.util.List;

public class Equals extends Formula
{
   private final Expression a, b;

   public Equals (final Expression a, final Expression b)
   {
      this.a = a;
      this.b = b;
   }

   public Expression get_first_operand ()
   {
      return a;
   }

   public Expression get_second_operand ()
   {
      return b;
   }
}
