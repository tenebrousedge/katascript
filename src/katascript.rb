# frozen_string_literal: true

require 'pry'
require 'delegate'

class Katascript
  VERSION = '0.1.0'

  def initialize
    @env = {}
  end

  def input(input)
    tokens = Lexer[input].tokens
    ast = Parser[tokens].ast
    Interpreter[ast, @env].eval
  end

  class Lexer
    def initialize(input)
      @input = input
    end

    def self.[](input)
      new(input)
    end

    def tokens
      @tokens ||= tokenize
    end

    private

    def tokenize(program = @input)
      return [] if program == ''

      regex = %r{\s*([-+*/%=()]|[A-Za-z_][A-Za-z0-9_]*|[0-9]*\.?[0-9]+)\s*}
      program.scan(regex).flatten.grep_v(/^\s*$/)
    end
  end

  class Parser
    OPERATORS = {
      '+' => {name: :add, precedence: 1},
      '-' => {name: :sub, precedence: 1},
      '*' => {name: :mul, precedence: 2},
      '/' => {name: :div, precedence: 2},
      '%' => {name: :mod, precedence: 2},
      '(' => {name: :paren, precedence: 0},
    }.freeze

    def initialize(tokens)
      @tokens = tokens
      @output = []
      @operators = []
    end

    def self.[](tokens)
      new(tokens)
    end

    def ast
      @ast ||= parse
    end

    private

    def parse(tokens = @tokens)
      children = []
      children << expression while tokens.any?
      children
    end

    def expression
      output = []
      operators = []
      while @tokens.any?
        token = @tokens.shift
        case token
        when /\A[0-9]*\.?[0-9]+\z/
          output << [:number, token.to_f]
        when /\A[A-Za-z_][A-Za-z0-9_]*\z/
          output << (@tokens.first == '=' ? assignment(token) : [:identifier, token])
        when '('
          operators << token
        when ')'
          output << [OPERATORS[operators.pop][:name], *output.pop(2)] while operators.last != '('
          operators.pop
        when *OPERATORS.keys
          operator(token, operators, output)
        else
          raise "Unexpected token: #{token}"
        end
      end
      output << [OPERATORS[operators.pop][:name], *output.pop(2)] while operators.any?
      output.pop
    end

    def operator(token, operators, output)
      while operators.any? && OPERATORS[operators.last][:precedence] >= OPERATORS[token][:precedence]
        output << [OPERATORS[operators.pop][:name], *output.pop(2)]
      end
      operators << token
    end

    def assignment(token)
      @tokens.shift
      [:assign, token, expression]
    end
  end

  class Interpreter
    InvalidIdentifierError = Class.new(StandardError) do
      def initialize(message)
        super("ERROR: Invalid identifier. No variable with name '%s' was found." % message)
      end
    end

    def initialize(ast, env = {})
      @ast = ast
      @env = env
    end

    def self.[](ast, env = {})
      new(ast, env)
    end

    def eval
      @result ||= evaluate
    end

    private

    def evaluate
      last_value = nil
      @ast.each do |node|
        last_value = evaluate_node(node)
      end
      last_value
    rescue InvalidIdentifierError => e
      e.message
    end

    def evaluate_node(node)
      case node.first
      when :number
        node[1]
      when :identifier
        @env.fetch(node[1]) { raise(InvalidIdentifierError, node[1]) }
      when :assign
        @env[node[1]] = evaluate_node(node[2])
      when :add, :sub, :mul, :div, :mod
        evaluate_operator(node[0], node[1], node[2])
      when :paren
        evaluate_node(node[2])
      end
    end

    def evaluate_operator(op, first, second)
      left = evaluate_node(first)
      right = evaluate_node(second)
      case op
      when :add
        left + right
      when :sub
        left - right
      when :mul
        left * right
      when :div
        left / right
      when :mod
        left % right
      end
    end
  end
end
