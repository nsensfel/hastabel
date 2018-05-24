package hastabel;

import hastabel.lang.Element;
import hastabel.lang.Type;
import hastabel.lang.Predicate;

import java.util.Collection;
import java.util.Map;
import java.util.Stack;
import java.util.List;
import java.util.HashMap;
import java.util.ArrayList;

public class GraphToFirstOrder
{
   private final Map<Element, Node> NODE_FROM_ELEMENT;
   private final ArrayList<Node> INITIAL_NODES;
   private final String ID_PREFIX;
   private int id_counter;

   public GraphToFirstOrder (final String id_prefix)
   {
      ID_PREFIX = id_prefix;
      NODE_FROM_ELEMENT = new HashMap<Element, Node>();
      INITIAL_NODES = new ArrayList<Node>();

      id_counter = 0;
   }

   public boolean run (final World world)
   {
      final Predicate is_start_node, node_connect, is_terminal;
      final Predicate is_path_of, contains_node, is_before;
      final Type path_type;

      is_start_node = world.get_predicates_manager().get("is_start_node");
      node_connect = world.get_predicates_manager().get("node_connect");
      is_terminal = world.get_predicates_manager().get("is_terminal");

      is_path_of = world.get_predicates_manager().get("is_path_of");
      contains_node = world.get_predicates_manager().get("contains_node");
      is_before = world.get_predicates_manager().get("is_before");

      path_type = world.get_types_manager().get("path");

      if
      (
         (is_start_node == null)
         || (node_connect == null)
         || (is_terminal == null)

         || (is_path_of == null)
         || (contains_node == null)
         || (is_before == null)

         || (path_type == null)
      )
      {
         print_relevant_issues(world);

         return false;
      }

      load_data(is_start_node, node_connect, is_terminal);
      complete_model(world, path_type, is_path_of, contains_node, is_before);

      return true;
   }

   private void load_data
   (
      final Predicate is_start_node,
      final Predicate node_connect,
      final Predicate is_terminal
   )
   {
      for (final List<Element> members: is_start_node.get_members())
      {
         mark_node_as_initial(members.get(0));
      }

      for (final List<Element> members: node_connect.get_members())
      {
         mark_nodes_as_connected(members.get(0), members.get(1));
      }

      for (final List<Element> members: is_terminal.get_members())
      {
         mark_node_as_terminal(members.get(0));
      }
   }

   private void complete_model
   (
      final World world,
      final Type path_type,
      final Predicate is_path_of,
      final Predicate contains_node,
      final Predicate is_before
   )
   {
      for (final Node initial_node: INITIAL_NODES)
      {
         for (final Path path: get_all_paths_from(initial_node))
         {
            final int path_length;
            final Element path_e;

            path_e = world.get_elements_manager().declare(path_type, next_id());

            path_length = path.nodes.size();
            is_path_of.add_member_(path_e, initial_node.get_element());

            for (int i = 0; i < path_length; i++)
            {
               final Element n_i;

               n_i = path.nodes.get(i).get_element();

               contains_node.add_member_( path_e, n_i);

               for (int j = 0; j < i; j++)
               {
                  is_before.add_member_
                  (
                     path.nodes.get(j).get_element(),
                     n_i,
                     path_e
                  );
               }
            }
         }
      }
   }

   private void print_relevant_issues (final World world)
   {
      if (world.get_predicates_manager().get("is_start_node") == null)
      {
         System.err.println("[E] Missing 'is_start_node' predicate.");
      }

      if (world.get_predicates_manager().get("node_connect") == null)
      {
         System.err.println("[E] Missing 'node_connect' predicate.");
      }

      if (world.get_predicates_manager().get("is_terminal") == null)
      {
         System.err.println("[E] Missing 'is_terminal' predicate.");
      }

      if (world.get_predicates_manager().get("is_path_of") == null)
      {
         System.err.println("[E] Missing 'is_path_of' predicate.");
      }

      if (world.get_predicates_manager().get("contains_node") == null)
      {
         System.err.println("[E] Missing 'contains_node' predicate.");
      }

      if (world.get_predicates_manager().get("is_before") == null)
      {
         System.err.println("[E] Missing 'is_before' predicate.");
      }

      if (world.get_types_manager().get("path") == null)
      {
         System.err.println("[E] Missing 'path' type.");
      }
   }

   private String next_id ()
   {
      final String result;

      result = ID_PREFIX + id_counter;

      id_counter++;

      return result;
   }

   private Node get_or_add_node (final Element element)
   {
      Node n;

      n = NODE_FROM_ELEMENT.get(element);

      if (n == (Node) null)
      {
         n = new Node(element);

         NODE_FROM_ELEMENT.put(element, n);
      }

      return n;
   }

   private void mark_node_as_initial (final Element element)
   {
      final Node n;

      n = get_or_add_node(element);

      INITIAL_NODES.add(n);
   }

   private void mark_node_as_terminal (final Element element)
   {
      final Node n;

      n = get_or_add_node(element);

      n.set_as_terminal();
   }

   private void mark_nodes_as_connected
   (
      final Element e_a,
      final Element e_b
   )
   {
      final Node n_a, n_b;

      n_a = get_or_add_node(e_a);
      n_b = get_or_add_node(e_b);

      n_a.next_nodes.add(n_b);
   }

   private Collection<Path> get_all_paths_from (final Node root_node)
   {
      final Collection<Path> result;
      final Stack<Path> waiting_list;

      result = new ArrayList<Path>();
      waiting_list = new Stack<Path>();

      waiting_list.push((new Path(root_node)));

      while (!waiting_list.empty())
      {
         final Path current_path;
         final Node current_node;
         final Collection<Node> next_nodes;

         current_path = waiting_list.pop();
         current_node = current_path.last_node;
         next_nodes = current_node.next_nodes();

         if (next_nodes.isEmpty())
         {
            result.add(current_path);
         }
         else
         {
            if (current_node.is_terminal())
            {
               result.add(current_path);
            }
            for (final Node next: next_nodes)
            {
               waiting_list.push(current_path.add_step(next));
            }
         }
      }

      return result;
   }

   private static class Node
   {
      private final Collection<Node> next_nodes;
      private boolean is_terminal;
      private Element element;

      private Node (final Element element)
      {
         this.element = element;

         next_nodes = new ArrayList<Node>();
         is_terminal = false;
      }

      private void set_as_terminal ()
      {
         is_terminal = true;
      }

      public Collection<Node> next_nodes ()
      {
         return next_nodes;
      }

      public boolean is_terminal ()
      {
         return is_terminal;
      }

      public Element get_element ()
      {
         return element;
      }
   }

   private static class Path
   {
      private final ArrayList<Node> nodes;
      private final Node last_node;

      private Path (final Node start)
      {
         nodes = new ArrayList<Node>();

         nodes.add(start);

         last_node = start;
      }

      private Path (final ArrayList<Node> nodes, final Node last_node)
      {
         this.nodes = nodes;
         this.last_node = last_node;

         this.nodes.add(last_node);
      }

      @SuppressWarnings("unchecked")
      /* 'nodes' is an ArrayList<Node>, and so should be its clone. */
      private Path add_step (final Node n)
      {
         return new Path((ArrayList<Node>) nodes.clone(), n);
      }

      public Collection<List<Node>> get_all_subpaths ()
      {
         final Collection<List<Node>> result;
         final int path_length;

         result = new ArrayList<List<Node>>();
         path_length = nodes.size();

         for (int i = 0; i < path_length; ++i)
         {
            result.add(nodes.subList(i, path_length));
         }

         return result;
      }
   }
}
