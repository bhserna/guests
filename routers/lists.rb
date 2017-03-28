class ListsRouter < BaseRouter
  before "/lists*" do
    return redirect to("/users/login") if Users.guest?(users_config)
    @user = Users.get_current_user(users_config)
  end

  before "/lists/:id" do
    unless Lists.has_access?(@user, params[:id], lists_store, people_store)
      return redirect to("/lists")
    end
  end

  get "/lists" do
    redirect to("/users/registration") if Users.guest?(users_config)
    @user = Users.get_current_user(users_config)
    @lists = Lists.lists_of_user(@user, lists_store, people_store)
    erb :"lists/index"
  end

  get "/lists/new" do
    redirect to("/") if Users.guest?(users_config)
    @form = Lists.new_list_form
    erb :"lists/new"
  end

  post "/lists" do
    redirect to("/") if Users.guest?(users_config)
    user = Users.get_current_user(users_config)
    response = Lists.create_list(user.id, params, lists_store, Lists::IdGenerator)

    if response.success?
      redirect to("/lists")
    else
      @form = response.form
      erb :"lists/new"
    end
  end

  get "/lists/:id" do
    redirect to("/") if Users.guest?(users_config)
    erb :"lists/show"
  end

  post "/lists/:list_id/invitations" do
    invitation = params[:invitation]
    invitation = JSON.parse(invitation)
    Invitations.save_record(params[:list_id], invitation, Invitations::Store)
  end

  patch "/lists/:list_id/invitations" do
    invitation = params[:invitation]
    invitation = JSON.parse(invitation)
    Invitations.update_record(params[:list_id], invitation, Invitations::Store)
  end

  delete "/lists/:list_id/invitations/:id" do
    Invitations.delete_record(params[:list_id], params[:id], Invitations::Store)
  end

  get "/lists/:list_id/invitations" do
    Invitations.fetch_records(params[:list_id], Invitations::Store).to_json
  end

  get "/lists/:list_id/access" do
    @details = Lists.current_access_details(params[:list_id], lists_store, people_store)
    erb :"lists/access"
  end

  get "/lists/:list_id/access/new" do
    @form = Lists.give_access_form
    @details = Lists.current_access_details(params[:list_id], lists_store, people_store)
    erb :"lists/new_access"
  end

  post "/lists/:list_id/access" do
    @details = Lists.current_access_details(params[:list_id], lists_store, people_store)
    response = Lists.give_access_to_person(params[:list_id], params, people_store)

    if response.success?
      redirect to("/lists/#{@details.list_id}/access")
    else
      @form = response.form
      erb :"lists/new_access"
    end
  end

  get "/lists/:list_id/access/:id/edit" do
    @form = Lists.edit_access_form(params[:id], people_store)
    @details = Lists.current_access_details(params[:list_id], lists_store, people_store)
    erb :"lists/edit_access"
  end

  post "/lists/:list_id/access/:id" do
    @details = Lists.current_access_details(params[:list_id], lists_store, people_store)
    response = Lists.update_access_for_person(params[:id], params, people_store)

    if response.success?
      redirect to("/lists/#{@details.list_id}/access")
    else
      @form = response.form
      erb :"lists/edit_access"
    end
  end

  post "/lists/:list_id/access/:id/remove" do
    Lists.remove_access_for_person(params[:id], people_store)
    redirect to("/lists/#{params[:list_id]}/access")
  end

  private

  def lists_store
    Lists::Store
  end

  def people_store
    Lists::PeopleStore
  end
end
