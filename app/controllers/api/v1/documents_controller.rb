class Api::V1::DocumentsController < ApplicationController
  def index
    if current_user.role == "teacher"
        documents = current_user.documents
    else
        documents = Document.all
    end

    documents = documents.map do |document|
        document.attributes.merge(can_view: document.file.content_type == "text/markdown")
    end

    render json: { documents: documents }
  end

  def show
    document = Document.find(params[:id])

    render json: { document: document, file: document.file.download }
  end

  def create
    documents = document_params[:files].to_h.map do |i, document_data|
      document = Document.create(title: document_data["title"], file: document_data["file"])
      document.author = current_user
      document.save

      document
    end
   
    if documents.all?(&:persisted?)
      render json: { documents: documents }, status: :created
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

  private

  def document_params
    params.require(:documents).permit(files: [:title, :file])
  end
end

