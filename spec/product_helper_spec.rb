require_relative "../lib/signup/product_helper"

describe ProductHelper do

  subject do
    Class.new { include(ProductHelper) }.new
  end

  describe "#products" do
    it "should returns all products" do
      expect(subject.products).to eq([
        :supporter,
        :member,
        :sponsor,
        :partner
      ])
    end
  end

  describe "#product_value" do
    context "product is supporter" do
      it "should be 60" do
        expect(subject.product_value("supporter")).to eq(60)
      end
    end

    context "product is sponsor" do
      it "should be 25000" do
        expect(subject.product_value("sponsor")).to eq(25000)
      end
    end

    context "product is partner" do
      it "should be 50000" do
        expect(subject.product_value("partner")).to eq(50000)
      end
    end

    context "product is individual" do
      it "should be 108" do
        expect(subject.product_value("individual")).to eq(108)
      end
    end

    context "product is student" do
      it "should be 0" do
        expect(subject.product_value("student")).to eq(0)
      end
    end

    context "product does not exist" do
      it "should raise an error" do
        expect { subject.product_value("does-not-exist") }.to raise_error(
          ArgumentError, "Unknown product value does-not-exist"
        )
      end
    end
  end

  describe "#product_duration" do
    context "product is individual" do
      it "should be 1" do
        expect(subject.product_duration("individual")).to eq(1)
      end
    end

    context "product is student" do
      it "should be 1" do
        expect(subject.product_duration("student")).to eq(1)
      end
    end

    context "product is supporter" do
      it "should be 12" do
        expect(subject.product_duration("supporter")).to eq(12)
      end
    end

    context "product is sponsor" do
      it "should be 3" do
        expect(subject.product_duration("sponsor")).to eq(3)
      end
    end

    context "product is partner" do
      it "should be 3" do
        expect(subject.product_duration("partner")).to eq(3)
      end
    end

    context "product does not exist" do
      it "should raise an error" do
        expect { subject.product_duration("does-not-exist") }.to raise_error(
          ArgumentError, "Unknown product duration does-not-exist"
        )
      end
    end
  end

  describe "#product_basis" do
    context "product is supporter" do
      it "should be 'MONTH'" do
        expect(subject.product_basis("supporter")).to eq("MONTH")
      end
    end

    context "product is sponsor" do
      it "should be 'YEAR'" do
        expect(subject.product_basis("sponsor")).to eq("YEAR")
      end
    end

    context "product is partner" do
      it "should be 'YEAR'" do
        expect(subject.product_basis("partner")).to eq("YEAR")
      end
    end

    context "product is individual" do
      it "should be 'YEAR'" do
        expect(subject.product_basis("individual")).to eq("YEAR")
      end
    end

    context "product is student" do
      it "should be 'YEAR'" do
        expect(subject.product_basis("student")).to eq("YEAR")
      end
    end

    context "product does not exist" do
      it "should raise an error" do
        expect { subject.product_basis("does-not-exist") }.to raise_error(
          ArgumentError, "Unknown product basis does-not-exist"
        )
      end
    end
  end
end

