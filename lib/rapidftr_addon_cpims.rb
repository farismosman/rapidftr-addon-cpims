require 'i18n'

module RapidftrAddonCpims

  autoload :ExportTask, "rapidftr_addon_cpims/export_task"

end

I18n.load_path += Dir[File.expand_path(File.join(__FILE__, '..', '..', 'locales', '*.yml'))]
