require 'pathname'
require './lib/minitest/unit'
require './test/minitest/metametameta'

module MyModule; end
class AnError < StandardError; include MyModule; end
class ImmutableString < String; def inspect; super.freeze; end; end

module MetaTest
  module Extensions
    module Class
      module DefineClassMethod
        def define_class_method(name, &block)
          (class << self; self; end).send(:define_method, name, &block)
        end
      end
    end
  end
end

class MTUTC < MiniTest::Unit::TestCase
  extend ::MetaTest::Extensions::Class::DefineClassMethod
end

class TestMiniTestUnitOrder < MetaMetaMetaTestCase
  # do not parallelize this suite... it just can't handle it.

  def test_setup_all_runs_once
    call_order = []
    Class.new MTUTC do
      define_method :setup do
        super()
        call_order << :setup
      end

      define_class_method(:setup_all) do
        call_order << :setup_all
      end

      define_method :test_omg  do call_order << :omg;  end
      define_method :test_zomg do call_order << :zomg; end
    end

    with_output do
      @tu.run %w[--seed 42]
    end

    expected = [:setup_all, :setup, :omg, :setup, :zomg]
    assert_equal expected, call_order
  end

  def test_setup_all_runs_once_when_inherited
    call_order = []
    parent =
      Class.new MTUTC do
        define_method :setup do
          super()
          call_order << :setup
        end

        define_class_method(:setup_all) do
          call_order << :setup_all
        end

        define_method :test_omg  do call_order << :omg;  end
        define_method :test_zomg do call_order << :zomg; end
      end

    Class.new parent

    with_output do
      @tu.run %w[--seed 42]
    end

    expected = [:setup_all ] + ([ :setup, :omg, :setup, :zomg ]) * 2
    assert_equal expected, call_order
  end

  def test_teardown_all_runs_once
    call_order = []
    Class.new MTUTC do
      define_method :teardown do
        super()
        call_order << :teardown
      end

      define_class_method(:teardown_all) do
        call_order << :teardown_all
      end

      define_method :test_omg  do call_order << :omg;  end
      define_method :test_zomg do call_order << :zomg; end
    end

    with_output do
      @tu.run %w[--seed 42]
    end

    expected = [ :omg, :teardown, :zomg, :teardown, :teardown_all ]
    assert_equal expected, call_order
  end

  def test_teardown_all_runs_once_when_inherited
    call_order = []
    parent =
      Class.new MTUTC do
        define_method :teardown do
          super()
          call_order << :teardown
        end

        define_class_method(:teardown_all) do
          call_order << :teardown_all
        end

        define_method :test_omg  do call_order << :omg;  end
        define_method :test_zomg do call_order << :zomg; end
      end

    Class.new parent

    with_output do
      @tu.run %w[--seed 42]
    end

    expected = ([ :omg, :teardown, :zomg, :teardown ]) * 2 + [ :teardown_all ]
    assert_equal expected, call_order
  end
end
