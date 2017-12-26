class NoticeController < ApplicationController
	before_action :set_college, only: [:show, :edit, :update, :destroy]
	def index
		@notice = Notice.all
	end
end