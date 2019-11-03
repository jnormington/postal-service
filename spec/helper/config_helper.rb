# frozen_string_literal: true

module ConfigHelper
  def build_config_content(postcodes = nil, lsoa = nil)
    JSON.generate(
      postcode: {
        lsoa_whitelist: lsoa || %w[
          Southwark
          Lambeth
        ],

        overrides: postcodes || %w[
          SH241AA
          SH241AB
        ]
      }
    )
  end
end
