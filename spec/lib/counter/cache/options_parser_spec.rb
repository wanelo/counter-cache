require 'spec_helper'

RSpec.describe Counter::Cache::OptionsParser do

  subject(:parser) { Counter::Cache::OptionsParser.new options }
  let(:options) { {} }

  describe "#cached?" do
    describe "if cache is nil" do
      it "it should be true" do
        expect(parser.cached?).to eq(true)
      end
    end

    describe "if cache is false" do
      let(:options) { { cache: false } }
      it "it should be false" do
        expect(parser.cached?).to eq(false)
      end
    end

    describe "if cache is true" do
      let(:options) { { cache: true } }
      it "it should be false" do
        expect(parser.cached?).to eq(true)
      end
    end
  end

  describe "#column" do
    let(:options) { { column: "column_name" } }
    it "returns option if set" do
      expect(parser.column).to eq("column_name")
    end
  end

  describe "#method" do
    let(:options) { { method: "method" } }
    it "returns option if set" do
      expect(parser.method).to eq("method")
    end
  end

  describe "#polymorphic" do
    let(:options) { { polymorphic: true } }

    it "returns option if set" do
      expect(parser.polymorphic?).to eq(true)
    end
  end

  describe "#if_value" do
    let(:options) { { if: true } }

    it "returns option if set" do
      expect(parser.if_value).to eq(true)
    end
  end

  describe "#recalculation?" do
    describe "if cache is nil" do
      it "it should be true" do
        expect(parser.recalculation?).to eq(true)
      end
    end

    describe "if cache is false" do
      let(:options) { { recalculation: false } }
      it "it should be false" do
        expect(parser.recalculation?).to eq(false)
      end
    end

    describe "if cache is true" do
      let(:options) { { recalculation: true } }
      it "it should be false" do
        expect(parser.recalculation?).to eq(true)
      end
    end
  end

  describe "#recalculation_delay" do
    describe "With a option" do
      let(:options) { { recalculation_delay: 1245 } }
      it "returns if option is set" do
        expect(parser.recalculation_delay).to eq(1245)
      end
    end

    describe "With no option" do
      it "returns default if no option is set" do
        Counter::Cache.configure do |config|
          config.recalculation_delay = 897
        end
        expect(parser.recalculation_delay).to eq(897)
      end
    end
  end

  describe "#relation" do
    let(:options) { { relation: "relation_name" } }
    it "returns option if set" do
      expect(parser.relation).to eq("relation_name")
    end
  end

  describe "#relation_class_name" do
    let(:options) { { relation_class_name: "relation_class_name" } }
    it "returns option if set" do
      expect(parser.relation_class_name).to eq("relation_class_name")
    end
  end

  describe "#relation_id" do
    let(:options) { { relation_id: 1 } }

    it "returns option if set" do
      expect(parser.relation_id).to eq(1)
    end
  end

  describe "#source_object_class_name" do
    let(:options) { { source_object_class_name: "class_name" } }
    it "returns option if set" do
      expect(parser.source_object_class_name).to eq("class_name")
    end
  end

  describe "#wait" do
    let(:source_object) { double("src_obj") }

    describe "with a value" do
      let(:options) { { wait: 1234 } }

      it "returns option if set" do
        expect(parser.wait(source_object)).to eq(1234)
      end
    end

    describe "with a proc" do
      let(:wait_double) { double("callee", call: 123456) }
      let(:options) { { wait: wait_double } }

      it "returns option if set" do
        expect(parser.wait(source_object)).to eq(123456)
      end
    end
  end


  describe "#worker" do
    describe "With a specified worker" do
      let(:options) { { worker_adapter: "Fake" } }
      it "returns worker on option" do
        expect(parser.worker_adapter).to eq("Fake")
      end
    end

    describe "With no options" do
      let(:options) { {} }
      let(:clazz) { Class.new }

      before do
        Counter::Cache.configure do |config|
          config.default_worker_adapter = clazz
        end
      end

      it "returns worker on option" do
        expect(parser.worker_adapter).to eq(clazz)
      end
    end
  end


end
