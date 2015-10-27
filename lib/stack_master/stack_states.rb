module StackMaster
  module StackStates
    SUCCESS_STATES = %w[
      CREATE_COMPLETE
      UPDATE_COMPLETE
      DELETE_COMPLETE
    ].freeze
    FAILURE_STATES = %w[
      CREATE_FAILED
      DELETE_FAILED
      UPDATE_ROLLBACK_FAILED
      ROLLBACK_FAILED
      ROLLBACK_COMPLETE
      ROLLBACK_FAILED
      UPDATE_ROLLBACK_COMPLETE
      UPDATE_ROLLBACK_FAILED
    ].freeze
    FINISH_STATES = (SUCCESS_STATES + FAILURE_STATES).freeze

    extend self

    def finish_state?(state)
      FINISH_STATES.include?(state)
    end
  end
end
