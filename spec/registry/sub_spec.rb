describe Registry, 'sub registries' do
  let!(:base) do
    Class.new do
      include Registry
      register :base
    end
  end

  let!(:sub) do
    Class.new(base) do
      # include Registry
      registry :sub
      register :sub
    end
  end

  describe 'base class' do
    let(:const) { base }

    describe 'class' do
      subject { const }

      it { should have registry_key: :base }
      it { should have registry_name: :default }

      it { should access :base, base }
      it { expect { subject[:sub] }.to raise_error Registry::UnknownKey }

      it { should lookup :sub, sub }
      it { should lookup :base, base }
      it { expect { subject.lookup(:unknown) }.to raise_error Registry::UnknownKey }

      it { should be_registered :base }
      it { should_not be_registered :sub }
      it { should_not be_registered :unknown }
    end

    describe 'instance' do
      subject { const.new }
      it { should have registry_key: :base }
    end
  end

  describe 'sub class' do
    let(:const) { sub }

    describe 'class' do
      subject { const }
      it { should have registry_key: :sub }
      it { should have registry_name: :sub }

      it { should access :sub, sub }
      it { expect { subject[:base] }.to raise_error Registry::UnknownKey }

      it { should lookup :sub, sub }
      it { should lookup :base, base }
      it { expect { subject.lookup(:unknown) }.to raise_error Registry::UnknownKey }

      it { should be_registered :sub }
      it { should_not be_registered :base }
      it { should_not be_registered :unknown }
    end

    describe 'instance' do
      subject { const.new }
      it { should have registry_key: :sub }
    end
  end
end
