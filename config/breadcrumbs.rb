crumb :app do
  link "Home", "/"
end

crumb :app_preference do
  link I18n.t("controller.www.app.preference.show.page_title"), "/preference"
  parent :app
end

crumb :app_preference_cookie do |user|
  link I18n.t("controller.www.app.preference.cookie.edit.page_title"), "/preference/cookie/edit"
  parent :app_preference
end

crumb :app_preference_email do |user|
  link I18n.t("controller.www.app.preference.email.new.page_title"), "/preference/cookie/edit"
  parent :app_preference
end

crumb :com do
  link "Home", "/"
end
crumb :com_preference do
  link I18n.t("controller.www.app.preference.show.page_title"), www_com_preference_path
  parent :com
end

crumb :org do
  link "Home", "/"
end

crumb :org_preference do
  link I18n.t("controller.www.app.preference.show.page_title"), "/preference"
  parent :org
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
