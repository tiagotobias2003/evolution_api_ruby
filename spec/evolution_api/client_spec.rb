# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EvolutionApi::Client do
  let(:client) { described_class.new }

  describe '#list_instances' do
    it 'returns list of instances', :vcr do
      response = client.list_instances
      expect(response).to be_an(Array)
    end
  end

  describe '#create_instance' do
    it 'creates a new instance', :vcr do
      response = client.create_instance('test_instance', {
        qrcode: true,
        webhook: 'https://example.com/webhook'
      })
      expect(response).to be_a(Hash)
    end
  end

  describe '#connect_instance' do
    it 'connects an instance', :vcr do
      response = client.connect_instance('test_instance')
      expect(response).to be_a(Hash)
    end
  end

  describe '#get_instance' do
    it 'returns instance information', :vcr do
      response = client.get_instance('test_instance')
      expect(response).to be_a(Hash)
      expect(response['instance']).to eq('test_instance')
    end
  end

  describe '#send_text_message' do
    it 'sends text message successfully', :vcr do
      response = client.send_text_message(
        'test_instance',
        '5511999999999',
        'Test message'
      )
      expect(response).to be_a(Hash)
    end
  end

  describe '#send_image_message' do
    it 'sends image message successfully', :vcr do
      response = client.send_image_message(
        'test_instance',
        '5511999999999',
        'https://example.com/image.jpg',
        'Test caption'
      )
      expect(response).to be_a(Hash)
    end
  end

  describe '#get_chats' do
    it 'returns list of chats', :vcr do
      response = client.get_chats('test_instance')
      expect(response).to be_an(Array)
    end
  end

  describe '#get_contacts' do
    it 'returns list of contacts', :vcr do
      response = client.get_contacts('test_instance')
      expect(response).to be_an(Array)
    end
  end

  describe '#set_webhook' do
    it 'sets webhook configuration', :vcr do
      response = client.set_webhook(
        'test_instance',
        'https://example.com/webhook',
        ['connection.update', 'message.upsert']
      )
      expect(response).to be_a(Hash)
    end
  end

  describe 'error handling' do
    context 'when instance not found' do
      it 'raises NotFoundError', :vcr do
        expect {
          client.get_instance('nonexistent_instance')
        }.to raise_error(EvolutionApi::NotFoundError)
      end
    end

    context 'when authentication fails' do
      it 'raises AuthenticationError', :vcr do
        EvolutionApi.configure { |c| c.api_key = 'invalid_key' }
        expect {
          client.list_instances
        }.to raise_error(EvolutionApi::AuthenticationError)
      end
    end
  end
end
