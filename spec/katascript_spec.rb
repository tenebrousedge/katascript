# frozen_string_literal: true

require 'ks_helper'

RSpec.describe(Katascript) do
  it 'has a version number' do
    expect(Katascript::VERSION).not_to be nil
  end
  let(:ks) { described_class.new }

  describe 'math' do
    it 'can perform addition' do
      expect(ks.input('1 + 1')).to eq(2)
    end

    it 'can perform subtraction' do
      expect(ks.input('1 - 1')).to eq(0)
    end

    it 'can perform multiplication' do
      expect(ks.input('2 * 2')).to eq(4)
    end

    it 'can perform division' do
      expect(ks.input('4 / 2')).to eq(2)
    end

    it 'can perform modulo' do
      expect(ks.input('5 % 2')).to eq(1)
    end
  end

  describe 'assignment' do
    before { ks.input('a = 1') }

    it 'can perform assignment' do
      expect(ks.input('a')).to eq(1)
    end

    it 'can perform operations with variables' do
      expect(ks.input('a + 1')).to eq(2)
    end

    it 'can assign variables using the same variable' do
      expect(ks.input('a = a + 1')).to eq(2)
    end

    it 'will error if the variable is not defined' do
      expect(ks.input('b')).to eq("ERROR: Invalid identifier. No variable with name 'b' was found.")
    end
  end

  describe 'parentheses' do
    it 'can perform operations with parentheses' do
      expect(ks.input('4 * ( 1 + 1 )')).to eq(8)
    end

    it 'can perform operations with multiple parentheses' do
      expect(ks.input('4 * ( 1 + ( 1 + 1 ) )')).to eq(12)
    end
  end

  describe 'precedence' do
    it 'can perform operations with precedence' do
      expect(ks.input('1 + 2 * 3')).to eq(7)
    end

    it 'can perform operations with precedence and parentheses' do
      expect(ks.input('1 + 2 * ( 3 + 1 )')).to eq(9)
    end
  end
end
