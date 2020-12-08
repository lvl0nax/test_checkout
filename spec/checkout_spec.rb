require_relative '../checkout'

describe Checkout do
  let(:product1) { OpenStruct.new(code: '001', name: 'Lavender heart', price: 9.25) }
  let(:product2) { OpenStruct.new(code: '002', name: 'Personalised cufflinks', price: 45.00) }
  let(:product3) { OpenStruct.new(code: '003', name: 'Kids T-shirt', price: 19.95) }

  describe '#scan' do
    it 'counts products and calculates prices' do
      checkout = Checkout.new
      checkout.scan(product1)
      expect(checkout.instance_variable_get('@products')).to eq({ '001' => { price: 9.25, count: 1 }})
    end
  end

  describe '#total' do
    context 'when total price over discount limit' do
      it 'applies total discount' do
        checkout = Checkout.new
        checkout.scan(product1)
        checkout.scan(product2)
        checkout.scan(product3)
        expect(checkout.total).to eq(66.78)
      end
    end

    context 'with multiple discount products' do
      it 'applies appropriate discount' do
        checkout = Checkout.new
        checkout.scan(product1)
        checkout.scan(product3)
        checkout.scan(product1)
        expect(checkout.total).to eq(36.95)
      end

      context 'when total price over discount limit' do
        it 'applies appropriate discount' do
          checkout = Checkout.new
          checkout.scan(product1)
          checkout.scan(product2)
          checkout.scan(product1)
          checkout.scan(product3)
          expect(checkout.total).to eq(73.76)
        end
      end
    end
  end
end

describe TotalPriceDiscount do
  describe '.apply' do
    context 'when total price more than limit' do
      it 'applies discount' do
        expect(TotalPriceDiscount.apply(100)).to eq(90)
      end
    end

    context 'when total price is equal to limit' do
      it 'does not apply discount' do
        expect(TotalPriceDiscount.apply(60)).to eq(60)
      end
    end

    context 'when total price less than limit' do
      it 'does not apply discount' do
        expect(TotalPriceDiscount.apply(40)).to eq(40)
      end
    end
  end
end

describe MultipleProductsDiscount do
  describe '.apply' do
    subject { MultipleProductsDiscount.apply(items) }

    context 'when items not on the discounts list' do
      let(:items) {{ '002' => { count: 5, price: 5 }}}

      it 'does not change items' do
        is_expected.to eq(items)
      end
    end

    context 'when items on the discount list' do
      context 'when number of items not enough for discount' do
        let(:items) {{ '001' => { count: 1, price: 5 }}}

        it 'does not change items' do
          is_expected.to eq(items)
        end
      end

      context 'when number of items enough for discount' do
        let(:items) {{ '001' => { count: 2, price: 9.5 }}}

        it 'changes items according to discount' do
          is_expected.to eq({ '001' => { count: 2, price: 17 }})
        end
      end
    end
  end
end
