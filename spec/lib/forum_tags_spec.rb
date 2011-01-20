require File.dirname(__FILE__) + '/../spec_helper'

describe "Forum Tags" do
  dataset :forums

  let(:page){ pages(:commentable) }

  describe "r:forum:topic tags" do
    let(:topic){ topics(:older) }
    let(:sticky){ topics(:sticky) }
    
    subject { page }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:name /></r:forum:topic>}).as(topic.name) }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:body /></r:forum:topic>}).as(topic.posts.first.body_html) }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:author /></r:forum:topic>}).as("Normal") }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:url /></r:forum:topic>}).as("/forum/forums/#{topic.forum.id}/topics/#{topic.id}") }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:context /></r:forum:topic>}).as("Started by Normal #{friendly_date(topic.created_at)}") }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:body /></r:forum:topic>}).as("<p>original topic message</p>") }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:link /></r:forum:topic>}).as(%{<a href="/forum/forums/#{topic.forum.id}/topics/#{topic.id}">#{topic.name}</a>}) }
    it { should render(%{<r:forum:topic id="#{topic.id}"><r:forum:topic:summary /></r:forum:topic>}).as(%{<li><a href="/forum/forums/#{topic.forum.id}/topics/#{topic.id}">#{topic.name}</a><br />Started by Normal #{friendly_date(topic.created_at)}</li>}) }
    it { should render(%{<r:forum:topic id="#{sticky.id}"><r:forum:topic:summary /></r:forum:topic>}).as(%{<li><a href="/forum/forums/#{sticky.forum.id}/topics/#{sticky.id}">#{sticky.name}</a><br />Started by Normal #{friendly_date(sticky.created_at)}</li>}) }
  end

  # describe "r:forum:post tags" do
  #   let(:post){ posts(:second) }
  #   let(:comment){ posts(:comment) }
  #   subject { page }
  #   it { should render(%{<r:forum:post id="#{post.id}"><r:forum:post:name /></r:forum:post>}).as(post.topic.name) }
  #   it { should render(%{<r:forum:post id="#{comment.id}"><r:forum:post:name /></r:forum:post>}).as(comment.page.name) }
  # end

end