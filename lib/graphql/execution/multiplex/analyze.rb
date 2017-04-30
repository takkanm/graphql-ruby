# frozen_string_literal: true
module GraphQL
  module Execution
    class Multiplex
      module Analyze
        module_function

        # This isn't going to work: we'll end up running analyzers even for invalid queries.
        # Need more decoupling!
        def analyze(multiplex)
          multiplex_analyzers = multiplex.schema.multiplex_analyzers
          m_results, q_results = GraphQL::Analysis.analyze_multiplex(multiplex, multiplex_analyzers)

          multiplex_analysis_errors = errors(m_results)

          multiplex.queries.each_with_index do |query, idx|
            q_result = q_results[idx]
            query_errors = errors(q_result)
            query_errors.concat(multiplex_analysis_errors)
            query.analysis_errors = query_errors
          end

          multiplex_analysis_errors
        end

        def errors(results)
          results
            .flatten # accept n-dimensional array
            .select { |r| r.is_a?(GraphQL::AnalysisError) }
        end
      end
    end
  end
end
