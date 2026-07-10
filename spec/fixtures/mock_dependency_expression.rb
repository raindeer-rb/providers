# frozen_string_literal: true

require 'low_type'

class MockDependencyExpression
  include LowType

  attr_reader :manual, :automatic

  def initialize(manual:, automatic: Dependency | :different_name)
    @manual = manual
    @automatic = automatic
  end
end
