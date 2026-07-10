# frozen_string_literal: true

require 'low_type'

class MockDependencyClass
  include LowType

  attr_reader :manual, :automatic

  def initialize(manual:, automatic: Dependency)
    @manual = manual
    @automatic = automatic
  end
end
