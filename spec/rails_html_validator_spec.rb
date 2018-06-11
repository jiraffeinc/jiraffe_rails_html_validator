module HtmlValidatorSpec
  class Blog
    include ActiveModel::Validations
    attr_accessor :body
    validates :body, html: true
  end

  class BlogWithExcludeScript < ActiveRecord::Base
    include ActiveModel::Validations
    self.table_name = "html_validator_spec_blogs"
    attr_accessor :body
    validates :body, html: {exclude_tags: %w(script)}
  end

  class BlogWithExcludeAnyTag < ActiveRecord::Base
    include ActiveModel::Validations
    self.table_name = "html_validator_spec_blogs"
    attr_accessor :body
    validates :body, html: {exclude_tags: %w(style script)}
  end
end

RSpec.describe "html validation" do

  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :html_validator_spec_blogs, force: true do |t|
        t.column :body, :string
      end
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:html_validator_spec_blogs)
  end

  context "with regular validator" do
    let(:blog) {::HtmlValidatorSpec::Blog.new}

    it "returns valid" do
      blog.body = "<div>test blog post</div>"
      blog.valid?
      expect(blog).to be_valid
    end

    it "returns a default error message" do
      I18n.locale = :en
      blog.body = "<div>test blog post</div></p>"
      blog.valid?
      expect(blog.errors[:body].first).to eq('is not a valid HTML')
    end

    context "when locale is Japanese" do
      it "returns a Japanese default error message" do
        I18n.locale = :ja
        blog.body = "<div>test blog post</div></p>"
        blog.valid?
        expect(blog.errors[:body].first).to eq("HTMLが壊れています")
      end
    end
  end

  context "with exclude script" do
    let(:blog) {::HtmlValidatorSpec::BlogWithExcludeScript.new}

    it "returns valid" do
      blog.body = "<div>test blog post</div>"
      blog.valid?
      expect(blog).to be_valid
    end

    it "returns a default error message" do
      I18n.locale = :en
      blog.body = "<div>test blog post</div><script>alert('hey')</script>"
      blog.valid?
      expect(blog.errors[:body]).to eq(['cannot use script tag'])

    end

    context "when locale is Japanese" do
      it "returns a Japanese default error message" do
        I18n.locale = :ja
      blog.body = "<div>test blog post</div><script>alert('hey')</script>"
      blog.valid?
      expect(blog.errors[:body]).to eq(["scriptタグは使用できません"])
      end
    end
  end

  context "with exclude script" do
    let(:blog) {::HtmlValidatorSpec::BlogWithExcludeAnyTag.new}

    it "returns valid" do
      I18n.locale = :en
      blog.body = "<div>test blog post</div>"
      blog.valid?
      expect(blog).to be_valid
    end

    it "returns a include script tag error message" do
      I18n.locale = :en
      blog.body = "<div>test blog post</div><script>alert('hey')</script>"
      blog.valid?
      expect(blog.errors[:body]).to eq(['cannot use script tag'])
    end

    it "returns a include style and script tag error message" do
      I18n.locale = :en
      blog.body = "<div>test blog post</div><style>div {color: #F00; }</style><script>alert('hey')</script>"
      blog.valid?
      expect(blog.errors[:body]).to eq(['cannot use style tag', 'cannot use script tag'])
    end

    context "when locale is Japanese" do
      it "returns a Japanese default error message" do
        I18n.locale = :ja
        blog.body = "<div>test blog post</div><style>div {color: #F00; }</style><script>alert('hey')</script>"
        blog.valid?
        expect(blog.errors[:body]).to eq(["styleタグは使用できません", "scriptタグは使用できません"])
      end
    end
  end
end
