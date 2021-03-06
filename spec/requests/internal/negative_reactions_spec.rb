require "rails_helper"

RSpec.describe "/internal/negative_reactions", type: :request do
  context "when the user is not an admin" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "blocks the request" do
      expect do
        get "/internal/negative_reactions"
      end.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when the user is a single resource admin" do
    let(:single_resource_admin) { create(:user, :single_resource_admin, resource: ModeratorAction) }

    it "renders with status 200" do
      sign_in single_resource_admin
      get internal_moderator_actions_path
      expect(response.status).to eq 200
    end
  end

  context "when the user is an admin" do
    let(:admin)              { create(:user, :admin) }
    let(:moderator)          { create(:user, :trusted) }
    let!(:user_reaction)     { create(:vomit_reaction, :user, user: moderator) }
    let!(:article_reaction)  { create(:vomit_reaction, user: moderator) }

    before do
      sign_in admin
    end

    it "does not block the request" do
      expect do
        get "/internal/negative_reactions"
      end.not_to raise_error
    end

    describe "GETS /internal/negative_reactions" do
      it "renders to appropriate page" do
        get "/internal/negative_reactions"
        expect(response.body).to include(moderator.username)
        expect(response.body).to include(user_reaction.reactable.username)
        expect(response.body).to include(article_reaction.reactable.title)
      end
    end
  end
end
