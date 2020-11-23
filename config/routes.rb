RStudio::Engine.routes.draw do
  post 'analytics/submit' => 'analytics#submit'
  post 'analytics/submit-click' => 'analytics#submit_click'
  get 'announcements.json' => 'announcements#show'
end

Discourse::Application.routes.append do
  mount ::RStudio::Engine, at: 'rstudio'
end