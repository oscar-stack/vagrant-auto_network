require 'spec_helper'

describe AutoNetwork::Pool do
  let(:ip_range) { '10.20.1.0/24' }
  let(:machine_a) do
    machine = double(
      :name => 'machine_a',
      :id   => 'some-uuid',
    )
    machine.stub_chain(:env, :root_path, :to_s).and_return('/some/Vagrantfile')

    machine
  end
  let(:machine_b) do
    machine = double(
      :name => 'machine_b',
      :id   => 'some-uuid',
    )
    machine.stub_chain(:env, :root_path, :to_s).and_return('/some/Vagrantfile')

    machine
  end

  subject { AutoNetwork::Pool.new(ip_range) }

  describe 'requesting an address for a machine' do

    it 'returns the next available address' do
      expect(subject.request(machine_a)).to eq('10.20.1.2')
    end

    it 'is idempotent' do
      subject.request(machine_a)
      expect(subject.request(machine_a)).to eq('10.20.1.2')
    end

    context 'when the pool is full' do
      subject { AutoNetwork::Pool.new('10.20.1.0/30') }

      it 'raises an error' do
        subject.request(machine_a)
        expect { subject.request(machine_b) }.to raise_error(AutoNetwork::Pool::PoolExhaustedError)
      end
    end

  end

  describe 'releasing an address from a machine' do

    it 'makes the address available' do
      subject.request(machine_a)
      subject.release(machine_a)
      expect(subject.request(machine_b)).to eq('10.20.1.2')
    end

  end

  describe 'looking up an address for a machine' do

    it 'returns the address assigned' do
      subject.request(machine_a)
      expect(subject.address_for(machine_a)).to eq('10.20.1.2')
    end

    it 'returns nil for unassigned machines' do
      expect(subject.address_for(machine_b)).to be_nil
    end

  end

end
