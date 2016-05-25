class Ckeditor::AttachmentFilesController < Ckeditor::ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  
  def index
    @attachments = Ckeditor.attachment_file_adapter.find_all(ckeditor_attachment_files_scope)
    @attachments = Ckeditor::Paginatable.new(@attachments).page(params[:page])

    respond_to do |format|
      format.html { render :layout => @attachments.first_page? }
    end
  end

  def upload_paste_file
    if file = params[:upload]

      if !file.original_filename.empty?
        filename = file.original_filename
        file_ext = filename.split('.').last.downcase
        new_filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}#{rand(10)}#{rand(10)}#{rand(10)}#{rand(10)}.#{file_ext}"
        folder_path = "/upload/#{Time.now.strftime('%Y-%m-%d')}"
        full_folder_path = "#{Rails.root}/public#{folder_path}"
        FileUtils.mkdir(full_folder_path) unless File.exist?(full_folder_path)
        
        File.open("#{full_folder_path}/#{new_filename}", "wb") do |f|
          f.write(file.read)
        end
        render :json=>{url: "#{folder_path}/#{new_filename}", uploaded: 1, 'fileName'=>filename}
      else
        render :json=>{error: {message: 'Upload error!'}, uploaded: 0}
      end
    else
      render :json=>{error: {message: 'Upload error!'}, uploaded: 0}
    end
  end

  def create
    @attachment = Ckeditor.attachment_file_model.new
    respond_with_asset(@attachment)
  end

  def destroy
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to attachment_files_path }
      format.json { render :nothing => true, :status => 204 }
    end
  end

  protected

    def find_asset
      @attachment = Ckeditor.attachment_file_adapter.get!(params[:id])
    end

    def authorize_resource
      model = (@attachment || Ckeditor.attachment_file_model)
      @authorization_adapter.try(:authorize, params[:action], model)
    end
end
