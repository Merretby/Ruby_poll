class CommentMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.comment_mailer.new_comment.subject
  #
  def new_comment(comment, recipient)
    @comment = comment
    @recipient = recipient
    @post = comment.post
    @commenter = comment.user

    mail(
      from: @commenter.email,
      to: @recipient.email,
      subject: "New comment on your post '#{@post.title}'"
    )
  end
end
