require 'spec_helper'

RSpec.describe DatabaseCleaner::ActiveRecord::SeededDeletion do
  let(:connection) { double('connection') }
  let(:strategy) { described_class.new }

  before do
    allow(strategy).to receive(:connection).and_return(connection)
    allow(connection).to receive(:transaction).and_yield
  end

  describe '#start' do
    before do
      allow(strategy).to receive(:table_max_id_hash).and_return({'users' => 10, 'posts' => 5})
      if defined?(Rails)
        allow(Rails.logger).to receive(:info)
      end
    end

    it 'caches the maximum IDs for each table' do
      strategy.start
      expect(described_class.table_max_id_cache).to eq({'users' => 10, 'posts' => 5})
    end
  end

  describe '#clean' do
    before do
      described_class.table_max_id_cache = {'users' => 10, 'posts' => 5}
      allow(strategy).to receive(:tables_to_clean).and_return(['users', 'posts', 'comments'])
      allow(connection).to receive(:execute)
      allow(connection).to receive(:quote_table_name) { |table_name| "\"#{table_name}\"" }
      allow(connection).to receive(:quote) { |value| "'#{value}'" }
    end

    it 'deletes records with IDs greater than the cached max ID' do
      expect(connection).to receive(:execute).with('DELETE FROM "users" WHERE id > \'10\'')
      expect(connection).to receive(:execute).with('DELETE FROM "posts" WHERE id > \'5\'')
      expect(strategy).to receive(:delete_table).with(connection, 'comments').and_call_original

      strategy.clean
    end
  end

  describe '#table_max_id_hash' do
    before do
      allow(strategy).to receive(:tables_to_clean).and_return(['users', 'posts'])
      allow(connection).to receive(:select_value).with(/information_schema/).and_return(true)
      allow(connection).to receive(:quote) { |value| "'#{value}'" }
      allow(connection).to receive(:quote_table_name) { |table_name| "\"#{table_name}\"" }
    end

    it 'queries the maximum ID for each table' do
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "users"').and_return(10)
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "posts"').and_return(5)

      result = strategy.send(:table_max_id_hash)
      expect(result).to eq({'users' => 10, 'posts' => 5})
    end

    it 'skips tables without rows' do
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "users"').and_return(nil)
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "posts"').and_return(5)

      result = strategy.send(:table_max_id_hash)
      expect(result).to eq({'posts' => 5})
    end

    it 'handles errors gracefully' do
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "users"').and_raise("Error")
      expect(connection).to receive(:select_value).with('SELECT MAX(id) FROM "posts"').and_return(5)

      result = strategy.send(:table_max_id_hash)
      expect(result).to eq({'posts' => 5})
    end
  end
end
