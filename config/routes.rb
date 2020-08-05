Rails.application.routes.draw do
  root to: "home#index"

  resources :foos

  match "users/edit_profile" => "users#edit_profile", :via => [:get], :as => :edit_profile
  match "users/update_profile" => "users#update_profile", :via => [:put], :as => :update_profile
  match "users/edit_mail" => "users#edit_mail", :via => [:get], :as => :edit_mail
  match "users/append_mail" => "users#append_mail", :via => [:post], :as => :append_mail
  match "users/delete_mail/:id" => "users#delete_mail", :via => [:delete], :as => :user_mail_address
  match "users/send_mail/:id" => "users#send_mail", :via => [:post], :as => :send_mail
  match "users/auth_mail/:id" => "users#auth_mail", :via => [:get], :as => :auth_mail
  post "users/notice_mail/:id" => "users#notice_mail", as: :notice_mail

  resources :users, except: [:index] do
    member do
      get :activate
    end
  end
  resources :sessions, only: [:new, :create]

  get 'signup'  => 'users#new',        as: 'signup'
  get 'login'   => 'sessions#new',     as: 'login'
  get 'logout'  => 'sessions#destroy', as: 'logout'
  post 'login'   => 'sessions#create'
  post 'logout'  => 'sessions#destroy'

  get 'nests/invite/:id' => 'nests#invite', as: :invite_nest
  post 'nests/invite/:id' => 'nests#invite_update'
  delete 'nests/invite/:id' => 'nests#invite_destroy'
  post 'nests/invite/:id/send' => 'nests#invite_send', as: :invite_nest_send

  get "nests/join/:id" => "nests#join", as: :nest_join
  post "nests/do_join/:id" => "nests#do_join", as: :nest_do_join

  get "nests/resign/:id" => "nests#resign", as: :nests_resign
  get "nests/join/:id" => "nests#join", as: :nests_join
  post "nests/do_resign/:id" => "nests#do_resign"
  get "nests/member_control/:id" => "nests#member_control", as: :nest_member_control
  delete "nests/ban/:id" => "nests#ban", as: :nest_ban
  post "nests/member_board" => "nests#member_board"

  resources :nests

  post "nest_tops/:id" => "nest_tops#update"
  resources :nest_tops

  get "invites/join/:id" => "invites#join", as: :invite_join

  post "invites/leave/:id" => "invites#leave", as: :invite_leave
  get "invites/abuse/:id" => "invites#abuse", as: :invite_abuse
  post "invites/report_abuse/:id" => "invites#report_abuse"
  post "invites/append/:id" => "invites#append", as: :invite_append
  resources :invites

  post "spaces/release/:id" => "spaces#release", as: :space_release
  post "spaces/unrelease/:id" => "spaces#unrelease", as: :space_unrelease
  get  "spaces/assign_admin/:id" => "spaces#assign_admin", as: :assign_admin
  post "spaces/assign_admin" => "spaces#assign_admin_op"
  resources :spaces

  post "entries/release/:id" => "entries#release", as: :entry_release
  post "entries/unrelease/:id" => "entries#unrelease", as: :entry_unrelease
  resources :entries
  resources :comments

  match 'attach_files/create' => "attach_files#create", via:[:post]
  match 'attach_files/upload' => "attach_files#upload", via:[:post]
  match 'attach_files/profile_upload' => "attach_files#profile_upload", via:[:post]
  match 'attach_files/destroy' => "attach_files#destroy", via:[:post]
  match 'attach_files/icon/:id' => "attach_files#icon", via: [:get]
  match 'attach_files/download/:id' => "attach_files#download", via: [:get]
  resources :attach_files

  match 'notices/watch/:id' => "notices#watch", via:[:post, :get], as: :notice_watch
  resources :notices

  get 'home' => "home#index"
  get 'home/watches' => "home#watches", as: :home_watches
  post 'home/update_watch/:id' => "home#update_watch"

  match 'err_404' => 'application#render_404', :via => [:get], :as => :err_404


  match 'forbidden' => "application#forbidden", :via => [:get], :as => :forbidden
  match 'internal_server_error' => "application#internal_server_error", :via => [:get], :as => :internal_server_error

  get 'top' => "top#index", :as => :top

  match 'about' => "top#about", :via => :get, :as => :about
  match 'guidance' => "top#guidance", :via => :get, :as => :guidance
  match 'term' => "top#term", :via => :get, :as => :term
  match 'privacy' => "top#privacy", :via => :get, :as => :privacy
  match 'help' => "help#index", :via => :get, :as => :help
  match 'help/glossary' => "help#glossary", :via => :get, :as => :glossary
  match 'help/what_is' => "help#what_is", :via => :get, :as => :what_is
  match 'help/create_channel' => "help#create_channel", :via => :get, :as => :create_channel
  match 'help/create_stream' => "help#create_stream", :via => :get, :as => :create_stream
  match 'help/write_log' => "help#write_log", :via => :get, :as => :write_log
  match 'help/api' => "help#api", :via => :get, :as => :api
  match 'help/find_channel' => "help#find_channel", :via => :get, :as => :find_channel
  match 'help/follow_channel' => "help#follow", :via => :get, :as => :follow_channel
  match 'help/forget_password' => "help#forget_password", :via => :get, :as => :forget_password
  match 'help/confirm_mail' => "help#confirm_mail", :via => :get, :as => :confirm_mail
  match 'help/login_trouble' => "help#login_trouble", :via => :get, :as => :login_trouble
  match 'help/sign_up' => "help#sign_up", :via => :get, :as => :sign_up

  match 'icons/create' => "icons#create", via:[:post]
  match 'icons/profile_upload' => "icons#profile_upload", via:[:post]
  match 'icons/channel_icon_upload/:id' => "icons#channel_icon_upload", via:[:post]
  match 'icons/download' => "icons#download", via: [:get]
  match 'icons/edit_icon' => "icons#edit_icon", via: [:get]
  match 'icons/edit_icon_info' => "icons#edit_icon_info", via: [:get]
  get 'icons/get_icon' => "icons#get_icon"
  resources :icons

end
