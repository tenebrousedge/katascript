# frozen_string_literal: true

require 'ks_helper'

RSpec.describe(Katascript::Parser) do
  describe 'parse' do
    it 'can parse simple math' do
      expected = [[:add, [:number, 1.0], [:number, 1.0]]]
      expect(described_class[%w[1 + 1]].ast).to eq(expected)
    end

    it 'can parse math with variables' do
      expected = [[:add, [:identifier, 'a'], [:number, 1.0]]]
      expect(described_class[%w[a + 1]].ast).to eq(expected)
    end

    it 'can parse assignment' do
      expect(described_class[%w[a = 1]].ast).to eq([[:assign, 'a', [:number, 1.0]]])
    end

    it 'can parse math with assignment' do
      expected = [[:assign, 'a', [:add, [:number, 1], [:number, 1]]]]
      expect(described_class[%w[a = 1 + 1]].ast).to eq(expected)
    end

    context 'with parentheses' do
      it 'can parse expressions with parentheses' do
        expected = [[:assign, "a", [:mul, [:number, 4.0], [:add, [:number, 1.0], [:number, 1.0]]]]]
        expect(described_class[%w(a = 4 * ( 1 + 1 ))].ast).to eq(expected)
      end

      it 'can parse expressions with multiple parentheses' do
        expected = [[:assign, "a", [:mul, [:number, 4.0], [:add, [:number, 1.0], [:add, [:number, 1.0], [:number, 1.0]]]]]]
        expect(described_class[%w(a = 4 * ( 1 + ( 1 + 1 ) ))].ast).to eq(expected)
      end
    end

    context 'with invalid input' do
    end

    context 'precedence' do
      it 'can parse expressions with multiplication before addition' do
        expected = [[:assign, "a", [:add, [:mul, [:number, 1.0], [:number, 2.0]], [:number, 3.0]]]]
        expect(described_class[%w(a = 1 * 2 + 3)].ast).to eq(expected)
      end

      it 'can parse expressions with division before addition' do
        expected = [[:assign, "a", [:add, [:div, [:number, 4.0], [:number, 2.0]], [:number, 1.0]]]]
        expect(described_class[%w(a = 4 / 2 + 1)].ast).to eq(expected)
      end
    end
  end
end
