# Resource for accessing lines in the hosted file.
class HostedFileLinesController < ApplicationController

  # GET /lines/<line index>
  def show
    # Assuming that users start counting at 1, so subtract 1 from the provided index.
    line_index = params[:line_index].to_i - 1
    if current_file.line_exists?(line_index)
      line = Rails.cache.fetch("#{current_file.file_identifier}/#{line_index}") do
        current_file.line(line_index)
      end
      render text: line
    else
      head 413
    end
  end

  private

  def current_file
    Logical::HostedFile.current_file
  end

end
