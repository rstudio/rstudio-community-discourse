# name: rstudio-community-discourse
# description: Custom Discourse functionality for community.rstudio.com
# version: 0.0.1
# author: Pavilion
# url: https://github.com/rstudio/rstudio-community-discourse

register_asset 'stylesheets/common/rstudio.scss'

after_initialize do
  %w[
    ../lib/rstudio/engine.rb
    ../config/routes.rb
    ../controllers/rstudio/analytics.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  Topic.register_custom_field_type('show_images', :boolean)
  Topic.register_custom_field_type('ad_url', :string)
  
  ad_fields = [:show_images, :ad_url]
  
  ad_fields.each do |field|
    add_to_class(:topic, field.to_sym) { self.custom_fields[field.to_s] }
    add_to_serializer(:topic_view, field.to_sym) { object.topic.send(field.to_s) }
    add_to_serializer(:topic_list_item, field.to_sym) { object.send(field.to_s) }
    TopicList.preloaded_custom_fields << field.to_s
    
    PostRevisor.track_topic_field(field.to_sym) do |tc, val|
      tc.record_change(field.to_s, tc.topic.custom_fields[field.to_s], val)
      tc.topic.custom_fields[field.to_s] = val
    end
  end
  
  on(:before_create_topic) do |topic, creator|
    ad_fields.each do |field|
      topic.custom_fields[field.to_s] = creator.opts[field.to_s]
    end
  end
  
  TopicQuery.add_custom_filter(:per_page) do |results, query|
    results
  end
  
  TopicQuery.add_custom_filter(:announcement) do |results, query|
    if ActiveModel::Type::Boolean.new.cast(query.options[:announcement])
      query.guardian.secure_category_ids << SiteSetting.ads_category.to_i
    end
    results
  end
  
  [:no_definitions, :random, :visible].each do |option|
    TopicQuery.add_custom_filter(option) { |results, query| results }
  end
  
  module TopicQueryRandomExtension
    def apply_ordering(result, options)
      options[:random] ? result.order("RANDOM()") : super(result, options)
    end
  end
  
  class ::TopicQuery
    prepend TopicQueryRandomExtension
  end
  
  module ListControllerAnnouncementExtension
    private def set_category
      if params[:announcement]
        guardian.secure_category_ids << SiteSetting.ads_category.to_i
      end
      super
    end
  end
  
  class ::ListController
    prepend ListControllerAnnouncementExtension
  end
end