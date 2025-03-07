# frozen_string_literal: true

require "rails_helper"

RSpec.describe ListController do
  fab!(:admin) { Fabricate(:admin) }
  fab!(:user) { Fabricate(:user) }
  fab!(:category) { Fabricate(:category) }
  fab!(:topic_1) { Fabricate(:topic, title: "This is the first topic", user: user, category: category) }
  fab!(:post_1) { Fabricate(:post, topic: topic_1) }
  fab!(:post_event_1) { Fabricate(:event, name: "event1", post: post_1, original_starts_at: 1.days.from_now) }
  fab!(:topic_2) { Fabricate(:topic, title: "This is the second topic", user: user, category: category) }
  fab!(:post_2) { Fabricate(:post, topic: topic_2) }
  fab!(:post_event_2) { Fabricate(:event, name: "event2", post: post_2, original_starts_at: 2.days.from_now) }

  before do
    admin
    SiteSetting.calendar_enabled = true
    SiteSetting.sort_categories_by_event_start_date_enabled = true
  end

  describe '#sort_event_topics' do
    it 'gets topics in order of event_date if sort_topics_by_event_start_date is true' do
      category.custom_fields["sort_topics_by_event_start_date"] = true
      category.save

      get "/c/#{category.slug}/#{category.id}/l/latest.json?ascending=false"

      topics = response.parsed_body["topic_list"]["topics"]

      expect(topics[0]["id"]).to eq(topic_1.id)
      expect(topics[1]["id"]).to eq(topic_2.id)
    end

    it 'does not gets topics in order of event_date if sort_topics_by_event_start_date is false' do
      category.custom_fields["sort_topics_by_event_start_date"] = false
      category.save

      get "/c/#{category.slug}/#{category.id}/l/latest.json?ascending=false"

      topics = response.parsed_body["topic_list"]["topics"]

      expect(topics[0]["id"]).to eq(topic_2.id)
      expect(topics[1]["id"]).to eq(topic_1.id)
    end

  end

end
