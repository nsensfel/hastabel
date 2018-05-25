package hastabel.lang;

public abstract class Expression
{
   protected final Type type;

   public Expression (final Type type)
   {
      this.type = type;
   }

   public Type get_type()
   {
      return type;
   }
}
