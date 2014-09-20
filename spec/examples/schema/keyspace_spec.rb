# -*- encoding : utf-8 -*-
require File.expand_path('../../../environment', __FILE__)
require 'cequel'
require 'tzinfo'

Dir.glob(File.expand_path('../../../support/**/*.rb', __FILE__)).each do |file|
  require file
end
Dir.glob(File.expand_path('../../../shared/**/*.rb', __FILE__)).each do |file|
  require file
end

RSpec.configure do |config|
  config.include(Cequel::SpecSupport::Helpers)
  config.extend(Cequel::SpecSupport::Macros)

  config.filter_run_excluding rails: ->(requirement) {
    !Gem::Requirement.new(requirement).
      satisfied_by?(Gem::Version.new(ActiveSupport::VERSION::STRING))
  }
=begin
  unless defined? CassandraCQL
    config.filter_run_excluding thrift: true
  end

  config.before(:all) do
    cequel.schema.create!
    Cequel::Record.connection = cequel
    Time.zone = 'UTC'
    I18n.enforce_available_locales = false
    SafeYAML::OPTIONS[:default_mode] = :safe if defined? SafeYAML
  end

  config.after(:all) do
    cequel.schema.drop!
  end

  config.after(:each) { Timecop.return }
=end
end

if defined? byebug
  Kernel.module_eval { alias_method :debugger, :byebug }
end

describe Cequel::Schema::Keyspace do
  describe "#create!" do
    let(:connection) { double(Cequel::Metal::Keyspace) }
    let(:keyspace) { double('keyspace', name: nil)}
    before do
      allow(Cequel::Metal::Keyspace).to receive(:new).and_return(connection)
    end
    context "when no strategy_class is specified in the keyspace configuration file" do
      it 'creates a keyspace of SimpleStrategy class' do
        expect(connection).to receive(:execute).with do |statement|
          expect(statement).to include("'class': 'SimpleStrategy'")
        end
        subject.create!({})
      end
    end
    context "when settings are passed via keyspace configuration file" do

      it 'creates a keyspace of SimpleStrategy with a replication_factor of 1' do
=begin
        set keyspace.configuration to
        {
          :strategy_class => 'NetworkTopologyStrategy',
          :strategy_options => {
            'DC1' => '2',
            'DC2' => '1'
          }
        }
=begin
        TODO
        connection.should_receive(:execute).with("
CREATE KEYSPACE #{keyspace.name} WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'DC1': '2',
  'DC2': '1'
};")
        Cequel::Record.connection.schema.create!
=end
      end
    end
  end
end

=begin
      def create!(options = {})
        bare_connection =
          Metal::Keyspace.new(keyspace.configuration.except(:keyspace))

        options = options.symbolize_keys
        options[:class] ||= keyspace.configuration[:strategy_class]
        options.reverse_merge!(keyspace.configuration[:strategy_options])
        options[:class] ||= 'SimpleStrategy'
        if options[:class] == 'SimpleStrategy'
          options[:replication_factor] ||= 1
        end
        options_strs = options.map do |name, value|
          "'#{name}': #{Cequel::Type.quote(value)}"
        end

        bare_connection.execute(<<-CQL)
          CREATE KEYSPACE #{keyspace.name}
          WITH REPLICATION = {#{options_strs.join(', ')}}
        CQL
      end
=end