# frozen_string_literal: true

# ErrorHandler to respond with json error payload
module ErrorHandler
  def halt_with_error(code, err_code, msg)
    halt(
      code,
      { 'Content-Type' => 'application/json' },
      JSON.generate(err: err_code, message: msg)
    )
  end
end
