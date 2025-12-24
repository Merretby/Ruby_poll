class CommentCounter < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :comments_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Post.reset_column_information
        Post.find_each do |post|
          Post.update_counters post.id, comments_count: post.comments.size
        end
      end
    end

    add_index :posts, :comments_count
  end
end
