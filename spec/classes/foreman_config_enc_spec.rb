require 'spec_helper'

describe 'foreman::config::enc' do

  describe 'without custom parameters' do

    it 'should set up enc' do
      should contain_file('/etc/puppet/node.rb').with({
        :content => /api\/hosts\/facts/,
        :mode    => '0550',
        :owner   => 'puppet',
        :group   => 'puppet',
      })
    end
  end

  describe 'with old enc api' do
    let :pre_condition do
      "class {'foreman::config::enc': enc_api => '1.2'}"
    end

    it 'should set up the 1.2 enc' do
      should contain_file('/etc/puppet/node.rb').with({
        :content => /fact_values\/create/,
        :mode    => '0550',
        :owner   => 'puppet',
        :group   => 'puppet',
      })
    end

  end
end
