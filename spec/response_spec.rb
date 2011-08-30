require 'spec_helper'

describe UEncode::Response do
  context "errors" do
    let(:response) { UEncode::Response.new :status => status, :message => "whatever" }

    context "when initialized with a 'BadRequest' status" do
      let(:status) { 'BadRequest' }

      it "raises a UEncode::Response::BadRequestError error containing the error message" do
        expect { response }.to raise_error(UEncode::Response::BadRequestError, "whatever")
      end
    end

    context "when initialized with a 'InvalidKey' status" do
      let(:status) { 'InvalidKey' }

      it "raises a UEncode::Response::InvalidKeyError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::InvalidKeyError, "whatever")
      end
    end

    context "when initialized with a 'NotActive' status" do
      let(:status) { 'NotActive' }

      it "raises a UEncode::Response::NotActiveError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::NotActiveError, "whatever")
      end
    end

    context "when initialized with a 'ServerError' status" do
      let(:status) { 'ServerError' }

      it "raises a UEncode::Response::ServerError containing the error message" do
        expect { response }.to raise_error(UEncode::Response::ServerError, "whatever")
      end
    end

    context "when initialized with an unknown status" do
      let(:status) { 'Ffffuuuuu' }

      it "raises a UEncode::Response::UnknownError containing the error status and the error message" do
        expect { response }.to raise_error(UEncode::Response::UnknownError, "Ffffuuuuu: whatever")
      end
    end

    context "when initialized with a 'Ok' status" do
      let(:status) { 'Ok' }

      it "raises no error" do
        expect { response }.to_not raise_error
      end
    end

    context "when initialized with a 'OK' status" do
      let(:status) { 'OK' }

      it "raises no error" do
        expect { response }.to_not raise_error
      end
    end
  end

end
