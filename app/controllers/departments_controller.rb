class DepartmentController < ApplicationController
	before_action :set_college, only: [:show, :edit, :update, :destroy]
	def index
		@department = Department.all
	end
end