class RStudio::AnalyticsController < ::ApplicationController
  def submit
    key = "rstudio_analytics"
    topic_ids = analytics_params[:topic_ids]

    topic_ids.each do |topic_id|
      existing = get_analytics(key, topic_id)
      count = existing.present? ? existing + 1 : 1
      set_analytics(key, topic_id, count)
    end

    render json: success_json
  end

  def submit_click
    key = "rstudio_click_analytics"
    topic_ids = (analytics_params[:topic_ids] || [])
    url = analytics_params[:url]
    
    if topic_ids.any?
      topic_id = topic_ids.first
      value = get_analytics(key, topic_id)  
      user_id = current_user.present? ? current_user.id : 'anonymous'
      
      value['count'] ||= 0
      value['user_ids'] ||= []
      
      value['count'] += 1
      value['user_ids'] |= [user_id]
        
      set_analytics(key, topic_id, value)
    end
    
    render json: success_json
  end
  
  protected
  
  def get_analytics(key, topic_id)
    PluginStore.get(key, build_key(topic_id)) || {}
  end
  
  def set_analytics(key, topic_id, value)
    PluginStore.set(key, build_key(topic_id), value)
  end
  
  def build_key(topic_id)
    "#{Time.new.strftime("%Y-%m-%d")}_#{topic_id}"
  end
  
  def analytics_params
    params.permit(:url, topic_ids: [])
  end
end
