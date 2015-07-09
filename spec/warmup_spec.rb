require 'warmup'

describe Parser do

  describe '#parse_tag' do

    let(:tag){subject.parse_tag("<p class='foo bar' id='baz' name='fozzie'>")}

    it 'should take a string with HTML tags and return struct' do
      expect(tag).to be_a Tag
    end

    it 'should return a struct that responds to .type, etc.' do
      expect(tag).to respond_to(:type, :classes, :id, :name, :children, :parent)
    end

    it 'should parse tag' do
      #expect(tag.type).to eq("p")
      expect(tag.classes).to eq(["foo", "bar"])
      expect(tag.id).to eq("baz")
      expect(tag.name).to eq("fozzie")
    end

  end

end