require 'rho/rhocontroller'
require 'helpers/browser_helper'

class QuoteTopicController < Rho::RhoController
  include BrowserHelper

  # GET /QuoteTopic
  def index
    @quotetopics = QuoteTopic.find(:all)
    render :back => '/app'
  end

  # GET /QuoteTopic/{1}
  def show
    @quotetopic = QuoteTopic.find(@params['id'])
    if @quotetopic
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /QuoteTopic/new
  def new
    @quotetopic = QuoteTopic.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /QuoteTopic/{1}/edit
  def edit
    @quotetopic = QuoteTopic.find(@params['id'])
    if @quotetopic
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /QuoteTopic/create
  def create
    @quotetopic = QuoteTopic.create(@params['quotetopic'])
    redirect :action => :index
  end

  # POST /QuoteTopic/{1}/update
  def update
    @quotetopic = QuoteTopic.find(@params['id'])
    @quotetopic.update_attributes(@params['quotetopic']) if @quotetopic
    redirect :action => :index
  end

  # POST /QuoteTopic/{1}/delete
  def delete
    @quotetopic = QuoteTopic.find(@params['id'])
    @quotetopic.destroy if @quotetopic
    redirect :action => :index  
  end
end
