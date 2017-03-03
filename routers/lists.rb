class ListsRouter < BaseRouter
  get "/lists" do
    redirect to("/users/registration") if Users.guest?(users_config)
    @user = users_config.fetch(:store).find(session_store.user_id)
    @lists = Lists.lists_of_user(Lists::Store, session_store)
    erb :"lists/index"
  end

  get "/lists/new" do
    redirect to("/") if Users.guest?(users_config)
    @form = Lists.new_list_form
    erb :"lists/new"
  end

  post "/lists" do
    redirect to("/") if Users.guest?(users_config)
    response = Lists.create_list(params, Lists::Store, session_store, Lists::IdGenerator)

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
end
