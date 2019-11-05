defmodule MoneyTest.Parse do
  use ExUnit.Case

  describe "Money.parse/2 " do
    test "parses with currency code in front" do
      assert Money.parse("USD 100") == Money.new(:USD, 100)
      assert Money.parse("USD100") == Money.new(:USD, 100)
      assert Money.parse("USD 100 ") == Money.new(:USD, 100)
      assert Money.parse("USD100 ") == Money.new(:USD, 100)
      assert Money.parse("USD 100.00") == Money.new(:USD, "100.00")
    end

    test "parses with a single digit amount" do
      assert Money.parse("USD 1") == Money.new(:USD, 1)
      assert Money.parse("USD1") == Money.new(:USD, 1)
      assert Money.parse("USD9") == Money.new(:USD, 9)
    end

    test "parses with currency code out back" do
      assert Money.parse("100 USD") == Money.new(:USD, 100)
      assert Money.parse("100USD") == Money.new(:USD, 100)
      assert Money.parse("100 USD ") == Money.new(:USD, 100)
      assert Money.parse("100USD ") == Money.new(:USD, 100)
      assert Money.parse("100.00USD") == Money.new(:USD, "100.00")
    end

    test "parsing with currency strings that are not codes" do
      assert Money.parse("australian dollar 12346.45") == Money.new(:AUD, "12346.45")
      assert Money.parse("12346.45 australian dollars") == Money.new(:AUD, "12346.45")
    end

    test "parses with locale specific separators" do
      assert Money.parse("100,00USD", locale: "de") == Money.new(:USD, "100.00")
    end

    test "parses euro (unicode symbol)" do
      assert Money.parse("99.99€") == Money.new(:EUR, "99.99")
    end

    test "parses negative amounts" do
      assert Money.parse("-100 USD") == Money.new(:USD, -100)
      assert Money.parse("-USD 100") == Money.new(:USD, -100)
      assert Money.parse("USD -100") == Money.new(:USD, -100)
      assert Money.parse("USD -100.00") == Money.new(:USD, "-100.00")
    end

    test "currency filtering" do
      assert Money.parse("100 Mexican silver pesos") == Money.new(:MXP, 100)

      assert Money.parse("100 Mexican silver pesos", currency_filter: [:current, :tender]) ==
               {:error,
                {Money.Invalid, "Unable to create money from \"mexican silver pesos\" and \"100\""}}
    end

    test "fuzzy matching of currencies" do
      assert Money.parse("100 eurosports", fuzzy: 0.8) == Money.new(:EUR, 100)

      assert Money.parse("100 eurosports", fuzzy: 0.9) ==
               {:error, {Money.Invalid, "Unable to create money from \"eurosports\" and \"100\""}}
    end

    test "parsing fails" do
      assert Money.parse("100") ==
               {:error,
                {Money.Invalid, "A currency code must be specified but was not found in \"100\""}}

      assert Money.parse("EUR") ==
               {:error, {Money.Invalid, "An amount must be specified but was not found in \"EUR\""}}

      assert Money.parse("EUR 100 USD") ==
               {:error,
                {Money.Invalid,
                 "A currency code can only be specified once. Found both \"eur\" and \"usd\"."}}

      assert Money.parse("EUR 100 And some bogus extra stuff") ==
               {:error,
                {Money.Invalid,
                 "A currency code can only be specified once. " <>
                   "Found both \"eur\" and \"and some bogus extra stuff\"."}}
    end
  end
end
