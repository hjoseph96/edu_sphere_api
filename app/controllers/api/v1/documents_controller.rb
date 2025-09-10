class Api::V1::DocumentsController < ApplicationController
  def index
    if current_user.role == "teacher"
        documents = current_user.documents
    else
        documents = Document.all
    end


    render json: { documents: documents.map(&:attributes) }
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

    render json: { document: document.attributes, file: document.file.download }
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
      DocumentEditor.create!(
        document_id: document.id,
        user_id: editor[:user_id],
        role: editor[:role]
      )
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
        return
    end

    document.reload

    payload = {
      document: document.attributes,
      editors: document.editors
    }
    
    render json: payload, status: :ok
  end

  private

  def document_params
    params.require(:documents).permit(files: [:title, :file])
  end

  def document_editors_params
    params.require(:document_editors).permit(editors: [:user_id, :role])
  end
end

