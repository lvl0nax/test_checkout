require 'ostruct'

# Example of products
PRODUCTS = [
  OpenStruct.new(code: '001', name: 'Lavender heart', price: 9.25),
  OpenStruct.new(code: '002', name: 'Personalised cufflinks', price: 45.00),
  OpenStruct.new(code: '003', name: 'Kids T-shirt', price: 19.95)
]

module TotalPriceDiscount
  LIMIT = 60
  PERCENT = 10

  def self.apply(total_price)
    return total_price if total_price <= LIMIT

    (total_price * (100 - PERCENT) / 100.0).round(2) # we are working with float for simplicity
  end
end

module MultipleProductsDiscount
  MULTIPLE_PRODUCT_DISCOUNTS = [
    OpenStruct.new(
      code: '001',
      count: 2,
      discounted_price: 8.5
    )
  ]

  def self.apply(items)
    MULTIPLE_PRODUCT_DISCOUNTS.each do |discount|
      next if items[discount.code].nil? || (items[discount.code][:count] < discount.count)

      items[discount.code][:price] = discount.discounted_price * items[discount.code][:count]
    end

    items
  end
end

class Checkout
  def initialize
    @products = Hash.new
  end

  def scan(item)
    @products[item.code] ||= { count: 0, price: 0 }
    @products[item.code][:count] += 1
    @products[item.code][:price] += item.price
  end

  def total
    products = MultipleProductsDiscount.apply(@products)

    total_price = products.sum { |_code, attrs| attrs[:price] }
    TotalPriceDiscount.apply(total_price)
  end
end
