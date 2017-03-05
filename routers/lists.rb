class ListsRouter < BaseRouter
  get "/lists" do
    redirect to("/users/registration") if Users.guest?(users_config)
    @user = Users.get_current_user(users_config)
    @lists = Lists.lists_of_user(@user.id, lists_store)
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

  get "/lists/:list_id/access_control" do
    @details = Lists.current_access_details(params[:list_id], lists_store)
    erb :"lists/access_control"
  end

  private

  def lists_store
    Lists::Store
  end
end
