class SetDefaultEmptyStringOnTokenPublicIds < ActiveRecord::Migration[8.2]
  def change
    change_column_default :staff_tokens, :public_id, from: nil, to: ""
    change_column_default :user_tokens, :public_id, from: nil, to: ""
  end
end
