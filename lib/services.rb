# frozen_string_literal: true

module Services
  class Scanner
    def self.run
      `./lib/scanner`
    end
  end
end
