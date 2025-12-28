class AddPublisherToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :publisher, foreign_key: { to_table: :users }, index: true
  end
end
