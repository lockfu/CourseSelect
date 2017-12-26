$: << "#{File.dirname(__FILE__)}/util"
require "pageinfo"
require 'spreadsheet'
class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index
  # Spreadsheet.client_encoding = "utf-8" 
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



    #----------------new edit list code---------------------------
    # cids = params[:cids]
    # @course = []
    # if cids.length > 0
    #   cidss = [];
    #   carids = cids.split(',');
    #   carids.each do |aa|
    #     cidss << (aa.to_i)
    #   end

    #   aresults = []

    #   cidss.each do |ids|
    #     @result = Course.where(:open=>true,:college_id=>ids)
    #     aresults << @result
    #   end
    #   rr  = []
    #   aresults.each do |ouu|
    #     ouu.each do |inn|
    #       rr << inn
    #     end
    #   end

    #   @course = (rr - current_user.courses)
    # else
    #   @course=Course.where(:open=>true)
    #   @course=@course-current_user.courses
    #   tmp=[]
    #   @course.each do |course|
    #     if course.open==true
    #       tmp<<course
    #     end
    #   end

    #   @course=tmp
    # end

    # @course


    @result
   
    curpage = params[:curpage]

    if curpage.to_i != 0
      curpage = curpage.to_i
    else
      curpage = 1
    end


    cids = params[:cids]
    @course = []
    if cids.length > 0
      cidss = [];
      carids = cids.split(',');
      carids.each do |aa|
        cidss << (aa.to_i)
      end

      aresults = []

      cidss.each do |ids|
        @result = Course.where(:open=>true,:college_id=>ids)
        aresults << @result
      end
      rr  = []
      aresults.each do |ouu|
        ouu.each do |inn|
          rr << inn
        end
      end
     
      @course = (rr - current_user.courses)
      
    else
      @course=Course.find_by_sql("select * from courses where open=true")
      @course=@course-current_user.courses
     
     
    end

    pageSize = 4

    recordCount = @course.length

    currecordslen = (curpage-1) * pageSize 

    maxAsize = (currecordslen + pageSize)

    
    
    records = []
    if maxAsize > recordCount
      for i in currecordslen...recordCount
        records << @course[i]
      end
    else
      records = @course[currecordslen,pageSize]
    end

    # records = @midresult[currecordslen,pageSize-1]
    
    pageinfo = PageInfo.new(curpage,pageSize,recordCount,records,cids)
    
    @result = pageinfo
    # render :text => "#{@result}"
    @result


  end

  #-------------new add-----
   def showcollege
    @college=College.all
  end

#-----------------------new edit------------------------
  def select
    @course=Course.find_by_id(params[:id])
    @grade = Grade.where(:user_id=>"#{@current_user.id}",:course_id=>"#{@course.id}")
    count = @course.student_num
    isMas = params[:isMas]
    

    # render :text => "#{cgid}"

    limitNum = false

    if !@course.limit_num
     limitNum = true
    else 
      limitNum = count >= @course.limit_num
    end
    if limitNum
       flash={:failer => "人数已达上限: #{@course.limit_num}"}
       redirect_to :back, flash: flash
    elsif cousetimeinterfere(@course)
      flash={:failer => "选课冲突: #{@course.name}"}
      redirect_to :back, flash: flash
    else
      current_user.courses<<@course
      count+=1
      @course.update_attributes(:student_num=>"#{count}")
      cgid = @current_user.id
      @grade[0].update_attributes(:ismas=>"#{isMas}")
      @course=Course.find_by_id(params[:id])
      flash={:suceess => "成功选择课程: #{@course.name}"}
      redirect_to courses_path, failerlash: flash
    end

  end

  # -------------------new add  批量增加课程--------------------------------
  def selectCourseByCids

    cids = params[:cids]
    mids = params[:ismass]
    cidss = []
    midss = []
    carids = cids.split(',')
    marids = mids.split(',')
    carids.each do |aa|
      cidss << (aa.to_i)
    end
    marids.each do |aa|
      midss << (aa.to_i)
    end


    
    # render :text => "#{cidss}================== #{midss}"

    errorresult = ""
    correctresult = ""

    ismascount = 0
    
    cidss.each do |cid|


      @course=Course.find_by_id(cid)
      count = @course.student_num

      @grade = Grade.where(:user_id=>"#{current_user.id}",:course_id=>"#{cid}") 

      limitNum = false
    

      if !@course.limit_num
       limitNum = true
      else 
        limitNum = count >= @course.limit_num
      end
      if limitNum
          errorresult += "======= #{@course.name} 人数已达上限 =>  #{@course.limit_num}"
      elsif cousetimeinterfere(@course)
        errorresult += "======  选课冲突: #{@course.name}"
      else
        current_user.courses<<@course
        count+=1
        @course.update_attributes(:student_num=>"#{count}")
        isMasid = midss[ismascount]
        @grade[0].update_attributes(:ismas=>"#{isMasid}")
        @course=Course.find_by_id(cid)
        correctresult += "成功选择课程: #{@course.name}"
      end

      ismascount += 1
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
#----------------------------------------------------------------------

#-----------------new add show course detail info---------------------
  def showCourseInfo
    cid = params[:cid]
    @course = Course.find_by_id(cid)
    @course
  end
#-------------------------------------------------------

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    count = (@course.student_num - 1)   # sub checknum
    @course.update_attributes(:student_num =>"#{count}")
    @course=Course.find_by_id(params[:id])
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------new add-------------------------------------
  def delCourseByCids
    cids = params[:cids]
    cidss = [];
    carids = cids.split(',');
    carids.each do |aa|
      cidss << (aa.to_i)
    end
    resultstr = "成功退选课程: "
    cidss.each do |cid|
      @course=Course.find_by_id(cid)
      current_user.courses.delete(@course)
      count = (@course.student_num - 1)   # sub checknum
      @course.update_attributes(:student_num=>"#{count}")
      @course=Course.find_by_id(cid)
      resultstr += "  #{@course.name}"
   end
   flash={:success => "#{resultstr}"}
   redirect_to courses_path, flash: flash
  end
 #-----------------------------------------------------------------------

  #-------------------------for both teachers and students----------------------

  def index


    #@course=current_user.teaching_courses if teacher_logged_in?
    # @course=current_user.courses if student_logged_in?

    @result
    if teacher_logged_in?
      courses = current_user.teaching_courses 
      pageSize = 4
      curpage = params[:curpage]

      if curpage.to_i != 0
        curpage = curpage.to_i
      else
        curpage = 1
      end

      recordCount = courses.length
      currecordslen = (curpage-1) * pageSize 
      maxAsize = (currecordslen + pageSize)

      records = []
      coursea = []
      coursea = courses
      if maxAsize > recordCount
        for i in currecordslen...recordCount
          records << coursea[i]
        end
      else
        records = coursea[currecordslen,pageSize]
      end


      cids = [1,2]
      pageinfo = PageInfo.new(curpage,pageSize,recordCount,records,cids)
      @result = pageinfo

    elsif student_logged_in?
      pageSize = 4
      curpage = params[:curpage]

      if curpage.to_i != 0
        curpage = curpage.to_i
      else
        curpage = 1
      end
      cuid = current_user.id
      grades = Grade.where(:user_id => "#{cuid}")
      tep = []
      grades.each do |grade|
        tep << grade.course_id
      end
      
      courses = Course.find(tep)
      recordCount = courses.length

      records = []

      currecordslen = (curpage-1) * pageSize 

      records = Course.find_by_sql("select * from courses where id in (select course_id from grades where user_id = #{cuid}) limit #{pageSize} offset #{currecordslen}")
      cids = [1,2]
      pageinfo = PageInfo.new(curpage,pageSize,recordCount,records,cids)
      @result = pageinfo
    end
    # render :text => "#{@result}"
    @result
  end



  #----------------------teacher function----------------------------------
  def downloadStuInfo
    cid = params[:cid]
    @students = User.find_by_sql("select * from users where id in (select user_id from grades where course_id = #{cid})")
    
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Students"
    blue = Spreadsheet::Format.new :color => :blue,:weight => :bold, :size => 13
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat %w{  id  num name major depart }
    crow = 1
    @students.each do |obj|
      sheet1[crow,0] = crow
      sheet1[crow,1] = obj.num
      sheet1[crow,2] = obj.name
      sheet1[crow,3] = obj.major
      sheet1[crow,4] = obj.department
      crow += 1
    end

    book.write Rails.root.join('public','student.xls')
# (Rails.root.join('app' , 'assets', 'images', 'image.jpg')
    respond_to do |format|
      format.xls{
        send_file Rails.root.join('public','student.xls'), :filename => "student22.xls", :type=>"application/octet-stream;charset=utf-8", :disposition => "attachment",  :x_sendfile=>true
        # "/home/lockjk/CourseSelect/public/student.xls", :filename => "student22.xls", :type=>"application/octet-stream;charset=utf-8", :disposition => "attachment",  :x_sendfile=>true
        }
      format.html
    end

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
    grades = Grade.where(:user_id => "#{cuid}")#find_by_sql("select course_id from grade where user_id = #{cuid}")
    tep=[]

    grades.each do |grade|
      tep << grade.course_id
    end


    coursesbycurrentuser = []

    tep.each do |cid|
      cos = Course.find_by_id(cid)
      coursesbycurrentuser << cos
    end
   
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
    # tempweek1.to_i
    # tempweek2.to_i
    result=[tempweek1.to_i,tempweek2.to_i]
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
    ctime = cs.course_time
    cweek = cs.course_week
    oldtime = timespilt(ctime)
    oldweek = weeksplit(cweek)
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



  #=======================xml define=========================
 

  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Students"
    blue = Spreadsheet::Format.new :color => :blue,:weight => :bold, :size => 13
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat %w{  id  num name major depart }
    crow = 1
    objs.each do |obj|
      sheet1[crow,0] = crow
      sheet1[crow,1] = obj.num
      sheet1[crow,2] = obj.name
      sheet1[crow,3] = obj.major
      sheet1[crow,4] = obj.department
      crow += 1
    end
    book.write xls_report
    xls_report.string
  end

end
