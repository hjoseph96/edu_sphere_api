class Api::V1::DocumentsController < ApplicationController
  def index
    documents = current_user.documents
    
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

  private

  def document_params
    params.require(:documents).permit(files: [:title, :file])
  end
end

