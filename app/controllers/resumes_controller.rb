require 'htmltoword'
require 'prawn'
require 'cloudconvert-ruby'
require 'rest-client'
require 'json'
require 'open-uri'
require 'net/https'
require 'net/http/post/multipart'

class ResumesController < ApplicationController
  before_action :set_resume, only: [:show, :edit, :update, :destroy]
  respond_to :docx

  # GET /resumes
  # GET /resumes.json
  def index
    @resumes = Resume.all
  end

  # GET /resumes/1
  # GET /resumes/1.json
  def show
  end

  # GET /resumes/new
  def new
    @resume = Resume.new
  end

  # GET /resumes/1/edit
  def edit
  end

  def pdf
    generate_pdf()
    # convert()
    zamzar_convert()
    # download = open("https://aletha.infra.cloudconvert.com/download/~090291433565f12fda30e5e6790d0885b148cc087a4f75de63f892ae0c667218bc1a4171889d1ba00219b825")
    # IO.copy_stream(download, File.join(Rails.root, 'app/docs/output.docx').to_s)
    file_path = File.join(Rails.root, "app/docs/output.docx")
    File.open(file_path, 'r') do |f|
      send_data f.read, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", filename: "my_resume.docx"
    end
    File.delete(file_path)
    clean()
  end

  def download
    @bar = "Lorem Ipsum"

    respond_to do |format|
      format.docx do
        # docx - the docx template that you'll use
        # filename - the name of the created docx file

        render docx: 'download', filename: 'resumes.docx'
      end
    end
  end

  # POST /resumes
  # POST /resumes.json
  def create
    @resume = Resume.new(resume_params)

    respond_to do |format|
      if @resume.save
        format.html { redirect_to @resume, notice: 'Resume was successfully created.' }
        format.json { render :show, status: :created, location: @resume }
      else
        format.html { render :new }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resumes/1
  # PATCH/PUT /resumes/1.json
  def update
    respond_to do |format|
      if @resume.update(resume_params)
        format.html { redirect_to @resume, notice: 'Resume was successfully updated.' }
        format.json { render :show, status: :ok, location: @resume }
      else
        format.html { render :edit }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.json
  def destroy
    @resume.destroy
    respond_to do |format|
      format.html { redirect_to resumes_url, notice: 'Resume was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resume
      @resume = Resume.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def resume_params
      params.fetch(:resume, {})
    end
     
    def generate_pdf
        pdf = Prawn::Document.new do
          font_families.update("Arial" => {
            :normal => Rails.root.join("/app/assets/fonts/Calibri Regular.ttf"),
            :italic => Rails.root.join("/app/assets/fonts/Calibri Italic.ttf"),
            :bold => Rails.root.join("/app/assets/fonts/Library/Fonts/Calibri Bold.ttf"),
            :bold_italic => Rails.root.join("/app/assets/fonts/Calibri Bold Italic.ttf")
          })
          formatted_text [
            { text: '{First} {Last} ', styles: [:bold], color: '3C78D8', size: 16 },
            { text: '{Phone number} • {Email} • {Region}, {City}, {State}, {Country} • {LinkedIn}', size: 9 }
          ]
          move_down 12
          ### SUMMARY ###
          text 'Summary', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          text '{Summary}', size: 10.5
          move_down 12
          ### EDUCATION ###
          text 'Education', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          2.times {
            float { 
              formatted_text [ 
                { text: "{Institution name} ", size: 10.5, color: '3C78D8', align: :left, styles: [:bold] },
                { text: "- {City}, {State}, {Country}", size: 10.5, align: :left }
              ]
            }
            text '{Start date} - {End date}', align: :right, size: 10.5, style: :bold
            formatted_text [
              { text: '{Degree} ', size: 10.5, styles: [:bold] },
              { text: '- {Grade/score}', size: 10.5 }
            ]
            move_down 5
          }
          move_down 10
          ### WORK EXPERIENCE ###
          text 'Work Experience', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          3.times {
            formatted_text [ 
              { text: "{Company name} ", size: 10.5, color: '3C78D8', align: :left, styles: [:bold] },
              { text: "- {City}, {State}, {Country}", size: 10.5, align: :left }
            ]
            text '{Company description}', size: 10.5, align: :left, style: :italic
            move_down 5
            float { 
              text "{Job title} ", size: 10.5, align: :left, style: :bold
            }
            text '{Start date} - {End date}', align: :right, size: 10.5, style: :bold
            3.times {
              text '•    {Description, achievements, accomplishments}', size: 10.5
            }
            move_down 5
          }
          move_down 5
          ### EXTRACURRICULAR ACTIVITIES ###
          text 'Extracurricular Activities', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          3.times {
            text '•    {Activities, clubs, extracurriculars}', size: 10.5
          }
          move_down 10
          ### CERTIFICATIONS ###
          text 'Certifications', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          3.times {
            text '•    {Certification} - {Issuer}, {Date granted}', size: 10.5
          }
          move_down 10
          ### ADDITIONAL ###
          text 'Additional', align: :center, size: 12, style: :bold, color: '3C78D8'
          stroke_horizontal_rule
          move_down 5
          text 'Skills', size: 10.5, style: :bold
          text '•    {Skills}', size: 10.5
          move_down 5
          text 'Hobbies', size: 10.5, style: :bold
          text '•    {Hobbies}', size: 10.5
          move_down 5
          text 'Awards', size: 10.5, style: :bold
          text '•    {Awards}', size: 10.5
          move_down 5
          text 'Volunteering', size: 10.5, style: :bold
          text '•    {Volunteering}', size: 10.5
        end
        filepath = File.join(Rails.root, "app/outputs", "output.pdf")
        pdf.render_file(filepath)
    end

    def convert
      @api_key = "GoW7OVjdQ-wRYXY3WOztJxmQ2dADV7gxCTpyZE1lMkm0fNF7dsyN33dfdeNreSTJ6DHMEOeRTGLF8Dw6YZuRmQ"
      proc_response = RestClient.post("https://api.cloudconvert.com/v1/process", {"inputformat": "pdf", "outputformat": "docx"}, headers={"Authorization": "Bearer " + @api_key})
      proc_resp_body = JSON.parse(proc_response.body)
      @task_endpoint = "https:" + proc_resp_body["url"]
      puts @task_endpoint
      convert_response = RestClient.post(@task_endpoint, {"input": "upload", "file": "output.pdf", "outputformat": "docx"}, headers={"Authorization": "Bearer " + @api_key})
      puts convert_response
      convert_resp_body = JSON.parse(convert_response.body)
      @upload_url = "https:" + convert_resp_body["upload"]["url"] + "/output.pdf"
      puts @upload_url
      upload_response = RestClient.put(@upload_url, File.open(File.join(Rails.root, "app/outputs/output.pdf"), 'r'), content_type: 'application/pdf')
      puts upload_response
      status_response = RestClient.get(@task_endpoint)
      status_resp_body = JSON.parse(status_response.body)
      while status_resp_body["step"] == "convert" do
        status_response = RestClient.get(@task_endpoint)
        status_resp_body = JSON.parse(status_response.body)
      end
      puts status_response
      download = open("https:" + status_resp_body["output"]["url"])
      IO.copy_stream(download, File.join(Rails.root, 'app/docs/output.docx').to_s)
    end

    def zamzar_convert
      api_key = 'be9eb6ee0d4c836a90089da3088379c20fb606ad'
      endpoint = "https://sandbox.zamzar.com/v1/jobs"
      source_file = File.join(Rails.root, "app/outputs/output.pdf").to_s
      target_format = "docx"

      uri = URI(endpoint)
      job_id = 0

      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        request = Net::HTTP::Post::Multipart.new(
          uri.request_uri,
          'source_file' => UploadIO.new(source_file, "application/pdf"),
          'target_format' => target_format
        )
        request.basic_auth(api_key, '')

        response = http.request(request)
        json_resp = JSON.parse(response.body)
        puts json_resp
        job_id = json_resp["id"].to_i
      end

      json_resp = nil
      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth(api_key, '')
      
        response = http.request(request)
        json_resp = JSON.parse(response.body)
      end
      while json_resp["data"][0]["status"] != "successful" do
        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth(api_key, '')
        
          response = http.request(request)
          json_resp = JSON.parse(response.body)
          puts json_resp["data"][0]
        end
      end
      file_id = json_resp["data"][0]["target_files"][0]["id"]

      endpoint = "https://sandbox.zamzar.com/v1/files/#{file_id}/content"
      local_filename = File.join(Rails.root, "app/docs/output.docx").to_s

      uri = URI(endpoint)

      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth(api_key, '')

        response = http.request(request)

        open(local_filename, "wb") do |file|
          file.write(response.body)
        end

        puts "File downloaded"
      end
    end

    def clean
      File.open(File.join(Rails.root, "app/outputs/output.pdf"), 'r') do |f|
        File.delete(f)
      end
    end
end
