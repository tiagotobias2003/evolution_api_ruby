# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EvolutionApi::Client do
  let(:client) { described_class.new }

  before do
    # Mock das respostas HTTP
    allow(client.class).to receive(:get).and_return(double(
      code: 200,
      body: '{"success": true, "data": []}'
    ))
    allow(client.class).to receive(:post).and_return(double(
      code: 200,
      body: '{"success": true, "data": {}}'
    ))
    allow(client.class).to receive(:delete).and_return(double(
      code: 200,
      body: '{"success": true}'
    ))
  end

  describe '#list_instances' do
    it 'returns list of instances' do
      allow(client.class).to receive(:get).with('/instance/fetchInstances', any_args).and_return(double(
        code: 200,
        body: '[{"instance": "test1"}, {"instance": "test2"}]'
      ))

      response = client.list_instances
      expect(response).to be_an(Array)
      expect(response.length).to eq(2)
    end
  end

  describe '#create_instance' do
    it 'creates a new instance' do
      allow(client.class).to receive(:post).with('/instance/create', any_args).and_return(double(
        code: 201,
        body: '{"success": true, "instance": "test_instance"}'
      ))

      response = client.create_instance('test_instance', {
        qrcode: true,
        webhook: 'https://example.com/webhook'
      })
      expect(response).to be_a(Hash)
    end
  end

  describe '#connect_instance' do
    it 'connects an instance' do
      allow(client.class).to receive(:post).with('/instance/connect/test_instance', any_args).and_return(double(
        code: 200,
        body: '{"success": true, "status": "connected"}'
      ))

      response = client.connect_instance('test_instance')
      expect(response).to be_a(Hash)
    end
  end

  describe '#get_instance' do
    it 'returns instance information' do
      allow(client.class).to receive(:get).with('/instance/fetchInstances/test_instance', any_args).and_return(double(
        code: 200,
        body: '{"instance": "test_instance", "status": "connected"}'
      ))

      response = client.get_instance('test_instance')
      expect(response).to be_a(Hash)
      expect(response['instance']).to eq('test_instance')
    end
  end

  describe '#send_text_message' do
    it 'sends text message successfully' do
      allow(client.class).to receive(:post).with('/message/sendText/test_instance', any_args).and_return(double(
        code: 200,
        body: '{"success": true, "messageId": "123"}'
      ))

      response = client.send_text_message(
        'test_instance',
        '5511999999999',
        'Test message'
      )
      expect(response).to be_a(Hash)
    end
  end

  describe '#send_image_message' do
    it 'sends image message successfully' do
      allow(client.class).to receive(:post).with('/message/sendImage/test_instance', any_args).and_return(double(
        code: 200,
        body: '{"success": true, "messageId": "456"}'
      ))

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
    it 'returns list of chats' do
      allow(client.class).to receive(:get).with('/chat/findChats/test_instance', any_args).and_return(double(
        code: 200,
        body: '[{"id": "chat1"}, {"id": "chat2"}]'
      ))

      response = client.get_chats('test_instance')
      expect(response).to be_an(Array)
    end
  end

  describe '#get_contacts' do
    it 'returns list of contacts' do
      allow(client.class).to receive(:get).with('/contact/findContacts/test_instance', any_args).and_return(double(
        code: 200,
        body: '[{"id": "contact1"}, {"id": "contact2"}]'
      ))

      response = client.get_contacts('test_instance')
      expect(response).to be_an(Array)
    end
  end

  describe '#set_webhook' do
    it 'sets webhook configuration' do
      allow(client.class).to receive(:post).with('/webhook/set/test_instance', any_args).and_return(double(
        code: 200,
        body: '{"success": true, "webhook": "https://example.com/webhook"}'
      ))

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
      it 'raises NotFoundError' do
        allow(client.class).to receive(:get).with('/instance/fetchInstances/nonexistent_instance', any_args).and_return(double(
          code: 404,
          body: '{"error": "Instance not found"}'
        ))

        expect {
          client.get_instance('nonexistent_instance')
        }.to raise_error(EvolutionApi::NotFoundError)
      end
    end

    context 'when authentication fails' do
      it 'raises AuthenticationError' do
        allow(client.class).to receive(:get).with('/instance/fetchInstances', any_args).and_return(double(
          code: 401,
          body: '{"error": "Unauthorized"}'
        ))

        expect {
          client.list_instances
        }.to raise_error(EvolutionApi::AuthenticationError)
      end
    end
  end
end
