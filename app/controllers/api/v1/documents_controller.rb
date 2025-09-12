class Api::V1::DocumentsController < ApplicationController
  def index
    if current_user.role == "teacher"
        documents = current_user.documents
    else
        documents = Document.all
    end

    render json: { documents: documents.map(&:attributes), shared_documents: current_user.shared_documents.map(&:attributes) }
  end

  def show
    document = Document.find(params[:id])

    # Track page view
    PageViewService.track_page_view(
      pageviewable: document,
      user: current_user,
      controller: controller_name,
      action: action_name,
      request: request,
      session: session,
      params: params
    )

    attrs = document.attributes.merge(versions: document.versions.reverse[0..9])

    render json: { document: attrs, file: document.file.download }
  end

  def create
    documents = document_params[:files].to_h.map do |i, document_data|
      document = Document.create(title: document_data["title"], file: document_data["file"])
      document.author = current_user
      document.save

      document
    end
   
    if documents.all?(&:persisted?)
      render json: { documents: documents.map(&:attributes) }, status: :created
    else
      render json: { errors: documents.flat_map {|d| d.errors.full_messages } }, status: :unprocessable_content
    end
  end

  def update
    document = Document.find(params[:id])
    
    md_content = document_update_params["markdown"]
    document_update_params["markdown"] = md_content.to_json
    
    if document.update(document_update_params)
      # Upload the markdown to the document in the background
      UploadMarkdownJob.perform_async(document.id)

      render json: { document: document.attributes.merge(versions: document.filtered_versions.reverse[0..9]) }, status: :ok
    else
      render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    document = Document.find(params[:id])
    
    document.destroy
    
    render json: { message: "Document deleted" }, status: :ok
  end

  def download
    document = Document.find(params[:id])
    
    send_data document.file.download, filename: document.title
  end

  def analytics
    document = Document.find(params[:id])
    period = params[:period]&.to_sym || :today
    
    analytics_data = PageViewService.get_analytics_for(document, period: period)
    
    render json: { analytics: analytics_data }, status: :ok
  end

  def add_editors
    document = Document.find(params[:id])

    document_editors_params[:editors].each do |editor| 
      if document.editors.exists?(id: editor[:user_id])
        render json: { errors: "User is already an editor" }, status: :unprocessable_entity
        return
      end

      DocumentEditor.create!(
        document_id:  document.id,
        user_id:      editor[:user_id],
        role:         editor[:role]
      )
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
        return
    end

    document.reload

    payload = {
      document: document.attributes,
      editors: document.editors.map(&:attributes)
    }
    
    render json: payload, status: :ok
  end

  def restore_version
    document = Document.find(params[:id])
    
    version = document.versions.find(params[:version_id])
    version.reify

    render json: { message: "Version restored", document: document.attributes }, status: :ok
  end

  private

  def document_params
    params.require(:documents).permit(files: [:title, :file])
  end

  def document_update_params
    params.require(:document).permit(:title, :markdown)
  end

  def document_editors_params
    params.require(:document_editors).permit(editors: [:user_id, :role])
  end
end

