require 'volt/router/routes'
require 'volt/models'

def routes(&block)
  @routes = Routes.new
  @routes.define(&block)
end

describe Routes do
  it "should setup direct routes" do
    routes do
      get '/', _view: 'index'
      get '/page1', _view: 'first_page'
    end

    direct_routes = @routes.instance_variable_get(:@direct_routes)
    expect(direct_routes).to eq({"/" => {:_view => "index"}, "/page1" => {:_view => "first_page"}})
  end

  it "should setup indiect routes" do
    routes do
      get '/blog/{_id}/edit', _view: 'blog/edit'
      get '/blog/{_id}', _view: 'blog/show'
    end

    indirect_routes = @routes.instance_variable_get(:@indirect_routes)
    expect(indirect_routes).to eq(
      {
        "blog" => {
          "*" => {
            "edit" => {
              nil => {:_view => "blog/edit", :_id => 1}
            },
            nil => {:_view => "blog/show", :_id => 1}
          }
        }
      }
    )
  end

  it "should match routes" do
    routes do
      get "/blog", _view: 'blog'
      get '/blog/{_id}', _view: 'blog/show'
      get '/blog/{_id}/edit', _view: 'blog/edit'
      get '/blog/tags/{_tag}', _view: 'blog/tag'
      get '/login/{_name}/user/{_id}', _view: 'login', _action: 'user'
    end

    params = @routes.url_to_params('/blog')
    expect(params).to eq({:_view => "blog"})

    params = @routes.url_to_params('/blog/55/edit')
    expect(params).to eq({:_view => "blog/edit", :_id => "55"})

    params = @routes.url_to_params('/blog/55')
    expect(params).to eq({:_view => "blog/show", :_id => "55"})

    params = @routes.url_to_params('/blog/tags/good')
    expect(params).to eq({:_view => "blog/tag", :_tag => "good"})

    params = @routes.url_to_params('/login/jim/user/10')
    expect(params).to eq({:_view => "login", :_action => "user", :_name => "jim", :_id => "10"})

    params = @routes.url_to_params('/login/cool')
    expect(params).to eq(false)

  end

  # it "should match routes" do
  #   params = Model.new({}, persistor: Persistors::Params)
  #   params._controller = 'blog'
  #   params._index = '5'
  #
  #   routes do
  #     get '/', _controller: 'index'
  #     get '/blog', _controller: 'blog'
  #   end
  #
  #   path, cleaned_params = @routes.params_to_url(params)
  #   expect(path).to eq('/blog')
  #   expect(cleaned_params).to eq({_index: '5'})
  # end
  #
  # it "should handle routes with bindings in them" do
  #   params = Model.new({}, persistor: Persistors::Params)
  #
  #   routes do
  #     get '/', _controller: 'index'
  #     get '/blog/{_id}', _controller: 'blog'
  #   end
  #
  #   params = @routes.url_to_params('/blog/20')
  #   puts params.inspect
  #
  # end
end
