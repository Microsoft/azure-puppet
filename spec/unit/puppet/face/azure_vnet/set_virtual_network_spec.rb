require 'spec_helper'

describe Puppet::Face[:azure_vnet, :current] do
  let(:vnet_service) { Azure::VirtualNetworkManagementService }
  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      virtual_network_name: 'login-name',
      affinity_group_name: 'AG1',
      address_space: '172.16.0.0/12,10.0.0.0/8,192.168.0.0/24',
      dns_servers: 'dns-1:8.8.8.8,dns-2:8.8.4.4',
      subnets: 'subnet-1:172.16.0.0:12,subnet-2:192.168.0.0:29',
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vnet_service.any_instance.stubs(:set_network_configuration).with(
      any_parameters
    )
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.set(@options) }.to_not raise_error
      end

    end

    describe '(virtual_network_name)' do
      it 'should validate the virtual network name' do
        @options.delete(:virtual_network_name)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: virtual_network_name/
        )
      end
    end

    describe '(affinity_group_name)' do
      it 'should validate the affinity group name' do
        @options.delete(:affinity_group_name)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: affinity_group_name/
        )
      end
    end

    describe '(address_space)' do
      it 'should validate address space' do
        @options.delete(:address_space)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: address_space/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :set
  end

  describe 'optional parameter validation' do
    before :each do
      vnet_service.any_instance.stubs(:create_affinity_group).with(
        any_parameters
      )
    end

    describe '(subnets)' do
      it 'subnets should be optional' do
        @options.delete(:subnets)
        expect { subject.set(@options) }.to_not raise_error
      end
    end

    describe '(dns_servers)' do
      it 'dns_servers should be optional' do
        @options.delete(:dns_servers)
        expect { subject.set(@options) }.to_not raise_error
      end

      it 'dns_servers and subnets should be optional' do
        @options.delete(:dns_servers)
        @options.delete(:subnets)
        expect { subject.set(@options) }.to_not raise_error
      end
    end
  end

end