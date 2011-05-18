require 'spec_helper'

describe UEncode::Response do
  context "errors" do
    let(:response) { UEncode::Response.new :code => code, :message => "whatever" }

    context "when initialized with a 'BadRequest' code" do
      let(:code) { 'BadRequest' }

      it "raises a UEncode::Response::BadRequestError error containing the error message" do
        expect { response }.to raise_error(UEncode::Response::BadRequestError, "whatever")
      end
    end

    context "when initialized with a 'InvalidKey' code" do
      let(:code) { 'InvalidKey' }

      it "raises a UEncode::Response::InvalidKeyError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::InvalidKeyError, "whatever")
      end
    end

    context "when initialized with a 'NotActive' code" do
      let(:code) { 'NotActive' }

      it "raises a UEncode::Response::NotActiveError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::NotActiveError, "whatever")
      end
    end

    context "when initialized with a 'ServerError' code" do
      let(:code) { 'ServerError' }

      it "raises a UEncode::Response::ServerError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::ServerError, "whatever")
      end
    end

    context "when initialized with an unknown code" do
      let(:code) { 'Ffffuuuuu' }

      it "raises a UEncode::Response::UnknownError containing the error code and the error message" do
        expect { response }.to raise_error(UEncode::Response::UnknownError, "Ffffuuuuu: whatever")
      end
    end
  end

end
