# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::OutputSafety, :config do
  context 'when using `#safe_concat`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo.safe_concat('bar')
            ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when wrapped inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([i18n_text.safe_concat(i18n_text)])
                             ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo&.safe_concat('bar')
               ^^^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#html_safe`' do
    it 'does not register an offense for static string literal receiver' do
      expect_no_offenses(<<~RUBY)
        "foo".html_safe
      RUBY
    end

    it 'registers an offense for dynamic string literal receiver' do
      expect_offense(<<~'RUBY')
        "foo#{1}".html_safe
                  ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense for variable receiver' do
      expect_offense(<<~RUBY)
        foo.html_safe
            ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense for variable receiver and arguments' do
      expect_no_offenses(<<~RUBY)
        foo.html_safe(one)
      RUBY
    end

    it 'does not register an offense without a receiver' do
      expect_no_offenses('html_safe')
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([i18n_text.html_safe, "foo"])
                             ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<~RUBY)
        foo(safe_join([i18n_text.html_safe, "bar"]))
                                 ^^^^^^^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for variable receiver and no argument' do
        expect_offense(<<~RUBY)
          foo&.html_safe
               ^^^^^^^^^ Tagging a string as html safe may be a security risk.
        RUBY
      end
    end
  end

  context 'when using `#raw`' do
    it 'registers an offense with no receiver and a variable argument' do
      expect_offense(<<~RUBY)
        raw(foo)
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense with no receiver and a literal argument' do
      expect_offense(<<~RUBY)
        raw("foo")
        ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'does not register an offense with a receiver' do
      expect_no_offenses(<<~RUBY)
        foo.raw(foo)
      RUBY
    end

    it 'does not register an offense without arguments' do
      expect_no_offenses('raw')
    end

    it 'does not register an offense with more than one argument' do
      expect_no_offenses('raw(one, two)')
    end

    it 'does not register an offense for comments' do
      expect_no_offenses(<<~RUBY)
        # foo.html_safe
        # raw foo
      RUBY
    end

    it 'registers an offense when used inside `#safe_join`' do
      expect_offense(<<~RUBY)
        safe_join([raw(i18n_text), "foo"])
                   ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end

    it 'registers an offense when used inside `#safe_join` in other method' do
      expect_offense(<<~RUBY)
        foo(safe_join([raw(i18n_text), "bar"]))
                       ^^^ Tagging a string as html safe may be a security risk.
      RUBY
    end
  end
end
