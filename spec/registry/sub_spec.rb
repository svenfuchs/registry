describe Registry, 'sub registries' do
  let!(:base) do
    Class.new do
      include Registry
      register :base
    end
  end

  let!(:sub) do
    Class.new(base) do
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

      describe 'unregister' do
        before { subject.unregister }
        it { should have registry_key: nil }
        it { should_not be_registered nil }
      end
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

      describe 'unregister' do
        before { subject.unregister }
        it { should have registry_key: nil }
        it { should_not be_registered nil }
      end
    end

    describe 'instance' do
      subject { const.new }
      it { should have registry_key: :sub }
    end
  end

  describe 'sub classes with conflicting keys' do
    let!(:one) do
      Class.new(base) do
        registry :one
        register :key
      end
    end

    let!(:two) do
      Class.new(base) do
        registry :two
        register :key
      end
    end

    describe ':one' do
      let(:const) { one }

      describe 'class' do
        subject { one }

        it { should have registry_key: :key }
        it { should have registry_name: :one }

        it { should access :key, one }
        it { expect { subject[:two] }.to raise_error Registry::UnknownKey }

        it { should lookup :key, one }
        it { expect { subject.lookup(:unknown) }.to raise_error Registry::UnknownKey }

        it { should be_registered :key }
        it { should_not be_registered :unknown }
      end

      describe 'instance' do
        subject { const.new }
        it { should have registry_key: :key }
      end
    end

    describe 'two' do
      let(:const) { two }

      describe 'class' do
        subject { two }

        it { should have registry_key: :key }
        it { should have registry_name: :two }

        it { should access :key, two }
        it { expect { subject[:one] }.to raise_error Registry::UnknownKey }

        it { should lookup :key, two }
        it { expect { subject.lookup(:unknown) }.to raise_error Registry::UnknownKey }

        it { should be_registered :key }
        it { should_not be_registered :unknown }
      end

      describe 'instance' do
        subject { const.new }
        it { should have registry_key: :key }
      end
    end
  end
end
