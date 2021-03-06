require 'spec_helper'

class EmbeddedParent
  include Mongoidal::RootDocument
  embeds_many :embedded_examples
end

class EmbeddedExample
  include Mongoidal::EmbeddedDocument
  embedded_in :embedded_parent
  embeds_many :deep_embedded_examples
end

class DeepEmbeddedExample
  include Mongoidal::EmbeddedDocument
  embedded_in :embedded_example
end

describe Mongoidal::EmbeddedDocument do
  let(:parent) { EmbeddedParent.create }
  subject(:child) { parent.embedded_examples.create }

  context '1 level deep' do
    its(:_parent) { should eq parent }
    its(:_root) { should eq parent }
    its(:created_at) { should_not be_nil }
  end

  context '2 levels deep' do
    subject(:deep_child) { child.deep_embedded_examples.create }

    its(:_parent) { should eq child }
    its(:_root) { should eq parent }
  end
end

