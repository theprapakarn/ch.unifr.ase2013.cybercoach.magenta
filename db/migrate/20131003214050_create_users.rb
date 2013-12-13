class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :basic_authorization
      t.string :email
      t.string :email_password
      t.timestamps
    end
  end
end
