class HomeController < ApplicationController
  # respond_to :docx

  # # filename and word_template are optional. By default it will name the file as your action and use the default template provided by the gem. The use of the .docx in the filename and word_template is optional.
  # def my_action
  #   # ...
  #   respond_with(@object, filename: 'my_file.docx', word_template: 'my_template.docx')
  #   # Alternatively, if you don't want to create the .docx.erb template you could
  #   respond_with(@object, content: '<html><head></head><body><p>Hello</p></body></html>', filename: 'my_file.docx')
  # end
  def show
  end

  def download
    @bar = "Lorem Ipsum"

    respond_to do |format|
      format.docx do
        # docx - the docx template that you'll use
        # filename - the name of the created docx file

        render docx: 'download', filename: 'test.docx'
      end
    end
  end
end
