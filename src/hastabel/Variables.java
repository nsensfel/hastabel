package hastabel;

import hastabel.lang.Type;
import hastabel.lang.Variable;
import hastabel.lang.Expression;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class Variables
{
   private final Map<String, Variable> from_string;
   private final List<Variable> seeked;
   private int next_id;

   public Variables ()
   {
      from_string = new HashMap<String, Variable>();
      seeked = new ArrayList<Variable>();
   }

   private String new_anonymous_variable_name ()
   {
      final String result;

      result = "_var" + next_id;

      next_id += 1;

      return result;
   }

   public Variable seek (final Type type, final String var_name)
   {
      final Variable var;

      var = add_variable(type, var_name);
      seeked.add(var);

      return var;
   }

   public List<Variable> get_all_seeked ()
   {
      return seeked;
   }

   public Variable add_variable (final Type type, final String var_name)
   {
      final Variable result;

      if (from_string.containsKey(var_name))
      {
         System.err.println
         (
            "[E] Invalid property: the variable name \""
            + var_name
            + "\" is declared multiple times."
         );

         return null;
      }

      result = new Variable(type, var_name);

      from_string.put(var_name, result);

      return result;
   }

   public Variable get (final String var_name)
   {
      final Variable result;

      result = from_string.get(var_name);

      if (result == null)
      {
         System.err.println
         (
            "[F] Variable \""
            + var_name
            + "\" is used, but not declared."
         );

         return null;
      }

      return result;
   }

   public Variable new_anonymous_variable (final Type t)
   {
      return add_variable(t, new_anonymous_variable_name());
   }
}
