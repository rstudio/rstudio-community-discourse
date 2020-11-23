class RStudio::AnnouncementsController < ::ApplicationController
  def show
    list = TopicQuery.new(Discourse.system_user,
      no_definitions: true,
      status: 'open',
      limit: 1,
      random: true,
      visible: true,
      category: SiteSetting.ads_category.to_i
    ).list_latest
    
    render_serialized(list, TopicListSerializer)
  end
end