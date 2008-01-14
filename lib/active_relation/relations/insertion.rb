module ActiveRelation
  module Relations
    class Insertion < Compound
      attr_reader :record
  
      def initialize(relation, record)
        @relation, @record = relation, record
      end

      def to_sql(options = {})
        [
          "INSERT",
          "INTO #{table_sql}",
          "(#{record.keys.collect(&:to_sql).join(', ')})",
          "VALUES #{inserts.collect(&:to_sql).join(', ')}"
        ].join("\n")
      end  

      protected
      def inserts
        relation.inserts + [record]
      end
    end
  end
end