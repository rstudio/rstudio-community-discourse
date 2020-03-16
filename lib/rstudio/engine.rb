module ::RStudio
  class Engine < ::Rails::Engine
    engine_name 'rstudio'
    isolate_namespace RStudio
  end
end