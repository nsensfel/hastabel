package hastabel;

import hastabel.lang.Type;
import hastabel.lang.Variable;
import hastabel.lang.Expression;

import java.io.BufferedWriter;
import java.io.IOException;

import java.util.HashMap;
import java.util.Map;

public class Variables
{
   private final Map<String, Variable> from_string;
   private final Map<String, Variable> seeked;
   private int next_id;

   public Variables ()
   {
      from_string = new HashMap<String, Variable>();
      seeked = new HashMap<String, Variable>();
   }

   private String generate_new_anonymous_variable_name ()
   {
      final String result;

      result = "_var" + next_id;

      next_id += 1;

      return result;
   }

   public void seek (final Type type, final String var_name)
   throws Exception
   {
      final Variable var;

      var = add_variable(type, var_name);
      seeked.put(var_name, var);
   }

   public Variable add_variable (final Type type, final String var_name)
   throws Exception
   {
      final Variable result;

      if (from_string.containsKey(var_name))
      {
         throw
            new Exception
            (
               "[F] Invalid property: the variable name \""
               + var_name
               + "\" is declared multiple times."
            );
      }

      result = new Variable(type, var_name);

      from_string.put(var_name, result);

      return result;
   }

   public Variable get_variable (final String var_name)
   throws Exception
   {
      final Variable result;

      result = from_string.get(var_name);

      if (result == null)
      {
         throw
            new Exception
            (
               "[F] Variable \""
               + var_name
               + "\" is used, but not declared."
            );
      }

      return result;
   }

   public Variable generate_new_anonymous_variable (final Type t)
   throws Exception
   {
      return add_variable(t, generate_new_anonymous_variable_name());
   }
}
