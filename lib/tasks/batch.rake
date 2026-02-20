# frozen_string_literal: true

namespace :batch do
  desc "期限切れのユーザートークンを削除"
  task expire_user_token: :environment do
    expired_tokens = UserToken.where(refresh_expires_at: ...Time.current)
    count = expired_tokens.count
    expired_tokens.delete_all
    puts "#{count}件の期限切れトークンを削除しました"
  end

  desc "期限切れのスタッフトークンを削除"
  task expire_staff_token: :environment do
    expired_tokens = StaffToken.where(refresh_expires_at: ...Time.current)
    count = expired_tokens.count
    expired_tokens.delete_all
    puts "#{count}件の期限切れトークンを削除しました"
  end

  desc "TODO"
  task create: :environment do
    puts "TODO: batch:create を実装してください"
  end
end
