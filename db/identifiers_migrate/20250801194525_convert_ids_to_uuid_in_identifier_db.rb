class ConvertIdsToUuidInIdentifierDb < ActiveRecord::Migration[8.0]
  def up
    # この操作は非常に危険です。本番環境では慎重に実行してください。
    # データのバックアップを必ず取ってから実行してください。
    
    # まず、外部キー制約があるテーブルの制約を一時的に削除する必要があります
    # その後、IDをUUIDに変換し、制約を再追加します
    
    # Step 1: 新しいUUID列を追加
    add_column :staffs, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :users, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :staff_emails, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :user_emails, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :staff_telephones, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :user_telephones, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :client_emails, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    add_column :client_telephones, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    
    # Step 2: 既存のデータに対してUUID値を生成
    execute "UPDATE staffs SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE users SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE staff_emails SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE user_emails SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE staff_telephones SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE user_telephones SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE client_emails SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    execute "UPDATE client_telephones SET uuid_id = gen_random_uuid() WHERE uuid_id IS NULL"
    
    # 注意: この段階では外部キー参照があるテーブルも同時に更新する必要があります
    # これは非常に複雑な作業です
    
    puts "警告: この時点で外部キー参照を手動で更新する必要があります"
    puts "すべての参照が更新されたら、以下のステップを実行してください："
    puts "1. 古いid列を削除"
    puts "2. uuid_id列をidにリネーム"
    puts "3. プライマリキー制約を再設定"
  end

  def down
    # ダウンマイグレーションは非常に複雑で危険です
    # 通常は手動でのデータ復元が必要です
    raise ActiveRecord::IrreversibleMigration, "UUID変換は元に戻せません。バックアップから復元してください。"
  end
end