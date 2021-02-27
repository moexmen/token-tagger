require 'rails_helper'

RSpec.describe Sally::Client do
  let (:endpoint) { 'https://sally-api.gov.sg' }
  let (:api_key) { 'api-key' }

  let (:token_id) { '123456' }

  describe 'transform_contact' do
    let (:client) { Sally::Client.new }
    
    context 'numbers beginning with +' do
      it { expect(client.send(:transform_contact, '+6591234567')).to eq('+6591234567') }
      it { expect(client.send(:transform_contact, '+6111111111111')).to eq('+6111111111111') }
    end
    
    context 'Singapore numbers missing +' do
      it { expect(client.send(:transform_contact, '6591234567')).to eq('+6591234567') }
      it { expect(client.send(:transform_contact, '6561234567')).to eq('+6561234567') }
    end

    context 'blank or nil contact' do
      it { expect(client.send(:transform_contact, '')).to eq('+6588888888') }
      it { expect(client.send(:transform_contact, nil)).to eq('+6588888888') }
    end

    context '8 digit numbers' do
      it { expect(client.send(:transform_contact, '91234567')).to eq('+6591234567') }
      it { expect(client.send(:transform_contact, '12345678')).to eq('+6512345678') }
    end

    context 'numbers with other number of digits' do
      it { expect(client.send(:transform_contact, '123456')).to eq('123456') }
      it { expect(client.send(:transform_contact, '123456789')).to eq('123456789') }
    end
  end

  describe 'assign_token' do
    let (:student) { FactoryBot.create(:student) }

    subject { Sally::Client.new(endpoint, api_key).assign_token(token_id, student.nric, student.contact) }

    context 'token successfully assigned' do
  
      before { stub_request(:post, endpoint).to_return(status: 200) }
        
      it { expect(subject).to eq({ success: true }) }
      it { expect{ subject }.to change{ student.reload.token_id }.from(nil).to(token_id) }
      it { expect{ subject }.to change{ student.reload.status }.from('pending').to('assigned') }
    end
  
    context 'token already assigned to someone else' do  
      before { stub_request(:post, endpoint).to_return(status: 400,  body: { message: Sally::Client::TOKEN_ALREADY_ASSIGNED_MESSAGE }.to_json ) }
    
      it { expect(subject).to eq({ success: false, reason: Sally::TOKEN_ALREADY_ASSIGNED }) }
      it { expect{ subject }.not_to change{ student.reload.token_id } }
      it { expect{ subject }.not_to change{ student.reload.status } }
    end

    context 'token already assigned to someone else - alternative message' do  
      before { stub_request(:post, endpoint).to_return(status: 400,  body: { message: Sally::Client::TOKEN_ALREADY_USED_MESSAGE }.to_json ) }
    
      it { expect(subject).to eq({ success: false, reason: Sally::TOKEN_ALREADY_ASSIGNED }) }
      it { expect{ subject }.not_to change{ student.reload.token_id } }
      it { expect{ subject }.not_to change{ student.reload.status } }
    end 
  
    context 'student already has token' do  
      before { stub_request(:post, endpoint).to_return(status: 400,  body: { message: Sally::Client::PERSON_QUOTA_REACHED }.to_json ) }
    
      it { expect(subject).to eq({ success: false, reason: Sally::PERSON_HAS_TOKEN }) }
      it { expect{ subject }.not_to change{ student.reload.token_id } }
      it { expect{ subject }.to change{ student.reload.status }.from('pending').to('error_quota') }
    end

    context 'NRIC is invalid' do  
      before { stub_request(:post, endpoint).to_return(status: 400,  body: { message: Sally::Client::INVALID_NRIC }.to_json ) }
    
      it { expect(subject).to eq({ success: false, reason: Sally::INVALID_NRIC }) }
      it { expect{ subject }.not_to change{ student.reload.token_id } }
      it { expect{ subject }.to change{ student.reload.status }.from('pending').to('error_nric') }
    end

    context 'HTTP 500 without body from API' do  
      before { stub_request(:post, endpoint).to_return(status: 500) }
    
      it { expect(subject).to eq({ success: false, reason: Sally::API_ERROR }) }
      it { expect{ subject }.not_to change{ student.reload.token_id } }
      it { expect{ subject }.not_to change{ student.reload.status } }
    end
  end
end
