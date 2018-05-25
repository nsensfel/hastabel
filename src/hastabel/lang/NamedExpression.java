package hastabel.lang;

abstract class NamedExpression extends Expression
{
   public final String name;

   public NamedExpression (final Type type, final String name)
   {
      super(type);
      this.name = name;
   }

   public String get_name ()
   {
      return name;
   }

   @Override
   public boolean equals (Object o)
   {
      final NamedExpression e;

      if ((o == null) || !(o instanceof NamedExpression))
      {
         return false;
      }

      e = (NamedExpression) o;

      return (e.name.equals(name) && e.type.equals(type));
   }

   @Override
   public int hashCode ()
   {
      return (name + '@' + type.get_name()).hashCode();
   }

   @Override
   public String toString ()
   {
      return (type.get_name() + " " + name);
   }
}
