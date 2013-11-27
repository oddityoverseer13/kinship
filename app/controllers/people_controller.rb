class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  # GET /people
  # GET /people.json
  def index
    @people = Person.all

    query = params[:query] || session[:query]
    sort = params[:sort] || session[:sort]

    case sort
    when 'first_name'
      ordering,@first_name_header = {:order => :first_name}, 'hilite'
    when 'last_name'
      ordering,@last_name_header = {:order => :last_name}, 'hilite'
    end
    @all_genders = Person.all_genders
    @selected_genders = params[:genders] || session[:genders] || {}

    if @selected_genders == {}
      @selected_genders = Hash[@all_genders.map {|gender| [gender, gender]}]
    end
    # Allow searching for people with no gender specified
    if @selected_genders.keys.include?('M') and @selected_genders.keys.include?('F')
       @selected_genders[' '] = "1"
    end

    if params[:sort] != session[:sort] or params[:genders] != session[:genders] or params[:query] != session[:query]
      session[:sort] = sort
      session[:genders] = @selected_genders
      session[:query] = query
      redirect_to :sort => sort, :genders => @selected_genders, :query => query and return
    end

    if query
       gender_results = Person.find_all_by_gender(@selected_genders.keys, ordering)
       people_results = Person.where('first_name NOT LIKE ? AND last_name NOT LIKE ?', "%#{query}%", "%#{query}%")
       @people = (gender_results - people_results).uniq
       
    else
      @people = Person.find_all_by_gender(@selected_genders.keys, ordering)
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    @eventsFormat = Setting.eventsFormat
    children_ids = Birth.find_all_by_father_id(params[:id]).map {|elt| elt.child_id}
    children_ids += Birth.find_all_by_mother_id(params[:id]).map {|elt| elt.child_id}
    @children = Person.find_all_by_id(children_ids)
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render action: 'show', status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if  @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:first_name, :last_name, :gender, :photo, birth_attributes: [:date, :father_id, :mother_id])
    end
end
