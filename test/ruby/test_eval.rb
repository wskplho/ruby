require 'test/unit'

class TestEval < Test::Unit::TestCase

  @ivar = 12
  @@cvar = 13
  $gvar__eval = 14
  Const = 15

  def test_eval_basic
    assert_equal nil,   eval("nil")
    assert_equal true,  eval("true")
    assert_equal false, eval("false")
    assert_equal self,  eval("self")
    assert_equal 1,     eval("1")
    assert_equal :sym,  eval(":sym")

    assert_equal 11,    eval("11")
    @ivar = 12
    assert_equal 12,    eval("@ivar")
    assert_equal 13,    eval("@@cvar")
    assert_equal 14,    eval("$gvar__eval")
    assert_equal 15,    eval("Const")

    assert_equal 16,    eval("7 + 9")
    assert_equal 17,    eval("17.to_i")
    assert_equal "18",  eval(%q("18"))
    assert_equal "19",  eval(%q("1#{9}"))

    1.times {
      assert_equal 12,  eval("@ivar")
      assert_equal 13,  eval("@@cvar")
      assert_equal 14,  eval("$gvar__eval")
      assert_equal 15,  eval("Const")
    }
  end

  def test_eval_binding_basic
    assert_equal nil,   eval("nil", binding())
    assert_equal true,  eval("true", binding())
    assert_equal false, eval("false", binding())
    assert_equal self,  eval("self", binding())
    assert_equal 1,     eval("1", binding())
    assert_equal :sym,  eval(":sym", binding())

    assert_equal 11,    eval("11", binding())
    @ivar = 12
    assert_equal 12,    eval("@ivar", binding())
    assert_equal 13,    eval("@@cvar", binding())
    assert_equal 14,    eval("$gvar__eval", binding())
    assert_equal 15,    eval("Const", binding())

    assert_equal 16,    eval("7 + 9", binding())
    assert_equal 17,    eval("17.to_i", binding())
    assert_equal "18",  eval(%q("18"), binding())
    assert_equal "19",  eval(%q("1#{9}"), binding())

    1.times {
      assert_equal 12,  eval("@ivar")
      assert_equal 13,  eval("@@cvar")
      assert_equal 14,  eval("$gvar__eval")
      assert_equal 15,  eval("Const")
    }
  end

  def test_module_eval_string_basic
    c = self.class
    assert_equal nil,   c.module_eval("nil")
    assert_equal true,  c.module_eval("true")
    assert_equal false, c.module_eval("false")
    assert_equal c,     c.module_eval("self")
    assert_equal :sym,  c.module_eval(":sym")
    assert_equal 11,    c.module_eval("11")
    @ivar = 12
    assert_equal 12,    c.module_eval("@ivar")
    assert_equal 13,    c.module_eval("@@cvar")
    assert_equal 14,    c.module_eval("$gvar__eval")
    assert_equal 15,    c.module_eval("Const")
    assert_equal 16,    c.module_eval("7 + 9")
    assert_equal 17,    c.module_eval("17.to_i")
    assert_equal "18",  c.module_eval(%q("18"))
    assert_equal "19",  c.module_eval(%q("1#{9}"))

    @ivar = 12
    1.times {
      assert_equal 12,  c.module_eval("@ivar")
      assert_equal 13,  c.module_eval("@@cvar")
      assert_equal 14,  c.module_eval("$gvar__eval")
      assert_equal 15,  c.module_eval("Const")
    }
  end

  def test_module_eval_block_basic
    c = self.class
    assert_equal nil,   c.module_eval { nil }
    assert_equal true,  c.module_eval { true }
    assert_equal false, c.module_eval { false }
    assert_equal c,     c.module_eval { self }
    assert_equal :sym,  c.module_eval { :sym }
    assert_equal 11,    c.module_eval { 11 }
    @ivar = 12
    assert_equal 12,    c.module_eval { @ivar }
    assert_equal 13,    c.module_eval { @@cvar }
    assert_equal 14,    c.module_eval { $gvar__eval }
    assert_equal 15,    c.module_eval { Const }
    assert_equal 16,    c.module_eval { 7 + 9 }
    assert_equal 17,    c.module_eval { "17".to_i }
    assert_equal "18",  c.module_eval { "18" }
    assert_equal "19",  c.module_eval { "1#{9}" }

    @ivar = 12
    1.times {
      assert_equal 12,  c.module_eval { @ivar }
      assert_equal 13,  c.module_eval { @@cvar }
      assert_equal 14,  c.module_eval { $gvar__eval }
      assert_equal 15,  c.module_eval { Const }
    }
  end

  def forall_TYPE(mid)
    objects = [Object.new, [], nil, true, false, 77, ] #:sym] # TODO: check
    objects.each do |obj|
      obj.instance_variable_set :@ivar, 12
      obj.class.class_variable_set :@@cvar, 13
          # Use same value with env. See also test_instance_variable_cvar.
      obj.class.const_set :Const, 15 unless obj.class.const_defined?(:Const)
      send! mid, obj
    end
  end

  def test_instance_eval_string_basic
    forall_TYPE :instance_eval_string_basic_i
  end

  def instance_eval_string_basic_i(o)
    assert_equal nil,   o.instance_eval("nil")
    assert_equal true,  o.instance_eval("true")
    assert_equal false, o.instance_eval("false")
    assert_equal o,     o.instance_eval("self")
    assert_equal 1,     o.instance_eval("1")
    assert_equal :sym,  o.instance_eval(":sym")

    assert_equal 11,    o.instance_eval("11")
    assert_equal 12,    o.instance_eval("@ivar")
    begin
      assert_equal 13,    o.instance_eval("@@cvar")
    rescue => err
      assert false, "cannot get cvar from #{o.class}"
    end
    assert_equal 14,    o.instance_eval("$gvar__eval")
    assert_equal 15,    o.instance_eval("Const")
    assert_equal 16,    o.instance_eval("7 + 9")
    assert_equal 17,    o.instance_eval("17.to_i")
    assert_equal "18",  o.instance_eval(%q("18"))
    assert_equal "19",  o.instance_eval(%q("1#{9}"))

    1.times {
      assert_equal 12,  o.instance_eval("@ivar")
      assert_equal 13,  o.instance_eval("@@cvar")
      assert_equal 14,  o.instance_eval("$gvar__eval")
      assert_equal 15,  o.instance_eval("Const")
    }
  end

  def test_instance_eval_block_basic
    forall_TYPE :instance_eval_block_basic_i
  end

  def instance_eval_block_basic_i(o)
    assert_equal nil,   o.instance_eval { nil }
    assert_equal true,  o.instance_eval { true }
    assert_equal false, o.instance_eval { false }
    assert_equal o,     o.instance_eval { self }
    assert_equal 1,     o.instance_eval { 1 }
    assert_equal :sym,  o.instance_eval { :sym }

    assert_equal 11,    o.instance_eval { 11 }
    assert_equal 12,    o.instance_eval { @ivar }
    assert_equal 13,    o.instance_eval { @@cvar }
    assert_equal 14,    o.instance_eval { $gvar__eval }
    assert_equal 15,    o.instance_eval { Const }
    assert_equal 16,    o.instance_eval { 7 + 9 }
    assert_equal 17,    o.instance_eval { 17.to_i }
    assert_equal "18",  o.instance_eval { "18" }
    assert_equal "19",  o.instance_eval { "1#{9}" }

    1.times {
      assert_equal 12,  o.instance_eval { @ivar }
      assert_equal 13,  o.instance_eval { @@cvar }
      assert_equal 14,  o.instance_eval { $gvar__eval }
      assert_equal 15,  o.instance_eval { Const }
    }
  end

  def test_instance_eval_cvar
    env = @@cvar
    cls = "class"
    [Object.new, [], 7, ].each do |obj| # TODO: check :sym
      obj.class.class_variable_set :@@cvar, cls
      assert_equal env, obj.instance_eval("@@cvar")
      assert_equal env, obj.instance_eval { @@cvar }
    end
    [true, false, nil].each do |obj|
      obj.class.class_variable_set :@@cvar, cls
      assert_equal cls, obj.instance_eval("@@cvar")
      assert_equal cls, obj.instance_eval { @@cvar }
    end
  end

  # 
  # From ruby/test/ruby/test_eval.rb
  #

  def test_ev
    local1 = "local1"
    lambda {
      local2 = "local2"
      return binding
    }.call
  end

  def test_eval_orig
    assert_nil(eval(""))
    $bad=false
    eval 'while false; $bad = true; print "foo\n" end'
    assert(!$bad)

    assert(eval('TRUE'))
    assert(eval('true'))
    assert(!eval('NIL'))
    assert(!eval('nil'))
    assert(!eval('FALSE'))
    assert(!eval('false'))

    $foo = 'assert(true)'
    begin
      eval $foo
    rescue
      assert(false)
    end

    assert_equal('assert(true)', eval("$foo"))
    assert_equal(true, eval("true"))
    i = 5
    assert(eval("i == 5"))
    assert_equal(5, eval("i"))
    assert(eval("defined? i"))

    $x = test_ev
    assert_equal("local1", eval("local1", $x)) # normal local var
    assert_equal("local2", eval("local2", $x)) # nested local var
    $bad = true
    begin
      p eval("local1")
    rescue NameError		# must raise error
      $bad = false
    end
    assert(!$bad)

    # !! use class_eval to avoid nested definition
    self.class.class_eval %q(
      module EvTest
	EVTEST1 = 25
	evtest2 = 125
	$x = binding
      end
    )
    assert_equal(25, eval("EVTEST1", $x))	# constant in module
    assert_equal(125, eval("evtest2", $x))	# local var in module
    $bad = true
    begin
      eval("EVTEST1")
    rescue NameError		# must raise error
      $bad = false
    end
    assert(!$bad)

    if false
      # Ruby 2.0 doesn't see Proc as Binding
      x = proc{}
      eval "i4 = 1", x
      assert_equal(1, eval("i4", x))
      x = proc{proc{}}.call
      eval "i4 = 22", x
      assert_equal(22, eval("i4", x))
      $x = []
      x = proc{proc{}}.call
      eval "(0..9).each{|i5| $x[i5] = proc{i5*2}}", x
      assert_equal(8, $x[4].call)
    end

    x = binding
    eval "i = 1", x
    assert_equal(1, eval("i", x))
    x = proc{binding}.call
    eval "i = 22", x
    assert_equal(22, eval("i", x))
    $x = []
    x = proc{binding}.call
    eval "(0..9).each{|i5| $x[i5] = proc{i5*2}}", x
    assert_equal(8, $x[4].call)
    x = proc{binding}.call
    eval "for i6 in 1..1; j6=i6; end", x
    assert(eval("defined? i6", x))
    assert(eval("defined? j6", x))

    proc {
      p = binding
      eval "foo11 = 1", p
      foo22 = 5
      proc{foo11=22}.call
      proc{foo22=55}.call
      # assert_equal(eval("foo11"), eval("foo11", p))
      # assert_equal(1, eval("foo11"))
      assert_equal(eval("foo22"), eval("foo22", p))
      assert_equal(55, eval("foo22"))
    }.call

    if false
      # Ruby 2.0 doesn't see Proc as Binding
      p1 = proc{i7 = 0; proc{i7}}.call
      assert_equal(0, p1.call)
      eval "i7=5", p1
      assert_equal(5, p1.call)
      assert(!defined?(i7))
    end

    if false
      # Ruby 2.0 doesn't see Proc as Binding
      p1 = proc{i7 = 0; proc{i7}}.call
      i7 = nil
      assert_equal(0, p1.call)
      eval "i7=1", p1
      assert_equal(1, p1.call)
      eval "i7=5", p1
      assert_equal(5, p1.call)
      assert_nil(i7)
    end
  end

  def test_nil_instance_eval_cvar # [ruby-dev:24103]
    def nil.test_binding
      binding
    end
    bb = eval("nil.instance_eval \"binding\"", nil.test_binding)
    assert_raise(NameError) { eval("@@a", bb) }
    class << nil
      remove_method :test_binding
    end
  end

  def test_fixnum_instance_eval_cvar # [ruby-dev:24213]
    assert_raise(NameError) { 1.instance_eval "@@a" }
  end

  def test_cvar_scope_with_instance_eval # [ruby-dev:24223]
    Fixnum.class_eval "@@test_cvar_scope_with_instance_eval = 1" # depends on [ruby-dev:24229]
    @@test_cvar_scope_with_instance_eval = 4
    assert_equal(4, 1.instance_eval("@@test_cvar_scope_with_instance_eval"))
    Fixnum.__send__(:remove_class_variable, :@@test_cvar_scope_with_instance_eval)
  end

  def test_eval_and_define_method # [ruby-dev:24228]
    assert_nothing_raised {
      def temporally_method_for_test_eval_and_define_method(&block)
        lambda {
          class << Object.new; self end.send!(:define_method, :zzz, &block)
        }
      end
      v = eval("temporally_method_for_test_eval_and_define_method {}")
      {}[0] = {}
      v.call
    }
  end

end
