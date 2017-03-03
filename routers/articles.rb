class ArticlesRouter < BaseRouter
  get "/articles/registration" do
    @form = Leads.register_form
    erb :"articles/registration"
  end

  post '/articles/registration' do
    response = Leads.register_lead(params, Leads::Store)

    if response.success?
      redirect to("/articles/registration_success")
    else
      @form = response.form
      erb :"articles/registration"
    end
  end

  get "/articles/registration_success" do
    erb :"articles/registration_success"
  end

  get "/articles/preguntas-para-reducir-su-lista-de-invitados" do
    @page_title = "Preguntas para reducir su lista de invitados"
    @meta_description = "Una pequeña guía de preguntas para ayudarlos a reducir su lista de invitados"
    erb :"articles/article-1", layout: :home_layout
  end
end
