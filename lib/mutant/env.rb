# frozen_string_literal: true

module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Anima.new(
      :config,
      :integration,
      :matchable_scopes,
      :mutations,
      :parser,
      :selector,
      :subjects
    )

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Result::Mutation]
    def kill(mutation)
      start = Timer.now

      Result::Mutation.new(
        isolation_result: run_mutation_tests(mutation),
        mutation:         mutation,
        runtime:          Timer.now - start
      )
    end

    # The test selections
    #
    # @return Hash{Mutation => Enumerable<Test>}
    def selections
      subjects.map do |subject|
        [subject, selector.call(subject)]
      end.to_h
    end
    memoize :selections

  private

    # Kill mutation under isolation with integration
    #
    # @return [Result::Isolation]
    def run_mutation_tests(mutation)
      config.isolation.call do
        result = mutation.insert(config.kernel)

        if result.equal?(Loader::Result::VoidValue.instance)
          Result::Test::VoidValue.instance
        else
          integration.call(selections.fetch(mutation.subject))
        end
      end
    end

  end # Env
end # Mutant
