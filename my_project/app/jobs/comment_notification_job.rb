class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment_id, recipient_id)
    comment = Comment.find(comment_id)
    recipient = User.find(recipient_id)
    
    CommentMailer.new_comment(comment, recipient).deliver_now
  end
end
