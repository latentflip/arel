require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Attribute do
    before do
      @relation = Table.new(:users)
      @attribute = Attribute.new(@relation, :id)
    end
  
    describe Attribute::Transformations do
      describe '#as' do
        it "manufactures an aliased attributed" do
          @attribute.as(:alias).should == Attribute.new(@relation, @attribute.name, :alias => :alias, :ancestor => @attribute)
        end
      end
    
      describe '#bind' do
        it "manufactures an attribute with the relation bound and self as an ancestor" do
          derived_relation = @relation.select(@relation[:id].eq(1))
          @attribute.bind(derived_relation).should == Attribute.new(derived_relation, @attribute.name, :ancestor => @attribute)
        end
        
        it "returns self if the substituting to the same relation" do
          @attribute.bind(@relation).should == @attribute
        end
      end
    
      describe '#to_attribute' do
        it "returns self" do
          @attribute.to_attribute.should == @attribute
        end
      end
    end
    
    describe '#column' do
      it "returns the corresponding column in the relation" do
        @attribute.column.should == @relation.column_for(@attribute)
      end
    end
    
    describe '#qualified_name' do
      it "manufactures an attribute name prefixed with the relation's name" do
        @attribute.qualified_name.should == "#{@relation.prefix_for(@attribute)}.id"
      end
    end
    
    describe '#engine' do
      it "delegates to its relation" do
        Attribute.new(@relation, :id).engine.should == @relation.engine
      end
    end
    
    describe Attribute::Congruence do
      describe '=~' do
        
        it "obtains if the attributes are identical" do
          Attribute.new(@relation, :name).should =~ Attribute.new(@relation, :name)
        end
      
        it "obtains if the attributes have an overlapping history" do
          Attribute.new(@relation, :name, :ancestor => Attribute.new(@relation, :name)).should =~ Attribute.new(@relation, :name)
          Attribute.new(@relation, :name).should =~ Attribute.new(@relation, :name, :ancestor => Attribute.new(@relation, :name))
        end
      end
      
      describe 'hashing' do
        it "implements hash equality" do
          Attribute.new(@relation, 'name').should hash_the_same_as(Attribute.new(@relation, 'name'))
          Attribute.new(@relation, 'name').should_not hash_the_same_as(Attribute.new(@relation, 'id'))
        end
      end
    end
    
    describe '#to_sql' do
      describe 'for a simple attribute' do
        it "manufactures sql with an alias" do
          @attribute.to_sql.should be_like("`users`.`id`")
        end
      end
      
      describe 'for an attribute in a join relation where the source relation is aliased' do
        before do
          another_relation = Table.new(:photos)
          @join_with_alias = @relation.as(:alias).join(another_relation).on(@relation[:id].eq(another_relation[:user_id]))
        end
        
        it "manufactures sql with an alias" do
          @join_with_alias[@attribute].to_sql.should be_like("`alias`.`id`")
        end
      end
    end
  
    describe Attribute::Predications do
      before do
        @attribute = Attribute.new(@relation, :name)
      end
    
      describe '#eq' do
        it "manufactures an equality predicate" do
          @attribute.eq('name').should == Equality.new(@attribute, 'name')
        end
      end
    
      describe '#lt' do
        it "manufactures a less-than predicate" do
          @attribute.lt(10).should == LessThan.new(@attribute, 10)
        end
      end
    
      describe '#lteq' do
        it "manufactures a less-than or equal-to predicate" do
          @attribute.lteq(10).should == LessThanOrEqualTo.new(@attribute, 10)
        end
      end
    
      describe '#gt' do
        it "manufactures a greater-than predicate" do
          @attribute.gt(10).should == GreaterThan.new(@attribute, 10)
        end
      end
    
      describe '#gteq' do
        it "manufactures a greater-than or equal-to predicate" do
          @attribute.gteq(10).should == GreaterThanOrEqualTo.new(@attribute, 10)
        end
      end
    
      describe '#matches' do
        it "manufactures a match predicate" do
          @attribute.matches(/.*/).should == Match.new(@attribute, /.*/)
        end
      end
      
      describe '#in' do
        it "manufactures an in predicate" do
          @attribute.in(1..30).should == In.new(@attribute, (1..30))
        end
      end
    end
  
    describe Attribute::Expressions do
      before do
        @attribute = Attribute.new(@relation, :name)    
      end
    
      describe '#count' do
        it "manufactures a count Expression" do
          @attribute.count.should == Expression.new(@attribute, "COUNT")
        end
      end
    
      describe '#sum' do
        it "manufactures a sum Expression" do
          @attribute.sum.should == Expression.new(@attribute, "SUM")
        end
      end
    
      describe '#maximum' do
        it "manufactures a maximum Expression" do
          @attribute.maximum.should == Expression.new(@attribute, "MAX")
        end
      end
    
      describe '#minimum' do
        it "manufactures a minimum Expression" do
          @attribute.minimum.should == Expression.new(@attribute, "MIN")
        end
      end
    
      describe '#average' do
        it "manufactures an average Expression" do
          @attribute.average.should == Expression.new(@attribute, "AVG")
        end
      end 
    end
  end
end