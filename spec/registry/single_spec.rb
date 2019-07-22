describe Registry, 'a single registry' do
  let!(:base) do
    Class.new do
      include Registry
      register :base
    end
  end

  let!(:one) do
    Class.new(base) do
      register :one, :two
    end
  end

  describe 'base class' do
    let(:const) { base }

    describe 'class' do
      subject { const }

      it { should have registry_key: :base }
      it { should have registry_name: :default }

      it { should access :base, base }
      it { should access :one, one }
      it { should access :two, one }

      it { should be_registered :base }
      it { should be_registered :one }
      it { should be_registered :two }
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
    let(:const) { one }

    describe 'class' do
      subject { const }
      it { should have registry_key: :one }
      it { should have registry_name: :default }

      it { should access :base, base }
      it { should access :one, one }
      it { should access :two, one }

      it { should be_registered :base }
      it { should be_registered :one }
      it { should be_registered :two }
      it { should_not be_registered :unknown }

      describe 'unregister' do
        before { subject.unregister }
        it { should have registry_key: nil }
        it { should_not be_registered nil }
      end
    end

    describe 'instance' do
      subject { const.new }
      it { should have registry_key: :one }
    end
  end
end
