# frozen_string_literal: true

class FakeController
  include ErrorHandler

  def halt(*args)
    OpenStruct.new(
      code: args[0],
      headers: args[1],
      body: args[2]
    )
  end
end

RSpec.describe ErrorHandler do
  subject { FakeController.new }

  describe '#halt_with_error' do
    it 'sets the content type' do
      expect(subject.halt_with_error(400, '', '').headers).to eq(
        'Content-Type' => 'application/json'
      )
    end

    it 'sets the status code' do
      expect(subject.halt_with_error(401, '', '').code).to eq 401
    end

    it 'creates json encoded body with error and message' do
      expect(subject.halt_with_error(0, 'errCode', 'i errored').body).to eq(
        '{"err":"errCode","message":"i errored"}'
      )
    end
  end
end
