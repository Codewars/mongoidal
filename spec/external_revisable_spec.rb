require 'spec_helper'

describe Mongoidal::Revisable do
  let(:fresh) { ExternalRevisableExample.new }
  let(:existing) { ExternalRevisableExample.create(age: 10, name: 'test') }
  let(:embedded) { existing.revisable_embedded_examples.create(name: 'a') }
  let(:user) { User.create }

  describe '#revisable_fields' do
    it 'should have fields marked as revisable' do
      expect(fresh.revisable_fields.to_a).to eq ['age', 'name']
    end
  end

  describe '#revisable_embeds' do
    it 'should return fields marked as revisable' do
      expect(fresh.revisable_embeds[:revisable_embedded_examples].to_a).to eq ['name']
    end
  end

  describe '#revised_changes' do
    subject { existing }
    context 'when there are changes' do
      before { existing.name = 'a' }
      its(:revised_changes) { should eq ({"name" => ["test", "a"]}) }

      it 'should save' do
        existing.revise!
      end
    end
  end

  describe 'auto saving' do
    subject { existing }
    context 'when there are changes' do
      before { existing.name = 'a' }
      its(:revised_changes) { should eq ({"name" => ["test", "a"]}) }
      its(:has_revised_changes?) { should eq true }

      it 'should save' do
        rev = existing.prepare_revision('test', nil)
        expect(rev).to be_changed
        existing.save
        expect(rev).to_not be_changed
      end
    end
  end

  describe 'event type' do
    subject { existing }
    context 'when there are changes' do
      it 'should save' do
        existing.revise!(type: :event, tag: 'clicked', event_data: {path: 'test'})
        expect(existing.reload.revisions[0].revised_attributes['name']).to eq 'test'
        expect(existing.revisions[1].event_data['path']).to eq 'test'
      end
    end
  end

  describe '#revised_embed_changes' do
    subject { existing }
    context 'when there are changes' do
      before { embedded.name = 'b' }

      it 'should report changes' do
        changes = existing.revised_embed_changes[:revisable_embedded_examples]
        expect(changes.first.first).to eq embedded.id.to_s
        expect(changes.first.last).to eq ({"name" => "b"})
      end
    end
  end

  describe '#field_revised?' do
    it 'should be true when revised' do
      existing.name = 'b'
      expect(existing).to be_field_revised(:name)
    end

    it 'should be false when not revised' do
      expect(existing).not_to be_field_revised(:name)
    end
  end

  # TODO: finish migrating specs from main project
end