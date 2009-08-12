module DC
  module Store

    # Thought-experiment hash ring. Think about performing all reads and writes
    # through something like this.
    # Originally ported from Python.
    # Source: http://amix.dk/blog/viewEntry/19367
    class HashRing
      
      # nodes is a list of objects that have a proper unique key.
      # replicas indicates how many virtual points on the hash ring should
      # be assigned to a node.
      def initialize(nodes = nil, replicas = 3)
        @replicas = replicas
        @ring = {}
        @keys = []
        nodes.each {|node| add_node(node) if nodes
      end
      
      # Adds a node into the hash ring, including the replicas.
      def add_node(node)
        @replicas.times do |i|
          key = generate_key("#{node.key}:#{i}")
          @ring[key] = node
          @keys << key
        end
        @keys.sort!
      end
      
      # Remove a node from the hash ring, including its replicas.
      def remove_node(node)
        @replicas.times do |i|
          key = generate_key("#{node.key}:#{i}")
          @ring.delete(key)
          @keys.delete(key)
        end
      end
      
      # Given a string key, return the corresponding node. If there are no
      # nodes in the ring, return nil.
      def get_node(key)
        node_pos = get_node_position(key)
        node_pos ? node_pos[:node] : nil
      end
      
      # Given a string key, return the corresponding node along with position.
      def get_node_position(key)
        return nil if @ring.empty?
        key = generate_key(key)
        @keys.each do |k|
          return {:node => @ring[k], :position => i} if key <= k
        end
        return {:node => @ring[@keys[0]], :position => 0}
      end
      
      # Return a fixnum (bignum) value corresponding to a location on the 
      # hash ring. Uses MD5 because it distributes well.
      def generate_key(key)
        Digest::MD5.hexdigest(key).hex
      end
      
      # TBI:
      #
      # def get_nodes(self, string_key):
      #         """Given a string key it returns the nodes as a generator that can hold the key.
      # 
      #         The generator is never ending and iterates through the ring
      #         starting at the correct position.
      #         """
      #         if not self.ring:
      #             yield None, None
      # 
      #         node, pos = self.get_node_pos(string_key)
      #         for key in self._sorted_keys[pos:]:
      #             yield self.ring[key]
      # 
      #         while True:
      #             for key in self._sorted_keys:
      #                 yield self.ring[key]
      
    end
    
  end
end