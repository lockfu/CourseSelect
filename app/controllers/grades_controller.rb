class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def updategrades
    render :text => "text ......."
  end

  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end


# for student
  def downstudent
    @grades=current_user.grades
    respond_to do |format|  
      format.xls {   
        send_data(xls_content_for(@grades),  
                  :type => "text/excel;charset=utf-8; header=present",  
                  :filename => "Grades_#{Time.now.to_date}.xls")  
      }  
      format.html  
    end  
  end  

# for teacher
  def downteacher
   
    cid = params[:cid]
    @grades=Grade.where(:course_id => "#{cid}")
    respond_to do |format|  
      format.xls {   
        send_data(xls_content_for(@grades),  
                  :type => "text/excel;charset=utf-8; header=present",  
                  :filename => "Student_Grades_#{Time.now.to_date}.xls")  
      }  
      format.html  
    end  
  end  

def studentInfo
    cid = params[:cid]
    @grades=Grade.where(:course_id => "#{cid}")
    respond_to do |format|  
      format.xls {   
        send_data(student_xls_content_for(@grades),  
                  :type => "text/excel;charset=utf-8; header=present",  
                  :filename => "Student_Informations_#{Time.now.to_date}.xls")  
      }  
      format.html  
    end  
  end  



  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end




  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "sheet1"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat %w{ 学号 名字 专业 培养单位 课程 目前分数}
    crow = 1

    objs.each do |obj|
        sheet1[crow,0]=obj.user.num
        sheet1[crow,1]=obj.user.name
        sheet1[crow,2]=obj.user.major
        sheet1[crow,3]=obj.user.department
        sheet1[crow,4]=obj.course.name
      if obj.grade != nil
        sheet1[crow,5]=obj.grade
      else
        sheet1[crow,5]="暂无成绩"
      end
      crow = crow + 1
    end 
  book.write xls_report
  xls_report.string
  end

  def student_xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "sheet1"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat %w{序号 学号 名字 专业 培养单位 邮箱}
    crow = 1

    objs.each do |obj|
        sheet1[crow,0]=crow
        sheet1[crow,1]=obj.user.num
        sheet1[crow,2]=obj.user.name
        sheet1[crow,3]=obj.user.major
        sheet1[crow,4]=obj.user.department
        sheet1[crow,5]=obj.user.email
      crow = crow + 1
    end 
  book.write xls_report
  xls_report.string
  end
end
