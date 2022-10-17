%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true,
      checks: [
        # Design
        {Credo.Check.Design.AliasUsage, priority: :low, if_nested_deeper_than: 2},
        # Readability
        {Credo.Check.Readability.AliasOrder, []},
        {Credo.Check.Readability.FunctionNames, []},
        {Credo.Check.Readability.ImplTrue, []},
        {Credo.Check.Readability.LargeNumbers, []},
        {Credo.Check.Readability.ModuleAttributeNames, []},
        {Credo.Check.Readability.ModuleNames, []},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
        {Credo.Check.Readability.RedundantBlankLines, []},
        {Credo.Check.Readability.Semicolons, []},
        {Credo.Check.Readability.SeparateAliasRequire, []},
        {Credo.Check.Readability.SinglePipe, []},
        {Credo.Check.Readability.SpaceAfterCommas, []},
        {Credo.Check.Readability.StringSigils, []},
        {Credo.Check.Readability.TrailingBlankLine, []},
        {Credo.Check.Readability.TrailingWhiteSpace, []},
        {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
        {Credo.Check.Readability.VariableNames, []},
        # Refactoring
        {Credo.Check.Refactor.AppendSingleItem, []},
        {Credo.Check.Refactor.CyclomaticComplexity, []},
        {Credo.Check.Refactor.DoubleBooleanNegation, []},
        {Credo.Check.Refactor.FunctionArity, max_arity: 5},
        {Credo.Check.Refactor.MatchInCondition, []},
        {Credo.Check.Refactor.NegatedConditionsWithElse, []},
        {Credo.Check.Refactor.NegatedIsNil, []},
        {Credo.Check.Refactor.Nesting, max_nesting: 3},
        {Credo.Check.Refactor.PipeChainStart, []},
        {Credo.Check.Refactor.UnlessWithElse, []},
        {Credo.Check.Refactor.WithClauses, []},
        # Warnings
        {Credo.Check.Warning.IoInspect, []},
        {Credo.Check.Warning.MapGetUnsafePass, []},
        {Credo.Check.Warning.MixEnv, []},
        {Credo.Check.Warning.OperationOnSameValues, []},
        # Consistency
        {Credo.Check.Consistency.ParameterPatternMatching, []},
        {Credo.Check.Consistency.SpaceAroundOperators, []}
      ]
    }
  ]
}
