# frozen_string_literal: true

require 'ks_helper'

RSpec.describe(Katascript::Lexer) do
  describe 'tokenize' do
    it 'can tokenize simple math' do
      expect(described_class['1 + 1'].tokens).to eq(%w[1 + 1])
    end

    it 'can tokenize math with variables' do
      expect(described_class['a + 1'].tokens).to eq(%w[a + 1])
    end

    it 'can tokenize assignment' do
      expect(described_class['a = 1'].tokens).to eq(%w[a = 1])
    end
  end
end
