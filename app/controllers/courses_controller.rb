class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    
    # @course=Course.where(:open=>true)
    # @course=@course-current_user.courses
    # tmp=[]
    # @course.each do |course|
    #   if course.open==true
    #     tmp<<course
    #   end
    # end
    # @course=tmp



    #----------------new code---------------------------
    cids = params[:cids]
    cidss = [];
    carids = cids.split(',');
    carids.each do |aa|
      cidss << (aa.to_i)
    end

    aresults = []

    cidss.each do |ids|
      @result = Course.where(:open=>true,:college_id=>ids)
      #@result = Course.where(:college_id=>ids)
      aresults << @result
    end

    rr  = []
    aresults.each do |ouu|
      ouu.each do |inn|
        rr << inn
      end
    end

    @course = (rr - current_user.courses)
  end


   def showcollege
    #-------QiaoCode--------
    @college=College.all
  end


  def select
    @course=Course.find_by_id(params[:id])
    count = @course.checknum
     
    if !count
      count = 0
    end
    if count >= @course.limit_num
       flash={:failer => "人数已达上限: #{@course.limit_num}"}
       #redirect_to :action=>'list', flash: flash
       redirect_to :back, flash: flash
    elsif cousetimeinterfere(@course)
      flash={:failer => "选课冲突: #{@course.name}"}
      redirect_to :back, flash: flash
    else
      current_user.courses<<@course
      count+=1
      @course.update_attributes(:checknum=>"#{count}")
      @course=Course.find_by_id(params[:id])
      flash={:suceess => "成功选择课程: #{@course.name}"}
      redirect_to courses_path, flash: flash
    end
  end

  # -------------------new add  批量增加课程--------------------------------
  def selectCourseByCids

    cids = params[:cids]
    cidss = []
    carids = cids.split(',')

    carids.each do |aa|
      cidss << (aa.to_i)
    end

    errorresult = ""
    correctresult = ""

    cidss.each do |cid|

      @course=Course.find_by_id(cid)
      count = @course.checknum
       
      if !count
        count = 0
      end
      if count >= @course.limit_num
          errorresult += "#{@course.name} 人数已达上限 =>  #{@course.limit_num}"
        # flash={:failer => "人数已达上限: #{@course.limit_num}"}
         #redirect_to :action=>'list', flash: flash
         #redirect_to :back, flash: flash
      elsif cousetimeinterfere(@course)
        errorresult += "======  选课冲突: #{@course.name}"
        #flash={:failer => "选课冲突: #{@course.name}"}
        #redirect_to :back, flash: flash
      else
        current_user.courses<<@course
        count+=1
        @course.update_attributes(:checknum=>"#{count}")
        @course=Course.find_by_id(cid)
        correctresult += "成功选择课程: #{@course.name}"
        #flash={:suceess => "成功选择课程: #{@course.name}"}
        #redirect_to courses_path, flash: flash
      end
  end

  if errorresult != ""
    if correctresult != ""
      errorresult += correctresult
    end
    flash={:failer => "#{errorresult}"}
    redirect_to :back, flash: flash
  else
    flash={:success => "#{correctresult}"}
    redirect_to courses_path, flash: flash
  end


  end


  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    count = @course.checknum   # sub checknum
    @course.update_attributes(:checknum=>"#{count}")
    @course=Course.find_by_id(params[:id])
    flash={:success => "成功退选课程: #{@course.name},#{@course.checknum}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end

# ------------------------------new add  ------------------------------
  def cousetimeinterfere(current_course)
    #@course=Course.find_by_id(params[:id])
    currtime = timespilt(current_course.course_time) # 周四，9,11
    currweek = weeksplit(current_course.course_week) # 2,12

    result=false  ## true表示冲突 false表示no冲突
    cuid = current_user.id
    cids = Grade.where(:user_id => "#{cuid}")#find_by_sql("select course_id from grade where user_id = #{cuid}")
    tep=[]

    cids.each do |cid|
      tep << cid.course_id
    end

    coursesbycurrentuser = Course.find(tep) # all courses relative with current_student
    
    coursesbycurrentuser.each do |cs|
      if !ifinterfere(currtime,currweek,cs)  
        result = true
        break                        
      end
    end
    result
  end

  def weeksplit(weekstr)
    tempweek = weekstr.split('-')
    tempweek1=tempweek[0].delete "第"
    tempweek2=tempweek[1].delete "周"
    tempweek1.to_i
    tempweek2.to_i
    result=[tempweek1,tempweek2]
  end
  def timespilt(timestr)
    temptime=timestr.split('(')
    temptime1 = temptime[0]
    temptime2=temptime[1].delete ")"
    temptimea = temptime2.split('-')
    temptime21=temptimea[0].to_i
    temptime22=temptimea[1].to_i
    retuslt=[temptime1,temptime21,temptime22]
  end
  def ifinterfere(curtime,curweek,cs)  #检查当前课程是否和已经选择的课程时间上冲突  true表示不冲突 false表示冲突
    result = false
    oldtime = timespilt(cs.course_time)
    oldweek = weeksplit(cs.course_week)
    if curweek[0] > oldweek[1] or oldweek[0] > curweek[1]
      result = true
    elsif curtime[0] != oldtime[0]
      result = true
    elsif curtime[1] > oldtime[2] or oldtime[1] > curtime[2]
      result = true
    else 
      retult = false
    end
    result
  end

end
