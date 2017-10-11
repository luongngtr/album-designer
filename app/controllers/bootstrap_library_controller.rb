class BootstrapLibraryController < ApplicationController
  layout 'bolilayout'
  protect_from_forgery with: :null_session
  require 'dimensions'
  
  def index
    @types = Type.all
    @typelists = @types[1..-1] # Pick all the objects from the second to end
    @pics = Picture.all
    @clickedid = 1
    if !@pics.empty?
      @firstid = @pics.last.id
    else
      @firstid = 1
    end
    
    #Rails.logger.debug("My object: #{params[:id].inspect}")
    #Rails.logger.debug("My object: #{@pics.first.id}")
  end
  
  def show
    @types = Type.all
    @typelists = @types[1..-1] # Pick all the objects from the second to end
    
    
    if params[:id] == '1'
      @pics = Picture.all
    else
      @pics = Type.find_by_id(params[:id]).pictures
    end
    @clickedid = params[:id].to_i
    @firstid = @pics.last.id
    respond_to do |format| 
      format.js 
      format.html 
    end
    # render :layout => false
  end
  
  def create
    
    uploaded_io = params[:myform][:newimage]
    if !uploaded_io.nil? 
      File.open(Rails.root.join('app','assets','images', uploaded_io.original_filename),'wb') do |file|
        file.write(uploaded_io.read)
      end
      
      #Dimensions.dimensions(Rails.root.join('app','assets','images', uploaded_io.original_filename))  # => [300, 225]
      filewidth = Dimensions.width(Rails.root.join('app','assets','images', uploaded_io.original_filename))       # => 300
      fileheight = Dimensions.height(Rails.root.join('app','assets','images', uploaded_io.original_filename))      # => 225
      
      if params[:myform][:optionsRadios] == "optionlast"
        newtype = params[:myform][:newtype]
        checknewtype = Type.find_by_name(newtype)
        checkunknown = Type.find_by_name('Others')
        
        if newtype != ""  && checknewtype.nil? 
          Type.create(:name => newtype)
        elsif newtype == "" && checkunknown.nil?
          Type.create(:name => 'Others')
          newtype = 'Others'
        elsif newtype == "" && !checkunknown.nil?
          newtype = 'Others'
        end
        Picture.create(name: uploaded_io.original_filename, width: filewidth, height: fileheight, :type => Type.find_by_name(newtype))
        temp = Type.find_by_name(newtype)
      else
        Picture.create(name: uploaded_io.original_filename, width: filewidth, height: fileheight, :type => Type.find_by_name(params[:myform][:optionsRadios]))
        temp = Type.find_by_name(params[:myform][:optionsRadios])
      end
      
      
    end
    
    temp = temp.id
    
    @types = Type.all
    @typelists = @types[1..-1] # Pick all the objects from the second to end
    
    
    if temp == 1
      @pics = Picture.all
    else
      @pics = Type.find_by_id(temp).pictures
    end
    @clickedid = temp.to_i
    @firstid = @pics.last.id
    
    respond_to do |format| 
      format.js {render :show}
      format.html 
    end
    
  end
end
